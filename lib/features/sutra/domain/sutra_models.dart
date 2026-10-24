/// Content schema from CLAUDE.md section 5 ("Schema nội dung Kinh").
enum BlockType { prose, verse, listItem, invocation, mantra, heading }

class SutraBlock {
  const SutraBlock({
    required this.id,
    required this.type,
    required this.text,
    this.repeat,
    this.prostrations,
  });

  final String id;
  final BlockType type;
  final String text;

  /// "(3 lần)" in the book.
  final int? repeat;

  /// "(1 lạy)" in the book.
  final int? prostrations;

  factory SutraBlock.fromJson(Map<String, dynamic> j) => SutraBlock(
    id: j['id'] as String,
    type: switch (j['type']) {
      'verse' => BlockType.verse,
      'list_item' => BlockType.listItem,
      'invocation' => BlockType.invocation,
      'mantra' => BlockType.mantra,
      'heading' => BlockType.heading,
      _ => BlockType.prose,
    },
    text: j['text'] as String,
    repeat: j['repeat'] as int?,
    prostrations: j['prostrations'] as int?,
  );
}

class SutraSection {
  const SutraSection({
    required this.id,
    this.number,
    this.title,
    required this.blocks,
  });

  final String id;
  final int? number;
  final String? title;
  final List<SutraBlock> blocks;

  factory SutraSection.fromJson(Map<String, dynamic> j) => SutraSection(
    id: j['id'] as String,
    number: j['number'] as int?,
    title: j['title'] as String?,
    blocks: [
      for (final b in j['blocks'] as List)
        SutraBlock.fromJson(b as Map<String, dynamic>),
    ],
  );

  /// TOC label: the numbered title, or the first line of an untitled section.
  String get label {
    if (title != null) {
      return number != null && number! > 0 ? '$number) $title' : title!;
    }
    final first = blocks.isEmpty ? '' : blocks.first.text.split('\n').first;
    return first.length > 48 ? '${first.substring(0, 48)}…' : first;
  }
}

class SutraChapter {
  const SutraChapter({
    required this.id,
    required this.number,
    required this.title,
    required this.sections,
  });

  final String id;
  final int number;
  final String title;
  final List<SutraSection> sections;

  factory SutraChapter.fromJson(Map<String, dynamic> j) => SutraChapter(
    id: j['id'] as String,
    number: j['number'] as int,
    title: j['title'] as String,
    sections: [
      for (final s in j['sections'] as List)
        SutraSection.fromJson(s as Map<String, dynamic>),
    ],
  );
}

/// Khai Kinh / Kết Kinh: sections only.
class SutraRite {
  const SutraRite({
    required this.id,
    required this.title,
    required this.sections,
  });

  final String id;
  final String title;
  final List<SutraSection> sections;

  factory SutraRite.fromJson(Map<String, dynamic> j) => SutraRite(
    id: j['id'] as String,
    title: j['title'] as String,
    sections: [
      for (final s in j['sections'] as List)
        SutraSection.fromJson(s as Map<String, dynamic>),
    ],
  );
}

class SutraVolume {
  const SutraVolume({
    required this.id,
    required this.title,
    required this.chapters,
    required this.closing,
  });

  final String id;
  final String title;
  final List<SutraChapter> chapters;

  /// Kệ + danh hiệu cuối quyển.
  final List<SutraBlock> closing;

  factory SutraVolume.fromJson(Map<String, dynamic> j) => SutraVolume(
    id: j['id'] as String,
    title: j['title'] as String,
    chapters: [
      for (final c in j['chapters'] as List)
        SutraChapter.fromJson(c as Map<String, dynamic>),
    ],
    closing: [
      for (final b in j['closing'] as List)
        SutraBlock.fromJson(b as Map<String, dynamic>),
    ],
  );
}

class SutraMeta {
  const SutraMeta({
    required this.title,
    required this.translatorVi,
    required this.translatorHan,
    required this.translatorHanReviewed,
    required this.publisher,
    required this.publisherAddress,
    required this.publisherWebsite,
    required this.edition,
    required this.license,
    required this.permissionNote,
    required this.proofread,
  });

  final String title;
  final String translatorVi;
  final String translatorHan;
  final bool translatorHanReviewed;
  final String publisher;
  final String publisherAddress;
  final String publisherWebsite;
  final String edition;
  final String license;
  final String permissionNote;
  final bool proofread;

  factory SutraMeta.fromJson(Map<String, dynamic> j) => SutraMeta(
    title: j['title'] as String,
    translatorVi: j['translatorVi'] as String,
    translatorHan: j['translatorHan'] as String,
    translatorHanReviewed: j['translatorHanReviewed'] as bool? ?? false,
    publisher: j['publisher'] as String,
    publisherAddress: j['publisherAddress'] as String,
    publisherWebsite: j['publisherWebsite'] as String,
    edition: j['edition'] as String,
    license: j['license'] as String,
    permissionNote: j['permissionNote'] as String,
    proofread: j['proofread'] as bool? ?? false,
  );
}

class Sutra {
  Sutra({
    required this.meta,
    required this.opening,
    required this.volumes,
    required this.closing,
  });

  final SutraMeta meta;
  final SutraRite opening; // Khai Kinh
  final List<SutraVolume> volumes;
  final SutraRite closing; // Kết Kinh

  SutraVolume volume(String id) => volumes.firstWhere((v) => v.id == id);

  late final Map<String, SutraBlock> _blocks = {
    for (final s in [...opening.sections, ...closing.sections])
      for (final b in s.blocks) b.id: b,
    for (final v in volumes) ...{
      for (final c in v.chapters)
        for (final s in c.sections)
          for (final b in s.blocks) b.id: b,
      for (final b in v.closing) b.id: b,
    },
  };

  SutraBlock? block(String id) => _blocks[id];

  /// The dedication verse at the very end of the book (section "HỒI HƯỚNG").
  SutraSection get dedicationVerse =>
      closing.sections.firstWhere((s) => s.title == 'HỒI HƯỚNG');

  SutraSection get chantingDedication =>
      closing.sections.firstWhere((s) => s.title == 'PHÚNG KINH');
}
