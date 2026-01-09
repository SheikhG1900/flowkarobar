import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumRepository {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SharedPreferences _prefs;
  
  // Product ID should be configured in Google Play Console
  // Using a realistic ID, but for testing 'android.test.purchased' can be used on Android
  static const String premiumProductId = 'flowpaisa_premium_lifetime';
  static const String _isPremiumKey = 'is_premium_user';

  PremiumRepository(this._prefs);

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  Future<void> init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // final InAppPurchaseAndroidPlatformAddition androidAddition =
      //    _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      // Optional: Enable pending purchases
      // await androidAddition.enablePendingPurchases(); 
    }
  }

  /// Load products from the store
  Future<List<ProductDetails>> getProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      return [];
    }
    
    const Set<String> _kIds = <String>{premiumProductId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product IDs not found: ${response.notFoundIDs}');
    }
    
    if (response.error != null) {
      debugPrint('Error querying products: ${response.error!.message}');
      return [];
    }

    return response.productDetails;
  }

  /// Initiate a purchase
  Future<bool> buyPremium(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    // For non-consumables (lifetime), we use buyNonConsumable
    // If it was a subscription, we would use buyNonConsumable as well usually, 
    // unless there's specific subscription handling needed, but the method is buyNonConsumable for auto-renewing subs too in the plugin usually.
    // However, the distinction is mainly consumable vs non-consumable.
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Verify purchase (client-side simple verification)
  /// In a real production app, verify receipt on backend
  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
    // For now, we trust the store response
    return purchaseDetails.status == PurchaseStatus.purchased || 
           purchaseDetails.status == PurchaseStatus.restored;
  }

  /// Complete the purchase flow
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  /// Save premium status locally
  Future<void> setPremiumStatus(bool isPremium) async {
    await _prefs.setBool(_isPremiumKey, isPremium);
  }

  /// Get local premium status
  bool getPremiumStatus() {
    return _prefs.getBool(_isPremiumKey) ?? false;
  }
}
