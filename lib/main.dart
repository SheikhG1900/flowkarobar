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
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/categories_list_screen.dart';
import 'package:flowpaisa/features/currencies/presentation/screens/currencies_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/language_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/font_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/theme_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/about_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/profile_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/messages/presentation/screens/message_templates_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/export_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flowpaisa/core/utils/deep_link_handler.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/features/cashbooks/presentation/screens/cashbooks_screen.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/shared/widgets/entrance_animation.dart';
import 'package:flowpaisa/shared/widgets/animated_amount.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flowpaisa/features/transactions/data/schedule_scheduler.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';

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

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization may fail if not configured yet
    debugPrint('Firebase initialization skipped: $e');
  }

  // Pre-cache fonts for all languages
  await _initializeFonts();

  // Force tree shaking for Material Symbols icons
  // This ensures only used icons are included in the build
  Symbols.forceCompileTimeTreeShaking();

  // Initialize workmanager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Register periodic task to run daily (at approximately midnight)
  await Workmanager().registerPeriodicTask(
    'schedule-transactions',
    'schedule-transactions',
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
    ),
  );

  // Initialize Sync Scheduler
  await SyncScheduler.init();
  await SyncScheduler.scheduleDailySync();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FlowPaisaApp(),
    ),
  );
}

/// Background task callback for workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'schedule-transactions') {
      await processSchedules();
      return Future.value(true);
    }
    return Future.value(false);
  });
}

Future<void> _initializeFonts() async {
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.notoSansDevanagari(),
    GoogleFonts.marhey(),
    GoogleFonts.lalezar(),
    GoogleFonts.kufam(),
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
    final currentFont = ref.watch(currentFontProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;

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
      theme: AppTheme.lightTheme(currentLocale.languageCode, currentFont,
          primaryColor: activeColor),
      darkTheme: AppTheme.darkTheme(currentLocale.languageCode, currentFont,
          primaryColor: activeColor),
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
    final activeCashbook = ref.watch(activeCashbookProvider);
    switch (index) {
      case 0: // Dashboard
        return activeCashbook.color;
      case 1: // Transactions
        return AppColors.transactionsSectionColor;
      case 2: // Analytics
        return AppColors.analyticsSectionColor;
      case 3: // Settings
        return AppColors.settingsSectionColor;
      default:
        return activeCashbook.color;
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
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.01, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: screens[_selectedIndex],
              ),
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedIndex),
                      child: screens[_selectedIndex],
                    ),
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
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = PremiumGate.isPremium(ref);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;
    final activeIcon = activeCashbook.icon;

    // Watch dashboard statistics and filter
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final filter = ref.watch(dashboardFilterProvider);

    // Show loading if currency is not yet loaded
    if (currency == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 420, // Reduced height for more compact header
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
                  // Gradient Background with Beveled Corner (bottom-right for LTR, bottom-left for RTL)
                  Container(
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        colors: [
                          activeColor.withValues(alpha: 0.4),
                          activeColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BeveledRectangleBorder(
                        side: BorderSide(
                            color: activeColor.withValues(alpha: 0.3),
                            width: 1),
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(40),
                        ),
                      ),
                    ),
                  ),
                  // Overlay for Contrast
                  Container(
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.8),
                          isDark
                              ? Colors.black.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(40),
                        ),
                      ),
                    ),
                  ),
                  // Main Content
                  Positioned(
                    left: 12,
                    right: 12,
                    top: MediaQuery.of(context).padding.top + 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Title
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CashbooksScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 2),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: activeColor.withValues(
                                        alpha: isDark ? 0.3 : 0.1),
                                    borderRadius:
                                        const BorderRadiusDirectional.only(
                                      topStart: Radius.circular(14),
                                      bottomEnd: Radius.circular(14),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05 / 1.0),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(activeIcon,
                                      color:
                                          isDark ? Colors.white : activeColor,
                                      size: 24),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppConstants.appName,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.lightText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 0.5,
                                        shadows: isDark
                                            ? AppTheme.textShadow(
                                                blurMultiplier: 2.0)
                                            : null,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          activeIcon,
                                          size: 14,
                                          color: activeColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          activeCashbook.name,
                                          style: TextStyle(
                                            color: activeColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color:
                                      isDark ? Colors.white54 : Colors.black54,
                                ),
                                if (isPremium) ...[
                                  const SizedBox(width: 8),
                                  const PremiumBadge(isSmall: true),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Balance Section
                        Text(
                          l10n.availableCash,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                            shadows: isDark
                                ? AppTheme.textShadow(blurMultiplier: 1.0)
                                : null,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            dashboardStatsAsync.when(
                              data: (stats) => AnimatedAmount(
                                amount: stats.totalBalance,
                                currencySymbol: currency.symbol,
                                decimalPlaces: currency.decimalPlaces,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightText,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  fontSize: AmountFormatter.getFontSize(
                                      stats.totalBalance,
                                      baseSize: 32,
                                      decimalPlaces: currency.decimalPlaces),
                                  shadows: isDark
                                      ? AppTheme.textShadow(blurMultiplier: 4.0)
                                      : null,
                                ),
                              ),
                              loading: () => SizedBox(
                                  height: 32,
                                  child: CircularProgressIndicator(
                                      color: isDark
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                      strokeWidth: 2)),
                              error: (_, __) => Text(l10n.error,
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.error)),
                            ),
                            _buildFilterChip(context, ref, filter, isDark),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stats Grid
                        dashboardStatsAsync.when(
                          data: (stats) => Column(
                            children: [
                              EntranceAnimation(
                                index: 1,
                                child: _buildSummaryRow(
                                  context,
                                  isDark: isDark,
                                  title: l10n.cashFlow,
                                  items: [
                                    _SummaryItem(
                                      label: l10n.income,
                                      amount: stats.income(filter),
                                      color: AppColors.incomeColor,
                                      icon: Icons.south_west,
                                    ),
                                    _SummaryItem(
                                      label: l10n.expense,
                                      amount: stats.expense(filter),
                                      color: AppColors.expenseColor,
                                      icon: Icons.north_east,
                                    ),
                                    _SummaryItem(
                                      label: l10n.netCash,
                                      amount: stats.netCash(filter),
                                      color: Colors.white,
                                      icon: Icons.account_balance_wallet,
                                    ),
                                  ],
                                  currency: currency,
                                ),
                              ),
                              const SizedBox(height: 12),
                              EntranceAnimation(
                                index: 2,
                                child: _buildSummaryRow(
                                  context,
                                  isDark: isDark,
                                  title: l10n.lendingCredit,
                                  items: [
                                    _SummaryItem(
                                      label: l10n.receivableTag,
                                      amount: stats.receivable(filter),
                                      color: AppColors.receivableColor,
                                      icon: Icons.call_received,
                                      overdue: stats.overdueReceivable,
                                    ),
                                    _SummaryItem(
                                      label: l10n.payableTag,
                                      amount: stats.payable(filter),
                                      color: AppColors.payableColor,
                                      icon: Icons.call_made,
                                      overdue: stats.overduePayable,
                                    ),
                                    _SummaryItem(
                                      label: l10n.netCredit,
                                      amount: stats.netCredit(filter),
                                      color: Colors.white,
                                      icon: Icons.swap_horiz,
                                    ),
                                  ],
                                  currency: currency,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                          loading: () => const SizedBox(height: 100),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              titlePadding: EdgeInsets.zero,
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final settings = context.dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings>();
                  final deltaExtent = settings!.maxExtent - settings.minExtent;
                  final t = (1.0 -
                          (settings.currentExtent - settings.minExtent) /
                              deltaExtent)
                      .clamp(0.0, 1.0);

                  if (t < 0.8) return const SizedBox.shrink();

                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(t),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.getPrimaryGradient(
                                  theme.colorScheme.primary),
                              borderRadius: const BorderRadiusDirectional.only(
                                topStart: Radius.circular(12),
                                bottomEnd: Radius.circular(12),
                              ),
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
                              fontSize: 18,
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
            child: EntranceAnimation(
              index: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _buildQuickActions(context, l10n, isPremium),
              ),
            ),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: EntranceAnimation(
              index: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                child: _buildRecentTransactionsHeader(context, l10n),
              ),
            ),
          ),

          // Recent Transactions List
          SliverToBoxAdapter(
            child: EntranceAnimation(
              index: 5,
              child: _buildRecentTransactions(context, ref),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref,
      DashboardFilter currentFilter, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final activeCashbook = ref.watch(activeCashbookProvider);
    final isMonthly = currentFilter == DashboardFilter.monthly;
    final label = isMonthly
        ? AppDateFormatter.formatMonth(DateTime.now(), context: context)
        : l10n.all;
    final icon = isMonthly ? Icons.calendar_today : Icons.all_inclusive;

    return ActionChip(
      color: WidgetStateProperty.all(activeCashbook.color.withAlpha(50)),
      label: Row(
        children: [
          Icon(icon, size: 16, color: activeCashbook.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: activeCashbook.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onPressed: () {
        final nextFilter =
            isMonthly ? DashboardFilter.overall : DashboardFilter.monthly;
        ref.read(dashboardFilterProvider.notifier).setFilter(nextFilter);
      },
      backgroundColor: activeCashbook.color.withValues(alpha: 0.1),
      side: BorderSide(
        color: activeCashbook.color,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required List<_SummaryItem> items,
    required dynamic currency,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.lightTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            final isLast = items.indexOf(item) == items.length - 1;
            return Expanded(
              child: Container(
                margin: EdgeInsetsDirectional.only(end: isLast ? 0 : 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.glassGradient(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, color: item.color, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.lightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AmountFormatter.formatWithCurrency(
                          item.amount,
                          currency.symbol,
                          currency.decimalPlaces,
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.overdue != null && item.overdue! > 0) ...[
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 12, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                AmountFormatter.formatWithCurrency(
                                    item.overdue!,
                                    currency.symbol,
                                    currency.decimalPlaces),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.redAccent
                                      : AppColors.error,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, AppLocalizations l10n, bool isPremium) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
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
                    label: l10n.add,
                    gradient:
                        AppColors.getPrimaryGradient(theme.colorScheme.primary),
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
                    label: l10n.scan,
                    gradient: AppColors.getSecondaryGradient(
                        theme.colorScheme.primary),
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
                    icon: Symbols.account_balance_wallet,
                    label: l10n.receivableTag,
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
                    label: l10n.payables,
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
                    label: l10n.analytics,
                    gradient: AppColors.analyticsSectionGradient,
                    showLock: !isPremium,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnalyticsScreen(),
                        ),
                      );
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
            l10n.recentTransactions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsListScreen(),
                ),
              );
            },
            child: Text(l10n.viewAll),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(transactionsWithDetailsProvider);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    l10n.noTransactionsYet,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tapToAddFirst,
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
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final userProfile = ref.watch(userProfileProvider);

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

            return _AnimatedPressScale(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetailsDialog(item: item),
                  ),
                );
              },
              child: Container(
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
                    child: CategoryHelper.buildCategoryIcon(
                        category?.icon, categoryColor, isExpense),
                  ),
                  title: Text(
                    transaction.description ??
                        (isExpense ? l10n.expense : l10n.income),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(AppDateFormatter.formatDate(transaction.date,
                      pattern: userProfile.dateFormat)),
                  trailing: Text(
                    '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}',
                    style: TextStyle(
                      color: isExpense
                          ? AppColors.expenseColor
                          : AppColors.incomeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
        child: Text(l10n.errorOccurred(error.toString())),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool showLock;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.showLock = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        decoration: BoxDecoration(
          gradient: gradient.withOpacity(0.2),
          border: Border.all(
              color: gradient.colors.first.withValues(alpha: 0.5), width: 1),
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            bottomEnd: Radius.circular(20),
          ),
          // Diagonal beveled
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: gradient.colors.first.withValues(alpha: 0.8),
                        width: 1),
                    color: gradient.colors.first.withValues(alpha: 0.2 / 1.0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24),
                ),
                if (showLock)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
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

/// Helper widget for press & scale micro-animation
class _AnimatedPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressScale({required this.child, required this.onTap});

  @override
  State<_AnimatedPressScale> createState() => _AnimatedPressScaleState();
}

class _AnimatedPressScaleState extends State<_AnimatedPressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = PremiumGate.isPremium(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l10n.myCashbooks),
            subtitle: Text(l10n.manageCashbooks),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CashbooksScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(l10n.contacts),
            subtitle: Text(l10n.manageContacts),
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
            leading: const Icon(Symbols.category),
            title: Text(l10n.categories),
            subtitle: Text(l10n.manageCategories),
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
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(l10n.currencies),
            subtitle: Text(l10n.manageCurrencies),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrenciesListScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(l10n.english),
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
            leading: const Icon(Icons.font_download_outlined),
            title: const Text('Font Selection'),
            subtitle: Consumer(
              builder: (context, ref, child) {
                final font = ref.watch(currentFontProvider);
                return Text(font);
              },
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FontSelectorScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(l10n.theme),
            subtitle: Text(l10n.system),
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
            title: Row(
              children: [
                Text(l10n.backup),
                const SizedBox(width: 8),
                if (!isPremium)
                  const PremiumBadge(isSmall: true, showLock: true),
              ],
            ),
            subtitle: Text(l10n.googleDriveBackupRestore),
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
            leading: const Icon(Icons.message_outlined),
            title: Row(
              children: [
                Text(l10n.messageTemplates),
                const SizedBox(width: 8),
                if (!isPremium)
                  const PremiumBadge(isSmall: true, showLock: true),
              ],
            ),
            subtitle: Text(l10n.customizeMessageTemplates),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (!isPremium) {
                PremiumGate.showPremiumDialog(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageTemplatesScreen(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.downloadDataCsvPdf),
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
          // Premium List Item
          Container(
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
            child: ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.white),
              title: Text(
                l10n.premium,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isPremium ? l10n.premiumActive : l10n.free,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
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

class _SummaryItem {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final double? overdue;

  _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.overdue,
  });
}
// Force save to disk
