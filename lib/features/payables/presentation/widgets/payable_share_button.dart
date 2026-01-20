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
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareOptions(context, ref),
      tooltip: 'Share Payment Acknowledgment',
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Payment Acknowledgment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green),
            title: const Text('Share via WhatsApp'),
            subtitle: widget.contact != null && widget.contact!.phone != null
                ? Text('To ${widget.contact!.name}')
                : const Text('Choose contact'),
            onTap: _isSharing
                ? null
                : () => _shareViaWhatsApp(context, widget.ref),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy Link'),
            subtitle: const Text('Copy deep link to clipboard'),
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
    setState(() => _isSharing = true);

    try {
      final deepLinkService = DeepLinkService();
      final transactionService = widget.ref.read(transactionServiceProvider);
      final whatsAppService = widget.ref.read(whatsAppServiceProvider);
      final currencyAsync = widget.ref.read(currentCurrencyProvider);
      final currency = currencyAsync.value;
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? 'Someone';
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
        message = '''
Hi ${widget.contact?.name ?? 'there'},

Greetings! 

The payment of ${AmountFormatter.formatWithCurrency(widget.payable.amount, currency?.symbol ?? '', currency?.decimalPlaces ?? 2)} dated ${AppDateFormatter.formatDate(widget.payable.date, pattern: userProfile.dateFormat)} has been completed and recorded. 

If you haven't updated this payment in FlowPaisa, please follow the link below to sync your records:
$link

Thank you!
''';
      } else {
        message = '''
📋 Payment Acknowledgment
I owe you: ${currency?.symbol ?? ''}${widget.payable.amount.toStringAsFixed(currency?.decimalPlaces ?? 2)}
Date: ${widget.payable.date.day}/${widget.payable.date.month}/${widget.payable.date.year}

View and record this in FlowPaisa:
$link
''';
      }

      await whatsAppService.sendMessage(widget.contact?.phone ?? '', message);

      if (context.mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, ref, 'Opening WhatsApp...');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, 'Failed to share: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _copyLink(BuildContext context, WidgetRef ref) async {
    setState(() => _isSharing = true);

    try {
      final deepLinkService = DeepLinkService();
      final transactionService = widget.ref.read(transactionServiceProvider);
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? 'Someone';
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
        ToastUtils.showSuccessToast(context, ref, 'Link copied to clipboard!');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, 'Failed to copy link: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
