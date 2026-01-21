import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';

class TransactionShareButton extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;

  const TransactionShareButton({
    Key? key,
    required this.transaction,
    this.category,
    this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareOptions(context, ref),
      tooltip: 'Share Transaction',
    );
  }

  void _showShareOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareOptionsSheet(
        transaction: transaction,
        category: category,
        contact: contact,
        ref: ref,
      ),
    );
  }
}

class _ShareOptionsSheet extends StatefulWidget {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;
  final WidgetRef ref;

  const _ShareOptionsSheet({
    required this.transaction,
    this.category,
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
            'Share Transaction',
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
      final currencySymbol = widget.ref.read(currencySymbolProvider);
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? 'Someone';
      final senderPhone = userProfile.phone ?? '';

      // Ensure external ID is persisted before sharing
      final effectiveExternalId = await transactionService.ensureExternalLinkId(
        transactionId: widget.transaction.id,
      );

      // Generate reciprocal link
      final link = deepLinkService.generateReciprocalLink(
        senderName: senderName,
        senderPhone: senderPhone,
        relationship: widget.transaction.paidRelationship,
        amount: widget.transaction.amount,
        date: widget.transaction.date,
        description: widget.transaction.description,
        categoryName: widget.category?.name,
        categoryColor: widget.category?.color,
        categoryIcon: widget.category?.icon,
        externalLinkId: effectiveExternalId,
      );

      // Create dummy message for WhatsApp - ideally whatsAppService should handle this
      // but for now we follow the existing pattern if possible or adjust it.
      // whatsAppService.shareTransactionWithLink uses TransactionShareData.
      // I'll update WhatsAppService later if needed, but for now I'll use the link.

      String relationshipText = '';
      if (widget.transaction.paidRelationship == 'PAID_FOR') {
        relationshipText = 'I have recorded that I paid on your behalf';
      } else if (widget.transaction.paidRelationship == 'PAID_BY') {
        relationshipText = 'I have recorded that you paid for me';
      } else if (widget.transaction.paidRelationship == 'WILL_RECEIVE') {
        relationshipText = 'I have recorded that I am expecting a payment of';
      } else if (widget.transaction.paidRelationship == 'RECEIVED_FROM') {
        relationshipText =
            'I have recorded that I received *${AmountFormatter.formatWithCurrency(widget.transaction.amount, currencySymbol, 2)}* from you';
      } else {
        relationshipText = 'I have recorded a payment of';
      }

      final message = '''
💰 Transaction Recorded

$relationshipText *${AmountFormatter.formatWithCurrency(widget.transaction.amount, currencySymbol, 2)}* on *${AppDateFormatter.formatDate(widget.transaction.date, pattern: userProfile.dateFormat)}*.

${widget.transaction.description != null && widget.transaction.description!.isNotEmpty ? 'This was for _${widget.transaction.description}_.\n' : ''}
View and import this transaction in FlowPaisa:
$link
''';

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
        transactionId: widget.transaction.id,
      );

      // Generate reciprocal link
      final link = deepLinkService.generateReciprocalLink(
        senderName: senderName,
        senderPhone: senderPhone,
        relationship: widget.transaction.paidRelationship,
        amount: widget.transaction.amount,
        date: widget.transaction.date,
        description: widget.transaction.description,
        categoryName: widget.category?.name,
        categoryColor: widget.category?.color,
        categoryIcon: widget.category?.icon,
        externalLinkId: effectiveExternalId,
      );

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
