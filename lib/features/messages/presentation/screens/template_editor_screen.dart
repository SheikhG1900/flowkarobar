import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final String templateType;
  final String templateStatus;

  const TemplateEditorScreen({
    super.key,
    required this.templateType,
    required this.templateStatus,
  });

  @override
  ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  String _selectedLanguage = 'en';
  late TextEditingController _templateController;
  bool _isLoading = false;
  bool _hasCustomTemplate = false;

  @override
  void initState() {
    super.initState();
    _templateController = TextEditingController();
    _loadTemplate();
  }

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final templateService = ref.read(messageTemplateServiceProvider);
      final template = await templateService.getTemplate(
        widget.templateType,
        widget.templateStatus,
        _selectedLanguage,
      );

      // Check if it's a custom template
      final repository = ref.read(messageTemplateRepositoryProvider);
      final customTemplate = await repository.getTemplate(
        widget.templateType,
        widget.templateStatus,
        _selectedLanguage,
      );

      setState(() {
        _templateController.text = template;
        _hasCustomTemplate = customTemplate != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, 'Error loading template: $e');
      }
    }
  }

  Future<void> _saveTemplate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final templateService = ref.read(messageTemplateServiceProvider);
      await templateService.setTemplate(
        widget.templateType,
        widget.templateStatus,
        _selectedLanguage,
        _templateController.text,
      );

      setState(() {
        _hasCustomTemplate = true;
        _isLoading = false;
      });

      if (mounted) {
        ToastUtils.showSuccessToast(context, ref, 'Template saved successfully');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, 'Error saving template: $e');
      }
    }
  }

  Future<void> _resetTemplate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Template'),
        content: const Text(
          'Are you sure you want to reset this template to the default? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final templateService = ref.read(messageTemplateServiceProvider);
        await templateService.resetTemplate(
          widget.templateType,
          widget.templateStatus,
          _selectedLanguage,
        );

        // Reload template (will get default now)
        await _loadTemplate();

        if (mounted) {
          ToastUtils.showSuccessToast(context, ref, 'Template reset to default');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ToastUtils.showErrorToast(context, ref, 'Error resetting template: $e');
        }
      }
    }
  }

  void _onLanguageChanged(String? language) {
    if (language != null && language != _selectedLanguage) {
      setState(() {
        _selectedLanguage = language;
      });
      _loadTemplate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTemplateName()),
        actions: [
          if (_hasCustomTemplate)
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Reset to default',
              onPressed: _isLoading ? null : _resetTemplate,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Language selector
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                      DropdownMenuItem(value: 'ur', child: Text('Urdu')),
                    ],
                    onChanged: _onLanguageChanged,
                  ),
                ),
                // Template editor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Template',
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                _showVariableHelp(context);
                              },
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: const Text('Variables'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            controller: _templateController,
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              hintText: 'Enter template text...',
                              border: const OutlineInputBorder(),
                              helperText: 'Use {variableName} for dynamic content',
                            ),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Save button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveTemplate,
                      child: const Text('Save Template'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _getTemplateName() {
    final statusText = widget.templateStatus.isEmpty
        ? ''
        : ' - ${widget.templateStatus.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')}';
    return '${widget.templateType.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ')}$statusText';
  }

  void _showVariableHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Variables'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('You can use these variables in your templates:'),
              SizedBox(height: 12),
              Text('• {contactName} - Contact\'s name'),
              Text('• {amount} - Formatted amount with currency'),
              Text('• {description} - Transaction/receivable/payable description'),
              Text('• {date} - Formatted date'),
              Text('• {dueDate} - Formatted due date'),
              Text('• {categoryName} - Category name'),
              Text('• {link} - Deep link URL'),
              Text('• {type} - Transaction type (Income/Expense)'),
              Text('• {status} - Status text'),
              Text('• {relationship} - Relationship text'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
