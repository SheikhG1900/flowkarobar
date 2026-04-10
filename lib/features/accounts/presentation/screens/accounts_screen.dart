import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/add_edit_account_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_transfer_sheet.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/transfer_account_box.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flowpaisa/shared/widgets/contextual_guide.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
    });
  }

  void _checkAndShowGuide() {
    final hasSeen = ref.read(accountsGuideSeenProvider);
    if (!hasSeen) {
      final l10n = AppLocalizations.of(context)!;
      ContextualGuide.show(
        context,
        title: l10n.accountsOverview,
        items: [
          GuideItem(
            illustration: UndrawIllustration.personalFinance,
            title: l10n.guideAccountsTitle,
            description: l10n.guideAccountsBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.creditCard,
            title: l10n.guideCreditCardsTitle,
            description: l10n.guideCreditCardsBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.dataReport,
            title: l10n.financialSummary,
            description: l10n.guideBudgetsBody,
          ),
        ],
        onDismiss: () {
          ref.read(accountsGuideSeenProvider.notifier).setSeen();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
        actions: [
          IconButton(
            icon: const Icon(Symbols.swap_horiz),
            tooltip: l10n.transferMoney,
            onPressed: () => _showTransferSheet(context),
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return _EmptyAccountsView(
                onAddTap: () => _goToAddAccount(context, ref));
          }

          final regularAccounts =
              accounts.where((a) => a.type != AccountType.creditCard).toList();
          final creditCardAccounts =
              accounts.where((a) => a.type == AccountType.creditCard).toList();

          return ListView(
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
            children: [
              // Net Worth summary card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NetWorthCard(accounts: accounts),
              ),
              const SizedBox(height: 24),

              if (accounts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionHeader(title: l10n.accounts),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 10, bottom: 30),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final awb = accounts[index];
                      final isLocked = !isPremium &&
                          (awb.account.addSeq ?? 0) >
                              PremiumGate.accountTotalLimit;
                      return _AccountCard(
                        awb: awb,
                        isLocked: isLocked,
                        onTap: isLocked
                            ? () => PremiumGate.showPremiumDialog(context)
                            : () => _goToDetail(context, awb.account),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _RecentTransfersSection(),
              ),
            ],
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(
            child: Text(
                AppLocalizations.of(context)!.errorOccurred(e.toString()))),
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () => _goToAddAccount(context, ref),
        tooltip: l10n.addAccount,
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Future<void> _goToAddAccount(BuildContext context, WidgetRef ref) async {
    final limits = await PremiumGate.getAccountLimits(ref);
    if (!limits.canAdd) {
      if (context.mounted) {
        PremiumGate.showPremiumDialog(context);
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddEditAccountScreen()),
      );
    }
  }

  void _goToDetail(BuildContext context, Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AccountDetailScreen(accountUuid: account.uuid)),
    );
  }

  void _showTransferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AccountTransferSheet(),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Net Worth summary — receivable / income / payable palette
// ────────────────────────────────────────────────────────────
class _NetWorthItem extends StatelessWidget {
  final String label;
  final double amount;
  final String symbol;
  final int decimals;
  final Color accentColor;

  const _NetWorthItem({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.decimals,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseAmountSize = 36.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Symbols.account_balance,
                  color: accentColor,
                  size: 18,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AmountFormatter.formatWithCurrency(amount, symbol, decimals),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
              height: 1.15,
              fontSize: AmountFormatter.getFontSize(
                amount,
                baseSize: baseAmountSize,
                decimalPlaces: decimals,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NetWorthCard extends ConsumerWidget {
  final List<AccountWithBalance> accounts;
  const _NetWorthCard({required this.accounts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);

    final totalAssets = accounts
        .where((a) => !a.type.balanceIsLiability)
        .fold<double>(0, (sum, a) => sum + a.balance.clamp(0, double.infinity));
    final totalLiabilities = accounts
        .where((a) => a.type.balanceIsLiability)
        .fold<double>(0, (sum, a) => sum + a.balance.abs());
    final netWorth = totalAssets - totalLiabilities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NetWorthItem(
          label: l10n.netWorth,
          amount: netWorth,
          symbol: symbol,
          decimals: decimals,
          accentColor: AppColors.receivableColor,
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatItem(
                  color: AppColors.incomeColor,
                  icon: Symbols.trending_up,
                  label: l10n.totalAssets,
                  amount: totalAssets,
                  symbol: symbol,
                  decimals: decimals,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatItem(
                  color: AppColors.payableColor,
                  icon: Symbols.trending_down,
                  label: l10n.totalLiabilities,
                  amount: totalLiabilities,
                  symbol: symbol,
                  decimals: decimals,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final double amount;
  final String symbol;
  final int decimals;

  const _StatItem({
    required this.color,
    required this.icon,
    required this.label,
    required this.amount,
    required this.symbol,
    required this.decimals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AmountFormatter.formatWithCurrency(amount, symbol, decimals),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Section header row
// ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Individual account card — mirrors contact card style
// ────────────────────────────────────────────────────────────
class _AccountCard extends ConsumerWidget {
  final AccountWithBalance awb;
  final VoidCallback onTap;
  final bool isLocked;

  const _AccountCard({
    required this.awb,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final acc = awb.account;
    final type = awb.type;

    final accountColor = acc.color != null
        ? Color(int.parse(acc.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;
    final iconData = IconHelper.getIconData(acc.icon) ?? _defaultIcon(type);
    final isDark = theme.brightness == Brightness.dark;

    final bool isNegative = awb.balance < 0;
    final Color balanceColor = Colors.white;

    final String balanceText = type.isCreditCard
        ? (awb.creditBalance > 0
            ? AmountFormatter.formatWithCurrency(
                awb.creditBalance, symbol, decimals)
            : '($symbol${AmountFormatter.formatAmount(awb.balance.abs(), decimals)})')
        : AmountFormatter.formatWithCurrency(awb.balance, symbol, decimals);

    return Container(
      width: 280,
      height: 185, // Increased height to prevent vertical overflow
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _accountCardGradient(accountColor, theme),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accountColor.withValues(alpha: isDark ? 0.4 : 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Pattern for Credit Cards
                    if (type.isCreditCard)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CustomPaint(
                            painter: _CardPatternPainter(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(iconData,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      acc.name,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _typeLabel(l10n, type),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (type.isCreditCard)
                                Container(
                                  width: 35,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.yellow.shade700,
                                        Colors.yellow.shade200,
                                        Colors.yellow.shade700,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            type.isCreditCard
                                ? (awb.creditBalance > 0
                                    ? l10n.creditBalance
                                    : l10n.outstandingBalance)
                                : l10n.currentBalance,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              balanceText,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (type.isCreditCard &&
                              (awb.dueAmount ?? 0.0) > 0) ...[
                            const SizedBox(height: 8),
                            _DueBadge(
                              dueAmount: awb.dueAmount ?? 0.0,
                              symbol: symbol,
                              decimals: decimals,
                              isDark: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _accountCardGradient(Color accountColor, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accountColor,
          Color.lerp(accountColor, theme.colorScheme.surface, 0.3)!,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accountColor,
        Color.lerp(accountColor, Colors.black, 0.1)!,
      ],
    );
  }

  IconData _defaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Symbols.payments;
      case AccountType.bank:
        return Symbols.account_balance;
      case AccountType.savings:
        return Symbols.savings;
      case AccountType.creditCard:
        return Symbols.credit_card;
    }
  }

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    switch (type) {
      case AccountType.cash:
        return l10n.cash;
      case AccountType.bank:
        return l10n.bank;
      case AccountType.savings:
        return l10n.savings;
      case AccountType.creditCard:
        return l10n.creditCard;
    }
  }
}

class _CardPatternPainter extends CustomPainter {
  final Color color;
  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = -size.height; i < size.width; i += 15) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _DueBadge extends StatelessWidget {
  final double dueAmount;
  final String symbol;
  final int decimals;
  final bool isDark;

  const _DueBadge({
    required this.dueAmount,
    required this.symbol,
    required this.decimals,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.expenseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${l10n.due}: ${AmountFormatter.formatWithCurrency(dueAmount, symbol, decimals)}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.white : AppColors.expenseColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Empty state
// ────────────────────────────────────────────────────────────
class _EmptyAccountsView extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyAccountsView({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.account_balance_wallet,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noAccounts,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noAccountsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: Text(l10n.addAccount),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Recent transfers (accounts screen)
// ────────────────────────────────────────────────────────────
const _recentTransfersLimit = 15;

class _RecentTransfersSection extends ConsumerWidget {
  const _RecentTransfersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final transfersAsync = ref.watch(allTransfersWithDetailsProvider);
    final cashbookAccent = ref.watch(activeCashbookProvider).color;

    return transfersAsync.when(
      data: (list) {
        final recent = list.take(_recentTransfersLimit).toList();
        if (recent.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: l10n.recentTransfers),
            const SizedBox(height: 8),
            for (var i = 0; i < recent.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              SwipeableListItem(
                borderRadius: 20,
                confirmTitle: l10n.deleteTransfer,
                confirmMessage: l10n.deleteTransferConfirm,
                deleteLabel: l10n.delete,
                onEdit: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AccountTransferSheet(
                      existingTransfer: recent[i].transfer,
                    ),
                  );
                },
                onDelete: () async {
                  await ref
                      .read(accountsRepositoryProvider)
                      .deleteTransfer(recent[i].transfer.uuid);
                  if (context.mounted) {
                    ToastUtils.showSuccessToast(
                        context, ref, l10n.transferDeleted);
                  }
                },
                child: Container(
                  decoration: AppColors.transactionListItemDecoration(
                    theme,
                    cashbookAccent,
                  ),
                  child: _TransferRow(details: recent[i]),
                ),
              ),
            ],
            const SizedBox(height: 40),
            const FadedBottomLogo(bottomPadding: 40),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TransferRow extends ConsumerWidget {
  final AccountTransferWithDetails details;

  const _TransferRow({required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final t = details.transfer;
    final desc = t.description?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    TransferAccountBox(
                      account: details.fromAccount,
                      theme: theme,
                      arrowBesideIcon: true,
                      showBorder: false,
                      onAccountTap: details.fromAccount != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountDetailScreen(
                                    accountUuid: details.fromAccount!.uuid,
                                  ),
                                ),
                              )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    TransferAccountBox(
                      account: details.toAccount,
                      theme: theme,
                      showBorder: false,
                      onAccountTap: details.toAccount != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountDetailScreen(
                                    accountUuid: details.toAccount!.uuid,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AmountFormatter.formatWithCurrency(
                        t.amount, symbol, decimals),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateFormatter.formatDate(t.date, pattern: dateFormat),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (desc != null && desc.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Symbols.notes,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
