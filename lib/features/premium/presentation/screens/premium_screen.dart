import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final premiumState = ref.watch(premiumProvider);

    // Listen for errors
    ref.listen(premiumProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(premiumProvider.notifier).togglePremium();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Toggled Debug Mode'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        label: const Text('DEBUG: Toggle Mode'),
        icon: const Icon(Icons.developer_mode),
        backgroundColor: Colors.grey[800],
      ),
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
                    const Text(
                      'FlowPaisa Premium',
                      style: TextStyle(
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
                      const Text(
                        'Unlock all features',
                        style: TextStyle(
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
                      child: const Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'You are a Premium Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'All premium features are active',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Features List
                  _buildFeatureCard(
                    context,
                    icon: Icons.cloud_upload,
                    title: 'Automatic Cloud Backup',
                    description:
                        'Your data is automatically backed up to Google Drive. Never lose your financial records.',
                    color: AppColors.brightCyan,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Advanced Analytics',
                    description:
                        'Get detailed insights with advanced charts, trends, and financial forecasting.',
                    color: Colors.purple,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.picture_as_pdf,
                    title: 'PDF Reports',
                    description:
                        'Generate beautiful PDF reports with charts and summaries for any date range.',
                    color: Colors.red,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.all_inclusive,
                    title: 'Unlimited Transactions',
                    description:
                        'No limits on the number of transactions, contacts, or categories you can create.',
                    color: Colors.green,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.support_agent,
                    title: 'Priority Support',
                    description:
                        'Get faster responses and dedicated support for any issues or questions.',
                    color: Colors.orange,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.new_releases,
                    title: 'Early Access',
                    description:
                        'Be the first to try new features before they\'re released to everyone.',
                    color: AppColors.primaryGradient.colors.last,
                    isPremium: premiumState.isPremium,
                  ),
                  const SizedBox(height: 32),

                  if (!premiumState.isPremium) ...[
                    // Pricing Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Premium Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getProductPrice(premiumState.products)
                                        ?.currencySymbol ??
                                    '₹',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getProductPrice(premiumState.products)
                                        ?.amount ??
                                    '99',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Lifetime', // Fixed text
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'One-time payment • Lifetime access',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Unlock Button
                    GradientButton(
                      label: premiumState.isLoading
                          ? 'Processing...'
                          : 'Unlock Premium',
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
                              // For testing, we use the toggle
                              ref
                                  .read(premiumProvider.notifier)
                                  .togglePremium();
                              // In production, use buyPremium()
                              // ref.read(premiumProvider.notifier).buyPremium();
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
                      label: const Text('Restore Purchases'),
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
                              'All premium features are yours forever with a one-time purchase. No subscriptions!',
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

  ({String currencySymbol, String amount})? _getProductPrice(
      List<ProductDetails> products) {
    if (products.isEmpty) return null;
    // Assuming first product is the one we want or filtering logic should be in provider
    // In provider we filter by ID, here we just take the first one or default
    // Ideally we should match ID
    try {
      final product = products.first; // Should filter by ID if multiple
      // Price string is usually like "₹99.00"
      // We want to split symbol and amount if possible, or just return as is
      // But for this UI design, it expects split.
      // This is a naive split, real world should use proper formatting
      final price = product.price; // e.g. "₹99.00"
      final currencySymbol = product.currencySymbol;

      // Remove symbol from price string if present to get amount
      String amount = price;
      if (price.startsWith(currencySymbol)) {
        amount = price.substring(currencySymbol.length).trim();
      }
      return (currencySymbol: currencySymbol, amount: amount);
    } catch (_) {
      return null;
    }
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(
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
