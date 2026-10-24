import 'package:dia_tang_niem/core/storage/local_store.dart';
import 'package:dia_tang_niem/features/dedication/data/dedication_controller.dart';
import 'package:dia_tang_niem/features/dedication/domain/dedication_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('49 days: seven weekly dates, death day counted as day 1', () {
    final weeks = memorialWeeks(DateTime(2026, 10, 1));
    expect(weeks.length, 7);
    expect(weeks.first.date, DateTime(2026, 10, 7));
    expect(weeks.last.date, DateTime(2026, 11, 18));
    expect(memorialDay(DateTime(2026, 10, 1), DateTime(2026, 10, 1)), 1);
    expect(memorialDay(DateTime(2026, 10, 1), DateTime(2026, 11, 18)), 49);
    expect(memorialDay(DateTime(2026, 10, 1), DateTime(2026, 11, 19)), isNull);
  });

  test('displayName shows relation and dharma name', () {
    const p = Person(
      id: '1',
      name: 'Nguyễn Thị A',
      dharmaName: 'Diệu Hạnh',
      relation: 'Mẹ',
    );
    expect(p.displayName, 'Mẹ — Nguyễn Thị A (Diệu Hạnh)');
  });

  test('deleting a person also removes them from the dedication log', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
    );
    final ctrl = c.read(dedicationProvider.notifier);
    ctrl.savePerson(const Person(id: 'a', name: 'A'));
    ctrl.savePerson(
      const Person(id: 'b', name: 'B', status: PersonStatus.deceased),
    );
    ctrl.dedicate(
      source: const DedicationSource(
        type: DedicationSourceType.chant,
        sourceId: 's',
        summary: '108 biến',
      ),
      personIds: const ['a', 'b'],
      toDharmaRealm: true,
      verseId: 'kt.s9',
    );
    ctrl.deletePerson('a');

    final state = c.read(dedicationProvider);
    expect(state.persons.map((p) => p.id), ['b']);
    expect(state.log.single.personIds, ['b']);

    // Persisted too.
    final c2 = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
    );
    expect(c2.read(dedicationProvider).log.single.personIds, ['b']);
    c.dispose();
    c2.dispose();
  });
}
