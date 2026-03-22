import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

/// Localized label for a settled split line: **Paid** when linked to a payable,
/// **Received** when linked to a receivable — same rule as
/// [SplittedTransactionsScreen] sibling rows.
String? splitShareSettledStatusLabel(
  AppLocalizations l10n,
  Payable? linkedPayable,
  Receivable? linkedReceivable,
) {
  final isSettled = (linkedPayable?.status == 'PAID') ||
      (linkedReceivable?.status == 'RECEIVED');
  if (!isSettled) return null;
  return linkedPayable != null ? l10n.paid : l10n.receivedLabel;
}
