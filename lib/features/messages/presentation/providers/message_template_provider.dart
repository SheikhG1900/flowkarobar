import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/messages/data/message_template_repository.dart';
import 'package:flowpaisa/features/messages/domain/message_template_service.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';

/// Provider for MessageTemplateRepository
final messageTemplateRepositoryProvider =
    Provider<MessageTemplateRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final preferencesRepo = UserPreferencesRepository(db);
  return MessageTemplateRepository(preferencesRepo);
});

/// Provider for MessageTemplateService
final messageTemplateServiceProvider =
    Provider<MessageTemplateService>((ref) {
  final repository = ref.watch(messageTemplateRepositoryProvider);
  return MessageTemplateService(repository);
});

/// Helper to get current language code
String getCurrentLanguageCode(WidgetRef ref) {
  final locale = ref.watch(languageProvider);
  return locale.languageCode;
}
