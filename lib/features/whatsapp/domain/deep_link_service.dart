import 'dart:convert';
import 'dart:math';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';

class DeepLinkService {
  static const String _scheme = 'flowpaisa';
  static const String _host = 'share';

  /// Generate a unique external link ID
  /// Format: "tx_8f7a3b" (tx_ prefix + 6 random hex chars)
  String generateExternalLinkId() {
    final random = Random();
    final chars = List.generate(
      6,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return 'tx_$chars';
  }

  /// Generate a deep link for a transaction
  String generateTransactionLink(TransactionShareData data) {
    final jsonData = data.toJson();
    final jsonString = json.encode(jsonData);
    final base64Data = base64Url.encode(utf8.encode(jsonString));
    return '$_scheme://$_host?type=transaction&data=$base64Data';
  }

  /// Generate a deep link for a receivable
  String generateReceivableLink(ReceivableShareData data) {
    final jsonData = data.toJson();
    final jsonString = json.encode(jsonData);
    final base64Data = base64Url.encode(utf8.encode(jsonString));
    return '$_scheme://$_host?type=receivable&data=$base64Data';
  }

  /// Generate a deep link for a payable
  String generatePayableLink(PayableShareData data) {
    final jsonData = data.toJson();
    final jsonString = json.encode(jsonData);
    final base64Data = base64Url.encode(utf8.encode(jsonString));
    return '$_scheme://$_host?type=payable&data=$base64Data';
  }

  /// Decode a deep link and return the shared data
  /// Returns null if the link is invalid
  SharedData? decodeLink(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      
      // Validate scheme and host
      if (uri.scheme != _scheme || uri.host != _host) {
        return null;
      }

      // Get the type and data parameters
      final type = uri.queryParameters['type'];
      final base64Data = uri.queryParameters['data'];

      if (type == null || base64Data == null) {
        return null;
      }

      // Decode base64
      final jsonString = utf8.decode(base64Url.decode(base64Data));
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Ensure the type matches
      if (jsonData['type'] != type) {
        return null;
      }

      // Parse based on type
      return SharedData.fromJson(jsonData);
    } catch (e) {
      // Invalid link format
      return null;
    }
  }

  /// Validate if a URI string is a valid FlowPaisa deep link
  bool isValidDeepLink(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      return uri.scheme == _scheme && uri.host == _host;
    } catch (e) {
      return false;
    }
  }
}
