import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/shared/widgets/import_dialog.dart';
import 'package:flowpaisa/shared/widgets/import_classification_sheet.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';

class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  BuildContext? _context;
  WidgetRef? _ref;

  /// Process initial link only once per process. After restart/rebirth the OS
  /// often returns the same (last) link again; we avoid handling it twice.
  static bool _initialLinkProcessed = false;

  DeepLinkHandler(this._deepLinkService);

  /// Initialize deep link handling
  /// Should be called once in main.dart after the app starts
  Future<void> initialize(BuildContext context, WidgetRef ref) async {
    _context = context;
    _ref = ref;

    // Handle initial link only once per process. After Phoenix.rebirth or
    // similar, initialize() runs again but getInitialLink() still returns
    // the previous link; we skip so the "last" deep link is not re-executed.
    if (!_initialLinkProcessed) {
      _initialLinkProcessed = true;
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          await _handleDeepLink(initialUri.toString());
        }
      } catch (e) {
        debugPrint('Error getting initial URI: $e');
      }
    }

    // Cancel previous subscription if initialize() was called again (e.g. rebirth)
    await _linkSubscription?.cancel();
    _linkSubscription = null;

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

    // Entity open links (flowpaisa://open/transaction/uuid etc) — navigate to detail
    final openResult = _deepLinkService.parseOpenLink(uriString);
    if (openResult != null) {
      await _navigateToEntity(openResult);
      return;
    }

    // Share links (flowpaisa://share?type=...&data=...) — decode and show import dialog
    final sharedData = _deepLinkService.decodeLink(uriString);

    if (sharedData == null) {
      _showErrorSnackBar('Invalid link format');
      return;
    }

    await _showImportDialog(sharedData);
  }

  Future<void> _navigateToEntity(OpenLinkResult result) async {
    if (_context == null || !_context!.mounted) return;
    final context = _context!;
    switch (result.entityType) {
      case 'transaction':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsDialog(
              transactionUuid: result.uuid,
            ),
          ),
        );
        break;
      case 'category':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(
              categoryUuid: result.uuid,
            ),
          ),
        );
        break;
      case 'contact':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactDetailsScreen(
              contactUuid: result.uuid,
            ),
          ),
        );
        break;
      case 'payable':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PayableDetailsDialog(
              payableUuid: result.uuid,
            ),
          ),
        );
        break;
      case 'receivable':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceivableDetailsDialog(
              receivableUuid: result.uuid,
            ),
          ),
        );
        break;
      default:
        _showErrorSnackBar('Unknown link type');
    }
  }

  /// Show the import dialog or classification sheet for the shared data
  Future<void> _showImportDialog(SharedData sharedData) async {
    if (_context == null || !_context!.mounted || _ref == null) {
      return;
    }
    final ref = _ref!;
    final context = _context!;

    bool alreadyImported = false;
    try {
      final payable = await ref
          .read(payablesRepositoryProvider)
          .getPayableByExternalLinkId(sharedData.externalLinkId);
      if (payable != null) alreadyImported = true;
      if (!alreadyImported) {
        final receivable = await ref
            .read(receivablesRepositoryProvider)
            .getReceivableByExternalLinkId(sharedData.externalLinkId);
        if (receivable != null) alreadyImported = true;
      }
      if (!alreadyImported) {
        alreadyImported = await ref
            .read(transactionsRepositoryProvider)
            .checkIfExternalLinkExists(sharedData.externalLinkId);
      }
    } catch (e) {
      debugPrint('DeepLinkHandler: Error checking if already imported: $e');
    }

    if (!context.mounted) return;

    if (alreadyImported) {
      await showDialog(
        context: context,
        builder: (ctx) => ImportDialog(sharedData: sharedData),
      );
      return;
    }

    if (sharedData is TransactionShareData &&
        ImportClassificationSheet.needsClassification(sharedData)) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ImportClassificationSheet(data: sharedData),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => ImportDialog(sharedData: sharedData),
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
