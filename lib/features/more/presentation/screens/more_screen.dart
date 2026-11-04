import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flowpaisa/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/features/businesses/presentation/screens/businesses_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/categories_list_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:flowpaisa/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/about_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/font_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/language_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/profile_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/theme_selector_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/user_guide_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.more)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _SectionHeader(title: l10n.manage),
          _MoreTile(
            icon: Icons.people_outline,
            color: AppColors.receivableColor,
            title: l10n.contacts,
            screen: const ContactsListScreen(),
          ),
          _MoreTile(
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.transactionsSectionColor,
            title: l10n.accounts,
            screen: const AccountsScreen(),
          ),
          _MoreTile(
            icon: Icons.storefront_outlined,
            color: AppColors.dashboardSectionColor,
            title: l10n.businesses,
            screen: const BusinessesScreen(),
          ),
          _MoreTile(
            icon: Icons.category_outlined,
            color: AppColors.expenseColor,
            title: l10n.categories,
            screen: const CategoriesListScreen(),
          ),
          _MoreTile(
            icon: Icons.insights_outlined,
            color: AppColors.analyticsSectionColor,
            title: l10n.analytics,
            screen: const AnalyticsScreen(),
          ),
          const Divider(height: 32),
          _SectionHeader(title: l10n.settings),
          _MoreTile(
            icon: Icons.person_outline,
            color: AppColors.settingsSectionColor,
            title: l10n.profile,
            screen: const ProfileScreen(),
          ),
          _MoreTile(
            icon: Icons.workspace_premium_outlined,
            color: AppColors.incomeColor,
            title: l10n.premium,
            screen: const PremiumScreen(),
          ),
          _MoreTile(
            icon: Icons.notifications_outlined,
            color: AppColors.settingsSectionColor,
            title: l10n.notifications,
            screen: const NotificationsScreen(),
          ),
          _MoreTile(
            icon: Icons.language,
            color: AppColors.settingsSectionColor,
            title: l10n.language,
            screen: const LanguageSelectorScreen(),
          ),
          _MoreTile(
            icon: Icons.font_download_outlined,
            color: AppColors.settingsSectionColor,
            title: l10n.fontSelection,
            screen: const FontSelectorScreen(),
          ),
          _MoreTile(
            icon: Icons.dark_mode_outlined,
            color: AppColors.settingsSectionColor,
            title: l10n.theme,
            screen: const ThemeSelectorScreen(),
          ),
          _MoreTile(
            icon: Icons.backup_outlined,
            color: AppColors.settingsSectionColor,
            title: l10n.backup,
            screen: const BackupScreen(),
          ),
          _MoreTile(
            icon: Icons.help_outline,
            color: AppColors.settingsSectionColor,
            title: l10n.userGuide,
            screen: const UserGuideScreen(),
          ),
          _MoreTile(
            icon: Icons.info_outline,
            color: AppColors.settingsSectionColor,
            title: l10n.about,
            screen: const AboutScreen(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget screen;

  const _MoreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
    );
  }
}
