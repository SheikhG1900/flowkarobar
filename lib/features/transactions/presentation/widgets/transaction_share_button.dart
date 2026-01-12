import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/whatsapp/domain/whatsapp_service.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

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
            onTap: _isSharing ? null : () => _shareViaWhatsApp(context),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy Link'),
            subtitle: const Text('Copy deep link to clipboard'),
            onTap: _isSharing ? null : () => _copyLink(context),
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

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    setState(() => _isSharing = true);

    try {
      final deepLinkService = DeepLinkService();
      final whatsAppService = widget.ref.read(whatsAppServiceProvider);
      final currencySymbol = widget.ref.read(currencySymbolProvider);

      // Create share data
      final shareData = TransactionShareData(
        amount: widget.transaction.amount,
        transactionType: widget.transaction.type,
        description: widget.transaction.description,
        date: widget.transaction.date,
        categoryName: widget.category?.name,
        contactName: widget.contact?.name,
        contactPhone: widget.contact?.phone,
        externalLinkId: deepLinkService.generateExternalLinkId(),
      );

      // Share via WhatsApp
      await whatsAppService.shareTransactionWithLink(
        transaction: shareData,
        contactPhone: widget.contact?.phone,
        currencySymbol: currencySymbol,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, 'Opening WhatsApp...');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, 'Failed to share: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    setState(() => _isSharing = true);

    try {
      final deepLinkService = DeepLinkService();

      // Create share data
      final shareData = TransactionShareData(
        amount: widget.transaction.amount,
        transactionType: widget.transaction.type,
        description: widget.transaction.description,
        date: widget.transaction.date,
        categoryName: widget.category?.name,
        contactName: widget.contact?.name,
        contactPhone: widget.contact?.phone,
        externalLinkId: deepLinkService.generateExternalLinkId(),
      );

      // Generate link
      final link = deepLinkService.generateTransactionLink(shareData);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: link));

      if (context.mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, 'Link copied to clipboard!');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, 'Failed to copy link: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
