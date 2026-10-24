import 'dart:convert';
import 'dart:io';

import 'package:dia_tang_niem/features/sutra/domain/reader_document.dart';
import 'package:dia_tang_niem/features/sutra/domain/sutra_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integrity checks for assets/sutra (CLAUDE.md section 5, "Quy trình nhập Kinh").
Map<String, dynamic> _json(String name) =>
    jsonDecode(File('assets/sutra/dia_tang/$name').readAsStringSync())
        as Map<String, dynamic>;

Sutra _loadSutra() => Sutra(
  meta: SutraMeta.fromJson(_json('meta.json')),
  opening: SutraRite.fromJson(_json('khai_kinh.json')),
  volumes: [
    for (final f in ['quyen_thuong.json', 'quyen_trung.json', 'quyen_ha.json'])
      SutraVolume.fromJson(_json(f)),
  ],
  closing: SutraRite.fromJson(_json('ket_kinh.json')),
);

const _chapterTitles = [
  'THẦN THÔNG TRÊN CUNG TRỜI ĐAO LỢI',
  'PHÂN THÂN TẬP HỘI',
  'QUÁN CHÚNG SANH NGHIỆP DUYÊN',
  'NGHIỆP CẢM CỦA CHÚNG SANH',
  'DANH HIỆU CỦA ĐỊA NGỤC',
  'NHƯ LAI TÁN THÁN',
  'LỢI ÍCH CẢ KẺ CÒN NGƯỜI MẤT',
  'CÁC VUA DIÊM LA KHEN NGỢI',
  'XƯNG DANH HIỆU CHƯ PHẬT',
  'SO SÁNH NHÂN DUYÊN CÔNG ĐỨC CỦA SỰ BỐ THÍ',
  'ĐỊA THẦN HỘ PHÁP',
  'THẤY NGHE ĐƯỢC LỢI ÍCH',
  'DẶN DÒ CỨU ĐỘ NHƠN THIÊN',
];

void main() {
  final sutra = _loadSutra();
  final doc = buildDocument(sutra, allParts);
  final blocks = doc.items.whereType<BlockItem>().map((i) => i.block).toList();

  test('3 volumes with chapters 1–4, 5–9, 10–13', () {
    expect(sutra.volumes.map((v) => v.id), ['q1', 'q2', 'q3']);
    expect(sutra.volumes.map((v) => v.chapters.map((c) => c.number).toList()), [
      [1, 2, 3, 4],
      [5, 6, 7, 8, 9],
      [10, 11, 12, 13],
    ]);
  });

  test('chapter titles match the table of contents in CLAUDE.md', () {
    final titles = [
      for (final v in sutra.volumes)
        for (final c in v.chapters) c.title,
    ];
    expect(titles, _chapterTitles);
  });

  test('opening and closing rites are complete', () {
    expect(sutra.opening.sections.map((s) => s.title), [
      'TỰA ĐỊA TẠNG BỒ TÁT',
      'VĂN PHÁT NGUYỆN',
      'KỆ KHAI KINH',
    ]);
    expect(sutra.closing.sections.map((s) => s.title).whereType<String>(), [
      'MA HA BÁT NHÃ BA LA MẬT ĐA TÂM KINH',
      'VÃNG SANH QUYẾT ĐỊNH CHƠN NGÔN',
      'TÁN PHẬT',
      'SÁM THẬP PHƯƠNG',
      'PHÚNG KINH',
      'PHỤC NGUYỆN',
      'TAM QUY Y',
      'HỒI HƯỚNG',
    ]);
    for (final v in sutra.volumes) {
      expect(
        v.closing.where((b) => b.repeat != null),
        isNotEmpty,
        reason: '${v.id} closing invocations',
      );
    }
  });

  test('dedication verse is read verbatim from the book', () {
    expect(
      sutra.dedicationVerse.blocks.single.text,
      'Nguyện đem công đức nầy,\nHướng về khắp tất cả,\nĐệ tử và chúng sanh,\nĐều trọn thành phật đạo.',
    );
  });

  test('no empty blocks and no PDF artefacts left', () {
    for (final b in blocks) {
      expect(b.text.trim(), isNotEmpty, reason: b.id);
      expect(b.text, isNot(contains('KINH ĐỊA TẠNG -')), reason: b.id);
      expect(b.text, isNot(matches(RegExp(r'PHẨM \d+\s+\d+'))), reason: b.id);
      expect(b.text, isNot(contains('❖')), reason: b.id);
      expect(b.text, isNot(contains('  ')), reason: b.id);
      expect(
        b.text,
        isNot(matches(RegExp(r'\(\d+ (lần|lạy)\)$'))),
        reason: '${b.id} marker not split off',
      );
    }
  });

  test('text is NFC (precomposed Vietnamese letters)', () {
    // Combining diacritics U+0300–U+036F only appear in decomposed (NFD) text.
    final combining = RegExp('[̀-ͯ]');
    for (final b in blocks) {
      expect(combining.hasMatch(b.text), isFalse, reason: b.id);
    }
  });

  test('ids are unique and stable in form', () {
    final ids = doc.items.map((i) => i.anchorId).toList();
    expect(ids.toSet().length, ids.length);
    for (final b in blocks) {
      expect(
        b.id,
        matches(
          RegExp(r'^(kk|kt)\.s\d+\.b\d+$|^q[123]\.(p\d+\.s\d+|c)\.b\d+$'),
        ),
      );
    }
  });

  test('every mantra with a source points at the same words in the book', () {
    final mantras = jsonDecode(
      File('assets/sutra/mantras.json').readAsStringSync(),
    ) as List;
    for (final m in mantras.cast<Map<String, dynamic>>()) {
      final id = m['sourceBlockId'] as String?;
      if (id == null) continue;
      final block = sutra.block(id);
      expect(block, isNotNull, reason: id);
      expect(block!.text.replaceAll(RegExp(r'\.$'), ''), m['text'], reason: id);
    }
  });

  test('passages cited by features exist', () {
    expect(sutra.block('q2.p6.s12.b1')!.text, contains('mười ngày trên đây'));
    expect(sutra.block('q2.p7.s3.b7')!.text, contains('bốn mươi chín ngày'));
    expect(sutra.block('q2.p6.s10.b2')!.text, contains('một muôn biến'));
    expect(sutra.block('q3.p12.s6.b6')!.text, contains('hai mươi mốt ngày'));
  });

  group('search', () {
    test('ignores diacritics and case', () {
      expect(foldVietnamese('Bà La Môn Nữ'), 'ba la mon nu');
      expect(foldVietnamese('ĐỊA TẠNG'), 'dia tang');
      final hits = searchDocument(doc, 'THANH nu');
      expect(hits, isNotEmpty);
      expect(hits.first.item.context, startsWith('Phẩm 1'));
    });

    test('short queries return nothing', () {
      expect(searchDocument(doc, 'a'), isEmpty);
    });
  });

  test('ritual of one volume is Khai Kinh + volume + Kết Kinh', () {
    final ritual = buildDocument(sutra, ritualParts('q2'));
    final parts = ritual.items
        .whereType<PartTitleItem>()
        .map((p) => p.anchorId)
        .toList();
    expect(parts, ['kk', 'q2', 'kt']);
  });
}
