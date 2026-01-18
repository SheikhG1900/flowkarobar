import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/widgets/add_cashbook_dialog.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';

class CashbooksScreen extends ConsumerWidget {
  const CashbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashbooks = ref.watch(cashbooksProvider);
    final activeId = ref.watch(activeCashbookIdProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cashbooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Add Cashbook',
          ),
        ],
      ),
      body: cashbooks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cashbooks.length,
              itemBuilder: (context, index) {
                final cashbook = cashbooks[index];
                final isActive = cashbook.id == activeId;
                final color = cashbook.color;
                final iconData = cashbook.icon;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: isDark ? 0.15 : 0.1)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? color : theme.dividerColor,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: color, size: 28),
                    ),
                    title: Text(
                      cashbook.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Created ${AppDateFormatter.formatDate(cashbook.createdAt, pattern: ref.watch(userProfileProvider).dateFormat)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) =>
                              _handleAction(context, ref, value, cashbook),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'clear',
                              child: Row(
                                children: [
                                  Icon(Icons.cleaning_services_outlined,
                                      size: 20, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Clear Data',
                                      style: TextStyle(color: Colors.orange)),
                                ],
                              ),
                            ),
                            if (cashbook.id != 'default')
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: isActive
                        ? null
                        : () => _switchCashbook(context, ref, cashbook),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCashbookDialog(),
    );
  }

  void _switchCashbook(BuildContext context, WidgetRef ref, Cashbook cashbook) {
    ref.read(activeCashbookIdProvider.notifier).setActive(cashbook.id);
    ToastUtils.showSuccessToast(context, ref, 'Switched to ${cashbook.name}');
  }

  void _handleAction(
      BuildContext context, WidgetRef ref, String action, Cashbook cashbook) {
    if (action == 'edit') {
      showDialog(
        context: context,
        builder: (context) => AddCashbookDialog(cashbook: cashbook),
      );
    } else if (action == 'clear') {
      _showClearConfirmation(context, ref, cashbook);
    } else if (action == 'delete') {
      _showDeleteConfirmation(context, ref, cashbook);
    }
  }

  void _showClearConfirmation(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Clear Data?'),
          ],
        ),
        content: Text(
          'Are you sure you want to clear all data in "${cashbook.name}"? '
          'This will permanently delete all transactions, contacts, and other records. '
          'The cashbook itself will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(cashbooksProvider.notifier)
                  .clearCashbookData(cashbook.id);
              if (context.mounted) {
                ToastUtils.showSuccessToast(
                    context, ref, 'Data cleared for ${cashbook.name}');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Cashbook?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${cashbook.name}"? '
          'ALL DATA within this cashbook will be PERMANENTLY LOST. '
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cashbooksProvider.notifier).deleteCashbook(cashbook.id);
              Navigator.pop(context);
              ToastUtils.showSuccessToast(
                  context, ref, 'Cashbook "${cashbook.name}" deleted');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
