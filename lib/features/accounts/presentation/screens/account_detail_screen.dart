import 'package:flowpaisa/features/accounts/presentation/screens/account_statement_screen.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
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

    // Use the .value directly to keep the UI stable during refreshes
    final awb = accountAsync.value;

    if (awb == null) {
      if (accountAsync.isLoading) {
        return const Scaffold(body: AppLoadingIndicator());
      }
      if (accountAsync.hasError) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text(l10n.errorOccurred(accountAsync.error.toString())),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.accountNotFound)),
      );
    }

    return _AccountDetailView(awb: awb);
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final symbol = currency.symbol;
    final decimals = currency.decimalPlaces;
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
                icon: const Icon(Icons.link),
                color: Colors.white,
                tooltip: l10n.copyLink,
                onPressed: () {
                  final link = DeepLinkService()
                      .generateEntityOpenLinkHttps('account', acc.uuid);
                  Clipboard.setData(ClipboardData(text: link));
                  ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                },
              ),
              Builder(
                builder: (context) {
                  ref.watch(dashboardWidgetLayoutProvider);
                  final notifier =
                      ref.read(dashboardWidgetLayoutProvider.notifier);
                  final isPinned = notifier.isPinned(
                      DashboardWidgetKind.account, acc.uuid);
                  return IconButton(
                    icon: Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: isPinned ? Colors.white : Colors.white70,
                    ),
                    tooltip: isPinned
                        ? l10n.unpinFromDashboard
                        : l10n.pinToDashboard,
                    onPressed: () async {
                      if (isPinned) {
                        final layout =
                            ref.read(dashboardWidgetLayoutProvider).value ?? [];
                        final idx = layout.indexWhere((c) =>
                            c.kind == DashboardWidgetKind.account &&
                            c.accountUuid == acc.uuid);
                        if (idx >= 0) {
                          await ref
                              .read(dashboardWidgetLayoutProvider.notifier)
                              .removeAt(idx);
                          if (context.mounted) {
                            ToastUtils.showSuccessToast(
                                context, ref, l10n.unpinnedFromDashboard);
                          }
                        }
                      } else {
                        await ref
                            .read(dashboardWidgetLayoutProvider.notifier)
                            .addWidget(DashboardWidgetConfig(
                              kind: DashboardWidgetKind.account,
                              accountUuid: acc.uuid,
                            ));
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.pinnedToDashboard);
                        }
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                color: Colors.white,
                tooltip: l10n.accountStatement,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccountStatementScreen(account: acc),
                  ),
                ),
              ),
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
                                            currency)
                                        // Normal outstanding — show as (amount)
                                        : '(${AmountFormatter.formatWithCurrency(widget.awb.balance.abs(), currency)})')
                                    : AmountFormatter.formatWithCurrency(
                                        widget.awb.balance, currency),
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
                      currency: currency,
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
                          currency,
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
                            currency,
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
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expenseColor,
              foregroundColor: Colors.white,
            ),
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
  final AppCurrency currency;

  const _CreditCardStatsCard({
    required this.awb,
    required this.accountColor,
    required this.currency,
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
          DualAmountProgressBar(
            leftLabel: l10n.outstanding,
            leftAmount: awb.balance < 0 ? awb.balance.abs() : 0.0,
            rightLabel: l10n.availableCredit,
            rightAmount: awb.availableCredit ?? 0.0,
            currency: currency,
            filledColor: awb.balance < 0 &&
                    awb.balance.abs() / (awb.account.creditLimit ?? 1) > 0.8
                ? AppColors.expenseColor
                : accountColor,
          ),

        // ── Bar 2: Amount Due vs Unbilled Amount ──────────────────────
        if ((awb.dueAmount ?? 0) > 0 || (awb.unbilledAmount ?? 0) > 0) ...[
          const SizedBox(height: 12),
          DualAmountProgressBar(
            leftLabel: l10n.amountDue,
            leftAmount: awb.dueAmount ?? 0.0,
            rightLabel: l10n.unbilledAmount,
            rightAmount: awb.unbilledAmount ?? 0.0,
            currency: currency,
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

class _CreditStat extends StatelessWidget {
  final String label;
  final double amount;
  final AppCurrency currency;
  final Color color;

  const _CreditStat({
    required this.label,
    required this.amount,
    required this.currency,
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
            AmountFormatter.formatWithCurrency(amount, currency),
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
    final cashbookAccent = ref.watch(activeBusinessProvider).color;

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
        Builder(
          builder: (context) {
            final list = transfersAsync.value;

            if (list == null) {
              if (transfersAsync.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

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
                          existingTransfer: list[i].transfer,
                        ),
                      );
                    },
                    onDelete: () async {
                      await ref
                          .read(accountsRepositoryProvider)
                          .deleteTransfer(list[i].transfer.uuid);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.transferDeleted);
                      }
                    },
                    child: _TransferTile(
                      details: list[i],
                      currentAccountUuid: accountUuid,
                      cashbookAccent: cashbookAccent,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                const FadedBottomLogo(bottomPadding: 40),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TransferTile extends ConsumerStatefulWidget {
  final AccountTransferWithDetails details;
  final String currentAccountUuid;
  final Color cashbookAccent;

  const _TransferTile({
    required this.details,
    required this.currentAccountUuid,
    required this.cashbookAccent,
  });

  @override
  ConsumerState<_TransferTile> createState() => _TransferTileState();
}

class _TransferTileState extends ConsumerState<_TransferTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final currentAccountUuid = widget.currentAccountUuid;
    final cashbookAccent = widget.cashbookAccent;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final symbol = currency.symbol;
    final decimals = currency.decimalPlaces;
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final t = details.transfer;
    final desc = t.description?.trim();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isHovered
              ? cashbookAccent
              : cashbookAccent.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cashbookAccent.withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHover: (hovering) {
              setState(() {
                _isHovered = hovering;
              });
            },
            hoverColor: Colors.transparent,
            onTap: () {}, // InkWell needs onTap to show hover effects, we already have SwipeableListItem for slides/actions
            borderRadius: BorderRadius.circular(19),
            child: Padding(
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
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                TransferAccountBox(
                                  account: details.fromAccount,
                                  theme: theme,
                                  arrowBesideIcon: true,
                                  showBorder: false,
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
                                if (t.isNotSynced == true)
                                  Positioned(
                                    right: -3,
                                    bottom: -3,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.orange.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 10,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            TransferAccountBox(
                              account: details.toAccount,
                              theme: theme,
                              showBorder: false,
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
                                t.amount, currency),
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
            ),
          ),
        ),
      ),
    );
  }
}
