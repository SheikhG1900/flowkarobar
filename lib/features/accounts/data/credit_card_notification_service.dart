import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';

/// Checks all active credit card accounts and generates payment due notifications.
///
/// Called on app start. Notifications are generated:
/// - Up to paymentDueDays before due date
/// - On the due date (isUrgent = true)
/// - After due date (overdue, isUrgent = true) — stops after 7 days overdue
class CreditCardNotificationService {
  final AccountsRepository _repo;

  CreditCardNotificationService(this._repo);

  Future<void> checkAndNotify({
    required String currencySymbol,
    required int decimals,
    required void Function({
      required String title,
      required String message,
      required NotificationType type,
      required bool isUrgent,
    }) addNotification,
  }) async {
    final accounts = await _repo.getAllAccounts();
    final creditCards =
        accounts.where((a) => AccountType.fromValue(a.type).isCreditCard);

    for (final card in creditCards) {
      final dueDate = _repo.getNextDueDate(card);
      if (dueDate == null) continue;

      final due = await _repo.getCreditCardDueAmount(card);
      if (due < 0.01) continue; // Nothing due

      final now = DateTime.now();
      final daysUntilDue = dueDate.difference(now).inDays;
      final daysOverdue = now.difference(dueDate).inDays;

      final amountText =
          '$currencySymbol${AmountFormatter.formatAmount(due, decimals)}';

      // Stop notifying 7 days after due date (user probably knows)
      if (daysOverdue > 7) continue;

      String title;
      String message;
      bool isUrgent;

      if (daysOverdue > 0) {
        // Overdue
        title = card.name;
        message =
            'Payment of $amountText is overdue by $daysOverdue day${daysOverdue == 1 ? '' : 's'}';
        isUrgent = true;
      } else if (daysUntilDue == 0) {
        // Due today
        title = card.name;
        message = 'Payment of $amountText is due today!';
        isUrgent = true;
      } else if (daysUntilDue <= (card.paymentDueDays ?? 5)) {
        // Upcoming
        title = card.name;
        message =
            'Payment of $amountText is due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'}';
        isUrgent = daysUntilDue <= 2;
      } else {
        continue; // Not yet time to notify
      }

      addNotification(
        title: title,
        message: message,
        type: NotificationType.creditCard,
        isUrgent: isUrgent,
      );
    }
  }
}
