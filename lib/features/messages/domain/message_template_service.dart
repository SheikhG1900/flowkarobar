import 'package:flowpaisa/features/messages/data/message_template_repository.dart';
import 'package:flowpaisa/features/messages/data/default_templates.dart';

/// Service for managing and rendering message templates
class MessageTemplateService {
  final MessageTemplateRepository _repository;

  MessageTemplateService(this._repository);

  /// Get template (custom or default) for given type, status, and language
  /// If fallbackToDefault is true and custom template not found, returns default
  Future<String> getTemplate(
    String type,
    String status,
    String language, {
    bool fallbackToDefault = true,
  }) async {
    // Try to get custom template first
    final customTemplate = await _repository.getTemplate(type, status, language);
    if (customTemplate != null) {
      return customTemplate;
    }

    // Fallback to default if enabled
    if (fallbackToDefault) {
      return DefaultTemplates.getDefaultTemplate(type, status, language);
    }

    return '';
  }

  /// Get default template for given type, status, and language
  String getDefaultTemplate(String type, String status, String language) {
    return DefaultTemplates.getDefaultTemplate(type, status, language);
  }

  /// Save a custom template
  Future<void> setTemplate(String type, String status, String language, String template) async {
    await _repository.setTemplate(type, status, language, template);
  }

  /// Delete a custom template (reset to default)
  Future<void> resetTemplate(String type, String status, String language) async {
    await _repository.deleteTemplate(type, status, language);
  }

  /// Render a template with variables replaced
  String renderTemplate(
    String template,
    Map<String, String> variables,
  ) {
    String result = template;

    // Replace all variables
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });

    // Handle conditional sections (lines that should be removed if variable is empty)
    // Format: {variable} - entire line is removed if variable is empty
    // We'll handle this by checking if the variable exists and is not empty
    final lines = result.split('\n');
    final processedLines = <String>[];

    for (final line in lines) {
      // Check if line contains only a variable placeholder
      final variableMatch = RegExp(r'^\{(\w+)\}$').firstMatch(line.trim());
      if (variableMatch != null) {
        final varName = variableMatch.group(1)!;
        // Only include line if variable has a value
        if (variables.containsKey(varName) && variables[varName]!.isNotEmpty) {
          processedLines.add(line);
        }
        // Otherwise skip the line
      } else {
        // Check if line contains variables that might be empty
        bool shouldInclude = true;
        final allVars = RegExp(r'\{(\w+)\}').allMatches(line);
        for (final match in allVars) {
          final varName = match.group(1)!;
          // If variable is empty and line only contains that variable, skip
          if (!variables.containsKey(varName) || variables[varName]!.isEmpty) {
            // Check if this is the only content (with optional whitespace/formatting)
            final lineWithoutVar = line.replaceAll('{$varName}', '').trim();
            if (lineWithoutVar.isEmpty || lineWithoutVar == '_' || lineWithoutVar == '*') {
              shouldInclude = false;
              break;
            }
          }
        }
        if (shouldInclude) {
          processedLines.add(line);
        }
      }
    }

    result = processedLines.join('\n');

    // Clean up multiple consecutive newlines (max 2)
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }

  /// Build variables map for receivable reminder
  Map<String, String> buildReceivableReminderVariables({
    required String contactName,
    required String amount,
    String? description,
    String? dueDate,
  }) {
    return {
      'contactName': contactName,
      'amount': amount,
      'description': description != null && description.isNotEmpty
          ? ' for _' + description + '_'
          : '',
      'dueDate': dueDate != null && dueDate.isNotEmpty
          ? 'Expected by: *$dueDate*.'
          : '',
    };
  }

  /// Build variables map for payable reminder
  Map<String, String> buildPayableReminderVariables({
    required String contactName,
    required String amount,
    String? description,
    String? dueDate,
    String? date,
  }) {
    return {
      'contactName': contactName,
      'amount': amount,
      'description': description != null && description.isNotEmpty
          ? ' for _' + description + '_'
          : '',
      'dueDate': dueDate != null && dueDate.isNotEmpty
          ? 'I will settle this by *$dueDate*.'
          : 'I will settle this soon. Thanks for your patience!',
      'date': date ?? '',
    };
  }

  /// Build variables map for transaction receipt
  Map<String, String> buildTransactionReceiptVariables({
    required String type,
    required String amount,
    required String date,
    String? description,
    String? categoryName,
    String? contactName,
  }) {
    final typeText = type.toUpperCase() == 'INCOME' ? 'an Income' : 'an Expense';
    return {
      'type': typeText,
      'amount': amount,
      'date': date,
      'description': description != null && description.isNotEmpty
          ? ' for _' + description + '_'
          : '',
      'categoryName': categoryName != null && categoryName.isNotEmpty
          ? 'This was categorized under *$categoryName*.\n'
          : '',
      'contactName': contactName != null && contactName.isNotEmpty
          ? 'This transaction is associated with *$contactName*.\n'
          : '',
    };
  }

  /// Build variables map for transaction share
  Map<String, String> buildTransactionShareVariables({
    required String type,
    required String amount,
    required String date,
    String? description,
    String? categoryName,
    String? link,
    String? relationship,
  }) {
    final isIncome = type.toUpperCase() == 'INCOME';
    final typeText = isIncome ? 'Income' : 'Expense';
    return {
      'type': typeText,
      'amount': amount,
      'date': date,
      'description': description != null && description.isNotEmpty
          ? ' for _' + description + '_'
          : '',
      'categoryName': categoryName != null && categoryName.isNotEmpty
          ? 'This was recorded under the *$categoryName* category.\n'
          : '',
      'link': link ?? '',
      'relationship': relationship ?? '',
    };
  }

  /// Build variables map for receivable share
  Map<String, String> buildReceivableShareVariables({
    required String amount,
    String? description,
    String? dueDate,
    String? date,
    String? link,
    String? contactName,
  }) {
    return {
      'contactName': contactName ?? '',
      'amount': amount,
      'description': description != null && description.isNotEmpty
          ? ' for _' + description + '_'
          : '',
      'dueDate': dueDate != null && dueDate.isNotEmpty
          ? 'Due Date: *$dueDate*\n'
          : '',
      'date': date ?? '',
      'link': link ?? '',
    };
  }

  /// Build variables map for payable share
  Map<String, String> buildPayableShareVariables({
    required String amount,
    String? description,
    String? dueDate,
    String? date,
    String? link,
    String? contactName,
  }) {
    return {
      'contactName': contactName ?? '',
      'amount': amount,
      'description': description != null && description.isNotEmpty
          ? ' for _' + description + '_'
          : '',
      'dueDate': dueDate != null && dueDate.isNotEmpty
          ? 'Planned payment date: *$dueDate*\n'
          : '',
      'date': date ?? '',
      'link': link ?? '',
    };
  }
}
