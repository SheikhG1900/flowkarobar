import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/features/currencies/presentation/screens/add_currency_screen.dart';
import 'package:flowpaisa/features/currencies/presentation/screens/edit_currency_screen.dart';
import 'package:flowpaisa/shared/widgets/glass_card.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

class CurrenciesListScreen extends ConsumerWidget {
  const CurrenciesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currenciesAsync = ref.watch(currenciesListProvider);
    final selectedCurrencyIdAsync = ref.watch(selectedCurrencyIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currencies),
      ),
      body: currenciesAsync.when(
        data: (currencies) {
          if (currencies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.currency_exchange,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCurrencies,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          final selectedCurrencyId = selectedCurrencyIdAsync.value;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = currency.uuid == selectedCurrencyId;
              return _CurrencyCard(
                currency: currency,
                isSelected: isSelected,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(l10n.errorOccurred(error.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCurrencyScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _CurrencyCard extends ConsumerWidget {
  final AppCurrency currency;
  final bool isSelected;

  const _CurrencyCard({
    required this.currency,
    required this.isSelected,
  });

  Future<void> _deleteCurrency(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(currenciesRepositoryProvider);

    try {
      await repository.deleteCurrency(currency.uuid);
      if (context.mounted) {
        ToastUtils.showSuccessToast(
            context, ref, l10n.currencyDeleted);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _selectCurrency(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(currencyNotifierProvider.notifier);
    await notifier.setSelectedCurrency(currency.uuid);

    if (context.mounted) {
      ToastUtils.showSuccessToast(
          context, ref, l10n.currencySetTo(currency.name));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : AppColors.secondaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SwipeableListItem(
        enableEdit: true,
        enableDelete: !currency.isDefault,
        editBackgroundColor: color,
        deleteBackgroundColor: AppColors.error,
        borderRadius: 16,
        backgroundMargin: const EdgeInsets.only(bottom: 12),
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCurrencyScreen(currency: currency),
            ),
          );
        },
        onDelete: currency.isDefault
            ? null
            : () async {
                await _deleteCurrency(context, ref);
              },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () => _selectCurrency(context, ref),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(
                        alpha:
                            theme.brightness == Brightness.dark ? 0.1 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: currency.symbol.isEmpty
                      ? Icon(Icons.money_off, size: 20, color: color)
                      : Text(
                          currency.symbol,
                          style: TextStyle(
                            fontSize: 24,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currency.code,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                if (currency.isDefault)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.defaultLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
