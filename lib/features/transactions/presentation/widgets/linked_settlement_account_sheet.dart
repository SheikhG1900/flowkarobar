import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picked account UUID, or `null` to settle without assigning an account.
/// Sheet returns `null` if the user cancelled.
typedef SettlementAccountChoice = ({bool keepTransactionAccount, String? accountUuid});

/// Settlement sheet with [AccountPickerField] (create account when needed), cancel,
/// continue without account, and primary action with a selected account.
Future<SettlementAccountChoice?> showLinkedSettlementAccountSheet(
  BuildContext context, {
  required bool isPayable,
  Account? initialAccount,
  bool showKeepOption = true,
}) {
  return showModalBottomSheet<SettlementAccountChoice>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _LinkedSettlementAccountSheet(
      isPayable: isPayable,
      initialAccount: initialAccount,
      showKeepOption: showKeepOption,
    ),
  );
}

/// Resolves default account: [initialAccount] if set, else match
/// [transactionForAccountDefault.accountUuid] against [accountsList].
///
/// For **receive** ([isPayable] false), never pre-select a **credit card** — e.g. PAID_FOR
/// expenses often use a card, but income/receive must not default to card ([AccountPickerField]
/// already excludes cards from the list).
Account? resolveSettlementInitialAccount(
  List<Account> accountsList,
  Account? initialAccount,
  Transaction? transactionForAccountDefault, {
  required bool isPayable,
}) {
  Account? resolved;
  if (initialAccount != null) {
    resolved = initialAccount;
  } else {
    final uuid = transactionForAccountDefault?.accountUuid;
    if (uuid != null && uuid.isNotEmpty) {
      for (final a in accountsList) {
        if (a.uuid == uuid) {
          resolved = a;
          break;
        }
      }
    }
  }
  if (resolved == null) return null;
  if (!isPayable && AccountType.fromValue(resolved.type).isCreditCard) {
    return null;
  }
  return resolved;
}

/// Always opens the settlement sheet so the user can pick, create, or skip account.
///
/// Loads accounts via [AccountsRepository.getAllAccounts] (always completes), unlike
/// `StreamProvider.future` which could hang if the stream never emits to this listener.
/// Returns `null` if cancelled. Otherwise [SettlementAccountChoice] with optional UUID.
Future<SettlementAccountChoice?> resolveSettlementAccountChoice(
  BuildContext context,
  WidgetRef ref, {
  required bool isPayable,
  Account? initialAccount,
  Transaction? transactionForAccountDefault,
  bool showKeepOption = true,
}) async {
  List<Account> accountsList;
  try {
    accountsList = await ref.read(accountsRepositoryProvider).getAllAccounts();
  } catch (_) {
    accountsList = const [];
  }

  if (!context.mounted) return null;

  final effectiveInitial = accountsList.isEmpty
      ? null
      : resolveSettlementInitialAccount(
          accountsList,
          initialAccount,
          transactionForAccountDefault,
          isPayable: isPayable,
        );
  return showLinkedSettlementAccountSheet(
    context,
    isPayable: isPayable,
    initialAccount: effectiveInitial,
    showKeepOption: showKeepOption,
  );
}

class _LinkedSettlementAccountSheet extends StatefulWidget {
  const _LinkedSettlementAccountSheet({
    required this.isPayable,
    this.initialAccount,
    this.showKeepOption = true,
  });

  final bool isPayable;
  final Account? initialAccount;
  final bool showKeepOption;

  @override
  State<_LinkedSettlementAccountSheet> createState() =>
      _LinkedSettlementAccountSheetState();
}

class _LinkedSettlementAccountSheetState
    extends State<_LinkedSettlementAccountSheet> {
  late Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initialAccount;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: bottomInset + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.isPayable ? l10n.markAsPaid : l10n.markAsReceived,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.isPayable
                ? l10n.markPendingAsPaidSubtitle
                : l10n.markReceivedSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AccountPickerField(
            selectedAccount: _selectedAccount,
            excludeCreditCard: !widget.isPayable,
            label: widget.isPayable ? l10n.payFrom : l10n.receiveInto,
            onChanged: (acc) => setState(() => _selectedAccount = acc),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.accountPickerInfoMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(
                  context,
                  (
                    keepTransactionAccount: false,
                    accountUuid: _selectedAccount?.uuid,
                  ),
                ),
            style: FilledButton.styleFrom(
              backgroundColor: widget.isPayable
                  ? AppColors.payableColor
                  : AppColors.receivableColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(widget.isPayable ? l10n.markAsPaid : l10n.markAsReceived),
          ),
          if (widget.showKeepOption) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(
                    context,
                    (
                      keepTransactionAccount: true,
                      accountUuid: null,
                    ),
                  ),
              child: Text(l10n.settlementContinueWithoutAccount),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
