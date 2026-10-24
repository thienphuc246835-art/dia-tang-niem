import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/strings.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/chant/presentation/chant_screen.dart';
import '../features/chant/presentation/plans_screen.dart';
import '../features/dedication/presentation/dedication_screen.dart';
import '../features/dedication/presentation/person_detail_screen.dart';
import '../features/dedication/presentation/person_form_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/more/more_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/settings_controller.dart';
import '../features/settings/settings_screen.dart';
import '../features/sutra/presentation/bookmarks_screen.dart';
import '../features/sutra/presentation/reader_screen.dart';
import '../features/sutra/presentation/search_screen.dart';
import '../features/sutra/presentation/sutra_home_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  GoRoute fullScreen(
    String path,
    Widget Function(GoRouterState s) build, {
    List<RouteBase> routes = const [],
  }) => GoRoute(
    path: path,
    parentNavigatorKey: _rootKey,
    builder: (context, state) => build(state),
    routes: routes,
  );

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/niem',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/niem', builder: (_, _) => const ChantScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kinh',
                builder: (_, _) => const SutraHomeScreen(),
                routes: [
                  fullScreen(
                    'doc',
                    (s) => ReaderScreen(
                      key: ValueKey(s.uri.toString()),
                      ritual: s.uri.queryParameters['ritual'],
                      anchor: s.uri.queryParameters['at'],
                    ),
                  ),
                  fullScreen('tim', (_) => const SearchScreen()),
                  fullScreen('danh-dau', (_) => const BookmarksScreen()),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/hoi-huong',
                builder: (_, _) => const DedicationScreen(),
                routes: [
                  fullScreen('them', (_) => const PersonFormScreen()),
                  fullScreen(
                    'nguoi/:id',
                    (s) =>
                        PersonDetailScreen(personId: s.pathParameters['id']!),
                    routes: [
                      fullScreen(
                        'sua',
                        (s) =>
                            PersonFormScreen(personId: s.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/them',
                builder: (_, _) => const MoreScreen(),
                routes: [
                  fullScreen('thoi-khoa', (_) => const PlansScreen()),
                  fullScreen('lich', (_) => const CalendarScreen()),
                  fullScreen('nhat-ky', (_) => const JournalScreen()),
                  fullScreen('cai-dat', (_) => const SettingsScreen()),
                  fullScreen('nguon-kinh', (_) => const AboutScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _Shell extends ConsumerStatefulWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  bool? _awake;

  /// Keep the screen on only while the Niệm tab is showing (if enabled in settings).
  void _syncWakelock() {
    final want =
        widget.shell.currentIndex == 0 && ref.read(settingsProvider).keepAwake;
    if (want == _awake) return;
    _awake = want;
    WakelockPlus.toggle(enable: want).catchError((_) {});
  }

  @override
  void dispose() {
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider.select((s) => s.keepAwake));
    _syncWakelock();
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.shell.currentIndex,
        onDestinationSelected: (i) => widget.shell.goBranch(
          i,
          initialLocation: i == widget.shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.adjust),
            label: S.tabChant,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: S.tabSutra,
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: S.tabDedication,
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: S.tabMore),
        ],
      ),
    );
  }
}
