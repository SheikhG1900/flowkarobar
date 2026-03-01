import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_schedule_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ScheduleDetailsDialog extends ConsumerWidget {
  final String scheduleUuid;

  const ScheduleDetailsDialog({
    super.key,
    required this.scheduleUuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    final itemAsync = ref.watch(scheduleWithDetailsProvider(scheduleUuid));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.scheduleDetails)),
            body: Center(child: Text(l10n.errorOccurred('Schedule not found'))),
          );
        }

        if (currency == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildContent(
          context,
          ref,
          item: item,
          currency: currency,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.scheduleDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.scheduleDetails)),
        body: Center(child: Text(l10n.errorOccurred(err.toString()))),
      ),
    );
  }

  static Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required ScheduleWithDetails item,
    required dynamic currency,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final schedule = item.schedule;
    final category = item.category;
    final contact = item.contact;
    final isExpense = schedule.type == 'EXPENSE';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scheduleDetails),
            Text(
              "SCHEDULE",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editSchedule,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScheduleScreen(
                    schedule: schedule,
                  ),
                ),
              ).then((updated) {
                if (updated == true) {
                  ref.invalidate(scheduleWithDetailsProvider(schedule.uuid));
                  ref.invalidate(allSchedulesWithDetailsProvider);
                }
              });
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSchedule(context, ref, schedule.uuid),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isExpense
                      ? [
                          AppColors.expenseColor
                              .withValues(alpha: schedule.isPaused ? 0.5 : 1.0),
                          AppColors.expenseColor
                              .withValues(alpha: schedule.isPaused ? 0.3 : 0.7)
                        ]
                      : [
                          AppColors.incomeColor
                              .withValues(alpha: schedule.isPaused ? 0.5 : 1.0),
                          AppColors.incomeColor
                              .withValues(alpha: schedule.isPaused ? 0.3 : 0.7)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor)
                        .withValues(alpha: schedule.isPaused ? 0.1 : 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isExpense ? l10n.expense : l10n.income,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(schedule.amount, currency.symbol, currency.decimalPlaces)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          AmountFormatter.getFontSize(schedule.amount) + 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Active/Inactive Toggle
                  SwitchListTile(
                    title: Text(
                      schedule.isPaused ? l10n.inactive : l10n.active,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: !schedule.isPaused,
                    onChanged: (value) =>
                        _toggleSchedule(context, ref, schedule),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white24,
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: Colors.black12,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact & Category Header Section
            if (contact != null || category != null) ...[
              if (contact != null) ...[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailsScreen(
                          contactUuid: contact.uuid,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Contact Section
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient:
                                AppColors.getContactGradient(contact.name),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getContactColor(contact.name)
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            contact.name.isNotEmpty
                                ? contact.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (contact.phone != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      contact.phone!,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Category Section
              Container(
                decoration: BoxDecoration(
                  color: category != null
                      ? Color(int.parse(
                              category.color!.replaceAll('#', '0xFF')))
                          .withValues(alpha: 0.1)
                      : (isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: category != null
                        ? Color(int.parse(
                                category.color!.replaceAll('#', '0xFF')))
                            .withValues(alpha: 0.3)
                        : (isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor)
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: category != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailsScreen(
                                  categoryUuid: category.uuid,
                                ),
                              ),
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: category != null
                                  ? Color(int.parse(category.color!
                                          .replaceAll('#', '0xFF')))
                                      .withValues(alpha: 0.2)
                                  : (isExpense
                                          ? AppColors.expenseColor
                                          : AppColors.incomeColor)
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category != null && category.icon != null
                                  ? IconHelper.getIconData(category.icon!)
                                  : (isExpense
                                      ? Icons.arrow_circle_down
                                      : Icons.arrow_circle_up),
                              color: category != null
                                  ? Color(int.parse(
                                      category.color!.replaceAll('#', '0xFF')))
                                  : (isExpense
                                      ? AppColors.expenseColor
                                      : AppColors.incomeColor),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.category,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  category != null
                                      ? LocalizationHelper
                                          .getLocalizedCategoryName(
                                              context, category.name)
                                      : (isExpense
                                          ? l10n.expense
                                          : l10n.income),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: category != null
                                        ? Color(int.parse(category.color!
                                            .replaceAll('#', '0xFF')))
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Schedule Pattern Section
            Text(
              l10n.schedulePattern,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              icon: Icons.repeat,
              label: l10n.frequency,
              value: _getFrequencyLabel(l10n, schedule.scheduleType),
            ),
            if (schedule.scheduleType == 'WEEKLY' &&
                schedule.selectedDaysOfWeek != null)
              _buildDetailRow(
                context,
                icon: Icons.calendar_view_week,
                label: l10n.days,
                value: _getDaysOfWeekLabels(l10n, schedule.selectedDaysOfWeek!),
              ),
            if (schedule.scheduleType == 'MONTHLY' &&
                schedule.selectedDaysOfMonth != null)
              _buildDetailRow(
                context,
                icon: Icons.calendar_month,
                label: l10n.days,
                value: _getDaysOfMonthLabels(schedule.selectedDaysOfMonth!),
              ),
            if (schedule.startDate != null)
              _buildDetailRow(
                context,
                icon: Icons.start,
                label: l10n.startDate,
                value: AppDateFormatter.formatDate(schedule.startDate!,
                    pattern: ref.watch(userProfileProvider).dateFormat),
              ),
            if (schedule.endDate != null)
              _buildDetailRow(
                context,
                icon: Icons.event_available,
                label: l10n.endDate,
                value: AppDateFormatter.formatDate(schedule.endDate!,
                    pattern: ref.watch(userProfileProvider).dateFormat),
              ),

            if (schedule.lastGeneratedDate != null)
              _buildDetailRow(
                context,
                icon: Icons.history,
                label: l10n.lastGenerated,
                value: AppDateFormatter.formatDate(schedule.lastGeneratedDate!,
                    pattern: ref.watch(userProfileProvider).dateFormat),
              ),

            if (schedule.description != null &&
                schedule.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                icon: Icons.description,
                label: l10n.description,
                value: schedule.description!,
              ),
            ],

            if (kDebugMode) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    "DEBUG INFO",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  leading: const Icon(Icons.bug_report, color: Colors.red),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  expandedAlignment: Alignment.topLeft,
                  children: [
                    _buildDebugInfo(context, "Schedule UUID", schedule.uuid),
                    _buildDebugInfo(
                        context, "Schedule Type", schedule.scheduleType),
                    _buildDebugInfo(
                        context, "Is Paused", schedule.isPaused.toString()),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("DEBUG: Execute Now"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () =>
                            _showTestExecuteDialog(context, ref, schedule),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Bottom padding
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDebugInfo(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  static String _getFrequencyLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'DAILY':
        return l10n.daily;
      case 'WEEKLY':
        return l10n.weekly;
      case 'MONTHLY':
        return l10n.monthly;
      default:
        return type;
    }
  }

  static String _getDaysOfWeekLabels(AppLocalizations l10n, String json) {
    try {
      final List<dynamic> days = jsonDecode(json);
      final labels = [
        l10n.sunday,
        l10n.monday,
        l10n.tuesday,
        l10n.wednesday,
        l10n.thursday,
        l10n.friday,
        l10n.saturday
      ];
      return days.map((d) => labels[d as int]).join(', ');
    } catch (_) {
      return '';
    }
  }

  static String _getDaysOfMonthLabels(String json) {
    try {
      final List<dynamic> days = jsonDecode(json);
      return days.join(', ');
    } catch (_) {
      return '';
    }
  }

  static void _toggleSchedule(
      BuildContext context, WidgetRef ref, TransactionSchedule schedule) async {
    final service = ref.read(scheduleServiceProvider);
    try {
      if (schedule.isPaused) {
        await service.resumeSchedule(schedule.uuid, DateTime.now());
      } else {
        await service.pauseSchedule(schedule.uuid);
      }
      ref.invalidate(scheduleWithDetailsProvider(schedule.uuid));
      ref.invalidate(allSchedulesWithDetailsProvider);
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, e.toString());
      }
    }
  }

  static void _deleteSchedule(
      BuildContext context, WidgetRef ref, String uuid) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSchedule),
        content: Text(l10n.deleteScheduleConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = ref.read(scheduleServiceProvider);
        await service.deleteSchedule(uuid);
        if (context.mounted) {
          ToastUtils.showSuccessToast(context, ref, l10n.scheduleDeleted);
          Navigator.pop(context); // Close details dialog
          ref.invalidate(allSchedulesWithDetailsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(context, ref, e.toString());
        }
      }
    }
  }

  static void _showTestExecuteDialog(
      BuildContext context, WidgetRef ref, TransactionSchedule schedule) async {
    DateTime selectedDate = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Debug: Execute Schedule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select a date to simulate transaction generation:"),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(AppDateFormatter.formatDate(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final scheduleService = ref.read(scheduleServiceProvider);
                  await scheduleService.generateTransactionsFromSchedule(
                    schedule.uuid,
                    customDate: selectedDate,
                  );

                  if (context.mounted) {
                    ToastUtils.showSuccessToast(context, ref,
                        "Debug: Official generation process executed for ${AppDateFormatter.formatDate(selectedDate)}");
                    ref.invalidate(allSchedulesWithDetailsProvider);
                    ref.invalidate(scheduleWithDetailsProvider(schedule.uuid));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showErrorToast(context, ref, "Debug Error: $e");
                  }
                }
              },
              child: const Text("Execute"),
            ),
          ],
        ),
      ),
    );
  }
}
