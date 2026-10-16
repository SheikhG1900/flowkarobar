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
    final selectedFont = ref.watch(currentFontProvider);
    final theme = Theme.of(context);
    final isPremium = PremiumGate.isPremium(ref);

    final availableFonts = [
      // English Fonts
      {
        'name': 'Inter',
        'isPremium': false,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Montserrat',
        'isPremium': false,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Saira',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Julius Sans One',
        'isPremium': true,
        'language': 'en',
        'preview': 'THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.',
      },
      {
        'name': 'Space Grotesk',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Josefin Sans',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Grechen Fuemen',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Nothing You Could Do',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Russo One',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Alata',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Oxanium',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Audiowide',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Courgette',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Kaushan Script',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Philosopher',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Sacramento',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Satisfy',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Petit Formal Script',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Tektur',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Geomini',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Eagle Lake',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },
      {
        'name': 'Fugaz One',
        'isPremium': true,
        'language': 'en',
        'preview': 'The quick brown fox jumps over the lazy dog.',
      },

      // Hindi Fonts
      {
        'name': 'Noto Sans Devanagari',
        'isPremium': false,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Rozha One',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Yatra One',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Arya',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Rajdhani',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Martel',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Tiro Devanagari Hindi',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Kripa',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Poppins',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Khand',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Kalam',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },
      {
        'name': 'Biryani',
        'isPremium': true,
        'language': 'hi',
        'preview': 'त्वरित भूरा लोमड़ी आलसी कुत्ते के ऊपर कूदता है',
      },

      // Urdu Fonts
      {
        'name': 'Marhey',
        'isPremium': false,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Lemonada',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Mada',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Markazi Text',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Aref Ruqaa',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Rakkas',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Jomhuria',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Reem Kufi',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Lalezar',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'El Messiri',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Almarai',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'IBM Plex Sans Arabic',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Noto Kufi Arabic',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Fustat',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
      {
        'name': 'Kufam',
        'isPremium': true,
        'language': 'ur',
        'preview': 'تیز رفتار بھوری لومڑی سست کتے کے اوپر سے چھلانگ لگاتی ہے.',
      },
    ];

    final currentLanguage = currentLocale.languageCode;
    final filteredFonts = availableFonts
        .where((font) => font['language'] == currentLanguage)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fontSelection),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredFonts.length,
        itemBuilder: (context, index) {
          final font = filteredFonts[index];
          final fontName = font['name'] as String;
          final isFontPremium = font['isPremium'] as bool;
          final isSelected = selectedFont == fontName;
          
          // A Premium user can select ANY font. 
          // A Free user can select ANY font WHERE isPremium is false.
          final isLocked = !isPremium && isFontPremium;
          
          // PDF Ready Condition: Geomini is NOT in PdfGoogleFonts (hence not PDF compatible).
          // And all Urdu fonts are not PDF compatible.
          final isPdfCompatible = fontName != 'Geomini' && font['language'] != 'ur';

          TextStyle getPreviewStyle() {
            try {
              return GoogleFonts.getFont(fontName, fontSize: 18);
            } catch (_) {
              switch (fontName) {
                case 'Lemonada':
                  return GoogleFonts.lemonada(fontSize: 18);
                case 'Mada':
                  return GoogleFonts.mada(fontSize: 18);
                case 'Markazi Text':
                  return GoogleFonts.markaziText(fontSize: 18);
                case 'Aref Ruqaa':
                  return GoogleFonts.arefRuqaa(fontSize: 18);
                case 'Rakkas':
                  return GoogleFonts.rakkas(fontSize: 18);
                case 'Jomhuria':
                  return GoogleFonts.jomhuria(fontSize: 18);
                case 'Lalezar':
                  return GoogleFonts.lalezar(fontSize: 18);
                case 'Kufam':
                  return GoogleFonts.kufam(fontSize: 18);
                case 'Marhey':
                  return GoogleFonts.marhey(fontSize: 18);
                case 'Noto Sans Devanagari':
                  return GoogleFonts.notoSansDevanagari(fontSize: 18);
                case 'Rozha One':
                  return GoogleFonts.rozhaOne(fontSize: 18);
                case 'Yatra One':
                  return GoogleFonts.yatraOne(fontSize: 18);
                case 'Arya':
                  return GoogleFonts.arya(fontSize: 18);
                case 'Petit Formal Script':
                  return GoogleFonts.petitFormalScript(fontSize: 18);
                default:
                  return GoogleFonts.montserrat(fontSize: 18);
              }
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
                      l10n.fontChanged(fontName),
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
                                    isLocked
                                        ? Icons.lock
                                        : Icons.workspace_premium,
                                    size: 16,
                                    color:
                                        isLocked ? Colors.grey : Colors.amber,
                                  ),
                                ],
                                if (isPdfCompatible) ...[
                                  const SizedBox(width: 8),
                                  const Tooltip(
                                    message: 'PDF Export Ready',
                                    child: Icon(
                                      Icons.picture_as_pdf,
                                      size: 16,
                                      color: Colors.green,
                                    ),
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
