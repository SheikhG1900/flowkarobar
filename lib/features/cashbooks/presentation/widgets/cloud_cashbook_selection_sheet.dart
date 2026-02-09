import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class CloudCashbookSelectionSheet extends ConsumerWidget {
  const CloudCashbookSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);
    final localCashbooks = ref.watch(cashbooksProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Filter cloud cashbooks that are not present locally
    final localIds = localCashbooks.map((c) => c.id).toSet();
    final cloudCashbooks = backupState.availableCashbookIds
        .where((id) => !localIds.contains(id))
        .map((id) => backupState.cashbookMetadata[id]!)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_download_outlined,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                l10n.addCloudCashbook,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (backupState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (cloudCashbooks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.cloud_off_outlined,
                        size: 48, color: theme.disabledColor),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noOtherCashbooks,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.disabledColor),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cloudCashbooks.length,
                itemBuilder: (context, index) {
                  final cloudCb = cloudCashbooks[index];
                  final color =
                      Color(int.parse(cloudCb.color.replaceFirst('#', '0xFF')));
                  final iconData = IconHelper.getIconData(cloudCb.icon) ??
                      Icons.account_balance_wallet;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconData, color: color, size: 24),
                      ),
                      title: Text(
                        cloudCb.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'ID: ${cloudCb.id.substring(0, 8)}...',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: theme.colorScheme.primary,
                        onPressed: () =>
                            _importCloudCashbook(context, ref, cloudCb),
                      ),
                      onTap: () => _importCloudCashbook(context, ref, cloudCb),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _importCloudCashbook(BuildContext context, WidgetRef ref,
      CloudCashbookMetadata cloudCb) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final newCashbook = Cashbook(
        id: cloudCb.id,
        name: cloudCb.name,
        colorCode: cloudCb.color,
        iconCodePoint: cloudCb.icon,
        dbPath: 'cashbook_${cloudCb.id}.db',
        createdAt: DateTime.now(),
      );

      await ref
          .read(cashbooksProvider.notifier)
          .addCashbookFromCloud(newCashbook);

      if (context.mounted) {
        Navigator.pop(context);
        ToastUtils.showSuccessToast(context, ref, l10n.cashbookAdded);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }
}
