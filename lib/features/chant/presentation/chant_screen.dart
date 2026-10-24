import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/common.dart';
import '../../dedication/domain/dedication_models.dart';
import '../../dedication/presentation/dedication_sheet.dart';
import '../../settings/settings_controller.dart';
import '../data/chant_controller.dart';
import '../domain/chant_models.dart';
import 'chant_button.dart';

class ChantScreen extends ConsumerStatefulWidget {
  const ChantScreen({super.key});

  @override
  ConsumerState<ChantScreen> createState() => _ChantScreenState();
}

class _ChantScreenState extends ConsumerState<ChantScreen> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _tap() {
    final settings = ref.read(settingsProvider);
    final result = ref.read(chantProvider.notifier).tap();
    if (settings.haptic) {
      result.roundCompleted
          ? HapticFeedback.mediumImpact()
          : HapticFeedback.lightImpact();
    }
    if (result.goalReached) {
      showQuietSnack(context, S.goalReached);
    } else if (result.roundCompleted) {
      showQuietSnack(context, S.roundComplete);
    }
  }

  Future<void> _reset() async {
    if (ref.read(chantProvider).sessionCount == 0) return;
    final ok = await confirmDialog(
      context,
      title: S.resetConfirmTitle,
      body: S.resetConfirmBody,
    );
    if (ok) ref.read(chantProvider.notifier).resetSession();
  }

  Future<void> _finish(List<Mantra> mantras) async {
    final controller = ref.read(chantProvider.notifier);
    final plan = ref.read(chantProvider).activePlan(DateTime.now());
    final session = controller.finishSession();
    if (session == null) {
      showQuietSnack(context, S.nothingToFinish);
      return;
    }
    final mantra = mantras.where((m) => m.id == session.mantraId).firstOrNull;
    await showDedicationSheet(
      context,
      DedicationSource(
        type: DedicationSourceType.chant,
        sourceId: session.id,
        summary:
            '${formatCount(session.count)} ${S.unitBien}${mantra != null ? ' · ${mantra.text}' : ''}',
      ),
      preselected: plan?.personIds ?? const [],
    );
  }

  void _pickMantra(List<Mantra> mantras, String current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: Space.l),
        children: [
          const SectionLabel(
            S.chooseMantra,
            padding: EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.s),
          ),
          for (final m in mantras)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: Space.l),
              title: Text(m.text),
              subtitle: Text(m.source),
              trailing: m.id == current
                  ? Icon(Icons.check, color: context.palette.accent)
                  : null,
              onTap: () {
                ref.read(chantProvider.notifier).selectMantra(m.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final chant = ref.watch(chantProvider);
    final settings = ref.watch(settingsProvider);
    final mantras = ref.watch(mantrasProvider).value ?? const <Mantra>[];
    final mantra =
        mantras.where((m) => m.id == chant.mantraId).firstOrNull ??
        mantras.firstOrNull;
    final now = DateTime.now();
    final today = chant.todayCount(now);
    final plan = chant.activePlan(now);

    final body = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = math
              .min(constraints.maxWidth * 0.74, constraints.maxHeight * 0.46)
              .clamp(200.0, 340.0);
          return Column(
            children: [
              const SizedBox(height: Space.l),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: mantras.isEmpty
                    ? null
                    : () => _pickMantra(mantras, chant.mantraId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.l,
                    vertical: Space.s,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          mantra?.text ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontSize: 19,
                            color: p.text,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Icon(Icons.expand_more, size: 20, color: p.textMuted),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.l),
                child: Text(
                  S.greatVow,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: p.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ChantButton(
                    count: chant.sessionCount,
                    size: size,
                    onTap: _tap,
                  ),
                ),
              ),
              _Stats(
                today: today,
                lifetime: chant.lifetime,
                goal: settings.dailyGoal,
              ),
              if (plan != null) ...[
                const SizedBox(height: Space.s),
                TextButton(
                  onPressed: () => context.go('/them/thoi-khoa'),
                  child: Text(
                    '${S.planActive}: ${formatCount(plan.progress(chant.daily))} / ${formatCount(plan.target)}'
                    '  ·  ngày ${plan.dayNumber(now)}/${plan.days}',
                    style: TextStyle(color: p.accentSoft, fontSize: 14),
                  ),
                ),
              ],
              const SizedBox(height: Space.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _QuietAction(
                        icon: Icons.undo,
                        label: S.undo,
                        onTap: chant.sessionCount > 0
                            ? ref.read(chantProvider.notifier).undo
                            : null,
                      ),
                    ),
                    Expanded(
                      child: _QuietAction(
                        icon: Icons.refresh,
                        label: S.reset,
                        onTap: chant.sessionCount > 0 ? _reset : null,
                      ),
                    ),
                    Expanded(
                      child: _QuietAction(
                        icon: Icons.spa_outlined,
                        label: S.finish,
                        onTap: () => _finish(mantras),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.m),
            ],
          );
        },
      ),
    );

    // Space / Enter also count, for keyboards and the web build.
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _tap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: settings.tapAnywhere
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _tap,
                child: body,
              )
            : body,
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({
    required this.today,
    required this.lifetime,
    required this.goal,
  });

  final int today;
  final int lifetime;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = TextStyle(fontSize: 14, color: p.textMuted);
    return Column(
      children: [
        Text(
          goal > 0
              ? '${S.today} ${formatCount(today)} / ${formatCount(goal)}'
              : '${S.today} ${formatCount(today)}',
          style: style,
        ),
        if (goal > 0)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 96,
              vertical: Space.s,
            ),
            child: LinearProgressIndicator(
              value: (today / goal).clamp(0, 1),
              minHeight: 2,
              backgroundColor: p.border,
              color: p.accentSoft,
            ),
          ),
        const SizedBox(height: Space.xs),
        Text('${S.lifetime} ${formatCount(lifetime)}', style: style),
      ],
    );
  }
}

class _QuietAction extends StatelessWidget {
  const _QuietAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null
        ? context.palette.border
        : context.palette.textMuted;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s,
            vertical: Space.s,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: Space.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
