import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpaisa/core/constants/app_constants.dart';
import 'dart:io';

/// Service for managing Firebase operations
class FirebaseService {
  final FirebaseFirestore _firestore;

  FirebaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Submit a language request from user
  Future<void> submitLanguageRequest(String languageCode, String languageName) async {
    try {
      await _firestore.collection(AppConstants.languageRequestsCollection).add({
        'language_code': languageCode,
        'language_name': languageName,
        'platform': Platform.operatingSystem,
        'app_version': '1.0.0',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail if Firebase is not configured
      // This ensures app works without Firebase
      return;
    }
  }

  /// Get language request count (for admin purposes)
  Future<Map<String, int>> getLanguageRequestCounts() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.languageRequestsCollection)
          .get();

      final Map<String, int> counts = {};
      for (final doc in snapshot.docs) {
        final languageCode = doc.data()['language_code'] as String?;
        if (languageCode != null) {
          counts[languageCode] = (counts[languageCode] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      return {};
    }
  }

  /// Check if Firebase is initialized and available
  static bool get isAvailable {
    try {
      FirebaseFirestore.instance;
      return true;
    } catch (e) {
      return false;
    }
  }
}


