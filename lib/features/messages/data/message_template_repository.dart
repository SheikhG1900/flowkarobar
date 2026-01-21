import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';

/// Repository for managing message templates
/// Templates are stored in UserPreferences table with keys: message_template_{type}_{status}_{language}
class MessageTemplateRepository {
  final UserPreferencesRepository _preferencesRepository;

  MessageTemplateRepository(this._preferencesRepository);

  /// Generate template key from type, status, and language
  static String _generateKey(String type, String status, String language) {
    return 'message_template_${type}_${status}_$language';
  }

  /// Get a custom template
  /// Returns null if not found
  Future<String?> getTemplate(String type, String status, String language) async {
    final key = _generateKey(type, status, language);
    return await _preferencesRepository.getPreference(key);
  }

  /// Save a custom template
  Future<void> setTemplate(String type, String status, String language, String template) async {
    final key = _generateKey(type, status, language);
    await _preferencesRepository.setPreference(key, template);
  }

  /// Delete a custom template (reset to default)
  Future<void> deleteTemplate(String type, String status, String language) async {
    final key = _generateKey(type, status, language);
    await _preferencesRepository.deletePreference(key);
  }

  /// Get all custom templates for a given type and status across all languages
  Future<Map<String, String>> getTemplatesForType(String type, String status) async {
    final result = <String, String>{};
    for (final lang in ['en', 'hi', 'ur']) {
      final template = await getTemplate(type, status, lang);
      if (template != null) {
        result[lang] = template;
      }
    }
    return result;
  }

  /// Get all custom templates (returns map of key -> template)
  Future<Map<String, String>> getAllCustomTemplates() async {
    final allPrefs = await _preferencesRepository.getAllPreferences();
    return Map.fromEntries(
      allPrefs.entries.where((entry) => entry.key.startsWith('message_template_')),
    );
  }

  /// Delete all custom templates
  Future<void> deleteAllTemplates() async {
    final allTemplates = await getAllCustomTemplates();
    for (final key in allTemplates.keys) {
      await _preferencesRepository.deletePreference(key);
    }
  }
}
