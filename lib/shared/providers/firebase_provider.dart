import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/firebase/firebase_service.dart';

/// Provider for Firebase service
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});


