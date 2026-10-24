import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';
import '../../core/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/common.dart';
import '../chant/data/chant_controller.dart';
import '../dedication/data/dedication_controller.dart';
import '../sutra/data/reading_controller.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDialog(
      context,
      title: '${S.clearData}?',
      body: S.clearDataBody,
      confirmLabel: S.delete,
    );
    if (!ok) return;
    await ref.read(localStoreProvider).clearAll();
    ref
      ..invalidate(settingsProvider)
      ..invalidate(chantProvider)
      ..invalidate(dedicationProvider)
      ..invalidate(readingProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final s = ref.watch(settingsProvider);
    final update = ref.read(settingsProvider.notifier).update;
    final mantras = ref.watch(mantrasProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text(S.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xl),
        children: [
          const SectionLabel(S.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.m),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(S.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(S.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(S.themeDark)),
              ],
              selected: {s.themeMode},
              onSelectionChanged: (v) =>
                  update((x) => x.copyWith(themeMode: v.first)),
            ),
          ),
          const SectionLabel(S.tabChant),
          SwitchListTile(
            title: const Text(S.haptic),
            value: s.haptic,
            onChanged: (v) => update((x) => x.copyWith(haptic: v)),
          ),
          SwitchListTile(
            title: const Text(S.keepAwake),
            value: s.keepAwake,
            onChanged: (v) => update((x) => x.copyWith(keepAwake: v)),
          ),
          SwitchListTile(
            title: const Text(S.tapAnywhere),
            subtitle: const Text(S.tapAnywhereHint),
            value: s.tapAnywhere,
            onChanged: (v) => update((x) => x.copyWith(tapAnywhere: v)),
          ),
          ListTile(
            title: const Text(S.dailyGoalSetting),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: Wrap(
                spacing: Space.s,
                runSpacing: Space.xs,
                children: [
                  for (final g in [0, 108, 1000, 3000, 10000])
                    ChoiceChip(
                      label: Text(g == 0 ? S.noGoal : formatCount(g)),
                      selected: s.dailyGoal == g,
                      onSelected: (_) =>
                          update((x) => x.copyWith(dailyGoal: g)),
                    ),
                ],
              ),
            ),
          ),
          if (mantras.isNotEmpty)
            ListTile(
              title: const Text(S.defaultMantra),
              subtitle: DropdownButton<String>(
                isExpanded: true,
                value: mantras.any((m) => m.id == s.defaultMantraId)
                    ? s.defaultMantraId
                    : mantras.first.id,
                underline: const SizedBox.shrink(),
                items: [
                  for (final m in mantras)
                    DropdownMenuItem(
                      value: m.id,
                      child: Text(m.text, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  update((x) => x.copyWith(defaultMantraId: v));
                  ref.read(chantProvider.notifier).selectMantra(v);
                },
              ),
            ),
          const SectionLabel('Dữ liệu'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.m),
            child: Text(
              S.privacyNote,
              style: TextStyle(color: p.textMuted, fontSize: 14, height: 1.5),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              S.clearData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _clearAll(context, ref),
          ),
        ],
      ),
    );
  }
}
