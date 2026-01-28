import 'dart:ui';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeCashbook = ref.watch(activeCashbookProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.googleDriveBackupRestore),
        actions: [
          if (state.currentUser != null)
            IconButton(
              onPressed: () => _showClearAllCloudDataDialog(context),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: l10n.clearAllCloudData,
            ),
          SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32, // Subtract padding
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Auth Section
                        _buildAuthSection(context, state, notifier, l10n),

                        if (state.currentUser != null) ...[
                          const SizedBox(height: 24),
                          _buildCashbookHeader(context, theme),
                          const SizedBox(height: 24),
                          _buildSyncSection(context, state, notifier, l10n),
                          const SizedBox(height: 24),
                          _buildBackupSection(context, state, notifier, l10n),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Loading Overlay
              if (state.isLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  activeCashbook.color),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.processing,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: activeCashbook.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Premium Lock Overlay
              if (!isPremium)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.all(32),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500)
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.premiumFeature,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.cloudBackupPremiumDesc,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: GradientButton(
                                    label: l10n.upgradeToPremium,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500)
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PremiumScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuthSection(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (state.currentUser == null) ...[
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.googleDriveBackup,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signInGoogleToBackup,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : () => notifier.signIn(),
                icon: const Icon(Icons.login),
                label: Text(l10n.signInGoogle),
              ),
            ] else ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: (state.currentUser!.photoUrl != null &&
                            state.currentUser!.photoUrl!.isNotEmpty)
                        ? NetworkImage(state.currentUser!.photoUrl!)
                        : null,
                    radius: 20,
                    child: (state.currentUser!.photoUrl == null ||
                            state.currentUser!.photoUrl!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.currentUser!.displayName ?? '',
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          state.currentUser!.email,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => notifier.signOut(),
                    child: Text(l10n.signOut),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCashbookHeader(BuildContext context, ThemeData theme) {
    final activeCashbook = ref.watch(activeCashbookProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.getPrimaryGradient(activeCashbook.color),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: activeCashbook.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconHelper.getIconData(activeCashbook.iconCodePoint) ??
                  Symbols.water_drop,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeCashbook,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  activeCashbook.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        l10n.synchronization,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (state.lockedBy != null)
                        GestureDetector(
                          onTap: () async {
                            final notifier = ref.read(backupProvider.notifier);
                            final content = await notifier.getManifestContent();
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.manifestContentLocked),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      content,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(l10n.close),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 6),
                                Builder(builder: (context) {
                                  final lockTime = state.lockedAt;
                                  if (lockTime == null)
                                    return Text(l10n.locked,
                                        style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold));

                                  final diff = DateTime.now()
                                      .toUtc()
                                      .difference(lockTime);
                                  final remaining = 60 - diff.inMinutes;
                                  return Text(
                                    l10n.lockedWithTime(
                                        remaining > 0 ? remaining : 0),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(8, -8),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => notifier.refreshVersions(),
                    tooltip: l10n.refreshStatus,
                  ),
                ),
              ],
            ),
            if (state.syncStatus != 'Idle')
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: state.syncStatus.contains('Error')
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.syncStatus.contains('Error')
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (state.syncStatus == 'Syncing...')
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (state.syncStatus.contains('Error'))
                        const Icon(Icons.error_outline,
                            size: 16, color: Colors.red)
                      else
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.syncStatus,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: state.syncStatus.contains('Error')
                                ? Colors.red
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Version and Count Boxes
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildInfoBox(
                      context,
                      title: l10n.versions,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVersionRow(
                              l10n.local, state.localVersion, theme),
                          const SizedBox(height: 4),
                          _buildVersionRow(
                              l10n.cloud, state.cloudVersion, theme,
                              isOrange:
                                  state.cloudVersion > state.localVersion),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoBox(
                      context,
                      title: l10n.pending,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sync_problem,
                                size: 20,
                                color: state.unsyncedCount > 0
                                    ? Colors.orange
                                    : Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              l10n.rows(state.unsyncedCount),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: state.unsyncedCount > 0
                                    ? Colors.orange
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.lastSyncTime != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      l10n.lastSync(AppDateFormatter.formatRelativeTime(
                          state.lastSyncTime!, context)),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (state.deltaFiles.isNotEmpty) ...[
              Text(
                state.deltaFiles.any((f) {
                  final ver = int.tryParse(
                          f.name?.replaceAll('v', '').replaceAll('.json', '') ??
                              '0') ??
                      0;
                  return ver > state.localVersion;
                })
                    ? l10n.upcomingSyncDeltas
                    : l10n.recentSyncDeltas,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: theme.dividerColor.withOpacity(0.5)),
                ),
                child: Column(
                  children: state.deltaFiles.map((file) {
                    final sizeKb = (int.tryParse(file.size ?? '0') ?? 0) / 1024;
                    final ver = int.tryParse(file.name
                                ?.replaceAll('v', '')
                                .replaceAll('.json', '') ??
                            '0') ??
                        0;
                    final isUpcoming = ver > state.localVersion;

                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onTap: () async {
                        final notifier = ref.read(backupProvider.notifier);
                        final content =
                            await notifier.getDeltaFileContent(file.id!);
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(file.name ?? l10n.deltaContent),
                              content: SingleChildScrollView(
                                child: Text(
                                  content,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.close),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      leading: Icon(
                        isUpcoming ? Icons.upcoming : Icons.history_edu,
                        size: 16,
                        color: isUpcoming ? Colors.orange : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            file.name ?? 'Unknown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isUpcoming ? Colors.orange : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // We don't have the summary here yet as it's inside the file,
                          // but we could fetch it or just show the size for now.
                          // In a future update, we can cache the summary locally.
                        ],
                      ),
                      trailing: Text(
                        '${sizeKb.toStringAsFixed(1)} KB',
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Full width buttons
            SizedBox(
              height: 56,
              child: GradientButton(
                label: l10n.syncNow,
                gradient:
                    AppColors.getPrimaryGradient(theme.colorScheme.primary)
                        .withOpacity(0.8),
                icon: Icons.sync,
                onPressed: () async {
                  // We don't show a toast here anymore because the UI
                  // will now show a persistent "Syncing..." status bar
                  await notifier.triggerSync(l10n);
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showResetCloudVersionDialog(context),
                icon: const Icon(Icons.upload_file, size: 20),
                label: Text(l10n.primeCloudWithLocal),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showResetLocalSyncDialog(context),
                icon: const Icon(Icons.restart_alt, size: 20),
                label: Text(l10n.resetLocalSyncState),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Expanded Dropdown
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: state.syncInterval,
                  items: [
                    DropdownMenuItem(value: 'manual', child: Text(l10n.manual)),
                    ...['12', '24', '36', '48', '60', '72', '84', '96']
                        .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text('$h ${l10n.hours}'),
                            )),
                  ],
                  onChanged: (v) =>
                      v != null ? notifier.setSyncInterval(v) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context,
      {required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, int version, ThemeData theme,
      {bool isOrange = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          '$version',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isOrange ? Colors.orange : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupSection(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.backup,
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    notifier.loadBackups();
                    notifier.loadAvailableCashbooks();
                  },
                  tooltip: l10n.refreshBackups,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBackupControls(context, state, notifier, l10n),
            const SizedBox(height: 24),
            _buildCloudCashbooks(context, state, notifier, l10n),
            const SizedBox(height: 24),
            _buildBackupsList(context, state, notifier, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupControls(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.backupDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.lastBackupTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    l10n.lastBackupAt(AppDateFormatter.formatDateTime(
                        state.lastBackupTime!.toLocal())),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 56,
            child: GradientButton(
              label: l10n.backupNow,
              gradient:
                  AppColors.getSecondaryGradient(theme.colorScheme.primary)
                      .withOpacity(0.8),
              icon: Icons.backup,
              onPressed: () async {
                await notifier.backup(l10n);
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: state.backupInterval,
                items: [
                  DropdownMenuItem(value: 'manual', child: Text(l10n.manual)),
                  DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                  DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
                ],
                onChanged: (v) =>
                    v != null ? notifier.setBackupInterval(v) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudCashbooks(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    if (state.availableCashbookIds.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cloudCashbooks,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.availableCashbookIds.length,
            itemBuilder: (context, index) {
              final id = state.availableCashbookIds[index];
              final metadata = state.cashbookMetadata[id];
              final isSelected = state.selectedCloudCashbookId == id;
              final isActive = activeCashbook.id == id;

              return GestureDetector(
                onTap: () => notifier.loadBackupsForCashbook(id),
                child: Stack(
                  children: [
                    Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (metadata != null
                                      ? Color(int.parse(metadata.color
                                          .replaceAll('#', '0xFF')))
                                      : Colors.grey)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              IconHelper.getIconData(metadata?.icon) ??
                                  Symbols.water_drop,
                              size: 20,
                              color: metadata != null
                                  ? Color(int.parse(
                                      metadata.color.replaceAll('#', '0xFF')))
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  metadata?.name ??
                                      (id == 'default'
                                          ? l10n.main
                                          : l10n.cloudDb),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isActive)
                                  Text(
                                    l10n.active,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isActive)
                      Positioned(
                        top: 0,
                        right: 12,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.cancel,
                              size: 18, color: Colors.red),
                          onPressed: () => _showDeleteCloudCashbookDialog(
                              context, id, metadata?.name ?? id),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackupsList(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.availableBackups,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (state.backups.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.backup_outlined,
                      size: 48, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noBackupsFound,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.backups.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final backup = state.backups[index];
              return SwipeableListItem(
                onDelete: () => notifier.deleteBackup(backup.id!),
                onEdit: () => _showRestoreDialog(context, backup),
                editIcon: Icons.restore,
                editLabel: l10n.restore,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    DateFormat.yMMMd().add_jm().format(backup.createdTime!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${(int.parse(backup.size ?? '0') / 1024 / 1024).toStringAsFixed(2)} MB',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_left, size: 20),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showRestoreDialog(BuildContext context, drive.File backup) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(backupProvider);
    final activeCashbook = ref.read(activeCashbookProvider);
    final cashbooks = ref.read(cashbooksProvider);

    // Logic to determine restore options
    final cloudCashbookId = state.selectedCloudCashbookId ?? 'default';
    final cloudMetadata = state.cashbookMetadata[cloudCashbookId];
    final cloudName = cloudMetadata?.name ??
        (cloudCashbookId == 'default' ? l10n.main : l10n.cloudDb);

    final isActive = activeCashbook.id == cloudCashbookId;
    final isLocallyAvailable = cashbooks.any((c) => c.id == cloudCashbookId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive
            ? l10n.restoreBackupTitle
            : (isLocallyAvailable
                ? l10n.overrideExistingCashbookTitle
                : l10n.restoreToNewCashbookTitle)),
        content: Text(isActive
            ? l10n.restoreBackupMessage
            : (isLocallyAvailable
                ? l10n.overrideExistingCashbookMessage(
                    cloudName, activeCashbook.name)
                : l10n.restoreToNewCashbookMessage(cloudName))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (!isActive && isLocallyAvailable)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performRestore(backup.id!, activeCashbook.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.restoreOptionOverride),
            ),
          if (!isActive && !isLocallyAvailable) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performRestore(backup.id!, activeCashbook.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.restoreOptionOverride),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performRestore(backup.id!, cloudCashbookId);
              },
              child: Text(l10n.restoreOptionNewEntry),
            ),
          ],
          if (isActive)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performRestore(backup.id!, activeCashbook.id);
              },
              child: Text(l10n.restore),
            ),
        ],
      ),
    );
  }

  Future<void> _performRestore(String fileId, String targetCashbookId) async {
    final notifier = ref.read(backupProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    try {
      await notifier.restoreToCashbook(fileId, targetCashbookId);
      if (mounted) {
        final metadata =
            ref.read(backupProvider).cashbookMetadata[targetCashbookId];
        final name = metadata?.name ?? targetCashbookId;

        ToastUtils.showSuccessToast(
            context,
            ref,
            targetCashbookId == ref.read(activeCashbookIdProvider)
                ? l10n.restoreSuccessful
                : l10n.restoreSuccessNew(name));
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.restoreFailed(e.toString()));
      }
    }
  }

  void _showDeleteCloudCashbookDialog(
      BuildContext context, String id, String name) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCloudCashbook),
        content: Text(l10n.deleteCloudCashbookMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(backupProvider.notifier).deleteCloudCashbook(id);
                if (context.mounted) {
                  ToastUtils.showSuccessToast(
                      context, ref, l10n.cloudCashbookDeletedSuccess);
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showErrorToast(
                      context, ref, l10n.errorOccurred(e.toString()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showResetCloudVersionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(backupProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetCloudVersion),
        content: Text(l10n.resetCloudVersionMessage(state.localVersion)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(backupProvider.notifier).resetSyncAfterRestore();
                if (context.mounted) {
                  ToastUtils.showSuccessToast(
                      context, ref, l10n.cloudVersionResetSuccess);
                  ref.read(backupProvider.notifier).refreshVersions();
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showErrorToast(
                      context, ref, l10n.cloudVersionResetFailed(e.toString()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.resetNow),
          ),
        ],
      ),
    );
  }

  void _showClearAllCloudDataDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllCloudData),
        content: Text(l10n.clearAllCloudDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(backupProvider.notifier).clearAllCloudData();
                if (context.mounted) {
                  ToastUtils.showSuccessToast(
                      context, ref, l10n.cloudDataClearedSuccess);
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showErrorToast(
                      context, ref, l10n.errorOccurred(e.toString()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.clearNow),
          ),
        ],
      ),
    );
  }

  void _showResetLocalSyncDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetLocalSyncState),
        content: Text(l10n.resetLocalSyncMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(backupProvider.notifier).resetLocalSyncState();
                if (context.mounted) {
                  ToastUtils.showSuccessToast(
                      context, ref, l10n.localSyncResetSuccess);
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showErrorToast(
                      context, ref, l10n.errorOccurred(e.toString()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.resetNow),
          ),
        ],
      ),
    );
  }
}
