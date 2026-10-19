import 'dart:async';
import 'dart:math' show min;

import 'package:drift/drift.dart' hide Column;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/bulk_import_parse.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart' hide Category;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

/// Holds default-value fields for bulk import; updated via [ValueNotifier] so
/// changing mapping does not rebuild defaults (and vice versa).
class BulkImportDefaultsData {
  const BulkImportDefaultsData({
    required this.defaultType,
    this.defaultCategory,
    this.defaultContact,
    this.defaultAccount,
    this.defaultLinkIntent,
    required this.defaultDate,
  });

  final String defaultType;
  final Category? defaultCategory;
  final Contact? defaultContact;
  final Account? defaultAccount;
  final String? defaultLinkIntent;
  final DateTime defaultDate;
}

/// Defers building the heavy preview [DataTable] until [delay] after data changes.
class _BulkImportPreviewDeferred extends StatefulWidget {
  const _BulkImportPreviewDeferred({
    required this.listenable,
    required this.delay,
    required this.rawRowsVersion,
    required this.placeholderBuilder,
    required this.tableBuilder,
  });

  final Listenable listenable;
  final Duration delay;
  final int rawRowsVersion;
  final WidgetBuilder placeholderBuilder;
  final WidgetBuilder tableBuilder;

  @override
  State<_BulkImportPreviewDeferred> createState() =>
      _BulkImportPreviewDeferredState();
}

class _BulkImportPreviewDeferredState extends State<_BulkImportPreviewDeferred> {
  Timer? _timer;
  bool _showTable = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onDataChanged);
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _BulkImportPreviewDeferred oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onDataChanged);
      widget.listenable.addListener(_onDataChanged);
    }
    if (oldWidget.rawRowsVersion != widget.rawRowsVersion) {
      _schedule();
    }
  }

  void _onDataChanged() {
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    setState(() => _showTable = false);
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _showTable = true);
      }
    });
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onDataChanged);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTable) {
      return widget.placeholderBuilder(context);
    }
    return widget.tableBuilder(context);
  }
}

class BulkImportScreen extends ConsumerStatefulWidget {
  final String? initialContent;
  const BulkImportScreen({super.key, this.initialContent});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  /// Default preview row count before the user taps "Show all".
  static const int _kPreviewRowsInitial = 20;

  static const List<String> _kMappingFields = [
    'Date',
    'Amount',
    'Description',
    'Category',
    'Type',
    'Contact',
    'Link',
    'Account',
  ];

  /// Rows above this: show a short busy overlay when mapping/defaults change.
  static const int _kPreviewBusyRowThreshold = 80;

  /// Defer building the preview [DataTable] so mapping/defaults stay responsive.
  static const Duration _kPreviewTableRevealDelay = Duration(milliseconds: 350);

  // Parsing state
  List<List<String>> _rawRows = [];
  List<String> _headers = [];
  bool _hasHeader = true;
  String _separator = '\t'; // Default to Tab for Google Sheets
  String _dateFormat = 'dd/MM/yyyy';
  String? _lastRawContent;

  final ValueNotifier<Map<String, int?>> _columnMappingNotifier =
      ValueNotifier<Map<String, int?>>({
    'Date': null,
    'Amount': null,
    'Description': null,
    'Category': null,
    'Type': null,
    'Contact': null,
    'Link': null,
    'Account': null,
  });

  final ValueNotifier<BulkImportDefaultsData> _defaultsNotifier =
      ValueNotifier<BulkImportDefaultsData>(
    BulkImportDefaultsData(
      defaultType: 'EXPENSE',
      defaultDate: DateTime.now(),
    ),
  );

  final ValueNotifier<Set<int>> _selectedRowIndicesNotifier =
      ValueNotifier<Set<int>>({});

  /// Keeps scroll offset when the subtree rebuilds (mapping/defaults/preview).
  final ScrollController _bulkImportScrollController = ScrollController();

  /// One notifier per spreadsheet column index — only that dropdown rebuilds.
  List<ValueNotifier<String?>>? _mappingFieldPerColumn;

  Listenable? _previewDataListenableCache;

  /// Mapping + defaults only. Selection is *not* included so toggling checkboxes
  /// does not rebuild the whole [DataTable].
  Listenable get _previewDataListenable {
    return _previewDataListenableCache ??= Listenable.merge([
      _columnMappingNotifier,
      _defaultsNotifier,
    ]);
  }

  Map<String, int?> get _columnMapping => _columnMappingNotifier.value;

  bool _isImporting = false;
  bool _isParsingContent = false;
  bool _isUiBusy = false;
  /// When false, preview shows only [_kPreviewRowsInitial] rows.
  bool _previewTableExpanded = false;
  int _importCurrent = 0;
  int _importTotal = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Let the push transition (and any sheet above) finish before parsing.
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (!mounted) {
          return;
        }
        await _loadRawData(widget.initialContent!);
      });
    }
  }

  @override
  void dispose() {
    _disposeMappingFieldNotifiers();
    _bulkImportScrollController.dispose();
    _columnMappingNotifier.dispose();
    _defaultsNotifier.dispose();
    _selectedRowIndicesNotifier.dispose();
    super.dispose();
  }

  void _disposeMappingFieldNotifiers() {
    if (_mappingFieldPerColumn == null) {
      return;
    }
    for (final n in _mappingFieldPerColumn!) {
      n.dispose();
    }
    _mappingFieldPerColumn = null;
  }

  void _ensureMappingFieldNotifiers(int maxColumns) {
    if (_mappingFieldPerColumn != null &&
        _mappingFieldPerColumn!.length == maxColumns) {
      return;
    }
    _disposeMappingFieldNotifiers();
    if (maxColumns == 0) {
      return;
    }
    _mappingFieldPerColumn = List.generate(
      maxColumns,
      (_) => ValueNotifier<String?>(null),
    );
  }

  void _syncMappingFieldNotifiersFromMasterMap(int maxColumns) {
    _ensureMappingFieldNotifiers(maxColumns);
    if (maxColumns == 0 || _mappingFieldPerColumn == null) {
      return;
    }
    final map = _columnMappingNotifier.value;
    for (var i = 0; i < maxColumns; i++) {
      String? fieldForCol;
      for (final f in _kMappingFields) {
        if (map[f] == i) {
          fieldForCol = f;
          break;
        }
      }
      if (_mappingFieldPerColumn![i].value != fieldForCol) {
        _mappingFieldPerColumn![i].value = fieldForCol;
      }
    }
  }

  void _rebuildColumnMappingFromFieldNotifiers() {
    final list = _mappingFieldPerColumn;
    if (list == null) {
      return;
    }
    final m = <String, int?>{
      for (final f in _kMappingFields) f: null,
    };
    for (var i = 0; i < list.length; i++) {
      final field = list[i].value;
      if (field != null) {
        m[field] = i;
      }
    }
    _columnMappingNotifier.value = m;
  }

  String _mappingFieldLabel(AppLocalizations l10n, String field) {
    switch (field) {
      case 'Date':
        return l10n.date;
      case 'Amount':
        return l10n.amount;
      case 'Description':
        return l10n.description;
      case 'Category':
        return l10n.category;
      case 'Type':
        return l10n.type;
      case 'Contact':
        return l10n.contact;
      case 'Account':
        return l10n.account;
      case 'Link':
        return l10n.bulkImportLinkColumn;
      default:
        return field;
    }
  }

  /// Parses AR/AP column text. Returns `RECEIVABLE`, `PAYABLE`, or null.
  static String? _parseLinkCell(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) {
      return null;
    }
    if (s.contains('RECEIV') || s == 'AR') {
      return 'RECEIVABLE';
    }
    if (s.contains('PAYABLE') || s == 'AP') {
      return 'PAYABLE';
    }
    return null;
  }

  /// Row cell when non-empty; otherwise default from import settings.
  String? _effectiveRowLinkIntent(String rowCell) {
    if (rowCell.trim().isNotEmpty) {
      return _parseLinkCell(rowCell);
    }
    return _defaultsNotifier.value.defaultLinkIntent;
  }

  /// Maps expense/income + receivable/payable to [paidRelationship].
  static String? _paidRelationshipForTypeAndLink(
      String type, String? linkIntent) {
    if (linkIntent == null) {
      return null;
    }
    if (type == 'EXPENSE' && linkIntent == 'RECEIVABLE') {
      return 'PAID_FOR';
    }
    if (type == 'EXPENSE' && linkIntent == 'PAYABLE') {
      return 'PAID_BY';
    }
    if (type == 'INCOME' && linkIntent == 'RECEIVABLE') {
      return 'WILL_RECEIVE';
    }
    if (type == 'INCOME' && linkIntent == 'PAYABLE') {
      return 'RECEIVED_FROM';
    }
    return null;
  }

  /// After [setState] shows a busy overlay, waits until that overlay has been
  /// laid out and painted before starting heavy work (compute, large rebuilds).
  Future<void> _waitForBusyOverlayPaint() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    await SchedulerBinding.instance.endOfFrame;
  }

  Future<void> _runWithPreviewBusy(VoidCallback fn) async {
    final heavy = _rawRows.length > _kPreviewBusyRowThreshold;
    if (heavy && mounted) {
      setState(() => _isUiBusy = true);
      await _waitForBusyOverlayPaint();
    }
    try {
      if (!mounted) {
        return;
      }
      fn();
      if (heavy && mounted) {
        await SchedulerBinding.instance.endOfFrame;
      }
    } finally {
      if (heavy && mounted) {
        setState(() => _isUiBusy = false);
      }
    }
  }

  Future<void> _runPreviewExpandToggle() async {
    if (!mounted || _isUiBusy) {
      return;
    }
    setState(() => _isUiBusy = true);
    await _waitForBusyOverlayPaint();
    if (!mounted) {
      return;
    }
    setState(() {
      _previewTableExpanded = !_previewTableExpanded;
    });
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    setState(() => _isUiBusy = false);
  }

  /// Updates header/separator in one [setState] with [_isParsingContent] so the
  /// next build skips the heavy mapping/preview subtree; then parses after the
  /// overlay can paint.
  void _applyParseOptionChangeAndReload(void Function() applyOption) {
    final content = _lastRawContent ?? '';
    if (content.isEmpty) {
      setState(applyOption);
      return;
    }
    setState(() {
      applyOption();
      _isParsingContent = true;
    });
    Future<void>(() async {
      await _waitForBusyOverlayPaint();
      if (!mounted) {
        return;
      }
      await _parseAndApplyContent(content);
    });
  }

  Future<void> _parseAndApplyContent(String content) async {
    try {
      final request = BulkImportParseRequest(
        content: content,
        separator: _separator,
        hasHeader: _hasHeader,
      );
      // Parse on a background isolate (VM/desktop/mobile) so the UI thread
      // does not block on split/map for large pastes.
      final result = await compute(parseBulkImportData, request);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastRawContent = content;
        _rawRows = result.rawRows;
        _headers = result.headers;
        _dateFormat = result.dateFormat;
        _previewTableExpanded = false;
      });
      _columnMappingNotifier.value =
          Map<String, int?>.from(result.columnMapping);
      _syncMappingFieldNotifiersFromMasterMap(
        result.rawRows.isNotEmpty ? result.rawRows.first.length : 0,
      );
      _selectedRowIndicesNotifier.value = result.selectedRowIndices.toSet();
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, 'Error parsing data with selected separator');
      }
    } finally {
      if (mounted) {
        setState(() => _isParsingContent = false);
      }
    }
  }

  Future<void> _loadRawData(String content) async {
    if (content.isEmpty) {
      return;
    }
    setState(() => _isParsingContent = true);
    await _waitForBusyOverlayPaint();
    if (!mounted) {
      return;
    }
    await _parseAndApplyContent(content);
  }

  void _reportImportProgress(int current, int total) {
    if (!mounted || total <= 0) {
      return;
    }
    final step = (total ~/ 80).clamp(1, 50);
    if (current == 1 ||
        current == total ||
        current % step == 0 ||
        total <= 30) {
      setState(() {
        _importCurrent = current;
        _importTotal = total;
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
      body: SafeArea(
        top: false,
        child: Stack(
        children: [
          Column(
            children: [
              if (_rawRows.isEmpty && !_isParsingContent)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file,
                            size: 64,
                            color: Theme.of(context).disabledColor),
                        const SizedBox(height: 16),
                        Text(l10n.noTransactions),
                      ],
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: SingleChildScrollView(
                    key: const PageStorageKey<String>(
                        'bulk_import_main_scroll'),
                    controller: _bulkImportScrollController,
                    child: Column(
                      children: [
                        _buildConfigurationSection(context, isTablet),
                        // Only shrink while raw data is re-parsed; keep full height
                        // during [_isUiBusy] so scroll offset is not destroyed.
                        if (_isParsingContent)
                          const SizedBox(height: 120)
                        else ...[
                          _buildMappingSection(context, isTablet),
                          _buildDefaultValuesSection(context, isTablet),
                          _buildPreviewSection(context),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildImportAction(context),
              ],
            ],
          ),
          if (_isParsingContent || _isUiBusy)
            Positioned.fill(
              child: AbsorbPointer(
                child: SizedBox.expand(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Material(
                        elevation: 6,
                        shadowColor: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.18),
                        surfaceTintColor:
                            Theme.of(context).colorScheme.surfaceTint,
                        borderRadius: BorderRadius.circular(20),
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppLoadingIndicator(
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isParsingContent
                                    ? l10n.bulkImportLoadingContent
                                    : l10n.bulkImportUpdatingPreview,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
            ),
        ],
        ),
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
                      await _loadRawData(data!.text!);
                    } else {
                      if (mounted) {
                        ToastUtils.showInfoToast(
                            context, ref, 'Clipboard is empty');
                      }
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
                _applyParseOptionChangeAndReload(() {
                  _hasHeader = value;
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
          _applyParseOptionChangeAndReload(() {
            _separator = value;
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
      onChanged: (value) async {
        if (value != null) {
          await _runWithPreviewBusy(() {
            setState(() {
              _dateFormat = value;
            });
          });
        }
      },
    );
  }

  Widget _buildMappingSection(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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

    if (maxColumns > 0 &&
        (_mappingFieldPerColumn == null ||
            _mappingFieldPerColumn!.length != maxColumns)) {
      _syncMappingFieldNotifiersFromMasterMap(maxColumns);
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
                if (_mappingFieldPerColumn == null ||
                    colIndex >= _mappingFieldPerColumn!.length) {
                  return const SizedBox.shrink();
                }
                final fieldNotifier = _mappingFieldPerColumn![colIndex];

                return SizedBox(
                  width: isTablet
                      ? (MediaQuery.of(context).size.width - 100) / 3
                      : (MediaQuery.of(context).size.width - 64),
                  child: ValueListenableBuilder<String?>(
                    valueListenable: fieldNotifier,
                    builder: (context, selectedField, _) {
                      return DropdownButtonFormField<String>(
                        key: ValueKey('mapping_col_${colIndex}_${maxColumns}'),
                        value: selectedField,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: colName,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                              value: null, child: Text(l10n.cancel)),
                          ..._kMappingFields.map((field) {
                            return DropdownMenuItem<String>(
                              value: field,
                              child: Text(_mappingFieldLabel(l10n, field)),
                            );
                          }),
                        ],
                        onChanged: (field) async {
                          await _runWithPreviewBusy(() {
                            if (field != null) {
                              for (var j = 0;
                                  j < _mappingFieldPerColumn!.length;
                                  j++) {
                                if (j != colIndex &&
                                    _mappingFieldPerColumn![j].value ==
                                        field) {
                                  _mappingFieldPerColumn![j].value = null;
                                }
                              }
                            }
                            fieldNotifier.value = field;
                            _rebuildColumnMappingFromFieldNotifiers();
                          });
                        },
                      );
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
    final contactsAsync = ref.watch(contactsListProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    return ValueListenableBuilder<BulkImportDefaultsData>(
      valueListenable: _defaultsNotifier,
      builder: (context, d, _) {
        final categoriesAsync =
            ref.watch(categoriesByTypeProvider(d.defaultType));
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          Expanded(child: _buildDefaultTypeDropdown(l10n, d)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildDefaultDatePicker(context, l10n, d)),
                        ],
                      )
                    else ...[
                      _buildDefaultTypeDropdown(l10n, d),
                      const SizedBox(height: 16),
                      _buildDefaultDatePicker(context, l10n, d),
                    ],
                    const SizedBox(height: 16),
                    if (isTablet)
                      Row(
                        children: [
                          Expanded(
                              child: _buildDefaultCategoryDropdown(
                                  l10n, categoriesAsync, d)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildDefaultContactDropdown(
                                  l10n, contactsAsync, d)),
                        ],
                      )
                    else ...[
                      _buildDefaultCategoryDropdown(
                          l10n, categoriesAsync, d),
                      const SizedBox(height: 16),
                      _buildDefaultContactDropdown(l10n, contactsAsync, d),
                    ],
                    const SizedBox(height: 16),
                    _buildDefaultLinkDropdown(l10n, d),
                    const SizedBox(height: 16),
                    _buildDefaultAccountDropdown(l10n, accountsAsync, d),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultTypeDropdown(
      AppLocalizations l10n, BulkImportDefaultsData d) {
    return DropdownButtonFormField<String>(
      value: d.defaultType,
      decoration: InputDecoration(
        labelText: l10n.type,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 'EXPENSE', child: Text(l10n.expense)),
        DropdownMenuItem(value: 'INCOME', child: Text(l10n.income)),
      ],
      onChanged: (value) async {
        if (value != null) {
          await _runWithPreviewBusy(() {
            final v = _defaultsNotifier.value;
            _defaultsNotifier.value = BulkImportDefaultsData(
              defaultType: value,
              defaultCategory: null,
              defaultContact: v.defaultContact,
              defaultAccount: v.defaultAccount,
              defaultLinkIntent: v.defaultLinkIntent,
              defaultDate: v.defaultDate,
            );
          });
        }
      },
    );
  }

  Widget _buildDefaultLinkDropdown(
      AppLocalizations l10n, BulkImportDefaultsData d) {
    return DropdownButtonFormField<String?>(
      value: d.defaultLinkIntent,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.bulkImportDefaultLink,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.none)),
        DropdownMenuItem(
            value: 'RECEIVABLE', child: Text(l10n.receivable)),
        DropdownMenuItem(value: 'PAYABLE', child: Text(l10n.payable)),
      ],
      onChanged: (value) async {
        await _runWithPreviewBusy(() {
          final v = _defaultsNotifier.value;
          _defaultsNotifier.value = BulkImportDefaultsData(
            defaultType: v.defaultType,
            defaultCategory: v.defaultCategory,
            defaultContact: v.defaultContact,
            defaultAccount: v.defaultAccount,
            defaultLinkIntent: value,
            defaultDate: v.defaultDate,
          );
        });
      },
    );
  }

  Widget _buildDefaultDatePicker(
      BuildContext context, AppLocalizations l10n, BulkImportDefaultsData d) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: d.defaultDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          await _runWithPreviewBusy(() {
            final v = _defaultsNotifier.value;
            _defaultsNotifier.value = BulkImportDefaultsData(
              defaultType: v.defaultType,
              defaultCategory: v.defaultCategory,
              defaultContact: v.defaultContact,
              defaultAccount: v.defaultAccount,
              defaultLinkIntent: v.defaultLinkIntent,
              defaultDate: date,
            );
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.date,
          border: const OutlineInputBorder(),
        ),
        child: Text(AppDateFormatter.formatDate(d.defaultDate)),
      ),
    );
  }

  Widget _buildDefaultCategoryDropdown(
      AppLocalizations l10n,
      AsyncValue<List<Category>> categoriesAsync,
      BulkImportDefaultsData d) {
    return DropdownButtonFormField<Category?>(
      value: d.defaultCategory,
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
      onChanged: (value) async {
        await _runWithPreviewBusy(() {
          final v = _defaultsNotifier.value;
          _defaultsNotifier.value = BulkImportDefaultsData(
            defaultType: v.defaultType,
            defaultCategory: value,
            defaultContact: v.defaultContact,
            defaultAccount: v.defaultAccount,
            defaultLinkIntent: v.defaultLinkIntent,
            defaultDate: v.defaultDate,
          );
        });
      },
    );
  }

  Widget _buildDefaultContactDropdown(
      AppLocalizations l10n,
      AsyncValue<List<Contact>> contactsAsync,
      BulkImportDefaultsData d) {
    return DropdownButtonFormField<Contact?>(
      value: d.defaultContact,
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
      onChanged: (value) async {
        await _runWithPreviewBusy(() {
          final v = _defaultsNotifier.value;
          _defaultsNotifier.value = BulkImportDefaultsData(
            defaultType: v.defaultType,
            defaultCategory: v.defaultCategory,
            defaultContact: value,
            defaultAccount: v.defaultAccount,
            defaultLinkIntent: v.defaultLinkIntent,
            defaultDate: v.defaultDate,
          );
        });
      },
    );
  }

  Widget _buildDefaultAccountDropdown(
      AppLocalizations l10n,
      AsyncValue<List<Account>> accountsAsync,
      BulkImportDefaultsData d) {
    return DropdownButtonFormField<Account?>(
      value: d.defaultAccount,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.account,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.cancel)),
        ...(accountsAsync.value ?? []).map((a) {
          return DropdownMenuItem(
            value: a,
            child: Text(
              a.name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: (value) async {
        await _runWithPreviewBusy(() {
          final v = _defaultsNotifier.value;
          _defaultsNotifier.value = BulkImportDefaultsData(
            defaultType: v.defaultType,
            defaultCategory: v.defaultCategory,
            defaultContact: v.defaultContact,
            defaultAccount: value,
            defaultLinkIntent: v.defaultLinkIntent,
            defaultDate: v.defaultDate,
          );
        });
      },
    );
  }

  Widget _buildPreviewPlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            AppLoadingIndicator(
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.bulkImportUpdatingPreview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return _BulkImportPreviewDeferred(
      listenable: _previewDataListenable,
      delay: _kPreviewTableRevealDelay,
      rawRowsVersion: _rawRows.length,
      placeholderBuilder: _buildPreviewPlaceholder,
      tableBuilder: (ctx) => ListenableBuilder(
        listenable: _previewDataListenable,
        builder: (context, _) {
          return _buildPreviewTableCard(context);
        },
      ),
    );
  }

  Widget _buildPreviewTableCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final columnMapping = _columnMappingNotifier.value;
    final def = _defaultsNotifier.value;

    final startIndex = _hasHeader ? 1 : 0;
    final rowsToPreview = _rawRows.skip(startIndex).toList();
    final totalDataRows = rowsToPreview.length;
    final previewRowCount = _previewTableExpanded
        ? totalDataRows
        : min(_kPreviewRowsInitial, totalDataRows);

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
                ValueListenableBuilder<Set<int>>(
                  valueListenable: _selectedRowIndicesNotifier,
                  builder: (context, selected, _) {
                    return Text(
                      '${selected.length} / $totalDataRows ${l10n.selected}',
                      style: theme.textTheme.bodySmall,
                    );
                  },
                ),
              ],
            ),
          ),
          if (!_previewTableExpanded && totalDataRows > _kPreviewRowsInitial)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.bulkImportPreviewShowingFirst(
                  min(_kPreviewRowsInitial, totalDataRows),
                  totalDataRows,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          if (_previewTableExpanded && totalDataRows > _kPreviewRowsInitial)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.bulkImportPreviewShowingAllRows(totalDataRows),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          if (totalDataRows > _kPreviewRowsInitial)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isUiBusy ? null : () => _runPreviewExpandToggle(),
                  child: Text(
                    _previewTableExpanded
                        ? l10n.bulkImportPreviewShowLess
                        : l10n.bulkImportPreviewShowAll,
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              showCheckboxColumn: false,
              columns: [
                DataColumn(
                  label: _BulkImportSelectAllCheckbox(
                    selectionListenable: _selectedRowIndicesNotifier,
                    startIndex: startIndex,
                    totalDataRows: totalDataRows,
                    totalRawRowCount: _rawRows.length,
                    hasHeader: _hasHeader,
                  ),
                ),
                ..._kMappingFields.map((field) {
                  return DataColumn(
                      label: Text(_mappingFieldLabel(l10n, field)));
                }),
              ],
              rows: List.generate(previewRowCount, (index) {
                final rowIndex = index + startIndex;
                final row = _rawRows[rowIndex];

                return DataRow(
                  onSelectChanged: (value) {
                    final s =
                        Set<int>.from(_selectedRowIndicesNotifier.value);
                    if (value == true) {
                      s.add(rowIndex);
                    } else {
                      s.remove(rowIndex);
                    }
                    _selectedRowIndicesNotifier.value = s;
                  },
                  cells: [
                    DataCell(
                      _BulkImportRowCheckbox(
                        rowIndex: rowIndex,
                        selectionListenable: _selectedRowIndicesNotifier,
                        onChanged: (value) {
                          final s = Set<int>.from(
                              _selectedRowIndicesNotifier.value);
                          if (value == true) {
                            s.add(rowIndex);
                          } else {
                            s.remove(rowIndex);
                          }
                          _selectedRowIndicesNotifier.value = s;
                        },
                      ),
                    ),
                    ..._kMappingFields.map((field) {
                      final colIndex = columnMapping[field];
                      String cellValue = '';
                      bool isDefaultCell = false;

                      if (colIndex != null && colIndex < row.length) {
                        cellValue = row[colIndex].trim();
                      }

                      if (field == 'Link' && cellValue.isNotEmpty) {
                        final p = _parseLinkCell(cellValue);
                        if (p == 'RECEIVABLE') {
                          cellValue = l10n.receivable;
                        } else if (p == 'PAYABLE') {
                          cellValue = l10n.payable;
                        }
                      }

                      if (cellValue.isEmpty) {
                        isDefaultCell = true;
                        if (field == 'Date') {
                          cellValue =
                              AppDateFormatter.formatDate(def.defaultDate);
                        } else if (field == 'Amount') {
                          cellValue = '0.00';
                        } else if (field == 'Category') {
                          cellValue = def.defaultCategory?.name ?? '-';
                        } else if (field == 'Type') {
                          cellValue = def.defaultType;
                        } else if (field == 'Contact') {
                          cellValue = def.defaultContact?.name ?? '-';
                        } else if (field == 'Account') {
                          cellValue = def.defaultAccount?.name ?? '-';
                        } else if (field == 'Link') {
                          if (def.defaultLinkIntent == null) {
                            cellValue = l10n.none;
                          } else {
                            cellValue = def.defaultLinkIntent == 'RECEIVABLE'
                                ? l10n.receivable
                                : l10n.payable;
                          }
                        }
                      }

                      return DataCell(
                        Text(
                          cellValue,
                          style: isDefaultCell
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
    return ListenableBuilder(
      listenable: _selectedRowIndicesNotifier,
      builder: (context, _) {
        final count = _selectedRowIndicesNotifier.value.length;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isImporting ||
                    _isParsingContent ||
                    _isUiBusy ||
                    count == 0
                ? null
                : _importTransactions,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.transactionsSectionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isImporting
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_importTotal > 0) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _importCurrent / _importTotal,
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.bulkImportProgress(
                            _importTotal == 0
                                ? 0
                                : ((_importCurrent * 100) / _importTotal)
                                    .round()
                                    .clamp(0, 100),
                            _importCurrent,
                            _importTotal,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  )
                : Text('${l10n.import} $count ${l10n.transactions}'),
          ),
        );
      },
    );
  }

  // --- Logic Methods ---

  Future<void> _importTransactions() async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(transactionServiceProvider);
    final categoriesRepo = ref.read(categoriesRepositoryProvider);
    final contactsRepo = ref.read(contactsRepositoryProvider);
    final accountsRepo = ref.read(accountsRepositoryProvider);

    final sortedRows = _selectedRowIndicesNotifier.value.toList()..sort();
    final totalRows = sortedRows.length;

    setState(() {
      _isImporting = true;
      _importCurrent = 0;
      _importTotal = totalRows;
    });

    int successCount = 0;
    int errorCount = 0;

    try {
      final accountsList =
          List<Account>.from(await accountsRepo.getAllAccounts());
      var processed = 0;
      for (final rowIndex in sortedRows) {
        processed++;
        _reportImportProgress(processed, totalRows);

        final row = _rawRows[rowIndex];

        final map = _columnMappingNotifier.value;
        final dateStr = map['Date'] != null && map['Date']! < row.length
            ? row[map['Date']!]
            : '';
        final amountStr = map['Amount'] != null && map['Amount']! < row.length
            ? row[map['Amount']!]
            : '';
        final description =
            map['Description'] != null && map['Description']! < row.length
                ? row[map['Description']!]
                : '';
        final categoryName =
            map['Category'] != null && map['Category']! < row.length
                ? row[map['Category']!]
                : '';
        final typeStr = map['Type'] != null && map['Type']! < row.length
            ? row[map['Type']!]
            : '';
        final contactName =
            map['Contact'] != null && map['Contact']! < row.length
                ? row[map['Contact']!]
                : '';
        final accountName =
            map['Account'] != null && map['Account']! < row.length
                ? row[map['Account']!]
                : '';
        final linkCell = map['Link'] != null && map['Link']! < row.length
            ? row[map['Link']!]
            : '';

        final defaults = _defaultsNotifier.value;
        DateTime date = defaults.defaultDate;
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

        String type = defaults.defaultType;
        if (typeStr.isNotEmpty) {
          final t = typeStr.toUpperCase();
          if (t.contains('INC')) {
            type = 'INCOME';
          } else if (t.contains('EXP')) {
            type = 'EXPENSE';
          }
        }

        String? categoryUuid = defaults.defaultCategory?.uuid;
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

        String? contactUuid = defaults.defaultContact?.uuid;
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

        String? accountUuid = defaults.defaultAccount?.uuid;
        if (accountName.trim().isNotEmpty) {
          final key = accountName.trim().toLowerCase();
          Account? match;
          for (final a in accountsList) {
            if (a.name.toLowerCase() == key) {
              match = a;
              break;
            }
          }
          if (match != null) {
            accountUuid = match.uuid;
          } else {
            final trimmedName = accountName.trim();
            final newUuid = const Uuid().v4();
            final now = DateTime.now();
            await accountsRepo.createAccount(
              AccountsCompanion.insert(
                uuid: newUuid,
                name: trimmedName,
                type: 'CASH',
                openingBalance: const Value(0.0),
                openingDate: Value(date),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
            // Avoid duplicate creates for the same name in this import batch.
            final created = await accountsRepo.getAccountByUuid(newUuid);
            if (created != null) {
              accountsList.add(created);
            }
            accountUuid = newUuid;
            ref.invalidate(accountsStreamProvider);
          }
        }

        var paidRelationship =
            _paidRelationshipForTypeAndLink(type, _effectiveRowLinkIntent(linkCell));
        if (paidRelationship != null && contactUuid == null) {
          paidRelationship = null;
        }

        try {
          await service.createTransaction(
            amount: amount,
            type: type,
            date: date,
            description: description.isNotEmpty ? description : null,
            categoryUuid: categoryUuid,
            contactUuid: contactUuid,
            accountUuid: accountUuid,
            paidRelationship: paidRelationship,
            isImport: true,
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
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importCurrent = 0;
          _importTotal = 0;
        });
      }
    }
  }
}

/// Checkbox for one preview row; listens to [selectionListenable] so the parent
/// [DataTable] does not rebuild when only selection changes.
class _BulkImportRowCheckbox extends StatefulWidget {
  const _BulkImportRowCheckbox({
    required this.rowIndex,
    required this.selectionListenable,
    required this.onChanged,
  });

  final int rowIndex;
  final ValueNotifier<Set<int>> selectionListenable;
  final ValueChanged<bool?> onChanged;

  @override
  State<_BulkImportRowCheckbox> createState() => _BulkImportRowCheckboxState();
}

class _BulkImportRowCheckboxState extends State<_BulkImportRowCheckbox> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectionListenable.value.contains(widget.rowIndex);
    widget.selectionListenable.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant _BulkImportRowCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionListenable != widget.selectionListenable) {
      oldWidget.selectionListenable.removeListener(_onSelectionChanged);
      widget.selectionListenable.addListener(_onSelectionChanged);
    }
    _syncFromNotifier();
  }

  void _onSelectionChanged() {
    final now = widget.selectionListenable.value.contains(widget.rowIndex);
    if (now != _selected) {
      setState(() => _selected = now);
    }
  }

  void _syncFromNotifier() {
    final now = widget.selectionListenable.value.contains(widget.rowIndex);
    if (now != _selected) {
      setState(() => _selected = now);
    }
  }

  @override
  void dispose() {
    widget.selectionListenable.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _selected,
      onChanged: widget.onChanged,
    );
  }
}

/// Header checkbox for select-all; only this widget rebuilds on selection churn.
class _BulkImportSelectAllCheckbox extends StatefulWidget {
  const _BulkImportSelectAllCheckbox({
    required this.selectionListenable,
    required this.startIndex,
    required this.totalDataRows,
    required this.totalRawRowCount,
    required this.hasHeader,
  });

  final ValueNotifier<Set<int>> selectionListenable;
  final int startIndex;
  final int totalDataRows;
  final int totalRawRowCount;
  final bool hasHeader;

  @override
  State<_BulkImportSelectAllCheckbox> createState() =>
      _BulkImportSelectAllCheckboxState();
}

class _BulkImportSelectAllCheckboxState extends State<_BulkImportSelectAllCheckbox> {
  late bool _allSelected;

  bool _computeAllSelected(Set<int> s) {
    if (widget.totalDataRows == 0) {
      return false;
    }
    for (var i = 0; i < widget.totalDataRows; i++) {
      if (!s.contains(widget.startIndex + i)) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _allSelected = _computeAllSelected(widget.selectionListenable.value);
    widget.selectionListenable.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant _BulkImportSelectAllCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectionListenable != widget.selectionListenable) {
      oldWidget.selectionListenable.removeListener(_onSelectionChanged);
      widget.selectionListenable.addListener(_onSelectionChanged);
    }
    _syncFromNotifier();
  }

  void _onSelectionChanged() {
    final now = _computeAllSelected(widget.selectionListenable.value);
    if (now != _allSelected) {
      setState(() => _allSelected = now);
    }
  }

  void _syncFromNotifier() {
    final now = _computeAllSelected(widget.selectionListenable.value);
    if (now != _allSelected) {
      setState(() => _allSelected = now);
    }
  }

  @override
  void dispose() {
    widget.selectionListenable.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.totalDataRows > 0 && _allSelected,
      onChanged: (value) {
        if (value == true) {
          final s = Iterable<int>.generate(widget.totalRawRowCount).toSet();
          if (widget.hasHeader) {
            s.remove(0);
          }
          widget.selectionListenable.value = s;
        } else {
          widget.selectionListenable.value = {};
        }
      },
    );
  }
}
