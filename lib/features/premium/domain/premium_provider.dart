import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/data/premium_repository.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

// Repository Provider
final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PremiumRepository(prefs);
});

// Premium State
class PremiumState {
  final bool isPremium;
  final bool isLoading;
  final String? error;
  final List<ProductDetails> products;
  final DateTime? expiryDate;
  final String? subscriptionType; // 'monthly', 'yearly', 'lifetime', null
  final String? premiumToken;
  final DateTime? premiumTokenExpiry;

  PremiumState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
    this.products = const [],
    this.expiryDate,
    this.subscriptionType,
    this.premiumToken,
    this.premiumTokenExpiry,
  });

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (subscriptionType == 'lifetime') return true;
    if (expiryDate != null) {
      return expiryDate!.isAfter(DateTime.now());
    }
    return true;
  }

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    List<ProductDetails>? products,
    DateTime? expiryDate,
    String? subscriptionType,
    String? premiumToken,
    DateTime? premiumTokenExpiry,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      expiryDate: expiryDate ?? this.expiryDate,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      premiumToken: premiumToken ?? this.premiumToken,
      premiumTokenExpiry: premiumTokenExpiry ?? this.premiumTokenExpiry,
    );
  }
}

// Premium Notifier
class PremiumNotifier extends Notifier<PremiumState> {
  late PremiumRepository _repository;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  PremiumState build() {
    _repository = ref.watch(premiumRepositoryProvider);
    _init();

    final isPremiumStored = _repository.getPremiumStatus();
    final expiryDate = _repository.getExpiryDate();
    final subscriptionType = _repository.getSubscriptionType();

    bool isPremiumActive = isPremiumStored;
    if (isPremiumStored) {
      if (subscriptionType != 'lifetime' && expiryDate != null) {
        if (expiryDate.isBefore(DateTime.now())) {
          isPremiumActive = false;
          _handleExpiredPremium();
        }
      }
    }

    return PremiumState(
      isPremium: isPremiumActive,
      expiryDate: expiryDate,
      subscriptionType: subscriptionType,
      premiumToken: _repository.getPremiumToken(),
      premiumTokenExpiry: _repository.getPremiumTokenExpiry(),
    );
  }

  Future<void> _handleExpiredPremium() async {
    await _repository.setPremiumStatus(false);
    await _repository.setSubscriptionType(null);
    await _repository.setExpiryDate(null);
    await _repository.setPremiumToken(null, null);
  }

  Future<void> _init() async {
    await _repository.init();

    // Listen to purchase updates
    _subscription = _repository.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );

    // Load products
    await loadProducts();

    // Check if premium token needs generation
    await checkAndGenerateToken();

    // Check if user is already premium locally (done in build), maybe verify with store?
    // Restoring purchases is usually explicit user action or on first install logic.
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.getProducts();
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> buyPremium(String productId) async {
    if (state.products.isEmpty) {
      state = state.copyWith(error: 'No products available');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Find the specific product using a more robust method for release mode
      final product =
          state.products.where((p) => p.id == productId).firstOrNull ??
              (state.products.isNotEmpty ? state.products.first : null);

      // Ensure the product is valid before attempting purchase
      if (product == null || product.id != productId) {
        state = state.copyWith(
            isLoading: false, error: 'Product not found: $productId');
        return;
      }

      await _repository.buyPremium(product);
      // State update happens in _onPurchaseUpdate
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (Platform.isWindows) {
        final verified = await verifyPremiumFromGoogleDrive();
        state = state.copyWith(isLoading: false);
        if (!verified) {
          state = state.copyWith(
              error:
                  'No premium verification found on Google Drive. Please sign in with the Google account used to purchase premium on mobile.');
        }
      } else {
        await _repository.restorePurchases();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    // If we were loading and get an empty list back, it means no purchases were found
    if (purchaseDetailsList.isEmpty && state.isLoading) {
      state = state.copyWith(isLoading: false, error: 'No purchases found');
      return;
    }

    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        state = state.copyWith(isLoading: true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.canceled) {
          state = state.copyWith(isLoading: false);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          state = state.copyWith(
              isLoading: false,
              error: purchaseDetails.error?.message ?? 'Purchase failed');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _repository.verifyPurchase(purchaseDetails);
          if (valid) {
            String? type;
            DateTime? expiry;

            if (purchaseDetails.productID ==
                PremiumRepository.premiumMonthlyId) {
              type = 'monthly';
              expiry = DateTime.now().add(const Duration(days: 30));
            } else if (purchaseDetails.productID ==
                PremiumRepository.premiumYearlyId) {
              type = 'yearly';
              expiry = DateTime.now().add(const Duration(days: 365));
            } else if (purchaseDetails.productID ==
                PremiumRepository.premiumLifetimeId) {
              type = 'lifetime';
              expiry = null;
            }

            await _repository.setPremiumStatus(true);
            await _repository.setSubscriptionType(type);
            await _repository.setExpiryDate(expiry);

            state = state.copyWith(
              isLoading: false,
              isPremium: true,
              subscriptionType: type,
              expiryDate: expiry,
            );
            await checkAndGenerateToken();
          } else {
            state = state.copyWith(isLoading: false, error: 'Invalid purchase');
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _repository.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Dev only: Toggle premium status
  Future<void> togglePremium() async {
    final newStatus = !state.isPremium;
    await _repository.setPremiumStatus(newStatus);
    state = state.copyWith(isPremium: newStatus);
  }

  /// Dev only: Reset premium status
  Future<void> debugResetPremium() async {
    await _repository.setPremiumStatus(false);
    state = state.copyWith(isPremium: false);
  }

  /// Dev only: Force unlock premium
  Future<void> debugUnlockPremium() async {
    await _repository.setPremiumStatus(true);
    state = state.copyWith(isPremium: true);
    await checkAndGenerateToken();
  }

  /// Verify premium status from Google Drive (for cross-platform support)
  Future<bool> verifyPremiumFromGoogleDrive() async {
    final driveService = ref.read(googleDriveServiceProvider);
    if (!driveService.isSignedIn) return false;

    try {
      if (kDebugMode) {
        print('PremiumNotifier: Checking Google Drive for premium verification...');
      }
      final syncFolderId = await driveService.getOrCreateCashbookFolder('');
      
      // Find premium_verification.json in the Sync Data folder
      final query = "name = 'premium_verification.json' and '$syncFolderId' in parents and trashed = false";
      final files = await driveService.listFilesWithQuery(query);
      
      if (files.isEmpty) {
        if (kDebugMode) {
          print('PremiumNotifier: No premium verification file found on Google Drive');
        }
        return false;
      }
      
      final fileId = files.first.id!;
      final result = await driveService.downloadFileWithETag(fileId);
      final tokenData = json.decode(result.content) as Map<String, dynamic>;
      
      final payload = tokenData['payload'] as Map<String, dynamic>;
      final signature = tokenData['signature'] as String;
      
      final payloadString = json.encode(payload);
      const secret = 'flowpaisa_premium_secret_2026';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final expectedSignature = hmac.convert(utf8.encode(payloadString)).toString();
      
      if (signature != expectedSignature) {
        if (kDebugMode) {
          print('PremiumNotifier: Premium token signature mismatch');
        }
        return false;
      }
      
      final expiryStr = payload['expiry'] as String;
      final expiry = DateTime.parse(expiryStr);
      if (expiry.isBefore(DateTime.now())) {
        if (kDebugMode) {
          print('PremiumNotifier: Premium token has expired: $expiry');
        }
        return false;
      }
      
      // Token is valid! Mark local user as premium
      await _repository.setPremiumStatus(true);
      await _repository.setSubscriptionType('cross_platform');
      await _repository.setExpiryDate(expiry);
      
      // Also save the token locally
      final token = base64Url.encode(utf8.encode(json.encode(tokenData)));
      await _repository.setPremiumToken(token, expiry);
      
      state = state.copyWith(
        isPremium: true,
        subscriptionType: 'cross_platform',
        expiryDate: expiry,
        premiumToken: token,
        premiumTokenExpiry: expiry,
      );
      
      if (kDebugMode) {
        print('PremiumNotifier: Successfully verified premium status from Google Drive expiring at $expiry');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('PremiumNotifier: Failed to verify premium from Google Drive: $e');
      }
      return false;
    }
  }

  /// Token generation logic
  Future<void> checkAndGenerateToken() async {
    if (!state.isPremium) {
      if (state.premiumToken != null) {
        await _repository.setPremiumToken(null, null);
        state = state.copyWith(premiumToken: null, premiumTokenExpiry: null);
      }
      return;
    }

    // Don't auto-regenerate if not signed in to Google Drive
    final driveService = ref.read(googleDriveServiceProvider);
    if (!driveService.isSignedIn) return;

    final now = DateTime.now();
    final currentToken = state.premiumToken;
    final currentExpiry = state.premiumTokenExpiry;

    bool needsGeneration = false;
    if (currentToken == null || currentExpiry == null) {
      needsGeneration = true;
    } else {
      final difference = currentExpiry.difference(now);
      if (difference.inDays < 2) {
        needsGeneration = true;
      }
    }

    if (needsGeneration) {
      await generatePremiumToken();
    }
  }

  Future<void> generatePremiumToken() async {
    final driveService = ref.read(googleDriveServiceProvider);
    if (!driveService.isSignedIn) {
      if (kDebugMode) {
        print(
            'PremiumNotifier: Skipping token generation because user is not signed in to Google Drive');
      }
      return;
    }

    try {
      final deviceId = await _getDeviceId();
      final expiry = DateTime.now().add(const Duration(days: 15));
      final issuedAt = DateTime.now();

      final payload = {
        'deviceId': deviceId,
        'expiry': expiry.toIso8601String(),
        'issuedAt': issuedAt.toIso8601String(),
        'version': 1,
      };

      final payloadString = json.encode(payload);

      // Simple signing (HMAC-SHA256)
      const secret = 'flowpaisa_premium_secret_2026';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final signature = hmac.convert(utf8.encode(payloadString));

      final tokenData = {
        'payload': payload,
        'signature': signature.toString(),
      };

      final token = base64Url.encode(utf8.encode(json.encode(tokenData)));

      // 1. Try to upload to Google Drive first for cross-platform verification
      try {
        final rootFolderId =
            await driveService.getOrCreateCashbookFolder(''); // Root appDataFolder
        await driveService.uploadFile(
          name: 'premium_verification.json',
          content: json.encode(tokenData),
          parentId: rootFolderId,
        );

        // 2. Save locally ONLY if upload was successful (to keep them in sync)
        await _repository.setPremiumToken(token, expiry);
        state = state.copyWith(
          premiumToken: token,
          premiumTokenExpiry: expiry,
        );

        if (kDebugMode) {
          print(
              'PremiumNotifier: Generated, uploaded and saved premium token expiring at $expiry');
        }
      } catch (driveError) {
        if (kDebugMode) {
          print(
              'PremiumNotifier: Failed to upload to Google Drive, skipping local save: $driveError');
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print('PremiumNotifier: Failed to generate premium token: $e');
      }
      rethrow;
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.deviceId;
    }
    return 'unknown_device';
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, PremiumState>(() {
  return PremiumNotifier();
});
