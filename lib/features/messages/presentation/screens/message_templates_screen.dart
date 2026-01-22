import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/messages/presentation/screens/template_editor_screen.dart';
import 'package:flowpaisa/features/messages/data/default_templates.dart';

class MessageTemplatesScreen extends ConsumerWidget {
  const MessageTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPremium = PremiumGate.isPremium(ref);

    if (!isPremium) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.messageTemplates),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.premiumFeature,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.messageTemplatesDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    PremiumGate.showPremiumDialog(context);
                  },
                  child: Text(l10n.upgradeToPremium),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messageTemplates),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTemplateSection(
            context,
            theme,
            l10n.receivableReminders,
            [
              _TemplateItem(
                name: l10n.pendingReceivable,
                type: DefaultTemplates.receivableReminder,
                status: DefaultTemplates.pending,
              ),
              _TemplateItem(
                name: l10n.receivedPayment,
                type: DefaultTemplates.receivableReminder,
                status: DefaultTemplates.received,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTemplateSection(
            context,
            theme,
            l10n.payableReminders,
            [
              _TemplateItem(
                name: l10n.pendingPayable,
                type: DefaultTemplates.payableReminder,
                status: DefaultTemplates.pending,
              ),
              _TemplateItem(
                name: l10n.paidPayable,
                type: DefaultTemplates.payableReminder,
                status: DefaultTemplates.paid,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTemplateSection(
            context,
            theme,
            l10n.transactionMessages,
            [
              _TemplateItem(
                name: l10n.transactionReceipt,
                type: DefaultTemplates.transactionReceipt,
                status: '',
              ),
              _TemplateItem(
                name: l10n.transactionSharePaidFor,
                type: DefaultTemplates.transactionShare,
                status: 'paid_for',
              ),
              _TemplateItem(
                name: l10n.transactionSharePaidBy,
                type: DefaultTemplates.transactionShare,
                status: 'paid_by',
              ),
              _TemplateItem(
                name: l10n.transactionShareWillReceive,
                type: DefaultTemplates.transactionShare,
                status: 'will_receive',
              ),
              _TemplateItem(
                name: l10n.transactionShareReceivedFrom,
                type: DefaultTemplates.transactionShare,
                status: 'received_from',
              ),
              _TemplateItem(
                name: l10n.transactionShareGeneric,
                type: DefaultTemplates.transactionShare,
                status: 'generic',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTemplateSection(
            context,
            theme,
            l10n.shareMessages,
            [
              _TemplateItem(
                name: l10n.receivableSharePending,
                type: DefaultTemplates.receivableShare,
                status: DefaultTemplates.pending,
              ),
              _TemplateItem(
                name: l10n.receivableShareReceived,
                type: DefaultTemplates.receivableShare,
                status: DefaultTemplates.received,
              ),
              _TemplateItem(
                name: l10n.payableSharePending,
                type: DefaultTemplates.payableShare,
                status: DefaultTemplates.pending,
              ),
              _TemplateItem(
                name: l10n.payableSharePaid,
                type: DefaultTemplates.payableShare,
                status: DefaultTemplates.paid,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(
    BuildContext context,
    ThemeData theme,
    String title,
    List<_TemplateItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildTemplateTile(context, theme, item)),
      ],
    );
  }

  Widget _buildTemplateTile(
    BuildContext context,
    ThemeData theme,
    _TemplateItem item,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(item.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemplateEditorScreen(
                templateType: item.type,
                templateStatus: item.status,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TemplateItem {
  final String name;
  final String type;
  final String status;

  _TemplateItem({
    required this.name,
    required this.type,
    required this.status,
  });
}
