import 'package:dia_tang_niem/core/storage/local_store.dart';
import 'package:dia_tang_niem/features/chant/data/chant_controller.dart';
import 'package:dia_tang_niem/features/settings/backup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('export then restore gives back the same data', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore(prefs);
    final c = ProviderContainer(
      overrides: [localStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);

    for (var i = 0; i < 5; i++) {
      c.read(chantProvider.notifier).tap();
    }
    // Taps are still debounced; a backup must include them.
    c.read(chantProvider.notifier).flush();
    final text = Backup.encode(store.exportAll(), DateTime(2026, 10, 24));

    await store.clearAll();
    c.invalidate(chantProvider);
    expect(c.read(chantProvider).lifetime, 0);

    await store.replaceAll(Backup.decode(text));
    c.invalidate(chantProvider);
    expect(c.read(chantProvider).lifetime, 5);
    expect(c.read(chantProvider).sessionCount, 5);
  });

  test('restore replaces existing data and keeps other apps\' keys', () async {
    SharedPreferences.setMockInitialValues({'dtn.old': '1', 'other.key': 'x'});
    final prefs = await SharedPreferences.getInstance();
    await LocalStore(prefs).replaceAll({'new': '2'});
    expect(prefs.getString('dtn.old'), isNull);
    expect(prefs.getString('dtn.new'), '2');
    expect(prefs.getString('other.key'), 'x');
  });

  test('rejects files that are not backups', () {
    expect(() => Backup.decode('hello'), throwsFormatException);
    expect(() => Backup.decode('{"a":1}'), throwsFormatException);
    expect(
      () => Backup.decode(
        '{"format":"dia_tang_niem_backup","version":99,"data":{}}',
      ),
      throwsFormatException,
    );
    expect(
      () => Backup.decode(
        '{"format":"dia_tang_niem_backup","version":1,"data":{"k":1}}',
      ),
      throwsFormatException,
    );
  });

  test('file name carries the date', () {
    expect(
      Backup.fileName(DateTime(2026, 10, 24, 9, 5)),
      'dia-tang-niem-20261024-0905.json',
    );
  });
}
