import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sutra/data/sutra_repository.dart';
import '../../features/sutra/domain/sutra_models.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Small caps-like label above a group.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding:
        padding ??
        const EdgeInsets.fromLTRB(Space.m, Space.l, Space.m, Space.s),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        letterSpacing: 1.6,
        color: context.palette.textMuted,
      ),
    ),
  );
}

class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Space.l),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: context.palette.textMuted, height: 1.5),
    ),
  );
}

/// Thin decorative divider: a line with a small circle (Enso-like) in the middle.
class QuietDivider extends StatelessWidget {
  const QuietDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.l),
      child: Row(
        children: [
          Expanded(child: Divider(color: p.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.m),
            child: Icon(Icons.circle_outlined, size: 10, color: p.accent),
          ),
          Expanded(child: Divider(color: p.border)),
        ],
      ),
    );
  }
}

/// Builds [builder] once the sutra JSON is loaded.
class SutraBuilder extends ConsumerWidget {
  const SutraBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, Sutra sutra) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(sutraProvider)
      .when(
        data: (s) => builder(context, s),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        error: (e, _) => EmptyNote('Không mở được Kinh: $e'),
      );
}

/// A verse from the book, line breaks preserved, centred.
class VerseText extends StatelessWidget {
  const VerseText(this.text, {super.key, this.fontSize = 18});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: Fonts.serif,
      fontSize: fontSize,
      height: 1.8,
      fontStyle: FontStyle.italic,
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String? confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? S.confirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void showQuietSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
