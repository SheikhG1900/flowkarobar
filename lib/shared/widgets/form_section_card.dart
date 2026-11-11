import 'package:flutter/material.dart';

/// Grouped form content with a titled card — reduces flat “wall of fields” layouts.
class FormSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const FormSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  trailing!,
                ],
              ],
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _withGaps(children),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _withGaps(List<Widget> children) {
    if (children.isEmpty) return children;
    final out = <Widget>[children.first];
    for (var i = 1; i < children.length; i++) {
      out.add(const SizedBox(height: 12));
      out.add(children[i]);
    }
    return out;
  }
}

/// Soft tinted page background for edit/create forms.
class FormPageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Color accentColor;
  final Widget body;
  final Widget? bottomBar;

  const FormPageScaffold({
    super.key,
    required this.accentColor,
    required this.body,
    this.appBar,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: base,
      appBar: appBar,
      body: ColoredBox(
        color: base,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Keep accent wash barely perceptible.
                Color.alphaBlend(
                  accentColor.withValues(alpha: 0.012),
                  base,
                ),
                base,
              ],
              stops: const [0.0, 0.22],
            ),
          ),
          child: SizedBox.expand(child: body),
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

/// Sticky bottom save area with safe padding.
class FormBottomBar extends StatelessWidget {
  final Widget child;

  const FormBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}
