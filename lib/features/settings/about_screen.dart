import 'package:flutter/material.dart';

import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/common.dart';

/// "Giới thiệu & Nguồn Kinh" — required by CLAUDE.md principle 5.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text(S.about)),
      body: SutraBuilder(
        builder: (context, sutra) {
          final m = sutra.meta;
          Widget row(String label, String value) => ListTile(
            title: Text(
              label,
              style: TextStyle(fontSize: 13, color: p.textMuted),
            ),
            subtitle: Text(
              value,
              style: TextStyle(fontSize: 16, color: p.text, height: 1.5),
            ),
          );
          return ListView(
            padding: const EdgeInsets.only(bottom: Space.xl),
            children: [
              const SizedBox(height: Space.l),
              Icon(Icons.circle_outlined, color: p.accent, size: 28),
              const SizedBox(height: Space.m),
              Text(
                S.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Space.s),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.l),
                child: Text(
                  S.freeDistribution,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.textMuted),
                ),
              ),
              const SectionLabel(S.sutraSource),
              row('Kinh', m.title),
              row('Việt dịch', m.translatorVi),
              // TODO(buddhist-review): the printed edition names a different Han translator than most
              // editions; shown only once a teacher has confirmed it (meta.translatorHanReviewed).
              if (m.translatorHanReviewed) row('Hán dịch', m.translatorHan),
              row(
                'Ấn tống',
                '${m.publisher}\n${m.publisherAddress}\n${m.publisherWebsite}',
              ),
              row('Phiên bản', m.edition),
              row('Điều kiện', m.license),
              if (!m.proofread)
                Padding(
                  padding: const EdgeInsets.all(Space.m),
                  child: Text(
                    'Kinh văn trong ứng dụng được chuyển từ bản PDF và đang chờ hiệu đính đối chiếu bản in. '
                    'Nếu thấy chỗ sai, xin vui lòng báo lại.',
                    style: TextStyle(
                      fontSize: 14,
                      color: p.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              const SectionLabel('Quyền riêng tư'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.m),
                child: Text(S.privacyNote, style: const TextStyle(height: 1.5)),
              ),
              const QuietDivider(),
              VerseText(
                sutra.dedicationVerse.blocks.map((b) => b.text).join('\n'),
                fontSize: 16,
              ),
            ],
          );
        },
      ),
    );
  }
}
