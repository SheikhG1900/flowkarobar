import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
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
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
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
        ToastUtils.showErrorToast(
            context, ref, '${l10n.errorOccurred(e.toString())}');
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
        ToastUtils.showSuccessToast(context, ref, l10n.templateSaved);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _resetTemplate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetTemplateTitle),
        content: Text(l10n.resetTemplateMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.reset),
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
          ToastUtils.showSuccessToast(context, ref, l10n.templateReset);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
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
              tooltip: l10n.resetToDefault,
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
                    decoration: InputDecoration(
                      labelText: l10n.language,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                      DropdownMenuItem(value: 'hi', child: Text(l10n.hindi)),
                      DropdownMenuItem(value: 'ur', child: Text(l10n.urdu)),
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
                              l10n.template,
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                _showVariableHelp(context);
                              },
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: Text(l10n.variables),
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
                              hintText: l10n.enterTemplateText,
                              border: const OutlineInputBorder(),
                              helperText: l10n.useVariableHint('variableName'),
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          foregroundColor: theme.colorScheme.onPrimary),
                      onPressed: _isLoading ? null : _saveTemplate,
                      child: Text(l10n.saveTemplate),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _getTemplateName() {
    final type =
        LocalizationHelper.localizeCategoryName(context, widget.templateType);
    final statusText = widget.templateStatus.isEmpty
        ? ''
        : ' - ${LocalizationHelper.localizeStatus(context, widget.templateStatus)}';
    return '$type$statusText';
  }

  void _showVariableHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.availableVariables),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.variablesInstructions),
              const SizedBox(height: 12),
              Text(l10n.variableContactName('contactName')),
              Text(l10n.variableAmount('amount')),
              Text(l10n.variableDescription('description')),
              Text(l10n.variableDate('date')),
              Text(l10n.variableDueDate('dueDate')),
              Text(l10n.variableCategoryName('categoryName')),
              Text(l10n.variableLink('link')),
              Text(l10n.variableType('type')),
              Text(l10n.variableStatus('status')),
              Text(l10n.variableRelationship('relationship')),
            ],
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
}
