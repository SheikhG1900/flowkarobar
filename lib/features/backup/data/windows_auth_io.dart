import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_drive_service.dart';

class WindowsAuthHelper {
  static const _winAccessTokenKey = 'windows_google_access_token';
  static const _winRefreshTokenKey = 'windows_google_refresh_token';
  static const _winExpiryKey = 'windows_google_token_expiry';
  static const _winUserEmailKey = 'windows_google_user_email';
  static const _winUserDisplayNameKey = 'windows_google_user_display_name';
  static const _winUserIdKey = 'windows_google_user_id';
  static const _winUserPhotoUrlKey = 'windows_google_user_photo_url';

  static drive.DriveApi? _driveApi;

  static drive.DriveApi? getDriveApiWindows() {
    return _driveApi;
  }

  static Future<GoogleSignInAccount?> signInWindows(String clientId, String? clientSecret, List<String> scopes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientIdObj = ClientId(clientId, clientSecret);

      final baseClient = http.Client();
      
      // Determine port based on client ID type
      // Web client IDs require a fixed port registered in Google Console (e.g., 5000)
      // Desktop client IDs can use a dynamic port (0)
      final useFixedPort = clientId.contains('evggbo9420c29ipo3q9qn5nusbq2v9ge');
      final listenPort = useFixedPort ? 5000 : 0;

      final credentials = await obtainAccessCredentialsViaUserConsent(
        clientIdObj,
        scopes,
        baseClient,
        (url) async {
          // Append offline access and consent prompt to ensure we get a refresh token
          final modifiedUrl = '$url&access_type=offline&prompt=consent';
          await launchUrl(Uri.parse(modifiedUrl), mode: LaunchMode.externalApplication);
        },
        listenPort: listenPort,
      );

      final authClient = authenticatedClient(baseClient, credentials);
      _driveApi = drive.DriveApi(authClient);

      // Fetch user profile info
      final response = await authClient.get(Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'));
      if (response.statusCode == 200) {
        final userInfo = jsonDecode(response.body);
        final email = userInfo['email'] ?? '';
        final displayName = userInfo['name'];
        final id = userInfo['id'] ?? '';
        final photoUrl = userInfo['picture'];

        final currentUser = WindowsGoogleSignInAccount(
          email: email,
          displayName: displayName,
          id: id,
          photoUrl: photoUrl,
        );

        // Save to SharedPreferences
        await prefs.setString(_winUserEmailKey, email);
        await prefs.setString(_winUserIdKey, id);
        if (displayName != null) await prefs.setString(_winUserDisplayNameKey, displayName);
        if (photoUrl != null) await prefs.setString(_winUserPhotoUrlKey, photoUrl);
        await prefs.setString(_winAccessTokenKey, credentials.accessToken.data);
        if (credentials.refreshToken != null) {
          await prefs.setString(_winRefreshTokenKey, credentials.refreshToken!);
        }
        await prefs.setString(_winExpiryKey, credentials.accessToken.expiry.toIso8601String());

        return currentUser;
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('WindowsAuthHelper: Sign-in failed: $e');
      }
      _driveApi = null;
      return null;
    }
  }

  static Future<GoogleSignInAccount?> silentSignInWindows(String clientId, String? clientSecret, List<String> scopes, {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_winUserEmailKey);
      final id = prefs.getString(_winUserIdKey);
      final accessToken = prefs.getString(_winAccessTokenKey);
      final refreshToken = prefs.getString(_winRefreshTokenKey);
      final expiryStr = prefs.getString(_winExpiryKey);

      if (email != null && id != null && accessToken != null && expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        final displayName = prefs.getString(_winUserDisplayNameKey);
        final photoUrl = prefs.getString(_winUserPhotoUrlKey);

        final currentUser = WindowsGoogleSignInAccount(
          email: email,
          displayName: displayName,
          id: id,
          photoUrl: photoUrl,
        );

        // Reconstruct credentials
        var credentials = AccessCredentials(
          AccessToken('Bearer', accessToken, expiry),
          refreshToken,
          scopes,
        );

        final baseClient = http.Client();
        
        // If expired (or expiring in less than 5 minutes), or forceRefresh is requested, refresh it
        if (forceRefresh || 
            credentials.accessToken.expiry.isBefore(DateTime.now()) || 
            credentials.accessToken.expiry.difference(DateTime.now()).inMinutes < 5) {
          if (refreshToken != null) {
            final clientIdObj = ClientId(clientId, clientSecret);
            credentials = await refreshCredentials(clientIdObj, credentials, baseClient);
            // Save refreshed credentials
            await prefs.setString(_winAccessTokenKey, credentials.accessToken.data);
            await prefs.setString(_winExpiryKey, credentials.accessToken.expiry.toIso8601String());
          } else {
            throw Exception('No refresh token available and access token is expired');
          }
        }

        final authClient = authenticatedClient(baseClient, credentials);
        _driveApi = drive.DriveApi(authClient);
        
        return currentUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('WindowsAuthHelper: Silent sign-in failed: $e');
      }
      _driveApi = null;
    }
    return null;
  }

  static Future<void> signOutWindows() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_winUserEmailKey);
    await prefs.remove(_winUserIdKey);
    await prefs.remove(_winUserDisplayNameKey);
    await prefs.remove(_winUserPhotoUrlKey);
    await prefs.remove(_winAccessTokenKey);
    await prefs.remove(_winRefreshTokenKey);
    await prefs.remove(_winExpiryKey);
    _driveApi = null;
  }
}
