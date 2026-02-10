import 'package:drift/drift.dart' hide Column;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class BulkImportScreen extends ConsumerStatefulWidget {
  final String? initialContent;
  const BulkImportScreen({super.key, this.initialContent});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  // Parsing state
  List<List<String>> _rawRows = [];
  List<String> _headers = [];
  bool _hasHeader = true;
  String _separator = '\t'; // Default to Tab for Google Sheets
  String _dateFormat = 'dd/MM/yyyy';
  String? _lastRawContent;

  // Mapping state
  Map<String, int?> _columnMapping = {
    'Date': null,
    'Amount': null,
    'Description': null,
    'Category': null,
    'Type': null,
    'Contact': null,
  };

  // Default values
  String _defaultType = 'EXPENSE';
  Category? _defaultCategory;
  Contact? _defaultContact;
  DateTime _defaultDate = DateTime.now();

  // Selection state
  Set<int> _selectedRowIndices = {};
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processRawData(widget.initialContent!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(premiumProvider).isPremium;

    if (!isPremium) {
      return const PremiumScreen();
    }

    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bulkImport),
      ),
      body: Column(
        children: [
          if (_rawRows.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file,
                        size: 64, color: Theme.of(context).disabledColor),
                    const SizedBox(height: 16),
                    Text(l10n.noTransactions), // Use "No transactions found"
                  ],
                ),
              ),
            )
          else ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildConfigurationSection(context, isTablet),
                    _buildMappingSection(context, isTablet),
                    _buildDefaultValuesSection(context, isTablet),
                    _buildPreviewSection(context),
                  ],
                ),
              ),
            ),
            _buildImportAction(context),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigurationSection(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.importSettings,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _processRawData(data!.text!);
                    } else {
                      if (mounted)
                        ToastUtils.showInfoToast(
                            context, ref, 'Clipboard is empty');
                    }
                  },
                  icon: const Icon(Icons.content_paste, size: 18),
                  label: Text(l10n.paste),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isTablet)
              Row(
                children: [
                  Expanded(child: _buildSeparatorDropdown(l10n)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateFormatDropdown(l10n)),
                ],
              )
            else ...[
              _buildSeparatorDropdown(l10n),
              const SizedBox(height: 16),
              _buildDateFormatDropdown(l10n),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.hasHeader),
              value: _hasHeader,
              onChanged: (value) {
                setState(() {
                  _hasHeader = value;
                  _processRawData(_lastRawContent ?? '');
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparatorDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _separator,
      decoration: InputDecoration(
        labelText: l10n.separator,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: '\t', child: Text(l10n.tab)),
        DropdownMenuItem(value: ',', child: Text(l10n.comma)),
        DropdownMenuItem(value: ';', child: Text(l10n.semicolon)),
        DropdownMenuItem(value: '|', child: Text(l10n.pipe)),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _separator = value;
            _processRawData(_lastRawContent ?? '');
          });
        }
      },
    );
  }

  Widget _buildDateFormatDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _dateFormat,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.dateFormat,
        border: const OutlineInputBorder(),
      ),
      items: [
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'yyyy-MM-dd',
        'dd-MM-yyyy',
        'MMM dd, yyyy',
      ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _dateFormat = value;
          });
        }
      },
    );
  }

  Widget _buildMappingSection(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // For now we show all: Date, Amount, Description, Category, Type, Contact
    const mappingFields = [
      'Date',
      'Amount',
      'Description',
      'Category',
      'Type',
      'Contact'
    ];

    // If no data is loaded yet, we should still show the mapping fields but with no options
    final maxColumns = _rawRows.isNotEmpty ? _rawRows.first.length : 0;

    // Generate display names for columns
    List<String> columnDisplayNames = [];
    if (maxColumns > 0) {
      if (_hasHeader && _headers.isNotEmpty) {
        columnDisplayNames = _headers;
      } else {
        columnDisplayNames =
            List.generate(maxColumns, (i) => 'Column ${i + 1}');
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.columnMapping,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: columnDisplayNames.asMap().entries.map((entry) {
                final colIndex = entry.key;
                final colName = entry.value;

                return SizedBox(
                  width: isTablet
                      ? (MediaQuery.of(context).size.width - 100) / 3
                      : (MediaQuery.of(context).size.width - 64),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('mapping_col_${colIndex}_${maxColumns}'),
                    value: _columnMapping.entries
                            .firstWhere((e) => e.value == colIndex,
                                orElse: () => const MapEntry('', null))
                            .key
                            .isEmpty
                        ? null
                        : _columnMapping.entries
                            .firstWhere((e) => e.value == colIndex)
                            .key,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: colName,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                          value: null, child: Text(l10n.cancel)),
                      ...mappingFields.map((field) {
                        String localizedLabel = field;
                        if (field == 'Date')
                          localizedLabel = l10n.date;
                        else if (field == 'Amount')
                          localizedLabel = l10n.amount;
                        else if (field == 'Description')
                          localizedLabel = l10n.description;
                        else if (field == 'Category')
                          localizedLabel = l10n.category;
                        else if (field == 'Type')
                          localizedLabel = l10n.type;
                        else if (field == 'Contact')
                          localizedLabel = l10n.contact;

                        return DropdownMenuItem<String>(
                          value: field,
                          child: Text(localizedLabel),
                        );
                      }),
                    ],
                    onChanged: (field) {
                      setState(() {
                        // Clear previous mapping for this field if any
                        if (field != null) {
                          _columnMapping.updateAll(
                              (key, value) => value == colIndex ? null : value);
                          _columnMapping[field] = colIndex;
                        } else {
                          // If cancelled, find which field was mapped to this column and clear it
                          _columnMapping.updateAll(
                              (key, value) => value == colIndex ? null : value);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultValuesSection(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_defaultType));
    final contactsAsync = ref.watch(contactsListProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          l10n.defaultValues,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isTablet)
                  Row(
                    children: [
                      Expanded(child: _buildDefaultTypeDropdown(l10n)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDefaultDatePicker(context, l10n)),
                    ],
                  )
                else ...[
                  _buildDefaultTypeDropdown(l10n),
                  const SizedBox(height: 16),
                  _buildDefaultDatePicker(context, l10n),
                ],
                const SizedBox(height: 16),
                if (isTablet)
                  Row(
                    children: [
                      Expanded(
                          child: _buildDefaultCategoryDropdown(
                              l10n, categoriesAsync)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildDefaultContactDropdown(
                              l10n, contactsAsync)),
                    ],
                  )
                else ...[
                  _buildDefaultCategoryDropdown(l10n, categoriesAsync),
                  const SizedBox(height: 16),
                  _buildDefaultContactDropdown(l10n, contactsAsync),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultTypeDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _defaultType,
      decoration: InputDecoration(
        labelText: l10n.type,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 'EXPENSE', child: Text(l10n.expense)),
        DropdownMenuItem(value: 'INCOME', child: Text(l10n.income)),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _defaultType = value;
            _defaultCategory = null;
          });
        }
      },
    );
  }

  Widget _buildDefaultDatePicker(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _defaultDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() => _defaultDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.date,
          border: const OutlineInputBorder(),
        ),
        child: Text(AppDateFormatter.formatDate(_defaultDate)),
      ),
    );
  }

  Widget _buildDefaultCategoryDropdown(
      AppLocalizations l10n, AsyncValue<List<Category>> categoriesAsync) {
    return DropdownButtonFormField<Category?>(
      value: _defaultCategory,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.category,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.cancel)),
        ...(categoriesAsync.value ?? []).map((c) {
          final isExpense = c.type == 'EXPENSE';
          final color = c.color != null
              ? Color(int.parse(c.color!.replaceAll('#', '0xFF')))
              : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

          return DropdownMenuItem(
            value: c,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CategoryHelper.buildCategoryIcon(
                      c.icon, color, isExpense,
                      size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    CategoryHelper.getCategoryName(c, l10n),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) => setState(() => _defaultCategory = value),
    );
  }

  Widget _buildDefaultContactDropdown(
      AppLocalizations l10n, AsyncValue<List<Contact>> contactsAsync) {
    return DropdownButtonFormField<Contact?>(
      value: _defaultContact,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.contact,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.cancel)),
        ...(contactsAsync.value ?? []).map((c) {
          final color = AppColors.transactionsSectionColor;

          return DropdownMenuItem(
            value: c,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Text(
                    c.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) => setState(() => _defaultContact = value),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final startIndex = _hasHeader ? 1 : 0;
    final rowsToPreview = _rawRows.skip(startIndex).toList();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.preview,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedRowIndices.length} / ${rowsToPreview.length} ${l10n.selected}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              showCheckboxColumn: false, // Hide the default checkbox column
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: rowsToPreview.isNotEmpty &&
                        _selectedRowIndices.length == rowsToPreview.length,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRowIndices =
                              Iterable<int>.generate(_rawRows.length).toSet();
                          if (_hasHeader) _selectedRowIndices.remove(0);
                        } else {
                          _selectedRowIndices.clear();
                        }
                      });
                    },
                  ),
                ),
                ...[
                  'Date',
                  'Amount',
                  'Description',
                  'Category',
                  'Type',
                  'Contact'
                ].map((field) {
                  String localizedLabel = field;
                  if (field == 'Date')
                    localizedLabel = l10n.date;
                  else if (field == 'Amount')
                    localizedLabel = l10n.amount;
                  else if (field == 'Description')
                    localizedLabel = l10n.description;
                  else if (field == 'Category')
                    localizedLabel = l10n.category;
                  else if (field == 'Type')
                    localizedLabel = l10n.type;
                  else if (field == 'Contact') localizedLabel = l10n.contact;
                  return DataColumn(label: Text(localizedLabel));
                }),
              ],
              rows: List.generate(rowsToPreview.length, (index) {
                final rowIndex = index + startIndex;
                final row = _rawRows[rowIndex];
                final isSelected = _selectedRowIndices.contains(rowIndex);

                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (value) {
                    setState(() {
                      if (value == true)
                        _selectedRowIndices.add(rowIndex);
                      else
                        _selectedRowIndices.remove(rowIndex);
                    });
                  },
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true)
                              _selectedRowIndices.add(rowIndex);
                            else
                              _selectedRowIndices.remove(rowIndex);
                          });
                        },
                      ),
                    ),
                    ...[
                      'Date',
                      'Amount',
                      'Description',
                      'Category',
                      'Type',
                      'Contact'
                    ].map((field) {
                      final colIndex = _columnMapping[field];
                      String value = '';
                      bool isDefault = false;

                      if (colIndex != null && colIndex < row.length) {
                        value = row[colIndex].trim();
                      }

                      if (value.isEmpty) {
                        isDefault = true;
                        if (field == 'Date')
                          value = AppDateFormatter.formatDate(_defaultDate);
                        else if (field == 'Amount')
                          value = '0.00';
                        else if (field == 'Category')
                          value = _defaultCategory?.name ?? '-';
                        else if (field == 'Type')
                          value = _defaultType;
                        else if (field == 'Contact')
                          value = _defaultContact?.name ?? '-';
                      }

                      return DataCell(
                        Text(
                          value,
                          style: isDefault
                              ? const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey)
                              : null,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportAction(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isImporting || _selectedRowIndices.isEmpty
            ? null
            : _importTransactions,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: AppColors.transactionsSectionColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isImporting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                '${l10n.import} ${_selectedRowIndices.length} ${l10n.transactions}'),
      ),
    );
  }

  // --- Logic Methods ---

  void _processRawData(String content) {
    if (content.isEmpty) return;
    _lastRawContent = content;

    try {
      final lines = content
          .split(RegExp(r'\r?\n'))
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.isEmpty) return;

      setState(() {
        _rawRows = lines.map((l) => l.split(_separator)).toList();
        _selectedRowIndices = Iterable<int>.generate(_rawRows.length).toSet();

        if (_hasHeader && _rawRows.isNotEmpty) {
          _headers = _rawRows.first.map((h) => h.trim()).toList();
          _selectedRowIndices.remove(0);
        } else {
          _headers = [];
        }
        _autoDetectColumns();
      });
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, 'Error parsing data with selected separator');
      }
    }
  }

  void _autoDetectColumns() {
    if (_headers.isEmpty) return;

    // Reset current mapping to avoid confusion from previous data
    final Map<String, int?> mapping = {
      'Date': null,
      'Amount': null,
      'Description': null,
      'Category': null,
      'Type': null,
      'Contact': null,
    };

    for (int i = 0; i < _headers.length; i++) {
      final header = _headers[i].toLowerCase();

      if (header.contains('date'))
        mapping['Date'] = i;
      else if (header.contains('amount') ||
          header.contains('price') ||
          header.contains('value'))
        mapping['Amount'] = i;
      else if (header.contains('desc'))
        mapping['Description'] = i;
      else if (header.contains('cat'))
        mapping['Category'] = i;
      else if (header.contains('type'))
        mapping['Type'] = i;
      else if (header.contains('contact') ||
          header.contains('name') ||
          header.contains('person')) mapping['Contact'] = i;
    }

    if (mapping['Date'] != null && _rawRows.length > (_hasHeader ? 1 : 0)) {
      final sampleDate = _rawRows[_hasHeader ? 1 : 0][mapping['Date']!];
      _suggestDateFormat(sampleDate);
    }

    setState(() {
      _columnMapping = Map<String, int?>.from(mapping);
    });
  }

  void _suggestDateFormat(String sample) {
    if (sample.isEmpty) return;

    if (sample.contains('-')) {
      if (sample.indexOf('-') == 4)
        _dateFormat = 'yyyy-MM-dd';
      else
        _dateFormat = 'dd-MM-yyyy';
    } else if (sample.contains('/')) {
      final parts = sample.split('/');
      if (parts.isNotEmpty) {
        final first = int.tryParse(parts[0]);
        if (first != null && first > 12)
          _dateFormat = 'dd/MM/yyyy';
        else
          _dateFormat = 'MM/dd/yyyy';
      }
    } else if (RegExp(r'[a-zA-Z]').hasMatch(sample)) {
      _dateFormat = 'MMM dd, yyyy';
    }
  }

  Future<void> _importTransactions() async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(transactionServiceProvider);
    final categoriesRepo = ref.read(categoriesRepositoryProvider);
    final contactsRepo = ref.read(contactsRepositoryProvider);

    setState(() => _isImporting = true);

    int successCount = 0;
    int errorCount = 0;

    try {
      for (final rowIndex in _selectedRowIndices) {
        final row = _rawRows[rowIndex];

        final dateStr = _columnMapping['Date'] != null &&
                _columnMapping['Date']! < row.length
            ? row[_columnMapping['Date']!]
            : '';
        final amountStr = _columnMapping['Amount'] != null &&
                _columnMapping['Amount']! < row.length
            ? row[_columnMapping['Amount']!]
            : '';
        final description = _columnMapping['Description'] != null &&
                _columnMapping['Description']! < row.length
            ? row[_columnMapping['Description']!]
            : '';
        final categoryName = _columnMapping['Category'] != null &&
                _columnMapping['Category']! < row.length
            ? row[_columnMapping['Category']!]
            : '';
        final typeStr = _columnMapping['Type'] != null &&
                _columnMapping['Type']! < row.length
            ? row[_columnMapping['Type']!]
            : '';
        final contactName = _columnMapping['Contact'] != null &&
                _columnMapping['Contact']! < row.length
            ? row[_columnMapping['Contact']!]
            : '';

        DateTime date = _defaultDate;
        if (dateStr.isNotEmpty) {
          try {
            date = DateFormat(_dateFormat).parse(dateStr);
          } catch (_) {}
        }

        double amount = 0.0;
        if (amountStr.isNotEmpty) {
          amount =
              double.tryParse(amountStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0.0;
        }

        String type = _defaultType;
        if (typeStr.isNotEmpty) {
          final t = typeStr.toUpperCase();
          if (t.contains('INC'))
            type = 'INCOME';
          else if (t.contains('EXP')) type = 'EXPENSE';
        }

        String? categoryUuid = _defaultCategory?.uuid;
        if (categoryName.isNotEmpty) {
          final categories =
              await categoriesRepo.watchCategoriesByType(type).first;
          final match = categories
              .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
              .firstOrNull;
          if (match != null) {
            categoryUuid = match.uuid;
          } else {
            // Create new category if not found
            final isExpense = type == 'EXPENSE';
            final defaultIcon =
                isExpense ? Symbols.payments : Symbols.account_balance_wallet;

            categoryUuid = await categoriesRepo.createCategory(
              CategoriesCompanion(
                name: Value(categoryName),
                type: Value(type),
                isDefault: const Value(false),
                icon: Value(defaultIcon.codePoint.toString()),
                color: Value(isExpense
                    ? AppColors.expenseColor.value
                        .toRadixString(16)
                        .padLeft(8, '0')
                        .replaceFirst('ff', '#')
                    : AppColors.incomeColor.value
                        .toRadixString(16)
                        .padLeft(8, '0')
                        .replaceFirst('ff', '#')),
              ),
            );
          }
        }

        String? contactUuid = _defaultContact?.uuid;
        if (contactName.isNotEmpty) {
          final contacts = await contactsRepo.watchAllContacts().first;
          final match = contacts
              .where((c) => c.name.toLowerCase() == contactName.toLowerCase())
              .firstOrNull;
          if (match != null) {
            contactUuid = match.uuid;
          } else {
            // Create new contact if not found
            contactUuid = await contactsRepo.createContact(
              ContactsCompanion(
                name: Value(contactName),
              ),
            );
            // Refresh contacts to avoid duplicate creation in the same batch
            ref.invalidate(contactsRepositoryProvider);
          }
        }

        try {
          await service.createTransaction(
            amount: amount,
            type: type,
            date: date,
            description: description.isNotEmpty ? description : null,
            categoryUuid: categoryUuid,
            contactUuid: contactUuid,
          );
          successCount++;
        } catch (e) {
          errorCount++;
        }
      }

      if (mounted) {
        if (errorCount == 0) {
          ToastUtils.showSuccessToast(
              context, ref, l10n.importedSuccessfully(successCount));
          Navigator.of(context).pop();
        } else {
          ToastUtils.showInfoToast(
              context, ref, 'Imported $successCount, failed $errorCount');
        }
      }
    } catch (e) {
      if (mounted) ToastUtils.showErrorToast(context, ref, e.toString());
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
