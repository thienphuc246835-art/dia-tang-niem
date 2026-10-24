import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';

class Bookmark {
  const Bookmark({
    required this.blockId,
    required this.label,
    required this.preview,
    required this.createdAt,
  });

  final String blockId;
  final String label;
  final String preview;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'blockId': blockId,
    'label': label,
    'preview': preview,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> j) => Bookmark(
    blockId: j['blockId'] as String,
    label: j['label'] as String? ?? '',
    preview: j['preview'] as String? ?? '',
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

/// One completed ritual recitation (RecitationLog in CLAUDE.md).
class RecitationLog {
  const RecitationLog({
    required this.id,
    required this.date,
    required this.scope,
    required this.duration,
  });

  final String id;
  final DateTime date;

  /// 'q1' | 'q2' | 'q3' | 'all'
  final String scope;
  final Duration duration;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'scope': scope,
    'durationSec': duration.inSeconds,
  };

  factory RecitationLog.fromJson(Map<String, dynamic> j) => RecitationLog(
    id: j['id'] as String,
    date: DateTime.parse(j['date'] as String),
    scope: j['scope'] as String,
    duration: Duration(seconds: j['durationSec'] as int? ?? 0),
  );
}

String scopeLabel(String scope) => switch (scope) {
  'q1' => 'Quyển Thượng',
  'q2' => 'Quyển Trung',
  'q3' => 'Quyển Hạ',
  _ => 'Trọn bộ',
};

class ReadingState {
  const ReadingState({
    this.lastAnchor,
    this.bookmarks = const [],
    this.recitations = const [],
  });

  final String? lastAnchor;
  final List<Bookmark> bookmarks;
  final List<RecitationLog> recitations;

  /// Volume to suggest for the next ritual session (the one after the last recited).
  String get nextRitualVolume {
    final last = recitations.where((r) => r.scope != 'all').firstOrNull?.scope;
    return switch (last) {
      'q1' => 'q2',
      'q2' => 'q3',
      _ => 'q1',
    };
  }

  bool isBookmarked(String blockId) =>
      bookmarks.any((b) => b.blockId == blockId);

  ReadingState copyWith({
    String? lastAnchor,
    List<Bookmark>? bookmarks,
    List<RecitationLog>? recitations,
  }) => ReadingState(
    lastAnchor: lastAnchor ?? this.lastAnchor,
    bookmarks: bookmarks ?? this.bookmarks,
    recitations: recitations ?? this.recitations,
  );
}

class ReadingController extends Notifier<ReadingState> {
  static const _kLast = 'reading.last';
  static const _kBookmarks = 'reading.bookmarks';
  static const _kRecitations = 'reading.recitations';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  ReadingState build() {
    final store = ref.read(localStoreProvider);
    return ReadingState(
      lastAnchor: store.readJson(_kLast) as String?,
      bookmarks: store.readList(_kBookmarks).map(Bookmark.fromJson).toList(),
      recitations: store
          .readList(_kRecitations)
          .map(RecitationLog.fromJson)
          .toList(),
    );
  }

  void saveLastPosition(String anchorId) {
    if (anchorId == state.lastAnchor) return;
    state = state.copyWith(lastAnchor: anchorId);
    _store.writeJson(_kLast, anchorId);
  }

  /// Returns true when a bookmark was added, false when removed.
  bool toggleBookmark(Bookmark bookmark) {
    final exists = state.isBookmarked(bookmark.blockId);
    final list = exists
        ? state.bookmarks.where((b) => b.blockId != bookmark.blockId).toList()
        : [bookmark, ...state.bookmarks];
    state = state.copyWith(bookmarks: list);
    _store.writeJson(_kBookmarks, list.map((b) => b.toJson()).toList());
    return !exists;
  }

  RecitationLog logRecitation(String scope, Duration duration) {
    final log = RecitationLog(
      id: newId(),
      date: DateTime.now(),
      scope: scope,
      duration: duration,
    );
    final list = [log, ...state.recitations];
    state = state.copyWith(recitations: list);
    _store.writeJson(_kRecitations, list.map((r) => r.toJson()).toList());
    return log;
  }
}

final readingProvider = NotifierProvider<ReadingController, ReadingState>(
  ReadingController.new,
);
