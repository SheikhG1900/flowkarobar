import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/whatsapp/domain/whatsapp_service.dart';
import 'package:flowpaisa/features/whatsapp/data/whatsapp_queue_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

/// Provider for WhatsApp Service
final whatsAppServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});

/// Provider for WhatsApp Queue Repository
final whatsAppQueueRepositoryProvider = Provider<WhatsAppQueueRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return WhatsAppQueueRepository(database);
});

