import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../../../core/utils/dates.dart';
import '../../settings/settings_controller.dart';
import '../domain/chant_models.dart';

final mantrasProvider = FutureProvider<List<Mantra>>((ref) async {
  final raw = await rootBundle.loadString('assets/sutra/mantras.json');
  return [
    for (final m in jsonDecode(raw) as List)
      Mantra.fromJson(m as Map<String, dynamic>),
  ];
});

class ChantState {
  const ChantState({
    required this.sessionCount,
    required this.sessionStart,
    required this.mantraId,
    required this.daily,
    required this.lifetime,
    required this.sessions,
    required this.plans,
  });

  /// Count shown on the big button (this sitting).
  final int sessionCount;
  final DateTime? sessionStart;
  final String mantraId;

  /// dayKey -> count, all mantras together.
  final Map<String, int> daily;
  final int lifetime;
  final List<ChantSession> sessions;
  final List<ChantPlan> plans;

  int todayCount(DateTime now) => daily[dayKey(now)] ?? 0;

  ChantPlan? activePlan(DateTime now) =>
      plans.where((p) => p.isActive(now)).firstOrNull;

  ChantState copyWith({
    int? sessionCount,
    DateTime? sessionStart,
    bool clearSessionStart = false,
    String? mantraId,
    Map<String, int>? daily,
    int? lifetime,
    List<ChantSession>? sessions,
    List<ChantPlan>? plans,
  }) => ChantState(
    sessionCount: sessionCount ?? this.sessionCount,
    sessionStart: clearSessionStart
        ? null
        : (sessionStart ?? this.sessionStart),
    mantraId: mantraId ?? this.mantraId,
    daily: daily ?? this.daily,
    lifetime: lifetime ?? this.lifetime,
    sessions: sessions ?? this.sessions,
    plans: plans ?? this.plans,
  );
}

class TapResult {
  const TapResult({required this.roundCompleted, required this.goalReached});
  final bool roundCompleted;
  final bool goalReached;
}

/// Owns every count. Writes are debounced but always flushed (CLAUDE.md: never lose a count).
class ChantController extends Notifier<ChantState> {
  static const _kCounter = 'chant.counter';
  static const _kDaily = 'chant.daily';
  static const _kSessions = 'chant.sessions';
  static const _kPlans = 'chant.plans';
  static const _debounce = Duration(milliseconds: 400);

  Timer? _saveTimer;
  DateTime Function() clock = DateTime.now;
  late LocalStore _store;

  /// State waiting to be written. Kept apart because Riverpod forbids reading [state] in onDispose.
  ChantState? _unsaved;

  @override
  ChantState build() {
    final store = _store = ref.read(localStoreProvider);
    ref.onDispose(() {
      _saveTimer?.cancel();
      if (_unsaved != null) _write(_unsaved!);
    });
    final counter = store.readMap(_kCounter);
    final daily = store
        .readMap(_kDaily)
        .map((k, v) => MapEntry(k, (v as num).toInt()));
    return ChantState(
      sessionCount: counter['sessionCount'] as int? ?? 0,
      sessionStart: counter['sessionStart'] == null
          ? null
          : DateTime.parse(counter['sessionStart'] as String),
      mantraId:
          counter['mantraId'] as String? ??
          ref.read(settingsProvider).defaultMantraId,
      daily: daily,
      lifetime: counter['lifetime'] as int? ?? 0,
      sessions: store.readList(_kSessions).map(ChantSession.fromJson).toList(),
      plans: store.readList(_kPlans).map(ChantPlan.fromJson).toList(),
    );
  }

  TapResult tap() {
    final now = clock();
    final key = dayKey(now);
    final today = (state.daily[key] ?? 0) + 1;
    final goal = ref.read(settingsProvider).dailyGoal;
    state = state.copyWith(
      sessionCount: state.sessionCount + 1,
      sessionStart: state.sessionStart ?? now,
      daily: {...state.daily, key: today},
      lifetime: state.lifetime + 1,
    );
    _scheduleSave();
    return TapResult(
      roundCompleted: completesRound(state.sessionCount),
      goalReached: goal > 0 && today == goal,
    );
  }

  /// Takes back the last tap of this sitting.
  void undo() {
    if (state.sessionCount == 0) return;
    final key = dayKey(clock());
    final today = state.daily[key] ?? 0;
    state = state.copyWith(
      sessionCount: state.sessionCount - 1,
      daily: {...state.daily, key: today > 0 ? today - 1 : 0},
      lifetime: state.lifetime > 0 ? state.lifetime - 1 : 0,
    );
    _scheduleSave();
  }

  /// Sets this sitting back to 0; daily and lifetime totals are kept.
  void resetSession() {
    state = state.copyWith(sessionCount: 0, clearSessionStart: true);
    _scheduleSave();
  }

  /// Closes the sitting and records it. Returns null when nothing was chanted.
  ChantSession? finishSession() {
    if (state.sessionCount == 0) return null;
    final now = clock();
    final session = ChantSession(
      id: newId(),
      start: state.sessionStart ?? now,
      end: now,
      count: state.sessionCount,
      mantraId: state.mantraId,
      planId: state.activePlan(now)?.id,
    );
    state = state.copyWith(
      sessions: [session, ...state.sessions],
      sessionCount: 0,
      clearSessionStart: true,
    );
    flush();
    return session;
  }

  void selectMantra(String id) {
    state = state.copyWith(mantraId: id);
    _scheduleSave();
  }

  void startPlan({
    required int target,
    required int days,
    required List<String> personIds,
  }) {
    final now = clock();
    final plans = [
      ChantPlan(
        id: newId(),
        target: target,
        days: days,
        startDate: dateOnly(now),
        personIds: personIds,
      ),
      // Only one active plan at a time: end the running one.
      for (final p in state.plans) p.isActive(now) ? p.end(now) : p,
    ];
    state = state.copyWith(plans: plans);
    flush();
  }

  void endPlan(String id) {
    final now = clock();
    state = state.copyWith(
      plans: [for (final p in state.plans) p.id == id ? p.end(now) : p],
    );
    flush();
  }

  void _scheduleSave() {
    _unsaved = state;
    _saveTimer?.cancel();
    _saveTimer = Timer(_debounce, flush);
  }

  /// Writes everything now. Called on debounce, app pause and dispose.
  void flush() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _write(state);
  }

  void _write(ChantState s) {
    _unsaved = null;
    _store.writeJson(_kCounter, {
      'sessionCount': s.sessionCount,
      'sessionStart': s.sessionStart?.toIso8601String(),
      'mantraId': s.mantraId,
      'lifetime': s.lifetime,
    });
    _store.writeJson(_kDaily, s.daily);
    _store.writeJson(_kSessions, s.sessions.map((x) => x.toJson()).toList());
    _store.writeJson(_kPlans, s.plans.map((x) => x.toJson()).toList());
  }
}

final chantProvider = NotifierProvider<ChantController, ChantState>(
  ChantController.new,
);
