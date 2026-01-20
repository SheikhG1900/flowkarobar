import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';

class ReceivableShareButton extends ConsumerWidget {
  final Receivable receivable;
  final Contact? contact;

  const ReceivableShareButton({
    Key? key,
    required this.receivable,
    this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareOptions(context, ref),
      tooltip: 'Share Payment Request',
    );
  }

  void _showShareOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareOptionsSheet(
        receivable: receivable,
        contact: contact,
        ref: ref,
      ),
    );
  }
}

class _ShareOptionsSheet extends StatefulWidget {
  final Receivable receivable;
  final Contact? contact;
  final WidgetRef ref;

  const _ShareOptionsSheet({
    required this.receivable,
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
            'Share Payment Request',
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
      final whatsAppService = widget.ref.read(whatsAppServiceProvider);
      final currencySymbol = widget.ref.read(currencySymbolProvider);
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? 'Someone';
      final senderPhone = userProfile.phone ?? '';

      // Create share data for recipient (Payable)
      final shareData = PayableShareData(
        amount: widget.receivable.amount,
        description: widget.receivable.description,
        date: widget.receivable.date,
        dueDate: widget.receivable.dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: widget.receivable.externalLinkId ?? deepLinkService.generateExternalLinkId(),
      );

      final link = deepLinkService.generatePayableLink(shareData);

      final message = '''
💰 Payment Request
Please pay: $currencySymbol${widget.receivable.amount.toStringAsFixed(2)}
Date: ${widget.receivable.date.day}/${widget.receivable.date.month}/${widget.receivable.date.year}

View and record this in FlowPaisa:
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
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? 'Someone';
      final senderPhone = userProfile.phone ?? '';

      // Create share data for recipient (Payable)
      final shareData = PayableShareData(
        amount: widget.receivable.amount,
        description: widget.receivable.description,
        date: widget.receivable.date,
        dueDate: widget.receivable.dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: widget.receivable.externalLinkId ?? deepLinkService.generateExternalLinkId(),
      );

      final link = deepLinkService.generatePayableLink(shareData);

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
