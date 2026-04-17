/// Heavy CSV / TSV parsing for bulk import — intended to run via [compute]
/// on a background isolate so the UI thread stays responsive.
class BulkImportParseRequest {
  final String content;
  final String separator;
  final bool hasHeader;

  const BulkImportParseRequest({
    required this.content,
    required this.separator,
    required this.hasHeader,
  });
}

class BulkImportParseResult {
  final List<List<String>> rawRows;
  final List<String> headers;
  final List<int> selectedRowIndices;
  final Map<String, int?> columnMapping;
  final String dateFormat;

  const BulkImportParseResult({
    required this.rawRows,
    required this.headers,
    required this.selectedRowIndices,
    required this.columnMapping,
    required this.dateFormat,
  });
}

Map<String, int?> _emptyMapping() => {
      'Date': null,
      'Amount': null,
      'Description': null,
      'Category': null,
      'Type': null,
      'Contact': null,
      'Account': null,
      'Link': null,
    };

Map<String, int?> _detectColumnMapping(List<String> headers) {
  final mapping = _emptyMapping();
  if (headers.isEmpty) {
    return mapping;
  }

  for (var i = 0; i < headers.length; i++) {
    final header = headers[i].toLowerCase();

    if (header.contains('date')) {
      mapping['Date'] = i;
    } else if (header.contains('amount') ||
        header.contains('price') ||
        header.contains('value')) {
      mapping['Amount'] = i;
    } else if (header.contains('desc')) {
      mapping['Description'] = i;
    } else if (header.contains('cat')) {
      mapping['Category'] = i;
    } else if (header.contains('type')) {
      mapping['Type'] = i;
    } else if (header.contains('account')) {
      mapping['Account'] = i;
    } else if (header == 'ar' ||
        header == 'ap' ||
        header.contains('receivable') ||
        header.contains('payable') ||
        header.contains(' ar/') ||
        header.contains('ar /')) {
      mapping['Link'] = i;
    } else if (header.contains('contact') ||
        header.contains('name') ||
        header.contains('person')) {
      mapping['Contact'] = i;
    }
  }
  return mapping;
}

String _suggestDateFormatFromSample(String sample) {
  if (sample.isEmpty) {
    return 'dd/MM/yyyy';
  }

  if (sample.contains('-')) {
    if (sample.indexOf('-') == 4) {
      return 'yyyy-MM-dd';
    }
    return 'dd-MM-yyyy';
  }
  if (sample.contains('/')) {
    final parts = sample.split('/');
    if (parts.isNotEmpty) {
      final first = int.tryParse(parts[0]);
      if (first != null && first > 12) {
        return 'dd/MM/yyyy';
      }
      return 'MM/dd/yyyy';
    }
  }
  if (RegExp(r'[a-zA-Z]').hasMatch(sample)) {
    return 'MMM dd, yyyy';
  }
  return 'dd/MM/yyyy';
}

/// Top-level for [compute] — must stay synchronous and isolate-safe.
BulkImportParseResult parseBulkImportData(BulkImportParseRequest request) {
  const defaultFormat = 'dd/MM/yyyy';
  final content = request.content;
  if (content.isEmpty) {
    return BulkImportParseResult(
      rawRows: const [],
      headers: const [],
      selectedRowIndices: const [],
      columnMapping: _emptyMapping(),
      dateFormat: defaultFormat,
    );
  }

  final lines = content
      .split(RegExp(r'\r?\n'))
      .where((l) => l.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) {
    return BulkImportParseResult(
      rawRows: const [],
      headers: const [],
      selectedRowIndices: const [],
      columnMapping: _emptyMapping(),
      dateFormat: defaultFormat,
    );
  }

  final sep = request.separator;
  final rawRows = lines.map((l) => l.split(sep)).toList();

  final selected = <int>[];
  for (var i = 0; i < rawRows.length; i++) {
    if (request.hasHeader && i == 0) {
      continue;
    }
    selected.add(i);
  }

  var headers = <String>[];
  if (request.hasHeader && rawRows.isNotEmpty) {
    headers = rawRows.first.map((h) => h.trim()).toList();
  }

  final mapping = _detectColumnMapping(headers);
  var dateFormat = defaultFormat;

  final dateCol = mapping['Date'];
  if (dateCol != null) {
    final rowIdx = request.hasHeader ? 1 : 0;
    if (rawRows.length > rowIdx && dateCol < rawRows[rowIdx].length) {
      final sampleDate = rawRows[rowIdx][dateCol];
      dateFormat = _suggestDateFormatFromSample(sampleDate);
    }
  }

  return BulkImportParseResult(
    rawRows: rawRows,
    headers: headers,
    selectedRowIndices: selected,
    columnMapping: mapping,
    dateFormat: dateFormat,
  );
}
