import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class FontSelectorScreen extends ConsumerWidget {
  const FontSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);
    final fonts = ref.watch(fontProvider);
    final selectedFont = fonts[currentLocale.languageCode] ?? 'Inter';
    final theme = Theme.of(context);
    final isPremium = PremiumGate.isPremium(ref);

    final availableFonts = [
      {
        'name': 'Inter',
        'isPremium': false,
        'preview': 'The quick brown fox jumps over the lazy dog',
      },
      {
        'name': 'Noto Sans Devanagari',
        'isPremium': false,
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Marhey',
        'isPremium': false,
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے',
      },
      {
        'name': 'Lalezar',
        'isPremium': true,
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے',
      },
      {
        'name': 'Kufam',
        'isPremium': true,
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fontSelection),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableFonts.length,
        itemBuilder: (context, index) {
          final font = availableFonts[index];
          final fontName = font['name'] as String;
          final isFontPremium = font['isPremium'] as bool;
          final isSelected = selectedFont == fontName;
          final isLocked = isFontPremium && !isPremium;

          TextStyle getPreviewStyle() {
            switch (fontName) {
              case 'Lalezar':
                return GoogleFonts.lalezar(fontSize: 18);
              case 'Kufam':
                return GoogleFonts.kufam(fontSize: 18);
              case 'Marhey':
                return GoogleFonts.marhey(fontSize: 18);
              case 'Noto Sans Devanagari':
                return GoogleFonts.notoSansDevanagari(fontSize: 18);
              default:
                return GoogleFonts.inter(fontSize: 18);
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (isLocked) {
                    PremiumGate.showPremiumDialog(context);
                    return;
                  }

                  // Update font
                  await ref
                      .read(fontProvider.notifier)
                      .setFont(currentLocale.languageCode, fontName);

                  if (context.mounted) {
                    ToastUtils.showSuccessToast(
                      context,
                      ref,
                      'Font changed to $fontName',
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  fontName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (isFontPremium) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    isLocked ? Icons.lock : Icons.workspace_premium,
                                    size: 16,
                                    color: isLocked ? Colors.grey : Colors.amber,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              font['preview'] as String,
                              style: getPreviewStyle().copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
