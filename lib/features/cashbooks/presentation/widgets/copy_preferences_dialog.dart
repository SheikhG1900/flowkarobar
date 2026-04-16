import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/domain/preferences_copy_service.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

import 'package:flowpaisa/l10n/app_localizations.dart';

class CopyPreferencesSheet extends ConsumerStatefulWidget {
  final String targetCashbookId;

  const CopyPreferencesSheet({
    super.key,
    required this.targetCashbookId,
  });

  @override
  ConsumerState<CopyPreferencesSheet> createState() =>
      _CopyPreferencesSheetState();
}

class _CopyPreferencesSheetState extends ConsumerState<CopyPreferencesSheet> {
  String? _selectedSourceCashbookId;
  bool _copyProfile = true;
  bool _copyDateAndFonts = true;
  bool _copyCurrencies = false;
  bool _copyTemplates = true;
  bool _copyContacts = false;
  bool _copyCategories = false;
  bool _copyDashboardWidgets = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the first available source
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cashbooks = ref.read(cashbooksProvider);
      final availableSources =
          cashbooks.where((c) => c.id != widget.targetCashbookId).toList();
      if (availableSources.isNotEmpty) {
        setState(() {
          _selectedSourceCashbookId = availableSources.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cashbooks = ref.watch(cashbooksProvider);
    final targetCashbook = cashbooks
        .firstWhereOrNull((c) => c.id == widget.targetCashbookId);
    final availableSources =
        cashbooks.where((c) => c.id != widget.targetCashbookId).toList();

    if (availableSources.isEmpty) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.copyPreferences,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (targetCashbook != null) ...[
              const SizedBox(height: 12),
              _CopyPreferencesTargetRow(
                cashbook: targetCashbook,
                l10n: l10n,
                theme: theme,
              ),
            ],
            const SizedBox(height: 24),
            Text(l10n.noOtherCashbooks),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary),
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.copyPreferences,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (targetCashbook != null) ...[
            const SizedBox(height: 12),
            _CopyPreferencesTargetRow(
              cashbook: targetCashbook,
              l10n: l10n,
              theme: theme,
            ),
          ],
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectSourceCashbook,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedSourceCashbookId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: l10n.cashbookNameHint,
                      prefixIcon: _selectedSourceCashbookId != null
                          ? Icon(
                              availableSources
                                  .firstWhere(
                                      (c) => c.id == _selectedSourceCashbookId)
                                  .icon,
                              color: availableSources
                                  .firstWhere(
                                      (c) => c.id == _selectedSourceCashbookId)
                                  .color,
                            )
                          : null,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return availableSources.map((cashbook) {
                        return Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(cashbook.name),
                          ],
                        );
                      }).toList();
                    },
                    items: availableSources.map((cashbook) {
                      return DropdownMenuItem<String>(
                        value: cashbook.id,
                        child: Row(
                          children: [
                            Icon(
                              cashbook.icon,
                              color: cashbook.color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(cashbook.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSourceCashbookId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.whatToCopy,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.copy,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text(l10n.userProfile),
                          subtitle: Text(l10n.userProfileDescription),
                          value: _copyProfile,
                          onChanged: (value) {
                            setState(() {
                              _copyProfile = value ?? false;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          title: Text(l10n.copyDashboardWidgets),
                          subtitle: Text(l10n.copyDashboardWidgetsDescription),
                          value: _copyDashboardWidgets,
                          onChanged: (value) {
                            setState(() {
                              _copyDashboardWidgets = value ?? false;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          title: Text(l10n.copyDateFormatAndFonts),
                          subtitle: Text(l10n.copyDateFormatAndFontsSubtitle),
                          value: _copyDateAndFonts,
                          onChanged: (value) {
                            setState(() {
                              _copyDateAndFonts = value ?? false;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          title: Text(l10n.messageTemplatesDescription),
                          subtitle: Text(l10n.messageTemplatesDescription),
                          value: _copyTemplates,
                          onChanged: (value) {
                            setState(() {
                              _copyTemplates = value ?? false;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          title: Text(l10n.copyContacts),
                          subtitle: Text(l10n.copyContactsDescription),
                          value: _copyContacts,
                          onChanged: (value) {
                            setState(() {
                              _copyContacts = value ?? false;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          title: Text(l10n.copyCategories),
                          subtitle: Text(l10n.copyCategoriesDescription),
                          value: _copyCategories,
                          onChanged: (value) {
                            setState(() {
                              _copyCategories = value ?? false;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          title: Text(l10n.copyCurrenciesOption),
                          subtitle: Text(l10n.copyCurrenciesOptionSubtitle),
                          value: _copyCurrencies,
                          onChanged: (value) {
                            setState(() {
                              _copyCurrencies = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimary),
                  onPressed: _isLoading ? null : _performCopyPreferences,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.copy),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _performCopyPreferences() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedSourceCashbookId == null) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseSelectSource);
      return;
    }

    if (!_copyProfile &&
        !_copyDateAndFonts &&
        !_copyCurrencies &&
        !_copyTemplates &&
        !_copyContacts &&
        !_copyCategories &&
        !_copyDashboardWidgets) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseSelectAtLeastOne);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cashbooks = ref.read(cashbooksProvider);

      if (_copyProfile &&
          _copyDateAndFonts &&
          _copyCurrencies &&
          _copyTemplates &&
          _copyDashboardWidgets &&
          !_copyContacts &&
          !_copyCategories) {
        await PreferencesCopyService.copyPreferences(
          _selectedSourceCashbookId!,
          widget.targetCashbookId,
          cashbooks,
        );
      } else {
        // Copy selectively
        if (_copyProfile) {
          await PreferencesCopyService.copyUserProfileOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
        if (_copyCurrencies) {
          await PreferencesCopyService.copyAllCurrenciesOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
        if (_copyDateAndFonts) {
          await PreferencesCopyService.copyDateAndFontsOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
          await PreferencesCopyService.copySelectedCurrencyOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
        if (_copyTemplates) {
          await PreferencesCopyService.copyMessageTemplatesOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
        if (_copyContacts) {
          await PreferencesCopyService.copyContactsOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
        if (_copyCategories) {
          await PreferencesCopyService.copyCategoriesOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
        if (_copyDashboardWidgets) {
          await PreferencesCopyService.copyDashboardWidgetsOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
      }

      if (mounted) {
        _invalidateCopiedPreferenceProviders(ref);
        Navigator.pop(context);
        ToastUtils.showSuccessToast(context, ref, l10n.preferencesCopied);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  /// Preferences are written directly to the target DB file; in-memory notifiers
  /// must be invalidated or the UI keeps stale profile, fonts, and currency state.
  void _invalidateCopiedPreferenceProviders(WidgetRef ref) {
    final copiedProfile = _copyProfile;
    final copiedDateFonts = _copyDateAndFonts;
    final copiedCurrencies = _copyCurrencies;

    if (copiedProfile || copiedDateFonts) {
      ref.invalidate(userProfileProvider);
    }
    if (copiedDateFonts) {
      ref.invalidate(languageProvider);
      ref.invalidate(fontProvider);
      ref.invalidate(selectedCurrencyIdProvider);
      ref.invalidate(currentCurrencyProvider);
    }
    if (copiedCurrencies) {
      ref.invalidate(currenciesListProvider);
    }
    if (_copyDashboardWidgets) {
      ref.invalidate(dashboardWidgetLayoutProvider);
      ref.invalidate(showDashboardWidgetAreaProvider);
      ref.invalidate(showDashboardPrivacyHighlightProvider);
      ref.invalidate(showDashboardFinancialSummaryProvider);
      ref.invalidate(bottomBarQuickActionProvider);
      ref.invalidate(showBottomBarQuickButtonProvider);
      ref.invalidate(dashboardVisibilityProvider);
    }
  }
}

class _CopyPreferencesTargetRow extends StatelessWidget {
  const _CopyPreferencesTargetRow({
    required this.cashbook,
    required this.l10n,
    required this.theme,
  });

  final Cashbook cashbook;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(cashbook.icon, color: cashbook.color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.toTarget(cashbook.name),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
