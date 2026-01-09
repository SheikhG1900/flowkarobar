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

  PremiumState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
    this.products = const [],
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    List<ProductDetails>? products,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable, so if not passed, it remains null (or we can clear it)
      products: products ?? this.products,
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
    return PremiumState(isPremium: _repository.getPremiumStatus());
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

  Future<void> buyPremium() async {
    if (state.products.isEmpty) {
      state = state.copyWith(error: 'No products available');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Find the premium product
      final product = state.products.firstWhere(
        (p) => p.id == PremiumRepository.premiumProductId,
        orElse: () => state.products.first, // Fallback to first available
      );
      
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
            await _repository.setPremiumStatus(true);
            state = state.copyWith(isLoading: false, isPremium: true);
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
