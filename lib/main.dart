import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flowpaisa/core/theme/app_theme.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/constants/app_constants.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/receipt_scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
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
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/settings/presentation/screens/language_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/font_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/theme_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/about_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/profile_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/messages/presentation/screens/message_templates_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/export_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/user_guide_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flowpaisa/core/utils/deep_link_handler.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/features/cashbooks/presentation/screens/cashbooks_screen.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

import 'package:flowpaisa/features/dashboard/presentation/widgets/sync_status_section.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/shared/widgets/entrance_animation.dart';
import 'package:flowpaisa/shared/widgets/animated_amount.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flowpaisa/features/transactions/data/schedule_scheduler.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flowpaisa/features/tour/presentation/providers/tour_provider.dart';
import 'package:flowpaisa/features/tour/domain/tour_service.dart';

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
    if (kDebugMode) {
      debugPrint('Firebase initialization skipped: $e');
    }
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

  // Initialize Sync Scheduler
  await SyncScheduler.init();
  await SyncScheduler.scheduleDailySync();

  runApp(
    Phoenix(
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const FlowpaisaApp(),
      ),
    ),
  );
}

/// Background task callback for workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Handle Sync Tasks
    if (task == syncTaskName || task.startsWith('on-demand-sync-')) {
      return await handleSyncTask(task, inputData);
    }

    // 2. Handle Schedule Tasks
    if (task == 'schedule-transactions') {
      await processSchedules();
      return Future.value(true);
    }

    return Future.value(false);
  });
}

Future<void> _initializeFonts() async {
  await GoogleFonts.pendingFonts([
    GoogleFonts.montserrat(),
    GoogleFonts.notoSansDevanagari(),
    GoogleFonts.marhey(),
    GoogleFonts.lalezar(),
    GoogleFonts.kufam(),
  ]);
}

class FlowpaisaApp extends ConsumerStatefulWidget {
  const FlowpaisaApp({super.key});

  @override
  ConsumerState<FlowpaisaApp> createState() => _FlowpaisaAppState();
}

class _FlowpaisaAppState extends ConsumerState<FlowpaisaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, refresh cloud state
      final backupNotifier = ref.read(backupProvider.notifier);
      backupNotifier.refreshCloudState();
    }
  }

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

        // Check if tour should be shown on first launch
        _checkAndShowTour();
      }
    });
  }

  Future<void> _checkAndShowTour() async {
    final tourNotifier = ref.read(tourNotifierProvider);
    if (!tourNotifier.isTourCompleted(tourNotifier.dashboardKey) && mounted) {
      // Wait a bit for UI to settle, then start tour
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _selectedIndex == 0) {
        // Only show tour if on dashboard tab
        try {
          final showcaseState = ShowCaseWidget.of(context);
          showcaseState.startShowCase(TourService.dashboardTourKeys);
        } catch (e) {
          debugPrint('Error starting tour: $e');
        }
      }
    }
  }

  Color _getSectionColor(int index) {
    final activeCashbook = ref.watch(activeCashbookProvider);
    switch (index) {
      case 0: // Dashboard
        return activeCashbook.foreColor(context);
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

    return ShowCaseWidget(
      enableAutoScroll: true,
      blurValue: 3,
      onStart: (index, key) {
        debugPrint('Tour step $index started');
      },
      onComplete: (index, key) {
        debugPrint('Tour step $index completed');
      },
      onFinish: () {
        debugPrint('Tour finished');
        // Mark dashboard tour as completed
        final tourNotifier = ref.read(tourNotifierProvider);
        tourNotifier.markTourCompleted(tourNotifier.dashboardKey);
      },
      builder: (context) => Scaffold(
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
                      if (index == 1) {
                        // Clear transactions filters and search when navigating via navigation rail
                        final notifier =
                            ref.read(transactionsPaginatedProvider.notifier);
                        notifier.search('');
                        notifier.applyFilters(TransactionFilters());
                      }
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
                    indicatorColor: _getSectionColor(_selectedIndex)
                        .withValues(alpha: 0.15),
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
                child: Consumer(
                  builder: (context, ref, child) {
                    final activeCashbook = ref.watch(activeCashbookProvider);
                    final activeColor = activeCashbook.color;
                    return Showcase(
                      key: TourService.bottomNavKey,
                      title: l10n.tourBottomNavTitle,
                      description: l10n.tourBottomNavDesc,
                      targetShapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      tooltipBackgroundColor: activeColor,
                      textColor: Colors.white,
                      targetBorderRadius: BorderRadius.circular(20),
                      child: NavigationBar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          if (index == 1) {
                            // Clear transactions filters and search when navigating via bottom bar
                            final notifier = ref
                                .read(transactionsPaginatedProvider.notifier);
                            notifier.search('');
                            notifier.applyFilters(TransactionFilters());

                            // Start transactions tour if not shown before
                            Future.delayed(const Duration(milliseconds: 800),
                                () {
                              if (context.mounted) {
                                final tourNotifier =
                                    ref.read(tourNotifierProvider);
                                if (!tourNotifier.isTourCompleted(
                                    tourNotifier.transactionsKey)) {
                                  TourService.startTransactionsTour(context);
                                  tourNotifier.markTourCompleted(
                                      tourNotifier.transactionsKey);
                                }
                              }
                            });
                          } else if (index == 2) {
                            // Start analytics tour if not shown before and premium is active
                            Future.delayed(const Duration(milliseconds: 800),
                                () {
                              if (context.mounted) {
                                final tourNotifier =
                                    ref.read(tourNotifierProvider);
                                final isPremium = PremiumGate.isPremium(ref);
                                if (!tourNotifier.isTourCompleted(
                                        tourNotifier.analyticsKey) &&
                                    isPremium) {
                                  TourService.startAnalyticsTour(context);
                                  tourNotifier.markTourCompleted(
                                      tourNotifier.analyticsKey);
                                }
                              }
                            });
                          } else if (index == 3) {
                            // Start settings tour if not shown before
                            Future.delayed(const Duration(milliseconds: 800),
                                () {
                              if (context.mounted) {
                                final tourNotifier =
                                    ref.read(tourNotifierProvider);
                                if (!tourNotifier.isTourCompleted(
                                    tourNotifier.settingsKey)) {
                                  TourService.startSettingsTour(context);
                                  tourNotifier.markTourCompleted(
                                      tourNotifier.settingsKey);
                                }
                              }
                            });
                          }
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
                  },
                ),
              )
            : null,
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
    final isPremium = PremiumGate.isPremium(ref);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;
    final activeIcon = activeCashbook.icon;
    final activeForeColor = activeCashbook.foreColor(context);

    // Watch dashboard statistics and filter
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final filter = ref.watch(dashboardFilterProvider);

    // Show loading if currency is not yet loaded
    if (currency == null) {
      return const AppLoadingIndicator(isFullPage: true, size: 80);
    }

    return Scaffold(
      body: RefreshIndicator(
        color: activeColor,
        onRefresh: () async {
          // Invalidate data providers to trigger a fresh fetch
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(transactionsWithDetailsProvider);
          ref.invalidate(currentCurrencyProvider);
          ref.invalidate(activeCashbookProvider);
          ref.invalidate(notificationProvider);

          // Refresh cloud sync status
          ref.read(backupProvider.notifier).refreshCloudState();

          // Wait for the main stats to load so the spinner stays visible until data is ready
          await ref.read(dashboardStatsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                      left: 8,
                      right: 8,
                      top: MediaQuery.of(context).padding.top,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Title & Cashbook Selector
                          Showcase(
                            key: TourService.dashboardHeaderKey,
                            title: l10n.tourDashboardHeaderTitle,
                            description: l10n.tourDashboardHeaderDesc,
                            targetShapeBorder: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            tooltipBackgroundColor: activeColor,
                            textColor: Colors.white,
                            targetBorderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CashbooksScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          textDirection: TextDirection.ltr,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/images/logo_square.svg',
                                                fit: BoxFit.contain,
                                                height: 40,
                                                colorFilter: ColorFilter.mode(
                                                    Color.lerp(
                                                            theme.colorScheme
                                                                .onSurface,
                                                            theme.colorScheme
                                                                .primary,
                                                            .5) ??
                                                        theme.colorScheme
                                                            .onSurface,
                                                    BlendMode.srcIn)),
                                            Transform.translate(
                                              offset: const Offset(-4, 0),
                                              child: Text(
                                                'lowpaisa',
                                                style: theme
                                                    .textTheme.displaySmall
                                                    ?.copyWith(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color.lerp(
                                                          theme.colorScheme
                                                              .onSurface,
                                                          theme.colorScheme
                                                              .primary,
                                                          .5) ??
                                                      theme.colorScheme
                                                          .onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          activeIcon,
                                          size: 14,
                                          color: activeForeColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          activeCashbook.name,
                                          style: TextStyle(
                                            color: activeForeColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                        if (isPremium) ...[
                                          const SizedBox(width: 4),
                                          const PremiumBadge(isSmall: true),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Balance Section
                          Showcase(
                            key: TourService.balanceKey,
                            title: l10n.tourBalanceTitle,
                            description: l10n.tourBalanceDesc,
                            targetShapeBorder: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            tooltipBackgroundColor: activeColor,
                            textColor: Colors.white,
                            targetBorderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.availableCash,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : AppColors.lightTextSecondary,
                                      fontWeight: FontWeight.w600,
                                      shadows: isDark
                                          ? AppTheme.textShadow(
                                              blurMultiplier: 1.0)
                                          : null,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      dashboardStatsAsync.when(
                                        data: (stats) => AnimatedAmount(
                                          amount: stats.totalBalance,
                                          currencySymbol: currency.symbol,
                                          decimalPlaces: currency.decimalPlaces,
                                          style: theme.textTheme.displaySmall
                                              ?.copyWith(
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.lightText,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                            fontSize:
                                                AmountFormatter.getFontSize(
                                                    stats.totalBalance,
                                                    baseSize: 32,
                                                    decimalPlaces:
                                                        currency.decimalPlaces),
                                            shadows: isDark
                                                ? AppTheme.textShadow(
                                                    blurMultiplier: 4.0)
                                                : null,
                                          ),
                                        ),
                                        loading: () => const SizedBox(
                                            height: 32,
                                            child:
                                                AppLoadingIndicator(size: 24)),
                                        error: (_, __) => Text(l10n.error,
                                            style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.error)),
                                      ),
                                      _buildFilterChip(
                                          context, ref, filter, isDark),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats Grid
                          dashboardStatsAsync.when(
                            data: (stats) => Column(
                              children: [
                                Showcase(
                                  key: TourService.cashFlowStatsKey,
                                  title: l10n.tourCashFlowTitle,
                                  description: l10n.tourCashFlowDesc,
                                  targetShapeBorder:
                                      const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  tooltipBackgroundColor: activeColor,
                                  textColor: Colors.white,
                                  targetBorderRadius: BorderRadius.circular(12),
                                  child: EntranceAnimation(
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
                                          onTap: () {
                                            final isMonthly = filter ==
                                                DashboardFilter.monthly;
                                            final now = DateTime.now();
                                            final startDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month, 1)
                                                : null;
                                            final endDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month + 1, 0)
                                                : null;

                                            ref
                                                .read(
                                                    transactionsPaginatedProvider
                                                        .notifier)
                                                .applyFilters(
                                                  TransactionFilters(
                                                    type: 'INCOME',
                                                    startDate: startDate,
                                                    endDate: endDate,
                                                  ),
                                                );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const TransactionsListScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        _SummaryItem(
                                          label: l10n.expense,
                                          amount: stats.expense(filter),
                                          color: AppColors.expenseColor,
                                          icon: Icons.north_east,
                                          onTap: () {
                                            final isMonthly = filter ==
                                                DashboardFilter.monthly;
                                            final now = DateTime.now();
                                            final startDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month, 1)
                                                : null;
                                            final endDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month + 1, 0)
                                                : null;

                                            ref
                                                .read(
                                                    transactionsPaginatedProvider
                                                        .notifier)
                                                .applyFilters(
                                                  TransactionFilters(
                                                    type: 'EXPENSE',
                                                    startDate: startDate,
                                                    endDate: endDate,
                                                  ),
                                                );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const TransactionsListScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        _SummaryItem(
                                          label: l10n.netCash,
                                          amount: stats.netCash(filter),
                                          color: activeForeColor,
                                          icon: Icons.account_balance_wallet,
                                          onTap: () {
                                            final isMonthly = filter ==
                                                DashboardFilter.monthly;
                                            final now = DateTime.now();
                                            final startDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month, 1)
                                                : null;
                                            final endDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month + 1, 0)
                                                : null;

                                            ref
                                                .read(
                                                    transactionsPaginatedProvider
                                                        .notifier)
                                                .applyFilters(
                                                  TransactionFilters(
                                                    startDate: startDate,
                                                    endDate: endDate,
                                                  ),
                                                );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const TransactionsListScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                      currency: currency,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Showcase(
                                  key: TourService.lendingStatsKey,
                                  title: l10n.tourLendingTitle,
                                  description: l10n.tourLendingDesc,
                                  targetShapeBorder:
                                      const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  tooltipBackgroundColor: activeColor,
                                  textColor: Colors.white,
                                  targetBorderRadius: BorderRadius.circular(12),
                                  child: EntranceAnimation(
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
                                          onTap: () {
                                            final isMonthly = filter ==
                                                DashboardFilter.monthly;
                                            final now = DateTime.now();
                                            final startDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month, 1)
                                                : null;
                                            final endDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month + 1, 0)
                                                : null;

                                            ref
                                                .read(
                                                    receivablesPaginatedProvider(
                                                            'PENDING')
                                                        .notifier)
                                                .applyFilters(
                                                  ReceivableFilters(
                                                    startDate: startDate,
                                                    endDate: endDate,
                                                  ),
                                                );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ReceivablesListScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        _SummaryItem(
                                          label: l10n.payableTag,
                                          amount: stats.payable(filter),
                                          color: AppColors.payableColor,
                                          icon: Icons.call_made,
                                          overdue: stats.overduePayable,
                                          onTap: () {
                                            final isMonthly = filter ==
                                                DashboardFilter.monthly;
                                            final now = DateTime.now();
                                            final startDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month, 1)
                                                : null;
                                            final endDate = isMonthly
                                                ? DateTime(
                                                    now.year, now.month + 1, 0)
                                                : null;

                                            ref
                                                .read(payablesPaginatedProvider(
                                                        'PENDING')
                                                    .notifier)
                                                .applyFilters(
                                                  PayableFilters(
                                                    startDate: startDate,
                                                    endDate: endDate,
                                                  ),
                                                );

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PayablesListScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        _SummaryItem(
                                          label: l10n.netCredit,
                                          amount: stats.netCredit(filter),
                                          color: activeForeColor,
                                          icon: Icons.swap_horiz,
                                        ),
                                      ],
                                      currency: currency,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                            loading: () => const SizedBox(height: 100),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 20),
                          // App Logo in Rounded Circle
                          Center(
                            child: EntranceAnimation(
                              index: 3,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: activeColor.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  'assets/images/logo_square.svg',
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    activeColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                    final deltaExtent =
                        settings!.maxExtent - settings.minExtent;
                    final t = (1.0 -
                            (settings.currentExtent - settings.minExtent) /
                                deltaExtent)
                        .clamp(0.0, 1.0);

                    if (t < 0.8) return const SizedBox.shrink();

                    return FadeTransition(
                      opacity: AlwaysStoppedAnimation(t),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top:
                                40), // Added top padding to push it down to middle
                        child: Container(
                          alignment: AlignmentDirectional.centerStart,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            textDirection: TextDirection.ltr,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset('assets/images/logo_square.svg',
                                  height: 24,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                      Color.lerp(theme.colorScheme.onSurface,
                                              theme.colorScheme.primary, .3) ??
                                          theme.colorScheme.onSurface,
                                      BlendMode.srcIn)),
                              Transform.translate(
                                offset: const Offset(-2, 0),
                                child: Text(
                                  'lowpaisa',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color.lerp(
                                            theme.colorScheme.onSurface,
                                            theme.colorScheme.primary,
                                            .3) ??
                                        theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final notifications = ref.watch(notificationProvider);
                    final unreadCount =
                        notifications.where((n) => (n.isRead == false)).length;
                    final hasUrgent = notifications.any(
                        (n) => (n.isRead == false) && (n.isUrgent == true));

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            unreadCount > 0
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: hasUrgent
                                    ? AppColors.error
                                    : theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (hasUrgent)
                                    BoxShadow(
                                      color: AppColors.error
                                          .withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Dismiss any active showcase overlay before restarting
                    try {
                      final showcaseState = ShowCaseWidget.of(context);
                      showcaseState.dismiss();
                    } catch (e) {
                      // Showcase might not be active, ignore
                      if (kDebugMode) {
                        debugPrint('No active showcase to dismiss: $e');
                      }
                    }

                    // Use post-frame callback to ensure showcase is dismissed before restart
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Phoenix.rebirth re-initializes the entire application
                      // including all Riverpod providers and database connections.
                      Phoenix.rebirth(context);
                    });
                  },
                  tooltip: 'Restart App',
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
                const SizedBox(width: 4),
              ],
            ),

            // Quick Actions Section
            SliverToBoxAdapter(
              child: Showcase(
                key: TourService.quickActionsKey,
                title: l10n.tourQuickActionsTitle,
                description: l10n.tourQuickActionsDesc,
                targetShapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                tooltipBackgroundColor: activeColor,
                textColor: Colors.white,
                targetBorderRadius: BorderRadius.circular(20),
                child: EntranceAnimation(
                  index: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      children: [
                        // Sync Status Section
                        const SyncStatusSection(),
                        const SizedBox(height: 16),
                        _buildPrivacyHighlight(context, ref, l10n, isDark),
                        const SizedBox(height: 16),
                        _buildQuickActions(context, ref, l10n, isPremium),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Recent Transactions Header
            SliverToBoxAdapter(
              child: EntranceAnimation(
                index: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: _buildRecentTransactionsHeader(context, l10n),
                ),
              ),
            ),
            // Recent Transactions List
            SliverToBoxAdapter(
              child: Showcase(
                key: TourService.recentTransactionsKey,
                title: l10n.tourRecentTransactionsTitle,
                description: l10n.tourRecentTransactionsDesc,
                targetShapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                tooltipBackgroundColor: activeColor,
                textColor: Colors.white,
                targetBorderRadius: BorderRadius.circular(16),
                child: EntranceAnimation(
                  index: 5,
                  child: _buildRecentTransactions(context, ref),
                ),
              ),
            ),
            // Bottom Padding with Logo
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Opacity(
                    opacity: 0.1,
                    child: SvgPicture.asset(
                      'assets/images/logo_square.svg',
                      height: 60,
                      colorFilter: ColorFilter.mode(
                        activeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // Add an empty sliver to ensure the scroll view is always scrollable
            // This allows pull-to-refresh to work even when there's little content
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref,
      DashboardFilter currentFilter, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeForeColor = activeCashbook.foreColor(context);
    final isMonthly = currentFilter == DashboardFilter.monthly;
    final label = isMonthly
        ? AppDateFormatter.formatMonth(DateTime.now(), context: context)
        : l10n.all;
    final icon = isMonthly ? Icons.calendar_today : Icons.all_inclusive;

    return ActionChip(
      color: WidgetStateProperty.all(activeCashbook.color.withAlpha(50)),
      label: Row(
        children: [
          Icon(icon, size: 16, color: activeForeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: activeForeColor,
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
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(12),
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacyHighlight(
      BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isDark) {
    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeForeColor = activeCashbook.foreColor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activeCashbook.color.withValues(alpha: 0.15),
            activeCashbook.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeCashbook.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeCashbook.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security_rounded,
              color: activeForeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacyHighlight,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: activeForeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.privacyHighlightDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildQuickActions(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, bool isPremium) {
    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          // Grid layout for quick actions (responsive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
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
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _QuickActionButton(
                      icon: Icons.add,
                      label: l10n.add,
                      gradient: AppColors.getPrimaryGradient(
                          theme.colorScheme.primary),
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
                        // Clear filters and search before navigating
                        final pendingNotifier = ref.read(
                            receivablesPaginatedProvider('PENDING').notifier);
                        pendingNotifier.updateSearchQuery('');
                        pendingNotifier.applyFilters(ReceivableFilters());

                        final overdueNotifier = ref.read(
                            receivablesPaginatedProvider('OVERDUE').notifier);
                        overdueNotifier.updateSearchQuery('');
                        overdueNotifier.applyFilters(ReceivableFilters());

                        final receivedNotifier = ref.read(
                            receivablesPaginatedProvider('RECEIVED').notifier);
                        receivedNotifier.updateSearchQuery('');
                        receivedNotifier.applyFilters(ReceivableFilters());

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
                        // Clear filters and search before navigating
                        final pendingNotifier = ref.read(
                            payablesPaginatedProvider('PENDING').notifier);
                        pendingNotifier.updateSearchQuery('');
                        pendingNotifier.applyFilters(PayableFilters());

                        final overdueNotifier = ref.read(
                            payablesPaginatedProvider('OVERDUE').notifier);
                        overdueNotifier.updateSearchQuery('');
                        overdueNotifier.applyFilters(PayableFilters());

                        final paidNotifier = ref
                            .read(payablesPaginatedProvider('PAID').notifier);
                        paidNotifier.updateSearchQuery('');
                        paidNotifier.applyFilters(PayableFilters());

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
                    _QuickActionButton(
                      icon: Icons.help_outline_rounded,
                      label: l10n.userGuide,
                      gradient: AppColors.getSecondaryGradient(
                          theme.colorScheme.secondary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserGuideScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionButton(
                      icon: Icons.tour_outlined,
                      label: l10n.appTour,
                      gradient: AppColors.getPrimaryGradient(activeColor),
                      onTap: () {
                        // Start the dashboard tour
                        try {
                          final showcaseState = ShowCaseWidget.of(context);
                          showcaseState
                              .startShowCase(TourService.dashboardTourKeys);
                        } catch (e) {
                          debugPrint('Error starting tour: $e');
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader(
      BuildContext context, AppLocalizations l10n) {
    return Row(
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
                    builder: (context) => TransactionDetailsDialog(
                        transactionUuid: transaction.uuid),
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
      loading: () => const AppLoadingIndicator(size: 60),
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
    final theme = Theme.of(context);
    final isPremium = PremiumGate.isPremium(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          Showcase(
            key: TourService.settingsProfileKey,
            title: l10n.tourSettingsProfileTitle,
            description: l10n.tourSettingsProfileDesc,
            targetShapeBorder: const CircleBorder(),
            tooltipBackgroundColor: theme.colorScheme.primary,
            textColor: theme.colorScheme.onPrimary,
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Showcase(
            key: TourService.settingsAppPreferencesKey,
            title: l10n.tourSettingsAppPreferencesTitle,
            description: l10n.tourSettingsAppPreferencesDesc,
            targetShapeBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            tooltipBackgroundColor: theme.colorScheme.primary,
            textColor: theme.colorScheme.onPrimary,
            child: Column(
              children: [
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
              ],
            ),
          ),
          const Divider(),
          Showcase(
            key: TourService.settingsBackupKey,
            title: l10n.tourSettingsBackupTitle,
            description: l10n.tourSettingsBackupDesc,
            targetShapeBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            tooltipBackgroundColor: theme.colorScheme.primary,
            textColor: theme.colorScheme.onPrimary,
            child: ListTile(
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
          ),
          const Divider(),
          Showcase(
            key: TourService.settingsPremiumKey,
            title: l10n.tourSettingsPremiumTitle,
            description: l10n.tourSettingsPremiumDesc,
            targetShapeBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            tooltipBackgroundColor: theme.colorScheme.primary,
            textColor: theme.colorScheme.onPrimary,
            child: Container(
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
                leading:
                    const Icon(Icons.workspace_premium, color: Colors.white),
                title: Text(
                  l10n.premium,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  l10n.unlockAdvancedAnalytics,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onTap: () {
                  PremiumGate.showPremiumDialog(context);
                },
              ),
            ),
          ),
          const Divider(),
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
  final VoidCallback? onTap;

  _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.overdue,
    this.onTap,
  });
}
// Force save to disk
