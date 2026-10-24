import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget item(IconData icon, String title, String route) => ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.l,
        vertical: Space.xs,
      ),
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(route),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(S.tabMore)),
      body: ListView(
        children: [
          item(Icons.event_note_outlined, S.plans, '/them/thoi-khoa'),
          item(Icons.calendar_month_outlined, S.calendar, '/them/lich'),
          item(Icons.insights_outlined, S.journal, '/them/nhat-ky'),
          item(Icons.tune, S.settings, '/them/cai-dat'),
          item(Icons.info_outline, S.about, '/them/nguon-kinh'),
          const SizedBox(height: Space.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.l),
            child: Text(
              'Nam mô Đại Nguyện Địa Tạng Vương Bồ Tát',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
