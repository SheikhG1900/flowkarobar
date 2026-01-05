import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flowpaisa/core/theme/app_theme.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/constants/app_constants.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final Locale _currentLocale = const Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
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
      locale: _currentLocale,
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
      theme: AppTheme.lightTheme(_currentLocale.languageCode),
      darkTheme: AppTheme.darkTheme(_currentLocale.languageCode),
      themeMode: ThemeMode.system,

      // Home
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Different screens for each tab
    final List<Widget> screens = [
      _DashboardTab(),
      const TransactionsListScreen(),
      _AnalyticsTab(),
      _SettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}

// Placeholder tabs
class _DashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            backgroundColor: AppColors.darkBackground
                .withValues(alpha: 0.9 / 1.0), // Darker header
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  // Dark Overlay for Contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black
                              .withValues(alpha: 0.3 / 1.0), // Darker top
                          Colors.black
                              .withValues(alpha: 0.1 / 1.0), // Lighter bottom
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
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
                                    Colors.white.withValues(alpha: 0.2 / 1.0),
                                borderRadius: BorderRadius.circular(14),
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
                        Text(
                          '₹15,420.50',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            fontSize: 42, // Larger amount
                            shadows: AppTheme.textShadow(
                                blurMultiplier: 4.0), // blurRadius 8 / 2 = 4
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Income/Expense Chips
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatChip(
                                context,
                                icon: Icons.arrow_downward_rounded,
                                label: 'Income',
                                amount: 25000,
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
                                amount: 9579.50,
                                color: Colors.white,
                                bgColor: Colors.orangeAccent
                                    .withValues(alpha: 0.25 / 1.0),
                                textColor: Colors.orangeAccent.shade100,
                              ),
                            ),
                          ],
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.water_drop,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'FlowPaisa',
                            style: TextStyle(
                              color: Colors.white,
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
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  // TODO: Notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined,
                    color: Colors.white),
                onPressed: () {
                  // TODO: Profile
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
        color: Colors.white.withValues(alpha: 0.15 / 1.0),
        borderRadius: BorderRadius.circular(16), // More rounded
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
                  borderRadius: BorderRadius.circular(8),
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
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add,
                  label: 'Add',
                  gradient: AppColors.primaryGradient,
                  onTap: () {
                    // TODO: Add transaction
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.document_scanner_outlined,
                  label: 'Scan',
                  gradient: AppColors.secondaryGradient,
                  onTap: () {
                    // TODO: Scan receipt
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.sync_alt,
                  label: 'Split',
                  gradient: AppColors.incomeGradient,
                  onTap: () {
                    // TODO: Split transaction
                  },
                ),
              ),
            ],
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
    final transactionsAsync = ref.watch(allTransactionsProvider);

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
            final transaction = recentTransactions[index];
            final isExpense = transaction.type == 'EXPENSE';
            final dateFormat = DateFormat.MMMd();
            final theme = Theme.of(context);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isExpense
                      ? theme.brightness == Brightness.dark
                          ? [const Color(0xFF2A2038), AppColors.darkCard]
                          : [const Color(0xFFFFF1F2), const Color(0xFFFFF5F5)]
                      : theme.brightness == Brightness.dark
                          ? [const Color(0xFF1A2E2A), AppColors.darkCard]
                          : [const Color(0xFFF0FDF4), const Color(0xFFF0F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isExpense
                      ? AppColors.expenseColor.withValues(alpha: 0.2 / 1.0)
                      : AppColors.incomeColor.withValues(alpha: 0.2 / 1.0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor)
                        .withValues(alpha: 0.15 / 1.0),
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
                    gradient: isExpense
                        ? AppColors.expenseGradient
                        : AppColors.incomeGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isExpense
                        ? Icons.shopping_bag_outlined
                        : Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
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
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(10),
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
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

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              'Analytics Coming Soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Charts and insights will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
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
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Language selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('System'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Theme selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(l10n.backup),
            subtitle: const Text('Last backup: Never'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Backup settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(l10n.premium),
            subtitle: Text(l10n.free),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Premium upgrade
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: About screen
            },
          ),
        ],
      ),
    );
  }
}
