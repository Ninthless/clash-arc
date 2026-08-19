import 'package:clash_arc/common/common.dart';
import 'package:flutter/material.dart';

abstract final class ClashArcDesignTokens {
  static const double compactBreakpoint = 600;
  static const double mediumBreakpoint = 840;
  static const double contentMaxWidth = 1440;
  static const double pagePadding = 24;
  static const double compactPagePadding = 16;
  static const double smallRadius = 8;
  static const double mediumRadius = 12;
  static const double largeRadius = 16;
  static const double extraLargeRadius = 28;

  static const EdgeInsets pageInsets = EdgeInsets.symmetric(
    horizontal: pagePadding,
    vertical: 16,
  );
  static const EdgeInsets compactPageInsets = EdgeInsets.symmetric(
    horizontal: compactPagePadding,
    vertical: 12,
  );
  static const RoundedRectangleBorder smallShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(smallRadius)),
  );
  static const RoundedRectangleBorder mediumShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(mediumRadius)),
  );
  static const RoundedRectangleBorder largeShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(largeRadius)),
  );
  static const RoundedRectangleBorder extraLargeShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(extraLargeRadius)),
  );
}

ThemeData buildClashArcTheme({
  required ColorScheme colorScheme,
  required PageTransitionsTheme pageTransitionsTheme,
}) {
  final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);
  final textTheme = base.textTheme.apply(
    fontFamily: 'Roboto',
    fontFamilyFallback: const ['Noto Sans CJK SC', 'Microsoft YaHei', 'sans'],
  );
  return base.copyWith(
    pageTransitionsTheme: pageTransitionsTheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(ClashArcDesignTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(ClashArcDesignTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(ClashArcDesignTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(ClashArcDesignTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(ClashArcDesignTokens.mediumRadius),
        ),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 40),
        shape: ClashArcDesignTokens.largeShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 40),
        shape: ClashArcDesignTokens.largeShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 40),
        shape: ClashArcDesignTokens.largeShape,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        shape: ClashArcDesignTokens.largeShape,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: ClashArcDesignTokens.extraLargeShape,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.secondaryContainer,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.secondaryContainer,
      indicatorShape: ClashArcDesignTokens.largeShape,
      useIndicator: true,
      minWidth: 80,
      minExtendedWidth: 256,
      groupAlignment: -0.8,
      labelType: NavigationRailLabelType.all,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      shape: ClashArcDesignTokens.largeShape,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ClashArcDesignTokens.extraLargeRadius),
        ),
      ),
    ),
  );
}

class CommonTheme {
  final BuildContext context;
  final Map<String, Color> _colorMap;
  final double textScaleFactor;

  CommonTheme.of(this.context, this.textScaleFactor) : _colorMap = {};

  Color get darkenSecondaryContainer {
    return _colorMap.updateCacheValue(
      'darkenSecondaryContainer',
      () => context.colorScheme.secondaryContainer.blendDarken(
        context,
        factor: 0.1,
      ),
    );
  }

  Color get darkenSecondaryContainerLighter {
    return _colorMap.updateCacheValue(
      'darkenSecondaryContainerLighter',
      () => context.colorScheme.secondaryContainer
          .blendDarken(context, factor: 0.1)
          .opacity60,
    );
  }

  Color get darken2SecondaryContainer {
    return _colorMap.updateCacheValue(
      'darken2SecondaryContainer',
      () => context.colorScheme.secondaryContainer.blendDarken(
        context,
        factor: 0.2,
      ),
    );
  }

  Color get darken3PrimaryContainer {
    return _colorMap.updateCacheValue(
      'darken3PrimaryContainer',
      () => context.colorScheme.primaryContainer.blendDarken(
        context,
        factor: 0.3,
      ),
    );
  }
}
