import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/cashbooks/domain/preferences_copy_service.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

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
  bool _copyPreferences = true;
  bool _copyTemplates = true;
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
                          title: Text(l10n.preferencesDescription),
                          subtitle: Text(
                              '${l10n.preferencesDescription} (Currency, Date, Fonts)'),
                          value: _copyPreferences,
                          onChanged: (value) {
                            setState(() {
                              _copyPreferences = value ?? false;
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

    if (!_copyProfile && !_copyPreferences && !_copyTemplates) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseSelectAtLeastOne);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cashbooks = ref.read(cashbooksProvider);

      if (_copyProfile && _copyPreferences && _copyTemplates) {
        // Copy all
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
        if (_copyPreferences) {
          final sourceCashbook =
              cashbooks.firstWhere((c) => c.id == _selectedSourceCashbookId);
          final targetCashbook =
              cashbooks.firstWhere((c) => c.id == widget.targetCashbookId);
          final sourceDb = AppDatabase(fileName: sourceCashbook.dbPath);
          final targetDb = AppDatabase(fileName: targetCashbook.dbPath);
          try {
            final sourceRepo = UserPreferencesRepository(sourceDb);
            final targetRepo = UserPreferencesRepository(targetDb);
            final dateFormat = await sourceRepo.getDateFormat();
            final currency = await sourceRepo.getCurrency();
            final fontEn = await sourceRepo.getFontForLanguage('en');
            final fontHi = await sourceRepo.getFontForLanguage('hi');
            final fontUr = await sourceRepo.getFontForLanguage('ur');

            await targetRepo.setDateFormat(dateFormat);
            await targetRepo.setCurrency(currency);
            await targetRepo.setFontForLanguage('en', fontEn);
            await targetRepo.setFontForLanguage('hi', fontHi);
            await targetRepo.setFontForLanguage('ur', fontUr);
          } finally {
            await sourceDb.close();
            await targetDb.close();
          }
        }
        if (_copyTemplates) {
          await PreferencesCopyService.copyMessageTemplatesOnly(
            _selectedSourceCashbookId!,
            widget.targetCashbookId,
            cashbooks,
          );
        }
      }

      if (mounted) {
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
}
