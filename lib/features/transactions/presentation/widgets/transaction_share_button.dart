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
import 'package:flowpaisa/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareOptions(context, ref),
      tooltip: l10n.shareTransaction,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shareTransaction,
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
      final currencySymbol = widget.ref.read(currencySymbolProvider);
      final userProfile = widget.ref.read(userProfileProvider);

      final senderName = userProfile.name ?? l10n.someone;
      final senderPhone = userProfile.phone ?? '';

      // Ensure external ID is persisted before sharing
      final effectiveExternalId = await transactionService.ensureExternalLinkId(
        transactionUuid: widget.transaction.uuid,
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

      final message = l10n.shareTransactionMessage(
        AmountFormatter.formatWithCurrency(
            widget.transaction.amount, currencySymbol, 2),
        AppDateFormatter.formatDate(widget.transaction.date,
            pattern: userProfile.dateFormat),
        link,
      );

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
        transactionUuid: widget.transaction.uuid,
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
