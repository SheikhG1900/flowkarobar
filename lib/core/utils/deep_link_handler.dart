import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/shared/widgets/import_dialog.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';

class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  BuildContext? _context;
  WidgetRef? _ref;

  DeepLinkHandler(this._deepLinkService);

  /// Initialize deep link handling
  /// Should be called once in main.dart after the app starts
  Future<void> initialize(BuildContext context, WidgetRef ref) async {
    _context = context;
    _ref = ref;

    // Handle initial link if app was opened via deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri.toString());
      }
    } catch (e) {
      debugPrint('Error getting initial URI: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri.toString());
        }
      },
      onError: (err) {
        debugPrint('Error in deep link stream: $err');
      },
    );
  }

  /// Handle an incoming deep link
  Future<void> _handleDeepLink(String uriString) async {
    if (_context == null || !_context!.mounted) {
      return;
    }

    final sharedData = _deepLinkService.decodeLink(uriString);
    
    if (sharedData == null) {
      // Invalid link - show error
      _showErrorSnackBar('Invalid link format');
      return;
    }

    // Show import dialog based on the data type
    await _showImportDialog(sharedData);
  }

  /// Show the import dialog for the shared data
  Future<void> _showImportDialog(SharedData sharedData) async {
    if (_context == null || !_context!.mounted || _ref == null) {
      return;
    }

    await showDialog(
      context: _context!,
      builder: (context) => ImportDialog(
        sharedData: sharedData,
        ref: _ref!,
      ),
    );
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    if (_context == null || !_context!.mounted || _ref == null) {
      return;
    }

    ToastUtils.showErrorToast(_context!, _ref!, message);
  }

  /// Dispose the handler and cancel subscriptions
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _context = null;
    _ref = null;
  }
}

/// Provider for DeepLinkHandler
final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  return DeepLinkHandler(DeepLinkService());
});
