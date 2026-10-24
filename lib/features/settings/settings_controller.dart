import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';

/// [auto] follows the app theme.
enum ReaderTheme { auto, light, sepia, dark }

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.haptic = true,
    this.keepAwake = true,
    this.tapAnywhere = false,
    this.dailyGoal = 0,
    this.defaultMantraId = 'dai_nguyen',
    this.readerFontSize = 20,
    this.readerLineHeight = 1.7,
    this.readerTheme = ReaderTheme.auto,
  });

  final ThemeMode themeMode;
  final bool haptic;
  final bool keepAwake;
  final bool tapAnywhere;

  /// 0 = no goal.
  final int dailyGoal;
  final String defaultMantraId;
  final double readerFontSize;
  final double readerLineHeight;
  final ReaderTheme readerTheme;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? haptic,
    bool? keepAwake,
    bool? tapAnywhere,
    int? dailyGoal,
    String? defaultMantraId,
    double? readerFontSize,
    double? readerLineHeight,
    ReaderTheme? readerTheme,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    haptic: haptic ?? this.haptic,
    keepAwake: keepAwake ?? this.keepAwake,
    tapAnywhere: tapAnywhere ?? this.tapAnywhere,
    dailyGoal: dailyGoal ?? this.dailyGoal,
    defaultMantraId: defaultMantraId ?? this.defaultMantraId,
    readerFontSize: readerFontSize ?? this.readerFontSize,
    readerLineHeight: readerLineHeight ?? this.readerLineHeight,
    readerTheme: readerTheme ?? this.readerTheme,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'haptic': haptic,
    'keepAwake': keepAwake,
    'tapAnywhere': tapAnywhere,
    'dailyGoal': dailyGoal,
    'defaultMantraId': defaultMantraId,
    'readerFontSize': readerFontSize,
    'readerLineHeight': readerLineHeight,
    'readerTheme': readerTheme.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[j['themeMode']] ?? d.themeMode,
      haptic: j['haptic'] as bool? ?? d.haptic,
      keepAwake: j['keepAwake'] as bool? ?? d.keepAwake,
      tapAnywhere: j['tapAnywhere'] as bool? ?? d.tapAnywhere,
      dailyGoal: j['dailyGoal'] as int? ?? d.dailyGoal,
      defaultMantraId: j['defaultMantraId'] as String? ?? d.defaultMantraId,
      readerFontSize:
          (j['readerFontSize'] as num?)?.toDouble() ?? d.readerFontSize,
      readerLineHeight:
          (j['readerLineHeight'] as num?)?.toDouble() ?? d.readerLineHeight,
      readerTheme:
          ReaderTheme.values.asNameMap()[j['readerTheme']] ?? d.readerTheme,
    );
  }
}

class SettingsController extends Notifier<AppSettings> {
  static const _key = 'settings';

  @override
  AppSettings build() =>
      AppSettings.fromJson(ref.read(localStoreProvider).readMap(_key));

  void update(AppSettings Function(AppSettings s) change) {
    state = change(state);
    ref.read(localStoreProvider).writeJson(_key, state.toJson());
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
