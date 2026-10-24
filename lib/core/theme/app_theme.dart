import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Gives widgets access to the current [Palette] via `context.palette`.
class PaletteExtension extends ThemeExtension<PaletteExtension> {
  const PaletteExtension(this.palette);

  final Palette palette;

  @override
  PaletteExtension copyWith({Palette? palette}) =>
      PaletteExtension(palette ?? this.palette);

  @override
  PaletteExtension lerp(PaletteExtension? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<PaletteExtension>()!.palette;
}

ThemeData buildTheme(Palette p, Brightness brightness) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.accent,
    onPrimary: brightness == Brightness.light ? Colors.white : p.background,
    secondary: p.accentSoft,
    onSecondary: Colors.white,
    error: const Color(0xFF9C4A3A),
    onError: Colors.white,
    surface: p.background,
    onSurface: p.text,
    surfaceContainerHighest: p.surface,
    surfaceContainerHigh: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerLow: p.surface,
    outline: p.border,
    outlineVariant: p.border,
    onSurfaceVariant: p.textMuted,
  );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
  );
  final serifText = base.textTheme.apply(
    fontFamily: Fonts.serif,
    bodyColor: p.text,
    displayColor: p.text,
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    textTheme: serifText.copyWith(
      bodyLarge: serifText.bodyLarge?.copyWith(fontSize: 17),
      bodyMedium: serifText.bodyMedium?.copyWith(fontSize: 16),
      bodySmall: serifText.bodySmall?.copyWith(
        fontSize: 14,
        color: p.textMuted,
      ),
    ),
    extensions: [PaletteExtension(p)],
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: Fonts.serif,
        fontSize: 19,
        color: p.text,
        letterSpacing: 0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.background,
      indicatorColor: p.accent.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: Fonts.serif,
          fontSize: 13,
          color: states.contains(WidgetState.selected) ? p.text : p.textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? p.accent : p.textMuted,
          size: 24,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: p.textMuted,
      textColor: p.text,
      minVerticalPadding: 12,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.text,
      contentTextStyle: TextStyle(
        fontFamily: Fonts.serif,
        color: p.background,
        fontSize: 15,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.border),
      ),
    ),
  );
}

final lightTheme = buildTheme(Palette.light, Brightness.light);
final darkTheme = buildTheme(Palette.dark, Brightness.dark);
