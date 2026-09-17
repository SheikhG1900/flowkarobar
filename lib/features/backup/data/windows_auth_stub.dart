import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class WindowsAuthHelper {
  static Future<GoogleSignInAccount?> signInWindows(String clientId, String? clientSecret, List<String> scopes) async {
    return null;
  }

  static Future<GoogleSignInAccount?> silentSignInWindows(String clientId, String? clientSecret, List<String> scopes, {bool forceRefresh = false}) async {
    return null;
  }

  static Future<void> signOutWindows() async {}

  static drive.DriveApi? getDriveApiWindows() {
    return null;
  }
}
