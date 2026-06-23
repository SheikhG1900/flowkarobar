import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumRepository {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SharedPreferences _prefs;
  
  // Product IDs configured in Google Play Console
  static const String premiumMonthlyId = 'flowpaisa_premium_monthly';
  static const String premiumYearlyId = 'flowpaisa_premium_yearly';
  static const String premiumLifetimeId = 'flowpaisa_premium_lifetime';

  static const String _isPremiumKey = 'is_premium_user';
  static const String _expiryDateKey = 'premium_expiry_date';
  static const String _subscriptionTypeKey = 'premium_subscription_type';
  static const String _premiumTokenKey = 'premium_verification_token';
  static const String _premiumTokenExpiryKey = 'premium_verification_token_expiry';

  PremiumRepository(this._prefs);

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  Future<void> init() async {
    // No specific initialization needed for modern in_app_purchase
  }

  /// Load products from the store
  Future<List<ProductDetails>> getProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      return [];
    }
    
    const Set<String> _kIds = <String>{
      premiumMonthlyId,
      premiumYearlyId,
      premiumLifetimeId,
    };
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
    
    if (productDetails.id == premiumLifetimeId) {
      // Lifetime is a non-consumable in-app product
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Monthly and Yearly are subscriptions
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Verify purchase (client-side simple verification)
  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
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

  /// Save expiry date
  Future<void> setExpiryDate(DateTime? date) async {
    if (date == null) {
      await _prefs.remove(_expiryDateKey);
    } else {
      await _prefs.setString(_expiryDateKey, date.toIso8601String());
    }
  }

  /// Get expiry date
  DateTime? getExpiryDate() {
    final dateStr = _prefs.getString(_expiryDateKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Save subscription type
  Future<void> setSubscriptionType(String? type) async {
    if (type == null) {
      await _prefs.remove(_subscriptionTypeKey);
    } else {
      await _prefs.setString(_subscriptionTypeKey, type);
    }
  }

  /// Get subscription type
  String? getSubscriptionType() {
    return _prefs.getString(_subscriptionTypeKey);
  }

  /// Save premium verification token
  Future<void> setPremiumToken(String? token, DateTime? expiry) async {
    if (token == null || expiry == null) {
      await _prefs.remove(_premiumTokenKey);
      await _prefs.remove(_premiumTokenExpiryKey);
    } else {
      await _prefs.setString(_premiumTokenKey, token);
      await _prefs.setString(_premiumTokenExpiryKey, expiry.toIso8601String());
    }
  }

  /// Get premium verification token
  String? getPremiumToken() {
    return _prefs.getString(_premiumTokenKey);
  }

  /// Get premium verification token expiry
  DateTime? getPremiumTokenExpiry() {
    final dateStr = _prefs.getString(_premiumTokenExpiryKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}
