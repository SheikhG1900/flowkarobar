import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class ThemeSelectorScreen extends ConsumerWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    final theme = Theme.of(context);

    final themeOptions = [
      {
        'mode': ThemeMode.light,
        'name': l10n.light,
        'description': l10n.lightThemeDescription,
        'icon': Icons.light_mode,
        'previewColors': [
          Colors.white,
          Colors.grey[100]!,
          theme.colorScheme.primary
        ],
      },
      {
        'mode': ThemeMode.dark,
        'name': l10n.dark,
        'description': l10n.darkThemeDescription,
        'icon': Icons.dark_mode,
        'previewColors': [
          const Color(0xFF0A0E27),
          const Color(0xFF1A1F3A),
          theme.colorScheme.primary
        ],
      },
      {
        'mode': ThemeMode.system,
        'name': l10n.system,
        'description': l10n.systemThemeDescription,
        'icon': Icons.brightness_auto,
        'previewColors': [
          Colors.grey[800]!,
          Colors.grey[300]!,
          theme.colorScheme.primary
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themeOptions.length,
        itemBuilder: (context, index) {
          final option = themeOptions[index];
          final mode = option['mode'] as ThemeMode;
          final isSelected = currentThemeMode == mode;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
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
                  await themeModeNotifier.setThemeMode(mode);
                  if (context.mounted) {
                    ToastUtils.showSuccessToast(
                        context, ref, l10n.themeSet(option['name'] as String));
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.getPrimaryGradient(
                                      theme.colorScheme.primary)
                                  : null,
                              color: isSelected
                                  ? null
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              option['icon'] as IconData,
                              size: 28,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['name'] as String,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option['description'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Selected Indicator
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.getPrimaryGradient(
                                    theme.colorScheme.primary),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          else
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.dividerColor,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preview
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            for (int i = 0;
                                i < (option['previewColors'] as List).length;
                                i++)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (option['previewColors'] as List)[i],
                                    borderRadius: i == 0
                                        ? const BorderRadiusDirectional.horizontal(
                                            start: Radius.circular(11),
                                          )
                                        : i ==
                                                (option['previewColors']
                                                            as List)
                                                        .length -
                                                    1
                                            ? const BorderRadiusDirectional.horizontal(
                                                end: Radius.circular(11),
                                              )
                                            : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.themeChangesApplyImmediately,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
