import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/common/utils.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('design tokens expose the responsive and shape contract', () {
    expect(ClashArcDesignTokens.compactBreakpoint, 600);
    expect(ClashArcDesignTokens.mediumBreakpoint, 840);
    expect(
      ClashArcDesignTokens.mediumShape.borderRadius,
      const BorderRadius.all(Radius.circular(12)),
    );
    expect(
      ClashArcDesignTokens.extraLargeShape.borderRadius,
      const BorderRadius.all(Radius.circular(28)),
    );
  });

  test('view mode boundary follows the existing navigation contract', () {
    expect(utils.getViewMode(600), ViewMode.mobile);
    expect(utils.getViewMode(601), ViewMode.laptop);
    expect(utils.getViewMode(840), ViewMode.laptop);
    expect(utils.getViewMode(841), ViewMode.desktop);
  });

  test('theme factory configures Material 3 component themes', () {
    final theme = buildClashArcTheme(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      pageTransitionsTheme: const PageTransitionsTheme(),
    );

    expect(theme.useMaterial3, isTrue);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.dialogTheme.shape, ClashArcDesignTokens.extraLargeShape);
    expect(theme.navigationRailTheme.useIndicator, isTrue);
    expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
  });
}
