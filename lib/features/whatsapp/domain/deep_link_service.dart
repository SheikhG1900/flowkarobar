import 'dart:convert';
import 'package:flowpaisa/core/constants/app_constants.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:uuid/uuid.dart';

/// Result of parsing an entity open link (flowpaisa://open/transaction/uuid etc).
class OpenLinkResult {
  final String entityType; // 'transaction', 'category', 'contact', 'payable', 'receivable'
  final String uuid;

  const OpenLinkResult({required this.entityType, required this.uuid});
}

class DeepLinkService {
  static const String _scheme = AppConstants.deepLinkScheme;
  static const String _host = 'share';
  static const String _openHost = 'open';
  static const String _webBaseUrl =
      'https://tamatasoft.github.io/flowpaisa/share';

  /// Shorten a UUID by removing dashes and taking a stable prefix
  static String shortenUuid(String uuid) {
    // Remove dashes and take the first 12 characters for a stable, unique prefix
    return uuid.replaceAll('-', '').substring(0, 12);
  }

  /// Generate a new minified UUID (12-char, no dashes) for use as primary IDs
  static String newMinifiedUuid() {
    return shortenUuid(const Uuid().v4());
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
    String? status,
  }) {
    // Mapping logic based on user requirements:
    // "will receive" (WILL_RECEIVE) -> Create payable link
    // "I owe" (RECEIVED_FROM) -> Create receivable link
    // "paid by" (PAID_BY) -> Create paid for (PAID_FOR) transaction link
    // "paid for" (PAID_FOR) -> Create paid by (PAID_BY) transaction link

    // For status: if sender marks PAID, it remains PAID for the link.
    // Recipient will see "Sender marked this as PAID".

    if (relationship == 'WILL_RECEIVE') {
      return generatePayableLink(PayableShareData(
        amount: amount,
        date: date,
        description: description,
        dueDate: dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: externalLinkId,
        status: status,
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
        status: status,
      ));
    } else {
      // It's a regular transaction (Income/Expense) or PAID_BY/PAID_FOR
      String recipientRelationship = relationship ?? '';
      String recipientTransactionType = 'EXPENSE';

      if (relationship == 'PAID_BY') {
        recipientRelationship = 'PAID_FOR';
        recipientTransactionType = 'EXPENSE';
      } else if (relationship == 'PAID_FOR') {
        recipientRelationship = 'PAID_BY';
        recipientTransactionType = 'EXPENSE';
      }

      return generateTransactionLink(TransactionShareData(
        amount: amount,
        transactionType: recipientTransactionType,
        description: description,
        date: date,
        dueDate: dueDate,
        categoryName: categoryName,
        categoryColor: categoryColor,
        categoryIcon: categoryIcon,
        relationship: recipientRelationship,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: externalLinkId,
        status: status,
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
      String jsonString;
      try {
        jsonString = utf8.decode(base64Url.decode(base64Data));
      } catch (_) {
        jsonString = utf8.decode(base64.decode(base64Data));
      }
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Ensure the type matches
      if (jsonData['t'] != type && jsonData['type'] != type) {
        return null;
      }

      // Parse based on type
      return SharedData.fromJson(jsonData);
    } catch (e) {
      // Invalid link format
      return null;
    }
  }

  /// Generate entity open link (for copy link on detail screens).
  /// Format: flowpaisa://open/<entityType>/<uuid>
  String generateEntityOpenLink(String entityType, String uuid) {
    return '$_scheme://$_openHost/$entityType/$uuid';
  }

  /// Parse open link. Returns null if not an open link or invalid.
  OpenLinkResult? parseOpenLink(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      if (uri.scheme != _scheme || uri.host != _openHost) return null;
      final path = uri.path;
      if (path.isEmpty || path == '/') return null;
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length != 2) return null;
      final entityType = segments[0];
      final uuid = segments[1];
      if (uuid.isEmpty) return null;
      const allowed = ['transaction', 'category', 'contact', 'payable', 'receivable'];
      if (!allowed.contains(entityType)) return null;
      return OpenLinkResult(entityType: entityType, uuid: uuid);
    } catch (_) {
      return null;
    }
  }

  /// Validate if a URI string is a valid Flowpaisa deep link
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
