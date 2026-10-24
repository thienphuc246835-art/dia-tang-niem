import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';
import '../chant/data/chant_controller.dart';
import '../dedication/data/dedication_controller.dart';
import '../sutra/data/reading_controller.dart';
import 'settings_controller.dart';

/// Backup file: every LocalStore entry, unencrypted, saved where the user chooses.
abstract final class Backup {
  static const format = 'dia_tang_niem_backup';
  static const version = 1;

  static String encode(Map<String, String> entries, DateTime now) =>
      const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'version': version,
        'exportedAt': now.toIso8601String(),
        'data': entries,
      });

  /// Throws [FormatException] if [text] is not a backup made by this app.
  static Map<String, String> decode(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const FormatException('not json');
    }
    if (json is! Map ||
        json['format'] != format ||
        json['version'] is! int ||
        (json['version'] as int) > version ||
        json['data'] is! Map) {
      throw const FormatException('not a backup');
    }
    final data = json['data'] as Map;
    if (data.values.any((v) => v is! String)) {
      throw const FormatException('bad entry');
    }
    return data.cast<String, String>();
  }

  static String fileName(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'dia-tang-niem-${now.year}${two(now.month)}${two(now.day)}'
        '-${two(now.hour)}${two(now.minute)}.json';
  }
}

/// Writes pending counts so a backup or restore sees the latest data.
void _flushPending(WidgetRef ref) => ref.read(chantProvider.notifier).flush();

void _reloadAll(WidgetRef ref) => ref
  ..invalidate(settingsProvider)
  ..invalidate(chantProvider)
  ..invalidate(dedicationProvider)
  ..invalidate(readingProvider);

/// Returns false if the user cancelled the save dialog.
Future<bool> exportBackup(WidgetRef ref) async {
  _flushPending(ref);
  final now = DateTime.now();
  final text = Backup.encode(ref.read(localStoreProvider).exportAll(), now);
  final uri = await FilePicker.saveFile(
    fileName: Backup.fileName(now),
    bytes: Uint8List.fromList(utf8.encode(text)),
    mimeType: 'application/json',
    allowedExtensions: const ['json'],
  );
  // The web download has no dialog to cancel and may return null.
  return uri != null || kIsWeb;
}

/// Lets the user pick a backup file and returns its entries, or null if cancelled.
/// Throws [FormatException] for a file that is not a backup.
Future<Map<String, String>?> pickBackup() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (file == null) return null;
  return Backup.decode(utf8.decode(await file.xFile.readAsBytes()));
}

Future<void> restoreBackup(WidgetRef ref, Map<String, String> entries) async {
  _flushPending(ref);
  await ref.read(localStoreProvider).replaceAll(entries);
  _reloadAll(ref);
}

Future<void> clearAllData(WidgetRef ref) async {
  _flushPending(ref);
  await ref.read(localStoreProvider).clearAll();
  _reloadAll(ref);
}
