import '../../../core/utils/dates.dart';

enum PersonStatus { alive, deceased }

class Person {
  const Person({
    required this.id,
    required this.name,
    this.dharmaName,
    this.relation = '',
    this.status = PersonStatus.alive,
    this.deathDate,
    this.note,
  });

  final String id;
  final String name;
  final String? dharmaName;
  final String relation;
  final PersonStatus status;

  /// Solar date; the lunar date is always derived from it.
  final DateTime? deathDate;
  final String? note;

  bool get isDeceased => status == PersonStatus.deceased;

  /// "Mẹ — Nguyễn Thị A (Diệu Hạnh)"
  String get displayName {
    final dharma = (dharmaName?.isNotEmpty ?? false) ? ' ($dharmaName)' : '';
    final rel = relation.isNotEmpty ? '$relation — ' : '';
    return '$rel$name$dharma';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dharmaName': dharmaName,
    'relation': relation,
    'status': status.name,
    'deathDate': deathDate == null ? null : dayKey(deathDate!),
    'note': note,
  };

  factory Person.fromJson(Map<String, dynamic> j) => Person(
    id: j['id'] as String,
    name: j['name'] as String,
    dharmaName: j['dharmaName'] as String?,
    relation: j['relation'] as String? ?? '',
    status: PersonStatus.values.asNameMap()[j['status']] ?? PersonStatus.alive,
    deathDate: j['deathDate'] == null
        ? null
        : parseDayKey(j['deathDate'] as String),
    note: j['note'] as String?,
  );
}

enum DedicationSourceType { chant, recitation, plan }

/// What merit is being dedicated, shown above the verse.
class DedicationSource {
  const DedicationSource({
    required this.type,
    required this.sourceId,
    required this.summary,
  });

  final DedicationSourceType type;
  final String sourceId;

  /// e.g. "108 biến · Nam mô Đại Nguyện Địa Tạng Vương Bồ Tát"
  final String summary;
}

class Dedication {
  const Dedication({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.summary,
    required this.personIds,
    required this.toDharmaRealm,
    required this.verseId,
    required this.createdAt,
  });

  final String id;
  final DedicationSourceType sourceType;
  final String sourceId;
  final String summary;
  final List<String> personIds;
  final bool toDharmaRealm;

  /// Section id of the verse used (e.g. the "HỒI HƯỚNG" section of Kết Kinh).
  final String verseId;
  final DateTime createdAt;

  Dedication withoutPerson(String personId) => Dedication(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    summary: summary,
    personIds: personIds.where((p) => p != personId).toList(),
    toDharmaRealm: toDharmaRealm,
    verseId: verseId,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceType': sourceType.name,
    'sourceId': sourceId,
    'summary': summary,
    'personIds': personIds,
    'toDharmaRealm': toDharmaRealm,
    'verseId': verseId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Dedication.fromJson(Map<String, dynamic> j) => Dedication(
    id: j['id'] as String,
    sourceType:
        DedicationSourceType.values.asNameMap()[j['sourceType']] ??
        DedicationSourceType.chant,
    sourceId: j['sourceId'] as String,
    summary: j['summary'] as String? ?? '',
    personIds: (j['personIds'] as List? ?? const []).cast<String>(),
    toDharmaRealm: j['toDharmaRealm'] as bool? ?? false,
    verseId: j['verseId'] as String? ?? '',
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

/// One of the seven weekly observances in the 49 days after death (Phẩm 7).
class MemorialWeek {
  const MemorialWeek(this.week, this.date);

  /// 1..7; week 7 is chung thất (day 49).
  final int week;
  final DateTime date;
}

// TODO(buddhist-review): confirm the counting convention (death day = day 1) with a teacher.
List<MemorialWeek> memorialWeeks(DateTime deathDate) => [
  for (var w = 1; w <= 7; w++)
    MemorialWeek(w, dateOnly(deathDate).add(Duration(days: 7 * w - 1))),
];

/// Day 1..49 of the memorial period, or null outside it.
int? memorialDay(DateTime deathDate, DateTime today) {
  final day = dateOnly(today).difference(dateOnly(deathDate)).inDays + 1;
  return day >= 1 && day <= 49 ? day : null;
}
