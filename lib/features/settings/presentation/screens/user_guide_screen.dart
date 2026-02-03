import 'package:flutter/material.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/tour/domain/tour_service.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';

class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userGuide),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildGuideSection(
                  context,
                  title: l10n.guideGettingStarted,
                  description: l10n.guideGettingStartedDesc,
                  icon: Icons.rocket_launch_outlined,
                  items: [
                    _GuideItem(
                      question: l10n.guideAddTransaction,
                      answer: l10n.guideAddTransactionStep,
                      tourAction: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTransactionScreen(),
                          ),
                        );
                        // Start tour after navigation
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            TourService.startAddTransactionTour(context);
                          }
                        });
                      },
                    ),
                    _GuideItem(
                      question: l10n.guideSwitchCashbook,
                      answer: l10n.guideSwitchCashbookStep,
                      tourAction: (context) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        // Dashboard is the first screen
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            TourService.startDashboardTour(context);
                          }
                        });
                      },
                    ),
                  ],
                ),
                _buildGuideSection(
                  context,
                  title: l10n.guideManagingMoney,
                  description: l10n.guideManagingMoneyDesc,
                  icon: Icons.account_balance_wallet_outlined,
                  items: [
                    _GuideItem(
                      question: l10n.receivables,
                      answer: l10n.guideTrackReceivablesStep,
                      tourAction: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReceivablesListScreen(),
                          ),
                        );
                        // Start tour after navigation
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            TourService.startReceivablesTour(context);
                          }
                        });
                      },
                    ),
                    _GuideItem(
                      question: l10n.payables,
                      answer: l10n.guideTrackPayablesStep,
                      tourAction: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PayablesListScreen(),
                          ),
                        );
                        // Start tour after navigation
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            TourService.startPayablesTour(context);
                          }
                        });
                      },
                    ),
                  ],
                ),
                _buildGuideSection(
                  context,
                  title: l10n.guideRelationships,
                  description: l10n.guideRelationshipsDesc,
                  icon: Icons.people_outline,
                  items: [
                    _GuideItem(
                      question: l10n.guideLinkedTransactions,
                      answer: l10n.guideLinkedTransactionsStep,
                    ),
                  ],
                ),
                _buildGuideSection(
                  context,
                  title: l10n.guideSharing,
                  description: l10n.guideSharingDesc,
                  icon: Icons.share_outlined,
                  items: [
                    _GuideItem(
                      question: l10n.guideDeepLinks,
                      answer: l10n.guideDeepLinksStep,
                    ),
                    _GuideItem(
                      question: l10n.guideImportDeepLink,
                      answer: l10n.guideImportDeepLinkStep,
                    ),
                    _GuideItem(
                      question: l10n.guideSyncDevices,
                      answer: l10n.guideSyncDevicesStep,
                    ),
                  ],
                ),
                _buildGuideSection(
                  context,
                  title: l10n.guideAdvancedFeatures,
                  description: l10n.guideAdvancedFeaturesDesc,
                  icon: Icons.auto_awesome_outlined,
                  items: [
                    _GuideItem(
                      question: l10n.receiptScan,
                      answer: l10n.guideScanReceiptStep,
                    ),
                    _GuideItem(
                      question: l10n.splitBill,
                      answer: l10n.guideSplitBillStep,
                    ),
                    _GuideItem(
                      question: l10n.cloudBackup,
                      answer: l10n.guideCloudBackupStep,
                      tourAction: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupScreen(startTour: true),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                _buildGuideSection(
                  context,
                  title: l10n.guideCustomization,
                  description: l10n.guideCustomizationDesc,
                  icon: Icons.tune_outlined,
                  items: [
                    _GuideItem(
                      question: l10n.categories,
                      answer: l10n.manageCategories,
                    ),
                    _GuideItem(
                      question: l10n.currency,
                      answer: l10n.manageCurrencies,
                    ),
                    _GuideItem(
                      question: l10n.theme,
                      answer: l10n.themeChangesApplyImmediately,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required List<_GuideItem> items,
  }) {
    final theme = Theme.of(context);

    // Filter items based on search query
    final filteredItems = items.where((item) {
      return item.question.toLowerCase().contains(_searchQuery) ||
          item.answer.toLowerCase().contains(_searchQuery);
    }).toList();

    if (_searchQuery.isNotEmpty && filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
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
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...filteredItems.map((item) => _buildExpansionTile(context, item)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildExpansionTile(BuildContext context, _GuideItem item) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (item.tourAction != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => item.tourAction!(context),
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: Text(AppLocalizations.of(context)!.tourShowMeHow),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideItem {
  final String question;
  final String answer;
  final Function(BuildContext)? tourAction;

  _GuideItem({
    required this.question,
    required this.answer,
    this.tourAction,
  });
}
