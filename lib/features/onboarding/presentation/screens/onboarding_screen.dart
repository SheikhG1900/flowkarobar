import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String onboardingKey = 'has_seen_onboarding_v1';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final activeDotColor = primaryColor;
    final inactiveDotColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.32);
    final trackBorderColor =
        theme.colorScheme.outline.withValues(alpha: 0.35);

    final mq = MediaQuery.of(context);
    final statusBarHeight = mq.viewPadding.top;

    // Page background fills under the status bar; image starts below status icons.
    final pageDecoration = PageDecoration(
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      bodyTextStyle: theme.textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      pageColor: theme.scaffoldBackgroundColor,
      imagePadding: EdgeInsets.only(top: statusBarHeight + 24),
      contentMargin: const EdgeInsets.symmetric(horizontal: 24),
    );

    final pages = <PageViewModel>[
      PageViewModel(
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
        image: _buildWelcomeLogo(primaryColor, isDark, theme),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: l10n.onboardingScanTitle,
        body: l10n.onboardingScanBody,
        image: _buildUndraw(UndrawIllustration.mobileSite, primaryColor),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: l10n.onboardingTransactionsTitle,
        body: l10n.onboardingTransactionsBody,
        image: _buildUndraw(UndrawIllustration.digitalArtwork, primaryColor),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: l10n.onboardingCollaborationTitle,
        body: l10n.onboardingCollaborationBody,
        image: _buildUndraw(UndrawIllustration.chatting, primaryColor),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: l10n.onboardingSyncTitle,
        body: l10n.onboardingSyncBody,
        image: _buildUndraw(UndrawIllustration.cloudSync, primaryColor),
        decoration: pageDecoration,
      ),
    ];

    final totalSlides = pages.length;

    // [left, right, top, bottom]: extend under status bar (top false), keep above
    // nav / gesture bar (bottom true). Edge-to-edge: add bottom gap when needed.
    final bottomBarGap =
        (mq.viewPadding.bottom - mq.padding.bottom).clamp(0.0, double.infinity);

    return IntroductionScreen(
      pages: pages,
      onChange: (index) => setState(() => _currentPage = index),
      onDone: _onIntroEnd,
      onSkip: _onIntroEnd,
      showSkipButton: true,
      skip: FittedBox(
        child: Text(l10n.tourSkip,
            style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
      ),
      next: FittedBox(child: Icon(Icons.arrow_forward, color: primaryColor)),
      done: FittedBox(
        child: Text(l10n.done,
            style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      safeAreaList: const [true, true, false, true],
      controlsMargin:
          EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomBarGap),
      controlsPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      skipOrBackFlex: 1,
      dotsFlex: 1,
      nextFlex: 1,
      isProgress: true,
      customProgress: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: isDark ? 0.35 : 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: trackBorderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSlides, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active ? activeDotColor : inactiveDotColor,
              ),
            );
          }),
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(8.0, 8.0),
        color: inactiveDotColor,
        activeSize: const Size(22.0, 8.0),
        activeColor: activeDotColor,
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        spacing: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildUndraw(UndrawIllustration illustration, Color color) {
    return Undraw(
      illustration: illustration,
      color: color,
      width: 280,
      fit: BoxFit.contain,
      placeholder: const Center(child: CircularProgressIndicator()),
      errorWidget: const Icon(Icons.error_outline, color: Colors.red, size: 50),
    );
  }

  Widget _buildWelcomeLogo(Color accentColor, bool isDark, ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Large Shield Background
        Icon(
          Icons.shield_rounded,
          size: 200,
          color: accentColor.withValues(alpha: 0.12),
        ),
        // Logo in the center
        SvgPicture.asset(
          'assets/images/logo_square.svg',
          width: 132,
          height: 132,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
        ),
      ],
    );
  }

  Future<void> _onIntroEnd() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(OnboardingScreen.onboardingKey, true);
    ref.read(onboardingCompletedProvider.notifier).setCompleted(true);
  }
}
