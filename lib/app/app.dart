import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/strings.dart';
import '../core/theme/app_theme.dart';
import '../features/chant/data/chant_controller.dart';
import '../features/settings/settings_controller.dart';
import 'router.dart';

class DiaTangApp extends ConsumerStatefulWidget {
  const DiaTangApp({super.key});

  @override
  ConsumerState<DiaTangApp> createState() => _DiaTangAppState();
}

class _DiaTangAppState extends ConsumerState<DiaTangApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Never lose a count: write the counter as soon as the app leaves the foreground.
    void flush() => ref.read(chantProvider.notifier).flush();
    _lifecycle = AppLifecycleListener(
      onInactive: flush,
      onHide: flush,
      onPause: flush,
      onDetach: flush,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
