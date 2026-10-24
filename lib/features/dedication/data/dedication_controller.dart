import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_store.dart';
import '../domain/dedication_models.dart';

class DedicationState {
  const DedicationState({this.persons = const [], this.log = const []});

  final List<Person> persons;
  final List<Dedication> log;

  Person? person(String id) => persons.where((p) => p.id == id).firstOrNull;
}

class DedicationController extends Notifier<DedicationState> {
  static const _kPersons = 'dedication.persons';
  static const _kLog = 'dedication.log';

  LocalStore get _store => ref.read(localStoreProvider);

  @override
  DedicationState build() {
    final store = ref.read(localStoreProvider);
    return DedicationState(
      persons: store.readList(_kPersons).map(Person.fromJson).toList(),
      log: store.readList(_kLog).map(Dedication.fromJson).toList(),
    );
  }

  void savePerson(Person person) {
    final exists = state.persons.any((p) => p.id == person.id);
    final persons = exists
        ? [for (final p in state.persons) p.id == person.id ? person : p]
        : [...state.persons, person];
    state = DedicationState(persons: persons, log: state.log);
    _savePersons();
  }

  /// Removes the person and their name from every log entry (CLAUDE.md: xoá hoàn toàn).
  void deletePerson(String id) {
    state = DedicationState(
      persons: state.persons.where((p) => p.id != id).toList(),
      log: [for (final d in state.log) d.withoutPerson(id)],
    );
    _savePersons();
    _saveLog();
  }

  void dedicate({
    required DedicationSource source,
    required List<String> personIds,
    required bool toDharmaRealm,
    required String verseId,
  }) {
    final entry = Dedication(
      id: newId(),
      sourceType: source.type,
      sourceId: source.sourceId,
      summary: source.summary,
      personIds: personIds,
      toDharmaRealm: toDharmaRealm,
      verseId: verseId,
      createdAt: DateTime.now(),
    );
    state = DedicationState(persons: state.persons, log: [entry, ...state.log]);
    _saveLog();
  }

  void _savePersons() => _store.writeJson(
    _kPersons,
    state.persons.map((p) => p.toJson()).toList(),
  );

  void _saveLog() =>
      _store.writeJson(_kLog, state.log.map((d) => d.toJson()).toList());
}

final dedicationProvider =
    NotifierProvider<DedicationController, DedicationState>(
      DedicationController.new,
    );
