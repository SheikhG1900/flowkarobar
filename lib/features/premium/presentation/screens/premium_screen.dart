import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/premium/data/premium_repository.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class ProductInfo {
  final String price; // The Regular/Base price
  final String? trial; // e.g., "trial 7 days"
  final String? discountedPrice; // e.g., "$25"

  ProductInfo({required this.price, this.trial, this.discountedPrice});
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    // Default to yearly as it's the recommended one
    _selectedProductId = PremiumRepository.premiumYearlyId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final premiumState = ref.watch(premiumProvider);

    // Update selected product if list was empty and now has items
    if (_selectedProductId == PremiumRepository.premiumYearlyId &&
        premiumState.products.isNotEmpty &&
        !premiumState.products.any((p) => p.id == _selectedProductId)) {
      _selectedProductId = premiumState.products.first.id;
    }

    // Listen for errors and notifications
    ref.listen(premiumProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        if (next.error == 'No purchases found') {
          ToastUtils.showInfoToast(context, ref, l10n.noPurchasesFound);
        } else {
          ToastUtils.showErrorToast(context, ref, next.error!);
        }
      }
    });

    return Scaffold(
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(premiumProvider.notifier).togglePremium();
                ToastUtils.showInfoToast(context, ref, l10n.toggledDebugMode);
              },
              label: Text(l10n.debugToggleMode),
              icon: const Icon(Icons.developer_mode),
              backgroundColor: Colors.grey[800],
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFD700), // Gold
                      Color(0xFFFFA500), // Orange
                      Color(0xFFFF8C00), // Dark Orange
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        if (premiumState.isPremium)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.premiumTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (premiumState.isPremium)
                      const PremiumBadge(isLarge: true)
                    else
                      Text(
                        l10n.unlockAllFeatures,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  // Premium Active Card (Moved to top but keep features below)
                  if (premiumState.isPremium) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.teal.shade500],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.premiumMemberStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.premiumFeaturesActive,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  _buildFeatureCard(
                    context,
                    icon: Icons.message_outlined,
                    title: l10n.featureTemplatesTitle,
                    description: l10n.featureTemplatesDesc,
                    color: Colors.teal,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.cloud_upload,
                    title: l10n.featureCloudBackupTitle,
                    description: l10n.featureCloudBackupDesc,
                    color: theme.colorScheme.primary,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.analytics,
                    title: l10n.featureAnalyticsTitle,
                    description: l10n.featureAnalyticsDesc,
                    color: Colors.purple,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.picture_as_pdf,
                    title: l10n.featurePdfReportsTitle,
                    description: l10n.featurePdfReportsDesc,
                    color: Colors.red,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.all_inclusive,
                    title: l10n.featureUnlimitedTitle,
                    description: l10n.featureUnlimitedDesc,
                    color: Colors.green,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.support_agent,
                    title: l10n.featureSupportTitle,
                    description: l10n.featureSupportDesc,
                    color: Colors.orange,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.new_releases,
                    title: l10n.featureEarlyAccessTitle,
                    description: l10n.featureEarlyAccessDesc,
                    color: theme.colorScheme.primary,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.sync,
                    title: l10n.featureMultiDeviceSyncTitle,
                    description: l10n.featureMultiDeviceSyncDesc,
                    color: Colors.blue,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.library_books,
                    title: l10n.featureMultipleCashbooksTitle,
                    description: l10n.featureMultipleCashbooksDesc,
                    color: Colors.indigo,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.event_repeat,
                    title: l10n.featureUnlimitedSchedulesTitle,
                    description: l10n.featureUnlimitedSchedulesDesc,
                    color: Colors.cyan,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.mic,
                    title: l10n.featureUnlimitedVoiceExtractionTitle,
                    description: l10n.featureUnlimitedVoiceExtractionDesc,
                    color: Colors.deepPurple,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.receipt_long,
                    title: l10n.featureUnlimitedReceiptExtractionTitle,
                    description: l10n.featureUnlimitedReceiptExtractionDesc,
                    color: Colors.teal,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.upload_file,
                    title: l10n.featureBulkImportTitle,
                    description: l10n.featureBulkImportDesc,
                    color: Colors.orange,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 32),

                  if (!premiumState.isPremium) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.chooseYourPlan,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Monthly Plan
                    _buildPlanOption(
                      context,
                      id: PremiumRepository.premiumMonthlyId,
                      title: l10n.monthly,
                      subtitle: l10n.cancelAnytime,
                      productInfo: _getDetailedProductInfo(
                        context,
                        premiumState.products
                                .where((p) =>
                                    p.id == PremiumRepository.premiumMonthlyId)
                                .firstOrNull ??
                            ProductDetails(
                              id: PremiumRepository.premiumMonthlyId,
                              title: '',
                              description: '',
                              price: '₹29',
                              rawPrice: 29.0,
                              currencyCode: 'INR',
                            ),
                      ),
                      isSelected: _selectedProductId ==
                          PremiumRepository.premiumMonthlyId,
                    ),
                    const SizedBox(height: 12),

                    // Yearly Plan (Recommended)
                    _buildPlanOption(
                      context,
                      id: PremiumRepository.premiumYearlyId,
                      title: l10n.yearly,
                      subtitle: l10n.savePercentage("50"),
                      productInfo: _getDetailedProductInfo(
                        context,
                        premiumState.products
                                .where((p) =>
                                    p.id == PremiumRepository.premiumYearlyId)
                                .firstOrNull ??
                            ProductDetails(
                              id: PremiumRepository.premiumYearlyId,
                              title: '',
                              description: '',
                              price: '₹199',
                              rawPrice: 199.0,
                              currencyCode: 'INR',
                            ),
                      ),
                      isSelected: _selectedProductId ==
                          PremiumRepository.premiumYearlyId,
                      isRecommended: true,
                    ),
                    const SizedBox(height: 12),

                    // Lifetime Plan
                    _buildPlanOption(
                      context,
                      id: PremiumRepository.premiumLifetimeId,
                      title: l10n.lifetime,
                      subtitle: l10n.oneTimePayment,
                      productInfo: _getDetailedProductInfo(
                        context,
                        premiumState.products
                                .where((p) =>
                                    p.id == PremiumRepository.premiumLifetimeId)
                                .firstOrNull ??
                            ProductDetails(
                              id: PremiumRepository.premiumLifetimeId,
                              title: '',
                              description: '',
                              price: '₹399',
                              rawPrice: 399.0,
                              currencyCode: 'INR',
                            ),
                      ),
                      isSelected: _selectedProductId ==
                          PremiumRepository.premiumLifetimeId,
                    ),
                    const SizedBox(height: 24),

                    // Unlock Button
                    GradientButton(
                      label: premiumState.isLoading
                          ? l10n.processing
                          : l10n.unlockPremium,
                      icon: premiumState.isLoading
                          ? Icons.hourglass_empty
                          : Icons.lock_open,
                      isLoading: premiumState.isLoading,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      onPressed: premiumState.isLoading
                          ? () {}
                          : () {
                              if (_selectedProductId != null) {
                                ref
                                    .read(premiumProvider.notifier)
                                    .buyPremium(_selectedProductId!);
                              }
                            },
                    ),
                    const SizedBox(height: 12),

                    // Restore Purchases
                    TextButton.icon(
                      onPressed: premiumState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(premiumProvider.notifier)
                                  .restorePurchases();
                            },
                      icon: const Icon(Icons.restore),
                      label: Text(l10n.restorePurchases),
                    ),
                    const SizedBox(height: 16),

                    // Benefits Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.premiumBenefitsNote,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _parseIsoDuration(BuildContext context, String period) {
    final l10n = AppLocalizations.of(context)!;
    final numericValue = RegExp(r'[0-9]+').firstMatch(period)?.group(0);
    if (numericValue == null) return period;

    final count = int.parse(numericValue);
    if (period.contains('D')) {
      return l10n.daysFreeTrial(count);
    } else if (period.contains('M')) {
      return l10n.monthFreeTrial(count);
    } else if (period.contains('W')) {
      // Fallback for weeks if not in l10n, or just return as is
      return '$count weeks';
    }
    return period;
  }

  ProductInfo _getDetailedProductInfo(
      BuildContext context, ProductDetails product) {
    String regularPrice = product.price;
    String? trial;
    String? discountedPrice;

    if (product is GooglePlayProductDetails) {
      final googleProduct = product.productDetails;

      // --- CASE 1: SUBSCRIPTIONS (Phases) ---
      if (googleProduct.subscriptionOfferDetails != null &&
          googleProduct.subscriptionOfferDetails!.isNotEmpty) {
        final offer = googleProduct.subscriptionOfferDetails!.first;
        final phases = offer.pricingPhases;

        regularPrice = phases.last.formattedPrice;

        if (phases.length > 1) {
          for (var i = 0; i < phases.length - 1; i++) {
            var phase = phases[i];
            if (phase.priceAmountMicros == 0) {
              trial = _parseIsoDuration(context, phase.billingPeriod);
            } else if (phase.priceAmountMicros <
                phases.last.priceAmountMicros) {
              discountedPrice = phase.formattedPrice;
            }
          }
        }
      }
      // --- CASE 2: ONE-TIME PRODUCTS (Offers) ---
      else if (googleProduct.oneTimePurchaseOfferDetails != null) {
        final oneTimeDetails = googleProduct.oneTimePurchaseOfferDetails!;

        // The 'price' from product.price is usually the currently active offer price.
        // We look for the base price in the details to show the "original" price.
        regularPrice = oneTimeDetails.formattedPrice;

        // If Google Play returns a discounted price in the main object,
        // but it differs from our base price, we mark it as a discount.
        if (product.price != regularPrice) {
          discountedPrice = product.price;
        }
      }
    }

    return ProductInfo(
      price: regularPrice,
      trial: trial,
      discountedPrice: discountedPrice,
    );
  }

  Widget _buildPlanOption(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required ProductInfo productInfo,
    required bool isSelected,
    bool isRecommended = false,
  }) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (productInfo.trial != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            productInfo.trial!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (productInfo.discountedPrice != null)
                      Text(
                        productInfo.price,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    Text(
                      productInfo.discountedPrice ?? productInfo.price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isRecommended)
              Positioned(
                top: -24,
                right: isRtl ? null : -8,
                left: isRtl ? -8 : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA500),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.bestValue.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    bool isPremium = false,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? color.withValues(alpha: 0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.green.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              l10n.active,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
