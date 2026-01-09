import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flowpaisa/core/theme/app_theme.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/constants/app_constants.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/receipt_scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/categories_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/language_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/theme_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/about_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/profile_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/export_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flowpaisa/core/utils/deep_link_handler.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Edge-to-Edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization may fail if not configured yet
    debugPrint('Firebase initialization skipped: $e');
  }

  // Pre-cache fonts for all languages
  await _initializeFonts();

  runApp(
    const ProviderScope(
      child: FlowPaisaApp(),
    ),
  );
}

Future<void> _initializeFonts() async {
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.notoSansDevanagari(),
    GoogleFonts.notoNastaliqUrdu(),
  ]);
}

class FlowPaisaApp extends ConsumerStatefulWidget {
  const FlowPaisaApp({super.key});

  @override
  ConsumerState<FlowPaisaApp> createState() => _FlowPaisaAppState();
}

class _FlowPaisaAppState extends ConsumerState<FlowPaisaApp> {
  @override
  Widget build(BuildContext context) {
    // Watch language and theme mode from providers
    final currentLocale = ref.watch(languageProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('hi', 'IN'), // Hindi
        Locale('ur', 'PK'), // Urdu
      ],
      locale: currentLocale,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en', 'US');
      },

      // Theme
      theme: AppTheme.lightTheme(currentLocale.languageCode),
      darkTheme: AppTheme.darkTheme(currentLocale.languageCode),
      themeMode: currentThemeMode,

      // Home
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize deep link handler after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final deepLinkHandler = ref.read(deepLinkHandlerProvider);
        deepLinkHandler.initialize(context, ref);
      }
    });
  }

  Color _getSectionColor(int index) {
    switch (index) {
      case 0: // Dashboard
        return AppColors.dashboardSectionColor;
      case 1: // Transactions
        return AppColors.transactionsSectionColor;
      case 2: // Analytics
        return AppColors.analyticsSectionColor;
      case 3: // Settings
        return AppColors.settingsSectionColor;
      default:
        return AppColors.brightCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Different screens for each tab
    final List<Widget> screens = [
      _DashboardTab(),
      const TransactionsListScreen(),
      const AnalyticsScreen(),
      _SettingsTab(),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile Layout
            return IndexedStack(
              index: _selectedIndex,
              children: screens,
            );
          } else {
            // Tablet/Desktop Layout
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard),
                      label: Text(l10n.dashboard),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.receipt_long),
                      label: Text(l10n.transactions),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.analytics),
                      label: Text(l10n.analytics),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.settings),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  indicatorColor:
                      _getSectionColor(_selectedIndex).withValues(alpha: 0.15),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(
                          color: _getSectionColor(_selectedIndex));
                    }
                    return IconThemeData(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return TextStyle(
                        color: _getSectionColor(_selectedIndex),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.dashboard),
                    label: l10n.dashboard,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long),
                    label: l10n.transactions,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.analytics),
                    label: l10n.analytics,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings),
                    label: l10n.settings,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// Placeholder tabs
class _DashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Watch dashboard statistics
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 320, // Increased height for better spacing
            floating: false,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor
                .withValues(alpha: 0.9 / 1.0), // Adapts to light/dark mode
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background with Beveled Corner (bottom-right only)
                  Container(
                    decoration: const ShapeDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(
                              40), // This will now create a diagonal "cut"
                        ),
                      ),
                    ),
                  ),
                  // Dark Overlay for Contrast
                  Container(
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(
                              40), // This creates the "cut" effect
                        ),
                      ),
                    ),
                  ),
                  // Main Content
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Title (Visible in Expanded State)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withValues(alpha: 0.3 / 1.0),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ), // Diagonal beveled
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.1 / 1.0),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.water_drop,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'FlowPaisa',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28, // Large Title
                                letterSpacing: 0.5,
                                shadows:
                                    AppTheme.textShadow(blurMultiplier: 2.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 24), // Spacing between title and balance

                        // Balance Section
                        Text(
                          'Total Balance',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9 / 1.0),
                            fontWeight: FontWeight.w600,
                            shadows: AppTheme.textShadow(blurMultiplier: 1.0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        dashboardStatsAsync.when(
                          data: (stats) => Text(
                            '₹${stats.totalBalance.toStringAsFixed(2)}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              fontSize: 42, // Larger amount
                              shadows: AppTheme.textShadow(
                                  blurMultiplier: 4.0), // blurRadius 8 / 2 = 4
                            ),
                          ),
                          loading: () => Text(
                            '₹0.00',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              fontSize: 42,
                              shadows: AppTheme.textShadow(blurMultiplier: 4.0),
                            ),
                          ),
                          error: (_, __) => Text(
                            '₹0.00',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              fontSize: 42,
                              shadows: AppTheme.textShadow(blurMultiplier: 4.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Income/Expense Chips
                        dashboardStatsAsync.when(
                          data: (stats) => Row(
                            children: [
                              Expanded(
                                child: _buildStatChip(
                                  context,
                                  icon: Icons.arrow_downward_rounded,
                                  label: 'Income',
                                  amount: stats.totalIncome,
                                  color: Colors.white,
                                  bgColor: Colors.greenAccent
                                      .withValues(alpha: 0.25 / 1.0),
                                  textColor: Colors.greenAccent.shade100,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatChip(
                                  context,
                                  icon: Icons.arrow_upward_rounded,
                                  label: 'Expense',
                                  amount: stats.totalExpense,
                                  color: Colors.white,
                                  bgColor: Colors.orangeAccent
                                      .withValues(alpha: 0.25 / 1.0),
                                  textColor: Colors.orangeAccent.shade100,
                                ),
                              ),
                            ],
                          ),
                          loading: () => Row(
                            children: [
                              Expanded(
                                child: _buildStatChip(
                                  context,
                                  icon: Icons.arrow_downward_rounded,
                                  label: 'Income',
                                  amount: 0.0,
                                  color: Colors.white,
                                  bgColor: Colors.greenAccent
                                      .withValues(alpha: 0.25 / 1.0),
                                  textColor: Colors.greenAccent.shade100,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatChip(
                                  context,
                                  icon: Icons.arrow_upward_rounded,
                                  label: 'Expense',
                                  amount: 0.0,
                                  color: Colors.white,
                                  bgColor: Colors.orangeAccent
                                      .withValues(alpha: 0.25 / 1.0),
                                  textColor: Colors.orangeAccent.shade100,
                                ),
                              ),
                            ],
                          ),
                          error: (_, __) => Row(
                            children: [
                              Expanded(
                                child: _buildStatChip(
                                  context,
                                  icon: Icons.arrow_downward_rounded,
                                  label: 'Income',
                                  amount: 0.0,
                                  color: Colors.white,
                                  bgColor: Colors.greenAccent
                                      .withValues(alpha: 0.25 / 1.0),
                                  textColor: Colors.greenAccent.shade100,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatChip(
                                  context,
                                  icon: Icons.arrow_upward_rounded,
                                  label: 'Expense',
                                  amount: 0.0,
                                  color: Colors.white,
                                  bgColor: Colors.orangeAccent
                                      .withValues(alpha: 0.25 / 1.0),
                                  textColor: Colors.orangeAccent.shade100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              titlePadding: EdgeInsets.zero,
              // Only show title in collapsed state via this builder
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final settings = context.dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings>();
                  final deltaExtent = settings!.maxExtent - settings.minExtent;
                  final t = (1.0 -
                          (settings.currentExtent - settings.minExtent) /
                              deltaExtent)
                      .clamp(0.0, 1.0);

                  // Show title only when collapsed (t > 0.7)
                  if (t < 0.7) return const SizedBox.shrink();

                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(t),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ), // Diagonal beveled
                            ),
                            child: const Icon(Icons.water_drop,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'FlowPaisa',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Quick Actions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _buildQuickActions(context, l10n),
            ),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
              child: _buildRecentTransactionsHeader(context, l10n),
            ),
          ),

          // Recent Transactions List
          SliverToBoxAdapter(
            child: _buildRecentTransactions(context, ref),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required Color bgColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15 / 1.0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ), // Diagonal beveled
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1 / 1.0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Larger padding
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ), // Diagonal beveled
                ),
                child: Icon(icon, color: color, size: 18), // Larger icon
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  // Larger text style
                  color: textColor,
                  fontWeight: FontWeight.w600, // Bolder
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // More spacing
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20, // Larger amount
              shadows: [
                AppColors.textShadowSubtle(
                    Theme.of(context).brightness == Brightness.dark)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          // Grid layout for quick actions (responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate optimal item width based on available space
              const double minItemWidth = 100; // Minimum width per item
              final double availableWidth = constraints.maxWidth;

              // Calculate how many items can fit
              int crossAxisCount = (availableWidth / minItemWidth).floor();
              crossAxisCount =
                  crossAxisCount.clamp(2, 6); // Min 2, Max 6 columns

              // Calculate actual item width
              final double itemWidth = availableWidth / crossAxisCount;
              final double childAspectRatio =
                  itemWidth / 110; // Height is fixed at ~110px

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                children: [
                  _QuickActionButton(
                    icon: Icons.add,
                    label: 'Add',
                    gradient: AppColors.transactionsSectionGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTransactionScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.document_scanner_outlined,
                    label: 'Scan',
                    gradient: AppColors.secondaryGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanReceiptScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.sync_alt,
                    label: 'Split',
                    gradient: AppColors.incomeGradient,
                    onTap: () {
                      // TODO: Split transaction
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Receivables',
                    fontSizeMultiplier: 0.82,
                    gradient: AppColors.receivablesSectionGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReceivablesListScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.payment_outlined,
                    label: 'Payables',
                    gradient: AppColors.payablesSectionGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PayablesListScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Analytics',
                    gradient: AppColors.analyticsSectionGradient,
                    onTap: () {
                      // TODO: Analytics screen
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader(
      BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: () {
              // TODO: View all transactions
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsWithCategoryProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first transaction',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show only recent 5 transactions
        final recentTransactions = transactions.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final item = recentTransactions[index];
            final transaction = item.transaction;
            final category = item.category;
            final isExpense = transaction.type == 'EXPENSE';
            final dateFormat = DateFormat.MMMd();
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            // Resolve category color
            Color categoryColor;
            if (category?.color != null) {
              try {
                categoryColor =
                    Color(int.parse(category!.color!.replaceAll('#', '0xFF')));
              } catch (_) {
                categoryColor =
                    isExpense ? AppColors.expenseColor : AppColors.incomeColor;
              }
            } else {
              categoryColor =
                  isExpense ? AppColors.expenseColor : AppColors.incomeColor;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        categoryColor.withValues(alpha: isDark ? 0.05 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _buildCategoryIcon(
                      category?.icon, categoryColor, isExpense),
                ),
                title: Text(
                  transaction.description ?? (isExpense ? 'Expense' : 'Income'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(dateFormat.format(transaction.date)),
                trailing: Text(
                  '${isExpense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isExpense
                        ? AppColors.expenseColor
                        : AppColors.incomeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(32),
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }

  Widget _buildCategoryIcon(String? iconString, Color color, bool isExpense) {
    if (iconString == null) {
      return Icon(
        isExpense
            ? Icons.shopping_bag_outlined
            : Icons.account_balance_wallet_outlined,
        color: color,
        size: 24,
      );
    }

    // Try to parse as integer (code point for IconData)
    final int? codePoint = int.tryParse(iconString);
    if (codePoint != null) {
      return Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'),
        color: color,
        size: 24,
      );
    }

    // Fallback to text (emoji) for legacy data
    return Text(
      iconString,
      style: const TextStyle(fontSize: 24),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final double fontSizeMultiplier;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.fontSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ), // Diagonal beveled
          boxShadow: [
            // Bottom shadow for depth
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4 / 1.0),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            // Inner highlight for 3D effect
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1 / 1.0),
              blurRadius: 1,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2 / 1.0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1 / 1.0),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14 * fontSizeMultiplier,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Contacts'),
            subtitle: const Text('Manage your contacts'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactsListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categories'),
            subtitle: const Text('Manage expense & income categories'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesListScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectorScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSelectorScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(l10n.backup),
            subtitle: const Text('Google Drive Backup & Restore'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Data'),
            subtitle: const Text('Download your data as CSV'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(l10n.premium),
            subtitle: Text(l10n.free),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
