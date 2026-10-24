import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/common.dart';
import '../data/reading_controller.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final bookmarks = ref.watch(readingProvider).bookmarks;
    return Scaffold(
      appBar: AppBar(title: const Text(S.bookmarks)),
      body: bookmarks.isEmpty
          ? const EmptyNote(
              '${S.bookmarksEmpty}\nNhấn giữ một đoạn Kinh để đánh dấu.',
            )
          : ListView.separated(
              itemCount: bookmarks.length,
              separatorBuilder: (_, _) =>
                  const Divider(indent: Space.m, endIndent: Space.m),
              itemBuilder: (context, i) {
                final b = bookmarks[i];
                return Dismissible(
                  key: ValueKey(b.blockId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      ref.read(readingProvider.notifier).toggleBookmark(b),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: Space.l),
                    child: Icon(Icons.delete_outline, color: p.textMuted),
                  ),
                  child: ListTile(
                    title: Text(
                      b.label,
                      style: TextStyle(fontSize: 13, color: p.accent),
                    ),
                    subtitle: Text(
                      b.preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: p.text,
                        height: 1.5,
                      ),
                    ),
                    trailing: Text(
                      formatDate(b.createdAt),
                      style: TextStyle(fontSize: 12, color: p.textMuted),
                    ),
                    onTap: () => context.go(
                      '/kinh/doc?at=${Uri.encodeQueryComponent(b.blockId)}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
