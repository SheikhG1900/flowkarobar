import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/add_edit_account_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_transfer_sheet.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/pay_bill_sheet.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/transfer_account_box.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountDetailScreen extends ConsumerWidget {
  final String accountUuid;

  const AccountDetailScreen({super.key, required this.accountUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accountAsync =
        ref.watch(accountDetailWithBalanceProvider(accountUuid));

    return accountAsync.when(
      data: (awb) {
        if (awb == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.accountNotFound)),
          );
        }
        return _AccountDetailView(awb: awb);
      },
      loading: () => const Scaffold(body: AppLoadingIndicator()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
      ),
    );
  }
}

const _kAppBarExpandedHeight = 220.0;

/// App bar hero gradient — richer in light mode, deeper in dark mode.
LinearGradient _accountDetailHeaderGradient(
    Color accountColor, ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  if (isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accountColor,
        Color.lerp(accountColor, theme.colorScheme.surface, 0.25)!,
        Color.lerp(accountColor, const Color(0xFF0D0D0D), 0.25)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(Colors.white, accountColor, 0.82)!,
      accountColor,
      Color.lerp(accountColor, Colors.white, 0.22)!,
    ],
    stops: const [0.0, 0.42, 1.0],
  );
}

Color _accountDetailCardFill(ThemeData theme) => theme.cardColor;

class _AccountDetailView extends ConsumerStatefulWidget {
  final AccountWithBalance awb;

  const _AccountDetailView({required this.awb});

  @override
  ConsumerState<_AccountDetailView> createState() => _AccountDetailViewState();
}

class _AccountDetailViewState extends ConsumerState<_AccountDetailView> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final collapsed = _scrollController.hasClients &&
        _scrollController.offset >= _kAppBarExpandedHeight - kToolbarHeight;
    if (collapsed != _isAppBarCollapsed) {
      setState(() => _isAppBarCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final acc = widget.awb.account;
    final type = widget.awb.type;

    final accountColor = acc.color != null
        ? Color(int.parse(acc.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;
    final iconData = IconHelper.getIconData(acc.icon) ?? _defaultIcon(type);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero header with gradient
          SliverAppBar(
            expandedHeight: _kAppBarExpandedHeight,
            pinned: true,
            backgroundColor: accountColor,
            iconTheme: const IconThemeData(color: Colors.white),
            title: _isAppBarCollapsed
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(iconData, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          acc.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: Colors.white,
                tooltip: l10n.editAccount,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditAccountScreen(account: acc)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.white,
                tooltip: l10n.deleteAccount,
                onPressed: () => _confirmDelete(context, ref, l10n),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: _accountDetailHeaderGradient(accountColor, theme),
                ),
                child: SafeArea(
                  child: Tooltip(
                    message: l10n.openTransactionsForAccount,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final n =
                              ref.read(transactionsPaginatedProvider.notifier);
                          n.search('');
                          n.applyFilters(
                            TransactionFilters(accountUuids: [acc.uuid]),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransactionsListScreen(),
                            ),
                          );
                        },
                        splashColor: Colors.white24,
                        highlightColor: Colors.white10,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon & Name row
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(iconData,
                                        color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          acc.name,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _typeLabel(l10n, type),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Balance label & value
                              Text(
                                type.isCreditCard
                                    ? (widget.awb.creditBalance > 0
                                        ? l10n.creditBalance
                                        : l10n.outstandingBalance)
                                    : l10n.currentBalance,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.isCreditCard
                                    ? (widget.awb.creditBalance > 0
                                        // Overpaid — show credit balance as positive
                                        ? AmountFormatter.formatWithCurrency(
                                            widget.awb.creditBalance,
                                            symbol,
                                            decimals)
                                        // Normal outstanding — show as (amount)
                                        : '(${AmountFormatter.formatWithCurrency(widget.awb.balance.abs(), symbol, decimals)})')
                                    : AmountFormatter.formatWithCurrency(
                                        widget.awb.balance, symbol, decimals),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credit card stats
                  if (type.isCreditCard) ...[
                    _CreditCardStatsCard(
                      awb: widget.awb,
                      accountColor: accountColor,
                      symbol: symbol,
                      decimals: decimals,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons — app gradient button
                  if (type.isCreditCard)
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: l10n.payBill,
                        gradient: AppColors.getPrimaryGradient(accountColor),
                        icon: Symbols.payments,
                        foreColor: Colors.white,
                        onPressed: () => _showPayBillSheet(context, widget.awb),
                        width: double.infinity,
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: l10n.transferMoney,
                        gradient: AppColors.getPrimaryGradient(accountColor),
                        icon: Symbols.swap_horiz,
                        foreColor: Colors.white,
                        onPressed: () => _showTransferSheet(
                          context,
                          fromAccountUuid: acc.uuid,
                        ),
                        width: double.infinity,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Account information card
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.openingBalance,
                        value: AmountFormatter.formatWithCurrency(
                          acc.openingBalance,
                          symbol,
                          decimals,
                        ),
                      ),
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.openingDate,
                        value: AppDateFormatter.formatDate(
                          acc.openingDate,
                          pattern: dateFormat,
                        ),
                      ),
                      if (type.isCreditCard) ...[
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.credit_score_outlined,
                          label: l10n.creditLimit,
                          value: AmountFormatter.formatWithCurrency(
                            acc.creditLimit ?? 0,
                            symbol,
                            decimals,
                          ),
                        ),
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.calendar_month_outlined,
                          label: l10n.billingCycleDay,
                          value: l10n.dayLabel(acc.billingCycleDay ?? 1),
                        ),
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.alarm_outlined,
                          label: l10n.paymentDueDays,
                          value:
                              '${acc.paymentDueDays ?? 20} ${l10n.daysSuffix}',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  _TransfersSection(accountUuid: acc.uuid),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferSheet(
    BuildContext context, {
    String? fromAccountUuid,
    String? toAccountUuid,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountTransferSheet(
        preselectedFromUuid: fromAccountUuid,
        preselectedToUuid: toAccountUuid,
      ),
    );
  }

  void _showPayBillSheet(BuildContext context, AccountWithBalance awb) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayBillSheet(creditCard: awb),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.expenseColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        final repo = ref.read(accountsRepositoryProvider);
        await repo.deleteAccount(widget.awb.account.uuid);
        if (context.mounted) {
          ToastUtils.showSuccessToast(context, ref, l10n.accountDeleted);
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
        }
      }
    }
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

// ────────────────────────────────────────────────────────────
// Credit Card Stats Card — billed / unbilled / available
// ────────────────────────────────────────────────────────────
class _CreditCardStatsCard extends StatelessWidget {
  final AccountWithBalance awb;
  final Color accountColor;
  final String symbol;
  final int decimals;

  const _CreditCardStatsCard({
    required this.awb,
    required this.accountColor,
    required this.symbol,
    required this.decimals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Bar 1: Outstanding vs Available Credit ────────────────────
        if (awb.account.creditLimit != null &&
            (awb.account.creditLimit ?? 0) > 0)
          _CreditProgressBar(
            leftLabel: l10n.outstanding,
            leftAmount: awb.balance < 0 ? awb.balance.abs() : 0.0,
            rightLabel: l10n.availableCredit,
            rightAmount: awb.availableCredit ?? 0.0,
            symbol: symbol,
            decimals: decimals,
            filledColor: awb.balance < 0 &&
                    awb.balance.abs() / (awb.account.creditLimit ?? 1) > 0.8
                ? AppColors.expenseColor
                : accountColor,
          ),

        // ── Bar 2: Amount Due vs Unbilled Amount ──────────────────────
        if ((awb.dueAmount ?? 0) > 0 || (awb.unbilledAmount ?? 0) > 0) ...[
          const SizedBox(height: 12),
          _CreditProgressBar(
            leftLabel: l10n.amountDue,
            leftAmount: awb.dueAmount ?? 0.0,
            rightLabel: l10n.unbilledAmount,
            rightAmount: awb.unbilledAmount ?? 0.0,
            symbol: symbol,
            decimals: decimals,
            filledColor: accountColor,
            rightFilledColor: theme.colorScheme.primary,
            cornerPercents: true,
            comparisonMode: true,
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// Filled progress bar (contact-details style) for credit card
// ────────────────────────────────────────────────────────────
class _CreditProgressBar extends StatelessWidget {
  final String leftLabel;
  final double leftAmount;
  final String rightLabel;
  final double rightAmount;
  final String symbol;
  final int decimals;

  /// Color for the left / filled side.
  final Color filledColor;

  /// Optional independent color for the right side.
  /// Falls back to [filledColor] when null.
  final Color? rightFilledColor;

  /// When true, shows individual % badges at left/right corners instead of
  /// a single centred badge.
  final bool cornerPercents;

  /// When true, renders a split comparison bar (both sides solid-filled)
  /// instead of a left-to-right progress fill.
  final bool comparisonMode;

  const _CreditProgressBar({
    required this.leftLabel,
    required this.leftAmount,
    required this.rightLabel,
    required this.rightAmount,
    required this.symbol,
    required this.decimals,
    required this.filledColor,
    this.rightFilledColor,
    this.cornerPercents = false,
    this.comparisonMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = leftAmount + rightAmount;
    final percent = total > 0 ? (leftAmount / total).clamp(0.0, 1.0) : 0.0;
    final rightPercent = 1.0 - percent;
    // Resolved right color — falls back to filledColor when not provided.
    final resolvedRightColor = rightFilledColor ?? filledColor;

    final formattedLeft =
        AmountFormatter.formatWithCurrency(leftAmount, symbol, decimals);
    final formattedRight =
        AmountFormatter.formatWithCurrency(rightAmount, symbol, decimals);

    // ── Corner-percent layout: label / % badge / amount stacked vertically ─
    Widget buildCornerRow(Color leftColor, Color rightColor) {
      Widget corner({
        required String label,
        required String percentText,
        required String amount,
        required Color color,
        required Color badgeBorderColor,
        required CrossAxisAlignment align,
      }) =>
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: align,
            children: [
              // Label
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Percent badge — same card+border style as centred badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeBorderColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  percentText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Amount
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            corner(
              label: leftLabel,
              percentText: '${(percent * 100).toStringAsFixed(1)}%',
              amount: formattedLeft,
              color: leftColor,
              badgeBorderColor: filledColor,
              align: CrossAxisAlignment.start,
            ),
            corner(
              label: rightLabel,
              percentText: '${(rightPercent * 100).toStringAsFixed(1)}%',
              amount: formattedRight,
              color: rightColor,
              badgeBorderColor: resolvedRightColor,
              align: CrossAxisAlignment.end,
            ),
          ],
        ),
      );
    }

    // ── Centre-badge layout (original) ────────────────────────────────────
    Widget buildCentreRow(Color leftColor, Color rightColor) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    leftLabel,
                    style: TextStyle(
                      color: leftColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedLeft,
                    style: TextStyle(
                      color: leftColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filledColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${(percent * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: filledColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rightLabel,
                    style: TextStyle(
                      color: rightColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedRight,
                    style: TextStyle(
                      color: rightColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildRow(Color leftColor, Color rightColor) => cornerPercents
        ? buildCornerRow(leftColor, rightColor)
        : buildCentreRow(leftColor, rightColor);

    // ── Comparison bar: two solid segments, values rendered inside each ──────
    if (comparisonMode) {
      Widget segment({
        required Color color,
        required Color textColor,
        required String label,
        required String percentText,
        required String amount,
        required CrossAxisAlignment align,
        required BorderRadius borderRadius,
      }) {
        return Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: align,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  percentText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  amount,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              segment(
                color: filledColor,
                textColor: Colors.white,
                label: leftLabel,
                percentText: '${(percent * 100).toStringAsFixed(1)}%',
                amount: formattedLeft,
                align: CrossAxisAlignment.start,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(16),
                  bottomStart: const Radius.circular(16),
                ).resolve(Directionality.of(context)),
              ),
              Container(width: 1.5, color: Colors.white.withValues(alpha: 0.4)),
              segment(
                color: resolvedRightColor,
                textColor: theme.colorScheme.onPrimary,
                label: rightLabel,
                percentText: '${((1 - percent) * 100).toStringAsFixed(1)}%',
                amount: formattedRight,
                align: CrossAxisAlignment.end,
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: const Radius.circular(16),
                  bottomEnd: const Radius.circular(16),
                ).resolve(Directionality.of(context)),
              ),
            ],
          ),
        ),
      );
    }

    // ── Progress bar (bar 1 and default) ─────────────────────────────────────
    return Container(
      height: cornerPercents ? 80 : 64,
      decoration: BoxDecoration(
        color: cornerPercents
            ? Color.lerp(filledColor, resolvedRightColor, 0.5)!
                .withValues(alpha: 0.07)
            : filledColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cornerPercents
              ? Color.lerp(filledColor, resolvedRightColor, 0.5)!
                  .withValues(alpha: 0.5)
              : filledColor.withValues(alpha: 0.5),
          width: .5,
        ),
      ),
      child: Stack(
        children: [
          // Background row — right side uses resolvedRightColor in corner mode
          Align(
            alignment: Alignment.center,
            child: buildRow(
              filledColor,
              cornerPercents
                  ? resolvedRightColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          // Filled portion — clips left-to-right
          ClipRect(
            child: Align(
              alignment: Directionality.of(context) == TextDirection.rtl
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: filledColor.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: buildRow(Colors.white, Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditStat extends StatelessWidget {
  final String label;
  final double amount;
  final String symbol;
  final int decimals;
  final Color color;

  const _CreditStat({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.decimals,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            AmountFormatter.formatWithCurrency(amount, symbol, decimals),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Info card & row
// ────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _accountDetailCardFill(theme),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Transfers section for account detail
// ────────────────────────────────────────────────────────────
class _TransfersSection extends ConsumerWidget {
  final String accountUuid;

  const _TransfersSection({required this.accountUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final transfersAsync = ref.watch(transfersForAccountProvider(accountUuid));
    final cashbookAccent = ref.watch(activeCashbookProvider).color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.transfers.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        transfersAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.noTransfers,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  Container(
                    decoration: AppColors.transactionListItemDecoration(
                      theme,
                      cashbookAccent,
                    ),
                    child: _TransferTile(
                      details: list[i],
                      currentAccountUuid: accountUuid,
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TransferTile extends ConsumerWidget {
  final AccountTransferWithDetails details;
  final String currentAccountUuid;

  const _TransferTile({
    required this.details,
    required this.currentAccountUuid,
  });

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      hideName: details.fromAccount?.uuid == currentAccountUuid,
                      onAccountTap: details.fromAccount != null &&
                              details.fromAccount!.uuid != currentAccountUuid
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
                      hideName: details.toAccount?.uuid == currentAccountUuid,
                      onAccountTap: details.toAccount != null &&
                              details.toAccount!.uuid != currentAccountUuid
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
