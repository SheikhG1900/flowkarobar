import 'package:flutter/material.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class ContextualGuide extends StatelessWidget {
  final String title;
  final List<GuideItem> items;
  final VoidCallback onDismiss;
  final UndrawIllustration? mainIllustration;

  const ContextualGuide({
    super.key,
    required this.title,
    required this.items,
    required this.onDismiss,
    this.mainIllustration,
  });

  static void show(
    BuildContext context, {
    required String title,
    required List<GuideItem> items,
    required VoidCallback onDismiss,
    UndrawIllustration? mainIllustration,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextualGuide(
        title: title,
        items: items,
        onDismiss: onDismiss,
        mainIllustration: mainIllustration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final sheetHeight = screenHeight * 0.75;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Fixed Header (Handle)
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (mainIllustration != null) ...[
                    Center(
                      child: Undraw(
                        illustration: mainIllustration!,
                        color: theme.colorScheme.primary,
                        width: 180,
                        height: 130,
                        fit: BoxFit.contain,
                        placeholder: const SizedBox(height: 130),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (item.illustration != null) ...[
                              Undraw(
                                illustration: item.illustration!,
                                color: theme.colorScheme.primary,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                placeholder: const SizedBox(height: 140),
                              ),
                              const SizedBox(height: 20),
                            ] else if (item.icon != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Text(
                              item.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Fixed Footer (Button)
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              mq.padding.bottom + 24,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDismiss();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l10n.tourGotIt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuideItem {
  final IconData? icon;
  final UndrawIllustration? illustration;
  final String title;
  final String description;

  const GuideItem({
    this.icon,
    this.illustration,
    required this.title,
    required this.description,
  });
}
