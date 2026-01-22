import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class PayableShareButton extends ConsumerWidget {
  final Payable payable;
  final Contact? contact;

  const PayableShareButton({
    Key? key,
    required this.payable,
    this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareOptions(context, ref),
      tooltip: l10n.sharePaymentAcknowledgment,
    );
  }

  void _showShareOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareOptionsSheet(
        payable: payable,
        contact: contact,
        ref: ref,
      ),
    );
  }
}

class _ShareOptionsSheet extends StatefulWidget {
  final Payable payable;
  final Contact? contact;
  final WidgetRef ref;

  const _ShareOptionsSheet({
    required this.payable,
    this.contact,
    required this.ref,
  });

  @override
  State<_ShareOptionsSheet> createState() => _ShareOptionsSheetState();
}

class _ShareOptionsSheetState extends State<_ShareOptionsSheet> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sharePaymentAcknowledgment,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green),
            title: Text(l10n.shareViaWhatsApp),
            subtitle: widget.contact != null && widget.contact!.phone != null
                ? Text(l10n.toContact(widget.contact!.name))
                : Text(l10n.chooseContact),
            onTap: _isSharing
                ? null
                : () => _shareViaWhatsApp(context, widget.ref),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: Text(l10n.copyLink),
            subtitle: Text(l10n.copyDeepLinkSubtitle),
            onTap: _isSharing ? null : () => _copyLink(context, widget.ref),
          ),
          if (_isSharing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _shareViaWhatsApp(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSharing = true);

    try {
      final deepLinkService = DeepLinkService();
      final transactionService = widget.ref.read(transactionServiceProvider);
      final whatsAppService = widget.ref.read(whatsAppServiceProvider);
      final currencyAsync = widget.ref.read(currentCurrencyProvider);
      final currency = currencyAsync.value;
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? l10n.someone;
      final senderPhone = userProfile.phone ?? '';

      // Ensure external ID is persisted before sharing
      final effectiveExternalId = await transactionService.ensureExternalLinkId(
        payableId: widget.payable.id,
      );

      // Create share data for recipient (Receivable)
      final shareData = ReceivableShareData(
        amount: widget.payable.amount,
        description: widget.payable.description,
        date: widget.payable.date,
        dueDate: widget.payable.dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: effectiveExternalId,
        status: widget.payable.status,
      );

      final link = deepLinkService.generateReceivableLink(shareData);
      final isPaid = widget.payable.status == 'PAID';

      String message;
      if (isPaid) {
        message = l10n.sharePayableCompleted(
          amount: AmountFormatter.formatWithCurrency(widget.payable.amount,
              currency?.symbol ?? '', currency?.decimalPlaces ?? 2),
          date: AppDateFormatter.formatDate(widget.payable.date,
              pattern: userProfile.dateFormat),
          link: link,
        );
      } else {
        message = l10n.sharePayablePending(
          amount: AmountFormatter.formatWithCurrency(widget.payable.amount,
              currency?.symbol ?? '', currency?.decimalPlaces ?? 2),
          date: AppDateFormatter.formatDate(widget.payable.date,
              pattern: userProfile.dateFormat),
          link: link,
        );
      }

      await whatsAppService.sendMessage(widget.contact?.phone ?? '', message);

      if (context.mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, ref, l10n.openingWhatsApp);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.failedToShare(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _copyLink(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSharing = true);

    try {
      final deepLinkService = DeepLinkService();
      final transactionService = widget.ref.read(transactionServiceProvider);
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? l10n.someone;
      final senderPhone = userProfile.phone ?? '';

      // Ensure external ID is persisted before sharing
      final effectiveExternalId = await transactionService.ensureExternalLinkId(
        payableId: widget.payable.id,
      );

      // Create share data for recipient (Receivable)
      final shareData = ReceivableShareData(
        amount: widget.payable.amount,
        description: widget.payable.description,
        date: widget.payable.date,
        dueDate: widget.payable.dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: effectiveExternalId,
        status: widget.payable.status,
      );

      final link = deepLinkService.generateReceivableLink(shareData);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: link));

      if (context.mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.failedToCopyLink(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
