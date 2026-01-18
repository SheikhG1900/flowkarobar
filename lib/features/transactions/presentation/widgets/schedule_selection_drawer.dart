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
  final String? initialScheduleType; // 'DAILY', 'WEEKLY', 'MONTHLY'
  final List<int>? initialSelectedDaysOfWeek;
  final List<int>? initialSelectedDaysOfMonth;

  const ScheduleSelectionDrawer({
    super.key,
    this.initialScheduleType,
    this.initialSelectedDaysOfWeek,
    this.initialSelectedDaysOfMonth,
  });

  @override
  State<ScheduleSelectionDrawer> createState() =>
      _ScheduleSelectionDrawerState();
}

class _ScheduleSelectionDrawerState extends State<ScheduleSelectionDrawer> {
  late bool _isDailySelected;
  late final Set<int> _selectedDaysOfWeek; // 0=Sunday, 6=Saturday
  late final Set<int> _selectedDaysOfMonth; // 1-31

  @override
  void initState() {
    super.initState();
    // Initialize with current selection if provided
    // Only include selections that match the current schedule type
    _isDailySelected = widget.initialScheduleType == 'DAILY';

    if (widget.initialScheduleType == 'WEEKLY') {
      // For WEEKLY, only include days of week
      _selectedDaysOfWeek = widget.initialSelectedDaysOfWeek != null
          ? widget.initialSelectedDaysOfWeek!.toSet()
          : <int>{};
      _selectedDaysOfMonth = <int>{}; // Clear days of month
    } else if (widget.initialScheduleType == 'MONTHLY') {
      // For MONTHLY, only include days of month
      _selectedDaysOfWeek = <int>{}; // Clear days of week
      _selectedDaysOfMonth = widget.initialSelectedDaysOfMonth != null
          ? widget.initialSelectedDaysOfMonth!.toSet()
          : <int>{};
    } else {
      // For DAILY or no initial type, clear both
      _selectedDaysOfWeek = <int>{};
      _selectedDaysOfMonth = <int>{};
    }
  }

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
          // Scrollable content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
            ),
          ),
          // Action buttons (sticky at bottom)
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
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: _isDailySelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: _isDailySelected ? theme.colorScheme.primary : theme.dividerColor,
        width: _isDailySelected ? 2 : 1,
      ),
    );
  }

  Widget _buildDaysOfWeekChips(ThemeData theme) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _selectedDaysOfWeek.contains(index);
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDaysOfWeek.add(index);
                _isDailySelected = false;
                _selectedDaysOfMonth.clear();
              } else {
                _selectedDaysOfWeek.remove(index);
              }
            });
          },
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color:
                isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        );
      }),
    );
  }

  Widget _buildDaysOfMonthChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(31, (index) {
        final day = index + 1;
        final isSelected = _selectedDaysOfMonth.contains(day);
        return FilterChip(
          label: Text('$day'),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDaysOfMonth.add(day);
                _isDailySelected = false;
                _selectedDaysOfWeek.clear();
              } else {
                _selectedDaysOfMonth.remove(day);
              }
            });
          },
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color:
                isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
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
