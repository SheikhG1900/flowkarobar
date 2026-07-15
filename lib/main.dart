import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
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
import 'package:flowpaisa/features/settings/presentation/screens/dev_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/profile_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/messages/presentation/screens/message_templates_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/export_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/user_guide_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flowpaisa/core/services/in_app_review_service.dart';
import 'package:flowpaisa/core/utils/deep_link_handler.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/shared/widgets/user_avatar.dart';
import 'package:flowpaisa/features/cashbooks/presentation/screens/cashbooks_screen.dart';
import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flowpaisa/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/data/credit_card_notification_service.dart';

import 'package:flowpaisa/features/dashboard/presentation/widgets/sync_status_section.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/widgets/dashboard_entity_widget_card.dart';
import 'package:flowpaisa/features/dashboard/presentation/widgets/dashboard_summary_widget_card.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_hero_combine_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/widgets/dashboard_hero_combine_sheet.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/shared/widgets/entrance_animation.dart';
import 'package:flowpaisa/shared/widgets/animated_amount.dart';
import 'package:flowpaisa/shared/widgets/rolling_amount.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/features/transactions/data/schedule_scheduler.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';

import 'package:flowpaisa/core/services/update_service.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowpaisa/features/voice_command/presentation/screens/voice_add_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Edge-to-Edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Default for light mode
      statusBarBrightness: Brightness.light, // Default for iOS light mode
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
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

    // Check for in-app updates on startup (Android and Windows)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        ref.read(updateServiceProvider).checkForUpdate();
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        ref.read(updateServiceProvider).checkForWindowsUpdate(context, ref);
      }
    });
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
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (kIsWeb || !Platform.isWindows) return child!;
        
        // Always use a dark ambient background to create a theater-like cinematic experience
        // matching the gorgeous dark theme, even when the app itself is in light mode.
        final ambientColor = activeColor.withValues(alpha: 0.05);
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF121212),
                ambientColor,
                const Color(0xFF1E1E1E),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Left Logo Watermark
              Positioned(
                left: -80,
                bottom: 100,
                child: Opacity(
                  opacity: 0.03,
                  child: SvgPicture.asset(
                    'assets/images/logo_square.svg',
                    height: 280,
                    colorFilter: ColorFilter.mode(
                      activeColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              // Right Logo Watermark
              Positioned(
                right: -80,
                top: 100,
                child: Opacity(
                  opacity: 0.03,
                  child: SvgPicture.asset(
                    'assets/images/logo_square.svg',
                    height: 280,
                    colorFilter: ColorFilter.mode(
                      activeColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              // Central App Container
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 36,
                        spreadRadius: 4,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },

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
      home: onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static Future<void> showQuickActionSelectionSheetForBottomBar(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      AppLocalizations l10n) async {
    final actions = [
      ('voice_add', l10n.voiceAdd, Icons.mic_none_rounded),
      ('add_transaction', l10n.add, Icons.add),
      if (!Platform.isWindows)
        ('scan_receipt', l10n.scan, Icons.document_scanner_outlined),
      (
        'accounts',
        l10n.accounts,
        Platform.isWindows ? Icons.account_balance : Icons.account_balance
      ),
      ('contacts', l10n.contacts, Icons.people_outline_rounded),
      (
        'receivables',
        l10n.receivableTag,
        Platform.isWindows
            ? Icons.account_balance_wallet
            : Icons.account_balance_wallet
      ),
      ('payables', l10n.payables, Icons.payment_outlined),
      ('categories', l10n.categories, Icons.category_outlined),
      ('analytics', l10n.analytics, Icons.bar_chart_rounded),
      ('user_guide', l10n.userGuide, Icons.help_outline_rounded),
      ('app_tour', l10n.appTour, Icons.tour_outlined),
    ];

    final currentCode = ref.read(bottomBarQuickActionProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.quickActions,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: actions.map((e) {
                  return ListTile(
                    leading: Icon(e.$3),
                    title: Text(e.$2),
                    trailing:
                        currentCode == e.$1 ? const Icon(Icons.check) : null,
                    onTap: () {
                      ref
                          .read(bottomBarQuickActionProvider.notifier)
                          .setAction(e.$1);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSwitchingCashbook = false;
  Timer? _cashbookSwitchRevealTimer;

  /// Hold dimmed UI while the new cashbook DB and dashboard providers repopulate.
  static const Duration _cashbookSwitchHold = Duration(milliseconds: 1200);

  /// Fade between full brightness and the dimmed “switching” state.
  static const Duration _cashbookSwitchFade = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    // Initialize deep link handler after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final deepLinkHandler = ref.read(deepLinkHandlerProvider);
        deepLinkHandler.initialize(context, ref);

        // Check credit card payment due dates
        _checkCreditCardNotifications();

        // Process scheduled transactions (catch-up)
        // Add a delay to ensure the app is fully interactive before heavy processing
        Future.delayed(const Duration(seconds: 3), () {
          processSchedulesFromContext(ref);
        });
      }
    });
  }

  @override
  void dispose() {
    _cashbookSwitchRevealTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkCreditCardNotifications() async {
    try {
      final accountsRepo = ref.read(accountsRepositoryProvider);
      final notifier = ref.read(notificationProvider.notifier);
      final currencySymbol = ref.read(currencySymbolProvider);
      final decimals = ref.read(currencyDecimalPlacesProvider);

      final activeCashbook = ref.read(activeCashbookProvider);
      final service = CreditCardNotificationService(accountsRepo);
      await service.checkAndNotify(
        currencySymbol: currencySymbol,
        decimals: decimals,
        addNotification: ({
          required String title,
          required String message,
          required NotificationType type,
          required bool isUrgent,
          String? cashbookUuid,
          String? entityId,
          String? titleKey,
          String? messageKey,
          Map<String, String>? parameters,
        }) {
          notifier.addNotification(
            title: title,
            message: message,
            type: type,
            isUrgent: isUrgent,
            cashbookUuid: cashbookUuid ?? activeCashbook.id,
            entityId: entityId,
            titleKey: titleKey,
            messageKey: messageKey,
            parameters: parameters,
          );
        },
      );
    } catch (e) {
      debugPrint('Credit card notification check failed: $e');
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

    // Listen to active cashbook changes: dull UI briefly, then reveal
    ref.listen(activeCashbookIdProvider, (_, __) {
      if (!mounted) return;
      _cashbookSwitchRevealTimer?.cancel();
      setState(() {
        _isSwitchingCashbook = true;
      });
      _cashbookSwitchRevealTimer = Timer(_cashbookSwitchHold, () {
        if (!mounted) return;
        // One frame after hold: let the new cashbook tree paint with fresh data, then fade in.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _isSwitchingCashbook = false;
          });
        });
      });
    });

    ref.listen<BackupState>(backupProvider, (previous, next) {
      if (next.premiumExpiredLogout &&
          !(previous?.premiumExpiredLogout ?? false)) {
        // Clear flag
        ref.read(backupProvider.notifier).clearPremiumExpiredLogout();

        // Show dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.premiumRequired,
                    softWrap: true,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(l10n.premiumExpiredSyncPaused),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.understood),
              ),
            ],
          ),
        );
      }
    });

    // Different screens for each tab
    final List<Widget> screens = [
      _DashboardTab(),
      const TransactionsListScreen(),
      const AnalyticsScreen(),
      _SettingsTab(),
    ];

    return Scaffold(
      extendBody: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile Layout — dull + loading overlay while switching cashbooks
            return Stack(
              children: [
                AnimatedOpacity(
                  duration: _cashbookSwitchFade,
                  opacity: _isSwitchingCashbook ? 0.3 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isSwitchingCashbook,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
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
                    ),
                  ),
                ),
                if (_isSwitchingCashbook)
                  const Center(
                    child: AppLoadingIndicator(size: 60),
                  ),
              ],
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
                    // Unfocus before tab switch to avoid FocusScope assertion
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: Consumer(
                    builder: (context, ref, child) {
                      final showQuickButton =
                          ref.watch(showBottomBarQuickButtonProvider);
                      if (!showQuickButton) return const SizedBox.shrink();

                      final activeCashbook = ref.watch(activeCashbookProvider);
                      final activeColor = activeCashbook.color;
                      final quickActionCode =
                          ref.watch(bottomBarQuickActionProvider);
                      final isPremium = PremiumGate.isPremium(ref);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildCenterQuickButton(
                          context,
                          ref,
                          quickActionCode,
                          isPremium,
                          l10n,
                          activeColor,
                        ),
                      );
                    },
                  ),
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: _cashbookSwitchFade,
                        opacity: _isSwitchingCashbook ? 0.3 : 1.0,
                        child: IgnorePointer(
                          ignoring: _isSwitchingCashbook,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child: KeyedSubtree(
                              key: ValueKey<int>(_selectedIndex),
                              child: screens[_selectedIndex],
                            ),
                          ),
                        ),
                      ),
                      if (_isSwitchingCashbook)
                        const AppLoadingIndicator(size: 60),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? Consumer(
              builder: (context, ref, child) {
                final activeCashbook = ref.watch(activeCashbookProvider);
                final activeColor = activeCashbook.color;
                final quickActionCode = ref.watch(bottomBarQuickActionProvider);
                final isPremium = PremiumGate.isPremium(ref);
                final showQuickButton =
                    ref.watch(showBottomBarQuickButtonProvider);

                return BottomAppBar(
                  padding: EdgeInsets.zero,
                  height: 80,
                  notchMargin: 8.0,
                  shape:
                      showQuickButton ? const CircularNotchedRectangle() : null,
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 2,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      navigationBarTheme: NavigationBarThemeData(
                        backgroundColor: Colors.transparent,
                        indicatorColor: _selectedIndex == -1
                            ? Colors.transparent
                            : _getSectionColor(_selectedIndex)
                                .withValues(alpha: 0.15),
                        iconTheme: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return IconThemeData(
                                color: _selectedIndex == -1
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : _getSectionColor(_selectedIndex));
                          }
                          return IconThemeData(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          );
                        }),
                        labelTextStyle:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return TextStyle(
                              color: _selectedIndex == -1
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                  : _getSectionColor(_selectedIndex),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            );
                          }
                          return TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          );
                        }),
                      ),
                    ),
                    child: NavigationBar(
                      selectedIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
                      onDestinationSelected: (index) {
                        if (index == 1) {
                          final notifier =
                              ref.read(transactionsPaginatedProvider.notifier);
                          notifier.search('');
                          notifier.applyFilters(TransactionFilters());
                        }
                        FocusManager.instance.primaryFocus?.unfocus();
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
                  ),
                );
              },
            )
          : null,
      floatingActionButton: MediaQuery.of(context).size.width < 600
          ? Consumer(
              builder: (context, ref, child) {
                final showQuickButton =
                    ref.watch(showBottomBarQuickButtonProvider);
                if (!showQuickButton) return const SizedBox.shrink();

                final activeCashbook = ref.watch(activeCashbookProvider);
                final activeColor = activeCashbook.color;
                final quickActionCode = ref.watch(bottomBarQuickActionProvider);
                final isPremium = PremiumGate.isPremium(ref);
                final reorderMode = ref.watch(dashboardReorderModeProvider);
                final theme = Theme.of(context);

                final button = _buildCenterQuickButton(
                  context,
                  ref,
                  quickActionCode,
                  isPremium,
                  l10n,
                  activeColor,
                );

                if (reorderMode) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      button,
                      PositionedDirectional(
                        top: -8,
                        start: -8,
                        child: GestureDetector(
                          onTap: () => _DashboardTab
                              .showQuickActionSelectionSheetForBottomBar(
                                  context, ref, Theme.of(context), l10n),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: -8,
                        end: -8,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(showBottomBarQuickButtonProvider.notifier)
                              .setVisibility(false),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return button;
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCenterQuickButton(
    BuildContext context,
    WidgetRef ref,
    String code,
    bool isPremium,
    AppLocalizations l10n,
    Color activeColor,
  ) {
    final theme = Theme.of(context);

    IconData icon;
    VoidCallback onTap;

    switch (code) {
      case 'voice_add':
        icon = Icons.mic_none_rounded;
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => VoiceAddScreen()));
        break;
      case 'scan_receipt':
        icon = Icons.document_scanner_outlined;
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ScanReceiptScreen()));
        break;
      case 'accounts':
        icon = Symbols.account_balance;
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AccountsScreen()));
        break;
      case 'contacts':
        icon = Icons.people_outline_rounded;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ContactsListScreen()));
        break;
      case 'receivables':
        icon = Symbols.account_balance_wallet;
        onTap = () {
          ref
              .read(receivablesPaginatedProvider('PENDING').notifier)
              .applyFilters(ReceivableFilters());
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReceivablesListScreen()));
        };
        break;
      case 'payables':
        icon = Icons.payment_outlined;
        onTap = () {
          ref
              .read(payablesPaginatedProvider('PENDING').notifier)
              .applyFilters(PayableFilters());
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PayablesListScreen()));
        };
        break;
      case 'categories':
        icon = Icons.category_outlined;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CategoriesListScreen()));
        break;
      case 'analytics':
        icon = Icons.bar_chart_rounded;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
        break;
      case 'add_transaction':
      default:
        icon = Icons.add;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        break;
    }

    return GestureDetector(
      onLongPress: () => HomeScreen.showQuickActionSelectionSheetForBottomBar(
          context, ref, theme, l10n),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: activeColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  static Future<void> showQuickActionSelectionSheetForBottomBar(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      AppLocalizations l10n) async {
    await _DashboardTab.showQuickActionSelectionSheetForBottomBar(
        context, ref, theme, l10n);
  }
}

// Placeholder tabs

/// Dashboard scroll area; tracks top overscroll to reveal the large logo.
class _DashboardBodyScroll extends ConsumerStatefulWidget {
  const _DashboardBodyScroll({
    super.key,
    required this.activeColor,
    required this.showWidgetArea,
  });

  final Color activeColor;
  final bool showWidgetArea;

  @override
  ConsumerState<_DashboardBodyScroll> createState() =>
      _DashboardBodyScrollState();
}

class _DashboardBodyScrollState extends ConsumerState<_DashboardBodyScroll> {
  /// Pull distance (px) to fully reveal the logo (matches header slot height).
  static const double _kLogoRevealMax = 118.0;

  /// Extra distance (px) user must drag BEFORE the logo starts to reveal.
  static const double _kLogoRevealThreshold = 20.0;

  double _logoRevealPull = 0.0;
  final ValueNotifier<double> _logoRevealNotifier = ValueNotifier<double>(0.0);

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;

    // Calculate how much the user has overscrolled
    final overscroll = n.metrics.pixels < 0 ? -n.metrics.pixels : 0.0;

    // Only start revealing the logo after passing the threshold
    final next = overscroll > _kLogoRevealThreshold
        ? (overscroll - _kLogoRevealThreshold).clamp(0.0, _kLogoRevealMax)
        : 0.0;

    if (next != _logoRevealNotifier.value) {
      _logoRevealNotifier.value = next;
    }
    return false;
  }

  @override
  void dispose() {
    _logoRevealNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: RefreshIndicator(
        color: widget.activeColor,
        onRefresh: () async {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Phoenix.rebirth(context);
          });

          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          clipBehavior: Clip.hardEdge,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            ValueListenableBuilder<double>(
              valueListenable: _logoRevealNotifier,
              builder: (context, value, child) {
                return _DashboardHeader(logoRevealPull: value);
              },
            ),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, child) {
                  final activeColor =
                      ref.watch(activeCashbookProvider.select((c) => c.color));
                  final showPrivacyHighlight =
                      ref.watch(showDashboardPrivacyHighlightProvider);
                  return EntranceAnimation(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Consumer(
                            builder: (context, ref, child) {
                              final showSync =
                                  ref.watch(showDashboardSyncStatusProvider);
                              if (!showSync) {
                                return const SizedBox.shrink();
                              }
                              return const SyncStatusSection();
                            },
                          ),
                          if (showPrivacyHighlight) ...[
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: ref.watch(dashboardReorderModeProvider)
                                  ? _DashboardTab.wrapCard(
                                      child: const _DashboardPrivacyHighlight(),
                                      onRemove: () => ref
                                          .read(
                                              showDashboardPrivacyHighlightProvider
                                                  .notifier)
                                          .setVisibility(false),
                                    )
                                  : const _DashboardPrivacyHighlight(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.showWidgetArea)
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final layoutAsync =
                        ref.watch(effectiveDashboardWidgetLayoutProvider);
                    final reorderMode = ref.watch(dashboardReorderModeProvider);
                    final theme = Theme.of(context);
                    final l10n = AppLocalizations.of(context)!;
                    return layoutAsync.when(
                      data: (configs) =>
                          _DashboardTab._buildDashboardWidgetsSection(
                              context, ref, theme, l10n, configs, reorderMode),
                      loading: () {
                        final configs =
                            ref.read(dashboardWidgetLayoutProvider).value;
                        if (configs == null || configs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _DashboardTab._buildDashboardWidgetsSection(
                            context, ref, theme, l10n, configs, reorderMode);
                      },
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: EntranceAnimation(
                index: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Builder(
                    builder: (context) => _DashboardRecentTransactionsHeader(
                      l10n: AppLocalizations.of(context)!,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: _DashboardRecentTransactionsSection(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeColor =
        ref.watch(activeCashbookProvider.select((c) => c.color));
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final showWidgetArea = ref.watch(showDashboardWidgetAreaProvider);

    if (currency == null) {
      return const AppLoadingIndicator(isFullPage: true, size: 80);
    }

    return _DashboardBodyScroll(
      activeColor: activeColor,
      showWidgetArea: showWidgetArea,
    );
  }

  static Future<void> showQuickActionSelectionSheetForBottomBar(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      AppLocalizations l10n) async {
    final actions = [
      ('voice_add', l10n.voiceAdd, Icons.mic_none_rounded),
      ('add_transaction', l10n.add, Icons.add),
      if (!Platform.isWindows)
        ('scan_receipt', l10n.scan, Icons.document_scanner_outlined),
      (
        'accounts',
        l10n.accounts,
        Platform.isWindows ? Icons.account_balance : Icons.account_balance
      ),
      ('contacts', l10n.contacts, Icons.people_outline_rounded),
      (
        'receivables',
        l10n.receivableTag,
        Platform.isWindows
            ? Icons.account_balance_wallet
            : Icons.account_balance_wallet
      ),
      ('payables', l10n.payables, Icons.payment_outlined),
      ('categories', l10n.categories, Icons.category_outlined),
      ('analytics', l10n.analytics, Icons.bar_chart_rounded),
      ('user_guide', l10n.userGuide, Icons.help_outline_rounded),
      ('app_tour', l10n.appTour, Icons.tour_outlined),
    ];

    final currentCode = ref.read(bottomBarQuickActionProvider);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.quickActions,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: actions.map((e) {
                  return ListTile(
                    leading: Icon(e.$3),
                    title: Text(e.$2),
                    trailing:
                        currentCode == e.$1 ? const Icon(Icons.check) : null,
                    onTap: () {
                      ref
                          .read(bottomBarQuickActionProvider.notifier)
                          .setAction(e.$1);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }

  static Widget wrapCard({required Widget child, VoidCallback? onRemove}) {
    if (onRemove == null) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -10,
          end: -10,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildDashboardWidgetsSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    List<DashboardWidgetConfig> configs,
    bool reorderMode,
  ) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reorderMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.onDashboard,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: theme.colorScheme.primary,
                        tooltip: l10n.reorderWidgetsOff,
                        onPressed: () {
                          ref
                              .read(dashboardVisibilityProvider.notifier)
                              .setVisibility(DashboardVisibility.visible);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.checklist_rtl_outlined),
                        tooltip: l10n.addToDashboard,
                        onPressed: () =>
                            _showAddWidgetSheet(context, ref, theme, l10n),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (configs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        size: 48,
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noWidgetsOnDashboard,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            _showAddWidgetSheet(context, ref, theme, l10n),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addToDashboard),
                      ),
                    ],
                  ),
                ),
              )
            else
              reorderMode
                  ? ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex--;
                        ref
                            .read(dashboardWidgetLayoutProvider.notifier)
                            .reorder(oldIndex, newIndex);
                      },
                      children: [
                        for (var i = 0; i < configs.length; i++)
                          KeyedSubtree(
                            key: configs[i].kind.isEntity
                                ? ValueKey('entity-${configs[i].entityUuid}')
                                : ValueKey('summary-${configs[i].kind.name}'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReorderableDragStartListener(
                                  index: i,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 8, top: 16),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.drag_handle,
                                        color: theme.colorScheme.onPrimary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: configs[i].kind.isEntity
                                      ? DashboardEntityWidgetCard(
                                          config: configs[i],
                                          layoutIndex: i,
                                        )
                                      : DashboardSummaryWidgetCard(
                                          config: configs[i],
                                          layoutIndex: i,
                                          reorderKey: ValueKey(
                                              'summary-${configs[i].kind.name}'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < configs.length; i++)
                          configs[i].kind.isEntity
                              ? DashboardEntityWidgetCard(
                                  config: configs[i],
                                  layoutIndex: i,
                                )
                              : DashboardSummaryWidgetCard(
                                  config: configs[i],
                                  layoutIndex: i,
                                  reorderKey: ValueKey(
                                      'summary-${configs[i].kind.name}'),
                                ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  static void _showAddWidgetSheet(BuildContext context, WidgetRef ref,
      ThemeData theme, AppLocalizations l10n) {
    final summaryKinds = [
      (
        DashboardWidgetKind.balance,
        l10n.availableCash,
        Icons.account_balance_wallet_outlined
      ),
      (DashboardWidgetKind.cashFlow, l10n.cashFlow, Icons.trending_up),
      (
        DashboardWidgetKind.netCredit,
        l10n.netCredit,
        Icons.account_balance_wallet_outlined
      ),
      (DashboardWidgetKind.incomeSummary, l10n.income, Icons.trending_up),
      (DashboardWidgetKind.expenseSummary, l10n.expense, Icons.trending_down),
      (
        DashboardWidgetKind.receivablesSummary,
        l10n.receivableTag,
        Icons.call_received
      ),
      (DashboardWidgetKind.payablesSummary, l10n.payableTag, Icons.call_made),
      (
        DashboardWidgetKind.contactsSummary,
        l10n.contacts,
        Icons.people_outline
      ),
      (
        DashboardWidgetKind.categoriesSummary,
        l10n.categories,
        Icons.category_outlined
      ),
      (DashboardWidgetKind.netWorth, l10n.netWorth, Icons.pie_chart_outline),
      (
        DashboardWidgetKind.financialSummary,
        l10n.financialSummary,
        Icons.summarize_outlined
      ),
      (
        DashboardWidgetKind.quickActions,
        l10n.quickActions,
        Icons.grid_view_rounded
      ),
      (
        DashboardWidgetKind.accountsSlider,
        l10n.accounts,
        Symbols.account_balance
      ),
      (DashboardWidgetKind.cashbooksSlider, l10n.cashbooks, Symbols.book),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final layoutAsync = ref.watch(dashboardWidgetLayoutProvider);
            final configs = layoutAsync.value ?? defaultDashboardWidgetLayout;
            final showPrivacy =
                ref.watch(showDashboardPrivacyHighlightProvider);
            final showFinancial =
                ref.watch(showDashboardFinancialSummaryProvider);

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      l10n.onDashboard,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Widgets Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      l10n.widgets,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: summaryKinds.map((e) {
                        final checked = configs.any((c) => c.kind == e.$1);
                        final busy = layoutAsync.isLoading;

                        return FilterChip(
                          label: Text(e.$2),
                          avatar: Icon(
                            e.$3,
                            size: 16,
                            color: checked
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          selected: checked,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: checked
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight:
                                checked ? FontWeight.bold : FontWeight.normal,
                          ),
                          selectedColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          side: BorderSide(
                            color: checked
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                            width: checked ? 2 : 1,
                          ),
                          onSelected: busy
                              ? null
                              : (v) async {
                                  await ref
                                      .read(dashboardWidgetLayoutProvider
                                          .notifier)
                                      .setSummaryKindOnDashboard(e.$1, v);
                                },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Others Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      l10n.others,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.security_outlined,
                      color: showPrivacy
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      l10n.privacyHighlight,
                      style: TextStyle(
                        color: showPrivacy
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: showPrivacy,
                    onChanged: (v) {
                      ref
                          .read(showDashboardPrivacyHighlightProvider.notifier)
                          .setVisibility(v);
                    },
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.summarize_outlined,
                      color: showFinancial
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      l10n.financialSummary,
                      style: TextStyle(
                        color: showFinancial
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: showFinancial,
                    onChanged: (v) {
                      ref
                          .read(showDashboardFinancialSummaryProvider.notifier)
                          .setVisibility(v);
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final showQuickButton =
                          ref.watch(showBottomBarQuickButtonProvider);
                      return SwitchListTile(
                        secondary: Icon(
                          Icons.add_circle_outline,
                          color: showQuickButton
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          l10n.showQuickActionButton,
                          style: TextStyle(
                            color: showQuickButton
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: showQuickButton,
                        onChanged: (v) => ref
                            .read(showBottomBarQuickButtonProvider.notifier)
                            .setVisibility(v),
                      );
                    },
                  ),
                  SizedBox(
                    height: 16 + MediaQuery.paddingOf(context).bottom,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildFilterChip(BuildContext context, WidgetRef ref,
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

  /// Placeholder for summary amount when loading; keeps layout stable.
  static Widget _buildAmountPlaceholder(
      BuildContext context, dynamic currency, bool isDark) {
    return Text(
      '—',
      style: TextStyle(
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : AppColors.lightTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds amount (and optional overdue) content for a summary card.
  static Widget _buildSummaryAmountContent(
    BuildContext context, {
    required double amount,
    required dynamic currency,
    required bool isDark,
    double? overdue,
    required String label,
  }) {
    final style = TextStyle(
      color: isDark ? Colors.white : AppColors.lightText,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    return Column(
      key: ValueKey('summary-amount-col-$label'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          key: ValueKey('summary-amount-fitted-$label'),
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: RollingAmount(
            key: ValueKey('summary-amount-rolling-$label'),
            amount: amount,
            currency: currency,
            style: style,
          ),
        ),
        if (overdue != null && overdue > 0) ...[
          const SizedBox(height: 2),
          FittedBox(
            key: ValueKey('summary-overdue-fitted-$label'),
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 12, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    AmountFormatter.formatWithCurrency(
                        overdue, currency.symbol, currency.decimalPlaces),
                    style: TextStyle(
                      color: isDark ? Colors.redAccent : AppColors.error,
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
    );
  }

  static Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required List<_SummaryItem> items,
    required dynamic currency,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('summary-row-$title'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
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
                key: ValueKey('summary-item-${item.label}'),
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: EdgeInsetsDirectional.only(end: isLast ? 0 : 8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
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
                    key: ValueKey('summary-item-content-${item.label}'),
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
                      const SizedBox(height: 3),
                      item.amountContent,
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
                      icon: Icons.mic_none_rounded,
                      label: l10n.voiceAdd,
                      gradient: AppColors.transactionsSectionGradient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VoiceAddScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionButton(
                      icon: Icons.add,
                      label: l10n.add,
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
                      label: l10n.scan,
                      gradient: AppColors.transactionsSectionGradient,
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
                      icon: Symbols.account_balance,
                      label: l10n.accounts,
                      gradient: AppColors.dashboardSectionGradient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountsScreen(),
                          ),
                        );
                      },
                    ),
                    _QuickActionButton(
                      icon: Icons.people_outline_rounded,
                      label: l10n.contacts,
                      gradient: AppColors.getPrimaryGradient(
                          theme.colorScheme.primary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactsListScreen(),
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
                      icon: Icons.category_outlined,
                      label: l10n.categories,
                      gradient: AppColors.getSecondaryGradient(
                          theme.colorScheme.primary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoriesListScreen(),
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
                        ref
                            .read(onboardingCompletedProvider.notifier)
                            .setCompleted(false);
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

  Widget _buildCenterQuickButton(
    BuildContext context,
    WidgetRef ref,
    String code,
    bool isPremium,
    AppLocalizations l10n,
    Color activeColor,
  ) {
    final theme = Theme.of(context);

    IconData icon;
    VoidCallback onTap;

    switch (code) {
      case 'voice_add':
        icon = Icons.mic_none_rounded;
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => VoiceAddScreen()));
        break;
      case 'scan_receipt':
        icon = Icons.document_scanner_outlined;
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ScanReceiptScreen()));
        break;
      case 'accounts':
        icon = Symbols.account_balance;
        onTap = () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AccountsScreen()));
        break;
      case 'contacts':
        icon = Icons.people_outline_rounded;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ContactsListScreen()));
        break;
      case 'receivables':
        icon = Symbols.account_balance_wallet;
        onTap = () {
          ref
              .read(receivablesPaginatedProvider('PENDING').notifier)
              .applyFilters(ReceivableFilters());
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReceivablesListScreen()));
        };
        break;
      case 'payables':
        icon = Icons.payment_outlined;
        onTap = () {
          ref
              .read(payablesPaginatedProvider('PENDING').notifier)
              .applyFilters(PayableFilters());
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PayablesListScreen()));
        };
        break;
      case 'categories':
        icon = Icons.category_outlined;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CategoriesListScreen()));
        break;
      case 'analytics':
        icon = Icons.bar_chart_rounded;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
        break;
      case 'add_transaction':
      default:
        icon = Icons.add;
        onTap = () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        break;
    }

    return GestureDetector(
      onLongPress: () => HomeScreen.showQuickActionSelectionSheetForBottomBar(
          context, ref, theme, l10n),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: activeColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Future<void> _showQuickActionSelectionSheetForBottomBar(BuildContext context,
      WidgetRef ref, ThemeData theme, AppLocalizations l10n) async {
    await HomeScreen.showQuickActionSelectionSheetForBottomBar(
        context, ref, theme, l10n);
  }
}

class _DashboardPrivacyHighlight extends ConsumerWidget {
  const _DashboardPrivacyHighlight({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
}

class _DashboardRecentTransactionsSection extends ConsumerWidget {
  const _DashboardRecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntranceAnimation(
      index: 5,
      child: const _DashboardRecentTransactionsBody(),
    );
  }
}

class _DashboardRecentTransactionsHeader extends StatelessWidget {
  const _DashboardRecentTransactionsHeader({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
}

/// Isolated from the rest of the dashboard so transaction stream updates do not
/// rebuild dashboard header, stats, or related providers.
class _DashboardRecentTransactionsBody extends ConsumerWidget {
  const _DashboardRecentTransactionsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat =
        ref.watch(userProfileProvider.select((p) => p.dateFormat));
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

        final recentTransactions = transactions.take(5).toList();
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return RepaintBoundary(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in recentTransactions)
                _DashboardRecentTransactionTile(
                  key: ValueKey(item.transaction.uuid),
                  item: item,
                  currency: currency,
                  dateFormat: dateFormat,
                  l10n: l10n,
                  theme: theme,
                  isDark: isDark,
                ),
            ],
          ),
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

class _DashboardRecentTransactionTile extends StatelessWidget {
  const _DashboardRecentTransactionTile({
    super.key,
    required this.item,
    required this.currency,
    required this.dateFormat,
    required this.l10n,
    required this.theme,
    required this.isDark,
  });

  final TransactionWithDetails item;
  final AppCurrency currency;
  final String dateFormat;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final transaction = item.transaction;
    final category = item.category;
    final isExpense = transaction.type == 'EXPENSE';

    Color categoryColor =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    if (category?.color != null) {
      try {
        categoryColor =
            Color(int.parse(category!.color!.replaceAll('#', '0xFF')));
      } catch (_) {}
    }

    return _AnimatedPressScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailsDialog(transactionUuid: transaction.uuid),
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
              color: categoryColor.withValues(alpha: isDark ? 0.05 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
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
              transaction.description ?? (isExpense ? l10n.expense : l10n.income),
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(AppDateFormatter.formatDate(transaction.date,
                pattern: dateFormat)),
            trailing: Text(
              '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency)}',
              style: TextStyle(
                color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader({super.key, required this.logoRevealPull});

  /// Must match [_DashboardBodyScrollState._kLogoRevealMax] (pull to fully show).
  static const double _kLogoSlotHeight = 118.0;

  final double logoRevealPull;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;
    final activeIcon = activeCashbook.icon;
    final activeForeColor = activeCashbook.foreColor(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isPremium = PremiumGate.isPremium(ref);

    final showPrivacyHighlight =
        ref.watch(showDashboardPrivacyHighlightProvider);
    final showFinancialSummary =
        ref.watch(showDashboardFinancialSummaryProvider);

    final reveal = logoRevealPull.clamp(0.0, _kLogoSlotHeight).toDouble();

    double expandedHeight = 392;
    if (!showFinancialSummary) {
      expandedHeight -= 220;
    }

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
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
                      color: activeColor.withValues(alpha: 0.3), width: 1),
                  borderRadius: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(40),
                  ),
                ),
              ),
            ),
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
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
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
                            vertical: 4, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/logo_square.svg',
                                      fit: BoxFit.contain,
                                      height: 36,
                                      colorFilter: ColorFilter.mode(
                                        Color.lerp(
                                              theme.colorScheme.onSurface,
                                              theme.colorScheme.primary,
                                              .5,
                                            ) ??
                                            theme.colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(-4, 0),
                                      child: Text(
                                        'lowpaisa',
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color.lerp(
                                                theme.colorScheme.onSurface,
                                                theme.colorScheme.primary,
                                                .5,
                                              ) ??
                                              theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const _DashboardHeroContent(),
                  if (showFinancialSummary) const _DashboardStatsGrid(),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -_kLogoSlotHeight + reveal,
              height: _kLogoSlotHeight,
              child: Center(
                child: EntranceAnimation(
                  index: 3,
                  child: RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/logo_square.svg',
                        height: 88,
                        width: 88,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          activeColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        titlePadding: EdgeInsets.zero,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final settings = context
                .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
            final deltaExtent = settings!.maxExtent - settings.minExtent;
            final t = (1.0 -
                    (settings.currentExtent - settings.minExtent) / deltaExtent)
                .clamp(0.0, 1.0);

            if (t < 0.8) return const SizedBox.shrink();

            return FadeTransition(
              opacity: AlwaysStoppedAnimation(t),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/logo_square.svg',
                          height: 24,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            Color.lerp(
                                  theme.colorScheme.onSurface,
                                  theme.colorScheme.primary,
                                  .3,
                                ) ??
                                theme.colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
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
                                    .3,
                                  ) ??
                                  theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
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
            final hasUrgent = notifications
                .any((n) => (n.isRead == false) && (n.isUrgent == true));

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
                        builder: (context) => const NotificationsScreen(),
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
                              color: AppColors.error.withValues(alpha: 0.5),
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
        Consumer(
          builder: (context, ref, child) {
            // Keep sync status polling active globally (reactive approach).
            ref.watch(syncStatusPollingProvider);

            final showSync = ref.watch(showDashboardSyncStatusProvider);
            final backupState = ref.watch(backupProvider);
            final isAutoSync = ref.watch(autoSyncOnStartupProvider);

            final bool isSyncing = backupState.syncStatus == 'Syncing...' ||
                backupState.syncStatus == 'Processing...' ||
                backupState.syncStatus == 'Pulling...' ||
                backupState.syncStatus == 'Pushing...';
            final bool hasUnsynced = backupState.unsyncedCount > 0;
            final int updatesCount =
                backupState.cloudVersion - backupState.localVersion;
            final bool hasCloudUpdates = updatesCount > 0;
            final bool isSyncAlreadyInProgress =
                backupState.syncStatus == 'Sync already in progress';
            final bool isLockError = backupState.syncStatus.contains('Error') &&
                (backupState.syncStatus.contains('database is locked') ||
                    backupState.syncStatus.contains('1555') ||
                    backupState.syncStatus.contains('code 5') ||
                    backupState.syncStatus.contains('SQLITE_BUSY'));

            // Hide the cloud icon if everything is idle and the section is hidden
            if (!showSync &&
                !isSyncing &&
                !hasUnsynced &&
                !hasCloudUpdates &&
                !isSyncAlreadyInProgress &&
                !isLockError &&
                backupState.syncStatus != 'Success') {
              return const SizedBox.shrink();
            }

            IconData statusIcon;
            Color iconColor = theme.colorScheme.primary;

            if (isSyncAlreadyInProgress || isLockError || hasUnsynced) {
              iconColor = Colors.orange;
              statusIcon = showSync
                  ? (hasUnsynced ? Icons.cloud_upload : Icons.cloud)
                  : (hasUnsynced
                      ? Icons.cloud_upload_outlined
                      : Icons.cloud_outlined);
            } else if (isSyncing) {
              iconColor = theme.colorScheme.primary;
              statusIcon =
                  showSync ? Icons.cloud_sync : Icons.cloud_sync_outlined;
            } else if (hasCloudUpdates) {
              iconColor = Colors.lightBlue;
              statusIcon = showSync
                  ? Icons.cloud_download
                  : Icons.cloud_download_outlined;
            } else if (backupState.syncStatus == 'Success') {
              iconColor = Colors.green;
              statusIcon =
                  showSync ? Icons.cloud_done : Icons.cloud_done_outlined;
            } else if (backupState.syncStatus.contains('Error')) {
              iconColor = theme.colorScheme.error;
              statusIcon =
                  showSync ? Icons.cloud_off : Icons.cloud_off_outlined;
            } else {
              statusIcon = showSync ? Icons.cloud : Icons.cloud_outlined;
            }

            return IconButton(
              icon: Badge(
                label: const Text(
                  'A',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isLabelVisible: isAutoSync && !showSync,
                backgroundColor: iconColor,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  statusIcon,
                  color: iconColor,
                ),
              ),
              onPressed: () =>
                  ref.read(showDashboardSyncStatusProvider.notifier).toggle(),
              tooltip: l10n.syncStatusTitle,
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final visibility = ref.watch(dashboardVisibilityProvider);
            final hasSeenCustomization =
                ref.watch(dashboardCustomizationSeenProvider);
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;

            IconData icon;
            Color color;
            bool showBadge = false;

            switch (visibility) {
              case DashboardVisibility.visible:
                icon = Icons.dashboard_customize;
                color = theme.colorScheme.primary;
                break;
              case DashboardVisibility.edit:
                icon = Icons.dashboard_customize;
                color = theme.colorScheme.primary;
                showBadge = true;
                break;
              case DashboardVisibility.hidden:
                icon = Icons.dashboard_customize_outlined;
                color = theme.colorScheme.onSurface;
                break;
            }

            return Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(icon, color: color),
                  onPressed: () {
                    ref.read(dashboardVisibilityProvider.notifier).next();
                    if (ref.read(dashboardVisibilityProvider) !=
                        DashboardVisibility.hidden) {
                      ref
                          .read(dashboardCustomizationSeenProvider.notifier)
                          .setSeen();
                    }
                  },
                  tooltip: l10n.addToDashboard,
                ),
                if (!hasSeenCustomization || showBadge)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color:
                            showBadge ? Colors.orange : theme.colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: showBadge
                          ? const Center(
                              child: Icon(
                                Icons.edit,
                                size: 8,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final currentUser =
                ref.watch(backupProvider.select((s) => s.currentUser));
            return IconButton(
              icon: UserAvatar(
                user: currentUser,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _DashboardHeroContent extends ConsumerWidget {
  const _DashboardHeroContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final filter = ref.watch(dashboardFilterProvider);
    final lastStats = ref.watch(lastDashboardStatsProvider);
    final hasAccounts = ref.watch(hasAccountsProvider);
    final mainBalanceView = ref.watch(dashboardMainBalanceViewProvider);
    final accountsWithBalanceAsync = ref.watch(accountsWithBalanceProvider);
    final showNetWorthOnHero =
        hasAccounts && mainBalanceView == DashboardMainBalanceView.netWorth;
    final heroCombineAddends = ref.watch(dashboardHeroCombinedAddendsProvider);
    final heroCombineChips =
        ref.watch(dashboardHeroCombinedCashbooksForChipsProvider);
    final cashbookCount = ref.watch(cashbooksProvider).length;

    // Cache stats for loading state
    dashboardStatsAsync.whenData((s) {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(lastDashboardStatsProvider.notifier).setLast(s);
        }
      });
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAccounts
              ? () =>
                  ref.read(dashboardMainBalanceViewProvider.notifier).toggle()
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              showNetWorthOnHero
                                  ? l10n.netWorth
                                  : l10n.availableCash,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                                shadows: isDark
                                    ? AppTheme.textShadow(blurMultiplier: 1.0)
                                    : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (heroCombineChips.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            ...heroCombineChips.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: c.color
                                      .withValues(alpha: isDark ? 0.35 : 0.25),
                                  child: Icon(
                                    c.icon,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Combine other cashbooks into hero totals — only needs 2+ cashbooks, not accounts loaded.
                    if (cashbookCount > 1) ...[
                      IconButton(
                        tooltip: l10n.dashboardHeroCombineTitle,
                        onPressed: () =>
                            showDashboardHeroCombineSheet(context, ref),
                        // Avoid default 48dp / explicit 36×36 min — that stretched the hero label row.
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(2),
                        ),
                        icon: Icon(
                          Icons.layers_outlined,
                          size: 20,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (hasAccounts) const SizedBox(width: 10),
                    ],
                    if (hasAccounts)
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 18,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.55)
                            : AppColors.lightTextSecondary,
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    showNetWorthOnHero
                        ? accountsWithBalanceAsync.when(
                            data: (accounts) {
                              final nw =
                                  dashboardNetWorthFromAccounts(accounts) +
                                      heroCombineAddends.netWorth;
                              return RollingAmount(
                                amount: nw,
                                currency: currency,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightText,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  fontSize: AmountFormatter.getFontSize(
                                    nw,
                                    baseSize: 28,
                                    decimalPlaces: currency.decimalPlaces,
                                  ),
                                  shadows: isDark
                                      ? AppTheme.textShadow(blurMultiplier: 4.0)
                                      : null,
                                ),
                              );
                            },
                            loading: () => const SizedBox(height: 26),
                            error: (_, __) => Text(
                              l10n.error,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.error,
                              ),
                            ),
                          )
                        : dashboardStatsAsync.when(
                            skipLoadingOnRefresh: true,
                            data: (stats) {
                              final combinedCash = stats.totalBalance +
                                  heroCombineAddends.availableCash;
                              return RollingAmount(
                                amount: combinedCash,
                                currency: currency,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightText,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  fontSize: AmountFormatter.getFontSize(
                                    combinedCash,
                                    baseSize: 28,
                                    decimalPlaces: currency.decimalPlaces,
                                  ),
                                  shadows: isDark
                                      ? AppTheme.textShadow(blurMultiplier: 4.0)
                                      : null,
                                ),
                              );
                            },
                            loading: () => lastStats != null
                                ? RollingAmount(
                                    amount: lastStats.totalBalance +
                                        heroCombineAddends.availableCash,
                                    currency: currency,
                                    style:
                                        theme.textTheme.displaySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.lightText,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                      fontSize: AmountFormatter.getFontSize(
                                        lastStats.totalBalance +
                                            heroCombineAddends.availableCash,
                                        baseSize: 28,
                                        decimalPlaces: currency.decimalPlaces,
                                      ),
                                      shadows: isDark
                                          ? AppTheme.textShadow(
                                              blurMultiplier: 4.0)
                                          : null,
                                    ),
                                  )
                                : const SizedBox(height: 26),
                            error: (_, __) => Text(
                              l10n.error,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.error,
                              ),
                            ),
                          ),
                    _DashboardTab._buildFilterChip(
                        context, ref, filter, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardStatsGrid extends ConsumerWidget {
  const _DashboardStatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeForeColor = activeCashbook.foreColor(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);
    final filter = ref.watch(dashboardFilterProvider);
    final lastStats = ref.watch(lastDashboardStatsProvider);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DashboardTab._buildSummaryRow(
              context,
              isDark: isDark,
              title: l10n.cashFlow,
              items: [
                _SummaryItem(
                  label: l10n.income,
                  amountContent: dashboardStatsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (s) => _DashboardTab._buildSummaryAmountContent(
                      context,
                      amount: s.income(filter),
                      currency: currency,
                      isDark: isDark,
                      label: l10n.income,
                    ),
                    loading: () => lastStats != null
                        ? _DashboardTab._buildSummaryAmountContent(
                            context,
                            amount: lastStats.income(filter),
                            currency: currency,
                            isDark: isDark,
                            label: l10n.income,
                          )
                        : _DashboardTab._buildAmountPlaceholder(
                            context, currency, isDark),
                    error: (_, __) => _DashboardTab._buildAmountPlaceholder(
                        context, currency, isDark),
                  ),
                  color: AppColors.incomeColor,
                  icon: Icons.south_west,
                  onTap: () {
                    final isMonthly = filter == DashboardFilter.monthly;
                    final now = DateTime.now();
                    final startDate =
                        isMonthly ? DateTime(now.year, now.month, 1) : null;
                    final endDate =
                        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
                    ref
                        .read(transactionsPaginatedProvider.notifier)
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
                        builder: (context) => const TransactionsListScreen(),
                      ),
                    );
                  },
                ),
                _SummaryItem(
                  label: l10n.expense,
                  amountContent: dashboardStatsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (s) => _DashboardTab._buildSummaryAmountContent(
                      context,
                      amount: s.expense(filter),
                      currency: currency,
                      isDark: isDark,
                      label: l10n.expense,
                    ),
                    loading: () => lastStats != null
                        ? _DashboardTab._buildSummaryAmountContent(
                            context,
                            amount: lastStats.expense(filter),
                            currency: currency,
                            isDark: isDark,
                            label: l10n.expense,
                          )
                        : _DashboardTab._buildAmountPlaceholder(
                            context, currency, isDark),
                    error: (_, __) => _DashboardTab._buildAmountPlaceholder(
                        context, currency, isDark),
                  ),
                  color: AppColors.expenseColor,
                  icon: Icons.north_east,
                  onTap: () {
                    final isMonthly = filter == DashboardFilter.monthly;
                    final now = DateTime.now();
                    final startDate =
                        isMonthly ? DateTime(now.year, now.month, 1) : null;
                    final endDate =
                        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
                    ref
                        .read(transactionsPaginatedProvider.notifier)
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
                        builder: (context) => const TransactionsListScreen(),
                      ),
                    );
                  },
                ),
                _SummaryItem(
                  label: l10n.netCash,
                  amountContent: dashboardStatsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (s) => _DashboardTab._buildSummaryAmountContent(
                      context,
                      amount: s.netCash(filter),
                      currency: currency,
                      isDark: isDark,
                      label: l10n.netCash,
                    ),
                    loading: () => lastStats != null
                        ? _DashboardTab._buildSummaryAmountContent(
                            context,
                            amount: lastStats.netCash(filter),
                            currency: currency,
                            isDark: isDark,
                            label: l10n.netCash,
                          )
                        : _DashboardTab._buildAmountPlaceholder(
                            context, currency, isDark),
                    error: (_, __) => _DashboardTab._buildAmountPlaceholder(
                        context, currency, isDark),
                  ),
                  color: activeForeColor,
                  icon: Icons.account_balance_wallet,
                  onTap: () {
                    final isMonthly = filter == DashboardFilter.monthly;
                    final now = DateTime.now();
                    final startDate =
                        isMonthly ? DateTime(now.year, now.month, 1) : null;
                    final endDate =
                        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
                    ref
                        .read(transactionsPaginatedProvider.notifier)
                        .applyFilters(
                          TransactionFilters(
                            startDate: startDate,
                            endDate: endDate,
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsListScreen(),
                      ),
                    );
                  },
                ),
              ],
              currency: currency,
            ),
            const SizedBox(height: 8),
            _DashboardTab._buildSummaryRow(
              context,
              isDark: isDark,
              title: l10n.lendingCredit,
              items: [
                _SummaryItem(
                  label: l10n.receivableTag,
                  amountContent: dashboardStatsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (s) => _DashboardTab._buildSummaryAmountContent(
                      context,
                      amount: s.receivable(filter),
                      currency: currency,
                      isDark: isDark,
                      overdue: s.overdueReceivable,
                      label: l10n.receivableTag,
                    ),
                    loading: () => lastStats != null
                        ? _DashboardTab._buildSummaryAmountContent(
                            context,
                            amount: lastStats.receivable(filter),
                            currency: currency,
                            isDark: isDark,
                            overdue: lastStats.overdueReceivable,
                            label: l10n.receivableTag,
                          )
                        : _DashboardTab._buildAmountPlaceholder(
                            context, currency, isDark),
                    error: (_, __) => _DashboardTab._buildAmountPlaceholder(
                        context, currency, isDark),
                  ),
                  color: AppColors.receivableColor,
                  icon: Icons.call_received,
                  onTap: () {
                    final isMonthly = filter == DashboardFilter.monthly;
                    final now = DateTime.now();
                    final startDate =
                        isMonthly ? DateTime(now.year, now.month, 1) : null;
                    final endDate =
                        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
                    ref
                        .read(receivablesPaginatedProvider('PENDING').notifier)
                        .applyFilters(
                          ReceivableFilters(
                            startDate: startDate,
                            endDate: endDate,
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceivablesListScreen(),
                      ),
                    );
                  },
                ),
                _SummaryItem(
                  label: l10n.payableTag,
                  amountContent: dashboardStatsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (s) => _DashboardTab._buildSummaryAmountContent(
                      context,
                      amount: s.payable(filter),
                      currency: currency,
                      isDark: isDark,
                      overdue: s.overduePayable,
                      label: l10n.payableTag,
                    ),
                    loading: () => lastStats != null
                        ? _DashboardTab._buildSummaryAmountContent(
                            context,
                            amount: lastStats.payable(filter),
                            currency: currency,
                            isDark: isDark,
                            overdue: lastStats.overduePayable,
                            label: l10n.payableTag,
                          )
                        : _DashboardTab._buildAmountPlaceholder(
                            context, currency, isDark),
                    error: (_, __) => _DashboardTab._buildAmountPlaceholder(
                        context, currency, isDark),
                  ),
                  color: AppColors.payableColor,
                  icon: Icons.call_made,
                  onTap: () {
                    final isMonthly = filter == DashboardFilter.monthly;
                    final now = DateTime.now();
                    final startDate =
                        isMonthly ? DateTime(now.year, now.month, 1) : null;
                    final endDate =
                        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
                    ref
                        .read(payablesPaginatedProvider('PENDING').notifier)
                        .applyFilters(
                          PayableFilters(
                            startDate: startDate,
                            endDate: endDate,
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PayablesListScreen(),
                      ),
                    );
                  },
                ),
                _SummaryItem(
                  label: l10n.netCredit,
                  amountContent: dashboardStatsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (s) => _DashboardTab._buildSummaryAmountContent(
                      context,
                      amount: s.netCredit(filter),
                      currency: currency,
                      isDark: isDark,
                      label: l10n.netCredit,
                    ),
                    loading: () => lastStats != null
                        ? _DashboardTab._buildSummaryAmountContent(
                            context,
                            amount: lastStats.netCredit(filter),
                            currency: currency,
                            isDark: isDark,
                            label: l10n.netCredit,
                          )
                        : _DashboardTab._buildAmountPlaceholder(
                            context, currency, isDark),
                    error: (_, __) => _DashboardTab._buildAmountPlaceholder(
                        context, currency, isDark),
                  ),
                  color: activeForeColor,
                  icon: Icons.swap_horiz,
                ),
              ],
              currency: currency,
            ),
          ],
        ),
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
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    final backupState = ref.watch(backupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          IconButton(
            icon: UserAvatar(
              user: backupState.currentUser,
              size: 24,
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
      body: ListView(
        children: [
          // Accounts entry
          ListTile(
            leading: const Icon(Symbols.account_balance_wallet),
            title: Text(l10n.accounts),
            subtitle: Text(l10n.noAccountsDescription),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Consumer(
                  builder: (context, ref, child) {
                    final currentLocale = ref.watch(languageProvider);
                    switch (currentLocale.languageCode) {
                      case 'hi':
                        return Text(l10n.hindi);
                      case 'ur':
                        return Text(l10n.urdu);
                      case 'en':
                      default:
                        return Text(l10n.english);
                    }
                  },
                ),
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
                title: Text(l10n.fontSelection),
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
                subtitle: Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    switch (themeMode) {
                      case ThemeMode.light:
                        return Text(l10n.light);
                      case ThemeMode.dark:
                        return Text(l10n.dark);
                      case ThemeMode.system:
                      default:
                        return Text(l10n.system);
                    }
                  },
                ),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Row(
              children: [
                Text(l10n.backup),
                const SizedBox(width: 8),
                if (!isPremium)
                  const PremiumBadge(isSmall: true, showLock: true),
                if (isPremium) ...[
                  const SizedBox(width: 4),
                  _buildAdvancedChip(context, l10n),
                ],
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
          const Divider(),
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
            child: Material(
              type: MaterialType.transparency,
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
            leading: const Icon(Icons.star_outline),
            title: Text(l10n.rateUs),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ref.read(inAppReviewServiceProvider).requestReview();
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Developer'),
            subtitle: const Text('SharedPreferences & debug info'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DevScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedChip(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        l10n.advanced.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final Widget amountContent;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  _SummaryItem({
    required this.label,
    required this.amountContent,
    required this.color,
    required this.icon,
    this.onTap,
  });
}

class _BottomBarNotchPainter extends CustomPainter {
  final Color color;
  final double notchRadius;

  _BottomBarNotchPainter({required this.color, required this.notchRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    const curveWidth = 25.0; // Narrower curve for a tighter look

    path.moveTo(0, 0);

    // Line to the start of the notch curve
    path.lineTo(centerX - notchRadius - curveWidth, 0);

    // Smooth curve into the notch
    path.cubicTo(
      centerX - notchRadius - (curveWidth / 2), 0, // Control point 1
      centerX - notchRadius, 0, // Control point 2
      centerX - notchRadius, notchRadius * 0.2, // End point
    );

    // The notch itself (deeper arc)
    path.arcToPoint(
      Offset(centerX + notchRadius, notchRadius * 0.2),
      radius: Radius.circular(notchRadius * 1.1),
      clockwise: false,
    );

    // Smooth curve out of the notch
    path.cubicTo(
      centerX + notchRadius, 0, // Control point 1
      centerX + notchRadius + (curveWidth / 2), 0, // Control point 2
      centerX + notchRadius + curveWidth, 0, // End point
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// Force save to disk
