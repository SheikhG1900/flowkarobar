import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

class ScheduleSelectionResult {
  final String scheduleType; // 'DAILY', 'WEEKLY', 'MONTHLY'
  final List<int>? selectedDaysOfWeek; // 0=Sunday, 6=Saturday
  final List<int>? selectedDaysOfMonth; // 1-31

  ScheduleSelectionResult({
    required this.scheduleType,
    this.selectedDaysOfWeek,
    this.selectedDaysOfMonth,
  });
}

class ScheduleSelectionDrawer extends StatefulWidget {
  const ScheduleSelectionDrawer({super.key});

  @override
  State<ScheduleSelectionDrawer> createState() =>
      _ScheduleSelectionDrawerState();
}

class _ScheduleSelectionDrawerState extends State<ScheduleSelectionDrawer> {
  bool _isDailySelected = false;
  final Set<int> _selectedDaysOfWeek = {}; // 0=Sunday, 6=Saturday
  final Set<int> _selectedDaysOfMonth = {}; // 1-31

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Text(
            'Select Schedule Pattern',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Daily option
          _buildDailyChip(theme),
          const SizedBox(height: 16),
          // Days of week section
          Text(
            'Days of Week',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDaysOfWeekChips(theme),
          const SizedBox(height: 20),
          // Days of month section
          Text(
            'Days of Month',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDaysOfMonthChips(theme),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canConfirm() ? _onConfirm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brightCyan,
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDailyChip(ThemeData theme) {
    return FilterChip(
      label: const Text('Daily'),
      selected: _isDailySelected,
      onSelected: (selected) {
        setState(() {
          _isDailySelected = selected;
          if (selected) {
            _selectedDaysOfWeek.clear();
            _selectedDaysOfMonth.clear();
          }
        });
      },
      selectedColor: AppColors.brightCyan.withValues(alpha: 0.2),
      checkmarkColor: AppColors.brightCyan,
      side: BorderSide(
        color: _isDailySelected
            ? AppColors.brightCyan
            : theme.dividerColor,
        width: _isDailySelected ? 2 : 1,
      ),
    );
  }

  Widget _buildDaysOfWeekChips(ThemeData theme) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final isDisabled = _isDailySelected || _selectedDaysOfMonth.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _selectedDaysOfWeek.contains(index);
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: isDisabled
              ? null
              : (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDaysOfWeek.add(index);
                      _isDailySelected = false;
                    } else {
                      _selectedDaysOfWeek.remove(index);
                    }
                  });
                },
          selectedColor: AppColors.brightCyan.withValues(alpha: 0.2),
          checkmarkColor: AppColors.brightCyan,
          backgroundColor: isDisabled
              ? (isDark ? Colors.grey[800] : Colors.grey[200])
              : null,
          labelStyle: TextStyle(
            color: isDisabled
                ? (isDark ? Colors.grey[600] : Colors.grey[500])
                : (isSelected ? AppColors.brightCyan : theme.colorScheme.onSurface),
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.brightCyan
                : (isDisabled
                    ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                    : theme.dividerColor),
            width: isSelected ? 2 : 1,
          ),
        );
      }),
    );
  }

  Widget _buildDaysOfMonthChips(ThemeData theme) {
    final isDisabled = _isDailySelected || _selectedDaysOfWeek.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(31, (index) {
        final day = index + 1;
        final isSelected = _selectedDaysOfMonth.contains(day);
        return FilterChip(
          label: Text('$day'),
          selected: isSelected,
          onSelected: isDisabled
              ? null
              : (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDaysOfMonth.add(day);
                      _isDailySelected = false;
                    } else {
                      _selectedDaysOfMonth.remove(day);
                    }
                  });
                },
          selectedColor: AppColors.brightCyan.withValues(alpha: 0.2),
          checkmarkColor: AppColors.brightCyan,
          backgroundColor: isDisabled
              ? (isDark ? Colors.grey[800] : Colors.grey[200])
              : null,
          labelStyle: TextStyle(
            color: isDisabled
                ? (isDark ? Colors.grey[600] : Colors.grey[500])
                : (isSelected ? AppColors.brightCyan : theme.colorScheme.onSurface),
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.brightCyan
                : (isDisabled
                    ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                    : theme.dividerColor),
            width: isSelected ? 2 : 1,
          ),
        );
      }),
    );
  }

  bool _canConfirm() {
    return _isDailySelected ||
        _selectedDaysOfWeek.isNotEmpty ||
        _selectedDaysOfMonth.isNotEmpty;
  }

  void _onConfirm() {
    String scheduleType;
    List<int>? selectedDaysOfWeek;
    List<int>? selectedDaysOfMonth;

    if (_isDailySelected) {
      scheduleType = 'DAILY';
    } else if (_selectedDaysOfWeek.isNotEmpty) {
      scheduleType = 'WEEKLY';
      selectedDaysOfWeek = _selectedDaysOfWeek.toList()..sort();
    } else if (_selectedDaysOfMonth.isNotEmpty) {
      scheduleType = 'MONTHLY';
      selectedDaysOfMonth = _selectedDaysOfMonth.toList()..sort();
    } else {
      return; // Should not happen due to _canConfirm check
    }

    Navigator.pop(
      context,
      ScheduleSelectionResult(
        scheduleType: scheduleType,
        selectedDaysOfWeek: selectedDaysOfWeek,
        selectedDaysOfMonth: selectedDaysOfMonth,
      ),
    );
  }
}
