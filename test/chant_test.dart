import 'package:dia_tang_niem/core/storage/local_store.dart';
import 'package:dia_tang_niem/core/utils/dates.dart';
import 'package:dia_tang_niem/features/chant/data/chant_controller.dart';
import 'package:dia_tang_niem/features/chant/domain/chant_models.dart';
import 'package:dia_tang_niem/features/settings/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('108-bead rounds', () {
    test('bead position and completed rounds', () {
      expect(beadInRound(0), 0);
      expect(beadInRound(107), 107);
      expect(beadInRound(108), 0);
      expect(completedRounds(215), 1);
      expect(completesRound(108), isTrue);
      expect(completesRound(216), isTrue);
      expect(completesRound(0), isFalse);
      expect(completesRound(109), isFalse);
    });
  });

  test('streak counts consecutive days ending today or yesterday', () {
    final today = DateTime(2026, 10, 21);
    final daily = {
      dayKey(DateTime(2026, 10, 18)): 5,
      dayKey(DateTime(2026, 10, 19)): 108,
      dayKey(DateTime(2026, 10, 20)): 3,
    };
    expect(streakDays(daily, today), 3);
    expect(streakDays({...daily, dayKey(today): 1}, today), 4);
    expect(streakDays({dayKey(DateTime(2026, 10, 10)): 9}, today), 0);
  });

  test('plan sums only its own days', () {
    final plan = ChantPlan(
      id: 'p',
      target: 10000,
      days: 7,
      startDate: DateTime(2026, 10, 1),
    );
    final daily = {
      dayKey(DateTime(2026, 9, 30)): 999,
      dayKey(DateTime(2026, 10, 1)): 1000,
      dayKey(DateTime(2026, 10, 7)): 500,
      dayKey(DateTime(2026, 10, 8)): 999,
    };
    expect(plan.progress(daily), 1500);
    expect(plan.dailyTarget, 1429);
    expect(plan.lastDate, DateTime(2026, 10, 7));
    expect(plan.isActive(DateTime(2026, 10, 7, 23)), isTrue);
    expect(plan.isActive(DateTime(2026, 10, 8)), isFalse);
    expect(plan.dayNumber(DateTime(2026, 10, 3)), 3);
  });

  group('ChantController', () {
    test('tap, undo and reset keep totals consistent', () async {
      final c = await makeContainer();
      final chant = c.read(chantProvider.notifier);
      for (var i = 0; i < 110; i++) {
        chant.tap();
      }
      chant.undo();
      var s = c.read(chantProvider);
      expect(s.sessionCount, 109);
      expect(s.lifetime, 109);
      expect(s.todayCount(DateTime.now()), 109);

      chant.resetSession();
      s = c.read(chantProvider);
      expect(s.sessionCount, 0);
      expect(s.lifetime, 109, reason: 'reset keeps the totals');
      chant.undo();
      expect(
        c.read(chantProvider).lifetime,
        109,
        reason: 'nothing to undo after reset',
      );
      c.dispose();
    });

    test('tap reports a completed round and the daily goal', () async {
      final c = await makeContainer();
      c
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(dailyGoal: 108));
      final chant = c.read(chantProvider.notifier);
      TapResult? last;
      for (var i = 0; i < 108; i++) {
        last = chant.tap();
      }
      expect(last!.roundCompleted, isTrue);
      expect(last.goalReached, isTrue);
      expect(chant.tap().roundCompleted, isFalse);
      c.dispose();
    });

    test('counts survive a restart', () async {
      final c1 = await makeContainer();
      final chant = c1.read(chantProvider.notifier);
      for (var i = 0; i < 21; i++) {
        chant.tap();
      }
      chant.flush();
      c1.dispose();

      final c2 = await makeContainer();
      final s = c2.read(chantProvider);
      expect(s.sessionCount, 21);
      expect(s.lifetime, 21);
      c2.dispose();
    });

    test('finishing a sitting records it and starts a new one', () async {
      final c = await makeContainer();
      final chant = c.read(chantProvider.notifier);
      expect(chant.finishSession(), isNull);
      for (var i = 0; i < 5; i++) {
        chant.tap();
      }
      final session = chant.finishSession()!;
      expect(session.count, 5);
      final s = c.read(chantProvider);
      expect(s.sessionCount, 0);
      expect(s.sessions.single.id, session.id);
      expect(s.lifetime, 5);
      c.dispose();
    });

    test('only one plan is active at a time', () async {
      final c = await makeContainer();
      final chant = c.read(chantProvider.notifier);
      chant.startPlan(target: 10000, days: 7, personIds: const []);
      chant.startPlan(target: 1080, days: 1, personIds: const []);
      final s = c.read(chantProvider);
      expect(s.plans.where((p) => p.isActive(DateTime.now())).length, 1);
      expect(s.activePlan(DateTime.now())!.target, 1080);
      c.dispose();
    });
  });
}
