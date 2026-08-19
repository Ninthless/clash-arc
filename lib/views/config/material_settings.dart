import 'package:clash_arc/common/theme.dart';
import 'package:flutter/material.dart';

class MaterialSettingsList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const MaterialSettingsList({super.key, required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < ClashArcDesignTokens.compactBreakpoint;
        return ListView(
          padding:
              padding ??
              (compact
                  ? ClashArcDesignTokens.compactPageInsets
                  : ClashArcDesignTokens.pageInsets),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ClashArcDesignTokens.contentMaxWidth,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MaterialSettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final List<Widget> actions;
  final bool dangerous;

  const MaterialSettingsSection({
    super.key,
    this.title,
    required this.children,
    this.actions = const [],
    this.dangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionColor = dangerous
        ? colorScheme.errorContainer.withValues(alpha: 0.38)
        : colorScheme.surfaceContainerLow;
    final titleColor = dangerous
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    final items = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        items.add(
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant,
          ),
        );
      }
      items.add(children[index]);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: sectionColor,
            surfaceTintColor: Colors.transparent,
            shape: ClashArcDesignTokens.largeShape,
            clipBehavior: Clip.antiAlias,
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
}
