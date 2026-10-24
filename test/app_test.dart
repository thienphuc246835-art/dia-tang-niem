import 'dart:convert';

import 'package:dia_tang_niem/app/app.dart';
import 'package:dia_tang_niem/core/storage/local_store.dart';
import 'package:dia_tang_niem/core/strings.dart';
import 'package:dia_tang_niem/features/chant/data/chant_controller.dart';
import 'package:dia_tang_niem/features/chant/domain/chant_models.dart';
import 'package:dia_tang_niem/features/chant/presentation/chant_button.dart';
import 'package:dia_tang_niem/features/sutra/data/sutra_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // Asset loading needs real async; do it up front so screens never sit on a spinner.
  final sutra = (await tester.runAsync(() => loadSutra(rootBundle)))!;
  final mantras = (await tester.runAsync(
    () => rootBundle.loadString('assets/sutra/mantras.json'),
  ))!;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(LocalStore(prefs)),
        sutraProvider.overrideWith((ref) async => sutra),
        mantrasProvider.overrideWith(
          (ref) async => [
            for (final m in jsonDecode(mantras) as List)
              Mantra.fromJson(m as Map<String, dynamic>),
          ],
        ),
      ],
      child: const DiaTangApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping the round button counts and undo takes one back', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(
      find.text('Nam mô Đại Nguyện Địa Tạng Vương Bồ Tát'),
      findsOneWidget,
    );

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(ChantButton));
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(
      find.descendant(of: find.byType(ChantButton), matching: find.text('3')),
      findsOneWidget,
    );

    await tester.tap(find.text(S.undo));
    await tester.pump(const Duration(milliseconds: 120));
    expect(
      find.descendant(of: find.byType(ChantButton), matching: find.text('2')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  testWidgets(
    'finishing a sitting opens the dedication sheet with the verse from Kết Kinh',
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byType(ChantButton));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(find.text(S.finish));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nguyện đem công đức nầy'), findsOneWidget);
      expect(find.text(S.dharmaRealm), findsOneWidget);
    },
  );

  testWidgets('every tab opens', (tester) async {
    await pumpApp(tester);
    for (final tab in [S.tabSutra, S.tabDedication, S.tabMore, S.tabChant]) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
    }
    expect(find.byType(ChantButton), findsOneWidget);
  });
}
