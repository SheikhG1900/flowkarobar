import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/amount_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/accounts_provider.dart';
import '../../domain/models/account_models.dart';
import '../../../../core/utils/icon_helper.dart';

class CombineBalancesSheet extends ConsumerStatefulWidget {
  const CombineBalancesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CombineBalancesSheet(),
    );
  }

  @override
  ConsumerState<CombineBalancesSheet> createState() => _CombineBalancesSheetState();
}

class _CombineBalancesSheetState extends ConsumerState<CombineBalancesSheet> {
  final Set<String> _selectedAccountUuids = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final symbol = ref.watch(currencySymbolProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.combineBalances,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const SizedBox(height: 100);
                }

                // Calculate total
                double total = 0;
                for (final acc in accounts) {
                  if (_selectedAccountUuids.contains(acc.account.uuid)) {
                    total += acc.balance;
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        l10n.selectAccountsToCombine,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final acc = accounts[index];
                          final isSelected =
                              _selectedAccountUuids.contains(acc.account.uuid);

                          final accountColor = acc.account.color != null
                              ? Color(int.parse(
                                  acc.account.color!.replaceAll('#', '0xFF')))
                              : theme.colorScheme.primary;

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedAccountUuids.add(acc.account.uuid);
                                } else {
                                  _selectedAccountUuids.remove(acc.account.uuid);
                                }
                              });
                            },
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accountColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconHelper.getIconData(acc.account.icon),
                                color: accountColor,
                                size: 20,
                              ),
                            ),
                            title: Text(acc.account.name),
                            subtitle: Text(
                              AmountFormatter.formatWithCurrency(
                                  acc.balance, symbol, decimals),
                              style: TextStyle(
                                color: acc.balance >= 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.selectedTotal,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AmountFormatter.formatWithCurrency(
                                total, symbol, decimals),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: total >= 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
              error: (e, s) => Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(e.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
