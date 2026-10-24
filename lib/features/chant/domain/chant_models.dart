import '../../../core/utils/dates.dart';

const beadsPerRound = 108;

/// A name to recite, loaded from assets/sutra/mantras.json.
class Mantra {
  const Mantra({
    required this.id,
    required this.text,
    required this.source,
    this.sourceBlockId,
  });

  final String id;
  final String text;
  final String source;
  final String? sourceBlockId;

  factory Mantra.fromJson(Map<String, dynamic> j) => Mantra(
    id: j['id'] as String,
    text: j['text'] as String,
    source: j['source'] as String,
    sourceBlockId: j['sourceBlockId'] as String?,
  );
}

class ChantSession {
  const ChantSession({
    required this.id,
    required this.start,
    required this.end,
    required this.count,
    required this.mantraId,
    this.planId,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final int count;
  final String mantraId;
  final String? planId;

  Duration get duration => end.difference(start);

  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'count': count,
    'mantraId': mantraId,
    'planId': planId,
  };

  factory ChantSession.fromJson(Map<String, dynamic> j) => ChantSession(
    id: j['id'] as String,
    start: DateTime.parse(j['start'] as String),
    end: DateTime.parse(j['end'] as String),
    count: j['count'] as int,
    mantraId: j['mantraId'] as String,
    planId: j['planId'] as String?,
  );
}

/// Multi-day practice, e.g. "một muôn biến trong 7 ngày" (Phẩm 6, Phẩm 12).
class ChantPlan {
  const ChantPlan({
    required this.id,
    required this.target,
    required this.days,
    required this.startDate,
    this.personIds = const [],
    this.endedAt,
  });

  final String id;
  final int target;
  final int days;
  final DateTime startDate;
  final List<String> personIds;
  final DateTime? endedAt;

  DateTime get lastDate => dateOnly(startDate).add(Duration(days: days - 1));

  int get dailyTarget => (target / days).ceil();

  /// 1-based day of the plan for [today], clamped to the plan length.
  int dayNumber(DateTime today) =>
      (dateOnly(today).difference(dateOnly(startDate)).inDays + 1).clamp(
        1,
        days,
      );

  bool isActive(DateTime today) =>
      endedAt == null && !dateOnly(today).isAfter(lastDate);

  /// Sum of everything chanted on the plan's days.
  int progress(Map<String, int> daily) {
    var sum = 0;
    for (var i = 0; i < days; i++) {
      sum += daily[dayKey(dateOnly(startDate).add(Duration(days: i)))] ?? 0;
    }
    return sum;
  }

  ChantPlan end(DateTime at) => ChantPlan(
    id: id,
    target: target,
    days: days,
    startDate: startDate,
    personIds: personIds,
    endedAt: at,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'target': target,
    'days': days,
    'startDate': dayKey(startDate),
    'personIds': personIds,
    'endedAt': endedAt?.toIso8601String(),
  };

  factory ChantPlan.fromJson(Map<String, dynamic> j) => ChantPlan(
    id: j['id'] as String,
    target: j['target'] as int,
    days: j['days'] as int,
    startDate: parseDayKey(j['startDate'] as String),
    personIds: (j['personIds'] as List? ?? const []).cast<String>(),
    endedAt: j['endedAt'] == null
        ? null
        : DateTime.parse(j['endedAt'] as String),
  );
}

int beadInRound(int count) => count % beadsPerRound;

int completedRounds(int count) => count ~/ beadsPerRound;

bool completesRound(int count) => count > 0 && count % beadsPerRound == 0;

/// Consecutive days with chanting, ending today (or yesterday if today has none yet).
int streakDays(Map<String, int> daily, DateTime today) {
  var day = dateOnly(today);
  if ((daily[dayKey(day)] ?? 0) == 0) {
    day = day.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while ((daily[dayKey(day)] ?? 0) > 0) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}
