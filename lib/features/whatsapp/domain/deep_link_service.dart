import 'dart:convert';
import 'dart:math';
import 'package:flowpaisa/core/constants/app_constants.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';

class DeepLinkService {
  static const String _scheme = AppConstants.deepLinkScheme;
  static const String _host = 'share';
  static const String _webBaseUrl =
      'https://tamatasoft.github.io/flowpaisa/share';

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

  /// Helper to create the link with both scheme and https fallback
  String _buildLink(String type, String base64Data) {
    // We prioritize https link because it's clickable in most apps like WhatsApp
    return '$_webBaseUrl?type=$type&data=$base64Data';
  }

  /// Generate a deep link for a transaction
  String generateTransactionLink(TransactionShareData data) {
    final jsonData = data.toJson();
    final jsonString = json.encode(jsonData);
    final base64Data = base64Url.encode(utf8.encode(jsonString));
    return _buildLink('transaction', base64Data);
  }

  /// Generate a deep link for a receivable
  String generateReceivableLink(ReceivableShareData data) {
    final jsonData = data.toJson();
    final jsonString = json.encode(jsonData);
    final base64Data = base64Url.encode(utf8.encode(jsonString));
    return _buildLink('receivable', base64Data);
  }

  /// Generate a deep link for a payable
  String generatePayableLink(PayableShareData data) {
    final jsonData = data.toJson();
    final jsonString = json.encode(jsonData);
    final base64Data = base64Url.encode(utf8.encode(jsonString));
    return _buildLink('payable', base64Data);
  }

  /// Generate a reciprocal link based on the sender's transaction relationship
  String generateReciprocalLink({
    required String senderName,
    required String senderPhone,
    required String? relationship,
    required double amount,
    required DateTime date,
    String? description,
    String? categoryName,
    String? categoryColor,
    String? categoryIcon,
    DateTime? dueDate,
    required String externalLinkId,
  }) {
    // Mapping logic based on user requirements:
    // "will receive" (WILL_RECEIVE) -> Create payable link
    // "I owe" (RECEIVED_FROM) -> Create receivable link
    // "paid by" (PAID_BY) -> Create paid for (PAID_FOR) transaction link
    // "paid for" (PAID_FOR) -> Create paid by (PAID_BY) transaction link

    if (relationship == 'WILL_RECEIVE') {
      return generatePayableLink(PayableShareData(
        amount: amount,
        date: date,
        description: description,
        dueDate: dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: externalLinkId,
      ));
    } else if (relationship == 'RECEIVED_FROM') {
      return generateReceivableLink(ReceivableShareData(
        amount: amount,
        date: date,
        description: description,
        dueDate: dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: externalLinkId,
      ));
    } else {
      // It's a regular transaction (Income/Expense) or PAID_BY/PAID_FOR
      String recipientRelationship = relationship ?? '';
      String recipientTransactionType = 'EXPENSE';

      if (relationship == 'PAID_BY') {
        recipientRelationship = 'PAID_FOR';
        recipientTransactionType = 'INCOME';
      } else if (relationship == 'PAID_FOR') {
        recipientRelationship = 'PAID_BY';
        recipientTransactionType = 'EXPENSE';
      }

      return generateTransactionLink(TransactionShareData(
        amount: amount,
        transactionType: recipientTransactionType,
        description: description,
        date: date,
        categoryName: categoryName,
        categoryColor: categoryColor,
        categoryIcon: categoryIcon,
        relationship: recipientRelationship,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: externalLinkId,
      ));
    }
  }

  /// Decode a deep link and return the shared data
  /// Returns null if the link is invalid
  SharedData? decodeLink(String uriString) {
    try {
      final uri = Uri.parse(uriString);

      // Validate scheme and host for both flowpaisa:// and https://tamatasoft.github.io/flowpaisa/share
      final isCustomScheme = uri.scheme == _scheme && uri.host == _host;
      final isHttpsScheme = uri.scheme == 'https' &&
          uri.host == 'tamatasoft.github.io' &&
          uri.path == '/flowpaisa/share';

      if (!isCustomScheme && !isHttpsScheme) {
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
      final isCustomScheme = uri.scheme == _scheme && uri.host == _host;
      final isHttpsScheme = uri.scheme == 'https' &&
          uri.host == 'tamatasoft.github.io' &&
          uri.path == '/flowpaisa/share';
      return isCustomScheme || isHttpsScheme;
    } catch (e) {
      return false;
    }
  }
}
