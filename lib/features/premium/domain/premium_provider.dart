import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  PremiumState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
    this.products = const [],
    this.expiryDate,
    this.subscriptionType,
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    List<ProductDetails>? products,
    DateTime? expiryDate,
    String? subscriptionType,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      expiryDate: expiryDate ?? this.expiryDate,
      subscriptionType: subscriptionType ?? this.subscriptionType,
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
    return PremiumState(
      isPremium: _repository.getPremiumStatus(),
      expiryDate: _repository.getExpiryDate(),
      subscriptionType: _repository.getSubscriptionType(),
    );
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
      final product = state.products.where((p) => p.id == productId).firstOrNull ?? 
                     (state.products.isNotEmpty ? state.products.first : null);
      
      // Ensure the product is valid before attempting purchase
      if (product == null || product.id != productId) {
        state = state.copyWith(isLoading: false, error: 'Product not found: $productId');
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
      await _repository.restorePurchases();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        state = state.copyWith(isLoading: true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          state = state.copyWith(isLoading: false, error: purchaseDetails.error?.message ?? 'Purchase failed');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          final bool valid = await _repository.verifyPurchase(purchaseDetails);
          if (valid) {
            String? type;
            DateTime? expiry;

            if (purchaseDetails.productID == PremiumRepository.premiumMonthlyId) {
              type = 'monthly';
              expiry = DateTime.now().add(const Duration(days: 30));
            } else if (purchaseDetails.productID == PremiumRepository.premiumYearlyId) {
              type = 'yearly';
              expiry = DateTime.now().add(const Duration(days: 365));
            } else if (purchaseDetails.productID == PremiumRepository.premiumLifetimeId) {
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
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, PremiumState>(() {
  return PremiumNotifier();
});
