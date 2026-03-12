import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/data/transaction_scenarios.dart';
import 'package:flowpaisa/features/transactions/domain/transaction_scenario.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

/// Returns the localized label for a scenario [id].
String getScenarioLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'scenarioPaidForMeal':
      return l10n.scenarioPaidForMeal;
    case 'scenarioBoughtForSomeone':
      return l10n.scenarioBoughtForSomeone;
    case 'scenarioLentMoney':
      return l10n.scenarioLentMoney;
    case 'scenarioPaidBillForSomeone':
      return l10n.scenarioPaidBillForSomeone;
    case 'scenarioSplitYouPaid':
      return l10n.scenarioSplitYouPaid;
    case 'scenarioFriendPaidMeal':
      return l10n.scenarioFriendPaidMeal;
    case 'scenarioSomeonePaidBill':
      return l10n.scenarioSomeonePaidBill;
    case 'scenarioColleaguePaidForYou':
      return l10n.scenarioColleaguePaidForYou;
    case 'scenarioSplitTheyPaid':
      return l10n.scenarioSplitTheyPaid;
    case 'scenarioPaySomeoneForServices':
      return l10n.scenarioPaySomeoneForServices;
    case 'scenarioBorrowedCash':
      return l10n.scenarioBorrowedCash;
    case 'scenarioLoanReceived':
      return l10n.scenarioLoanReceived;
    case 'scenarioBorrowedFromContact':
      return l10n.scenarioBorrowedFromContact;
    case 'scenarioSalaryAdvance':
      return l10n.scenarioSalaryAdvance;
    case 'scenarioReceivedToRepay':
      return l10n.scenarioReceivedToRepay;
    case 'scenarioSalaryPending':
      return l10n.scenarioSalaryPending;
    case 'scenarioClientPaymentPending':
      return l10n.scenarioClientPaymentPending;
    case 'scenarioPaymentPending':
      return l10n.scenarioPaymentPending;
    case 'scenarioRentPending':
      return l10n.scenarioRentPending;
    case 'scenarioSalePending':
      return l10n.scenarioSalePending;
    case 'scenarioInvoicePending':
      return l10n.scenarioInvoicePending;
    case 'scenarioPersonalExpense':
      return l10n.scenarioPersonalExpense;
    case 'scenarioBillPaid':
      return l10n.scenarioBillPaid;
    case 'scenarioSubscription':
      return l10n.scenarioSubscription;
    case 'scenarioSalaryReceived':
      return l10n.scenarioSalaryReceived;
    case 'scenarioFreelanceIncome':
      return l10n.scenarioFreelanceIncome;
    case 'scenarioGiftReceived':
      return l10n.scenarioGiftReceived;
    case 'scenarioRefundReceived':
      return l10n.scenarioRefundReceived;
    default:
      return id;
  }
}

/// Shows a bottom sheet listing transaction scenarios. On tap, [onScenarioSelected]
/// is called with the scenario's type and relationship, then the sheet is closed.
/// Includes an "Auto suggest" toggle at the top to control auto-show on manual add.
Future<void> showTransactionScenarioPicker(
  BuildContext context, {
  required void Function(String type, String? relationship) onScenarioSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => _TransactionScenarioPicker(
        scrollController: scrollController,
        onScenarioSelected: onScenarioSelected,
      ),
    ),
  );
}

class _TransactionScenarioPicker extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final void Function(String type, String? relationship) onScenarioSelected;

  const _TransactionScenarioPicker({
    required this.scrollController,
    required this.onScenarioSelected,
  });

  @override
  ConsumerState<_TransactionScenarioPicker> createState() =>
      _TransactionScenarioPickerState();
}

class _TransactionScenarioPickerState
    extends ConsumerState<_TransactionScenarioPicker> {
  bool _autoSuggest = true;

  @override
  void initState() {
    super.initState();
    _loadAutoSuggest();
  }

  Future<void> _loadAutoSuggest() async {
    final repo = ref.read(userPreferencesRepositoryProvider);
    final value = await repo.getAutoSuggestTransactionScenario();
    if (mounted) setState(() => _autoSuggest = value);
  }

  Future<void> _onAutoSuggestChanged(bool value) async {
    setState(() => _autoSuggest = value);
    final repo = ref.read(userPreferencesRepositoryProvider);
    await repo.setAutoSuggestTransactionScenario(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.scenarioHelpTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.autoSuggest,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _autoSuggest,
                  onChanged: _onAutoSuggestChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: TransactionScenarios.all.length,
              itemBuilder: (context, index) {
                final scenario = TransactionScenarios.all[index];
                return _ScenarioTile(
                  scenario: scenario,
                  label: getScenarioLabel(l10n, scenario.id),
                  onTap: () {
                    widget.onScenarioSelected(scenario.type, scenario.relationship);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  final TransactionScenario scenario;
  final String label;
  final VoidCallback onTap;

  const _ScenarioTile({
    required this.scenario,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = scenario.isExpense;
    final typeColor =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    final relationshipColor = scenario.relationship != null
        ? AppColors.getRelationshipColor(scenario.relationship)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(scenario.icon, color: typeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          label: isExpense ? l10n.expense : l10n.income,
                          color: typeColor,
                        ),
                        if (relationshipColor != null) ...[
                          const SizedBox(width: 6),
                          _Chip(
                            label: scenario.relationship == 'PAID_FOR' ||
                                    scenario.relationship == 'WILL_RECEIVE'
                                ? l10n.receivable
                                : l10n.payable,
                            color: relationshipColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
