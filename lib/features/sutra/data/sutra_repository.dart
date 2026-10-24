import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sutra_models.dart';

const _base = 'assets/sutra/dia_tang';

Future<Map<String, dynamic>> _load(AssetBundle bundle, String file) async =>
    jsonDecode(await bundle.loadString('$_base/$file')) as Map<String, dynamic>;

Future<Sutra> loadSutra(AssetBundle bundle) async {
  final results = await Future.wait([
    _load(bundle, 'meta.json'),
    _load(bundle, 'khai_kinh.json'),
    _load(bundle, 'quyen_thuong.json'),
    _load(bundle, 'quyen_trung.json'),
    _load(bundle, 'quyen_ha.json'),
    _load(bundle, 'ket_kinh.json'),
  ]);
  return Sutra(
    meta: SutraMeta.fromJson(results[0]),
    opening: SutraRite.fromJson(results[1]),
    volumes: [for (final v in results.sublist(2, 5)) SutraVolume.fromJson(v)],
    closing: SutraRite.fromJson(results[5]),
  );
}

final sutraProvider = FutureProvider<Sutra>((ref) => loadSutra(rootBundle));
