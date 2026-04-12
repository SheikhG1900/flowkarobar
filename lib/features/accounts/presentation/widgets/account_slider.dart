import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A reusable horizontal slider for accounts, matching the design in AccountsScreen.
class AccountSlider extends ConsumerWidget {
  final bool showHeader;
  const AccountSlider({super.key, this.showHeader = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final awb = accounts[index];
                  return _AccountCard(
                    awb: awb,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AccountDetailScreen(accountUuid: awb.account.uuid),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

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

    final String balanceText = type.isCreditCard
        ? (awb.creditBalance > 0
            ? AmountFormatter.formatWithCurrency(
                awb.creditBalance, symbol, decimals)
            : '($symbol${AmountFormatter.formatAmount(awb.balance.abs(), decimals)})')
        : AmountFormatter.formatWithCurrency(awb.balance, symbol, decimals);

    return Container(
      width: 280,
      height: 185,
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
                      color: accountColor.withValues(alpha: isDark ? 0.5 : 0.7),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
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
