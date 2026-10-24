import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../domain/reader_document.dart';
import '../domain/sutra_models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  ReaderDocument? _doc;

  ReaderDocument _docFor(Sutra sutra) =>
      _doc ??= buildDocument(sutra, allParts);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: S.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          style: const TextStyle(fontFamily: Fonts.serif, fontSize: 18),
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: SutraBuilder(
        builder: (context, sutra) {
          final hits = searchDocument(_docFor(sutra), _query);
          if (_query.trim().length < 2) return const SizedBox.shrink();
          if (hits.isEmpty) return const EmptyNote(S.searchEmpty);
          return ListView.separated(
            itemCount: hits.length + 1,
            separatorBuilder: (_, _) =>
                const Divider(indent: Space.m, endIndent: Space.m),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.m,
                    Space.s,
                    Space.m,
                    Space.s,
                  ),
                  child: Text(
                    '${hits.length} kết quả',
                    style: TextStyle(color: p.textMuted, fontSize: 14),
                  ),
                );
              }
              final hit = hits[i - 1];
              return ListTile(
                title: Text(
                  hit.item.context,
                  style: TextStyle(fontSize: 13, color: p.accent),
                ),
                subtitle: Text(
                  hit.snippet,
                  style: TextStyle(fontSize: 15, color: p.text, height: 1.5),
                ),
                onTap: () => context.go(
                  '/kinh/doc?at=${Uri.encodeQueryComponent(hit.item.anchorId)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
