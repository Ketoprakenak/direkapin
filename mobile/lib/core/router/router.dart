import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/shell/presentation/app_shell.dart';

part 'router.g.dart';

abstract final class Routes {
  static const home = 'home';
  static const calendar = 'calendar';
  static const reports = 'reports';
  static const profile = 'profile';
}

GoRoute _tab(String path, String name, String title) => GoRoute(
  path: path,
  name: name,
  builder: (context, state) => EmptyTab(title: title),
);

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  initialLocation: '/beranda',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [_tab('/beranda', Routes.home, 'Beranda')],
        ),
        StatefulShellBranch(
          routes: [_tab('/kalender', Routes.calendar, 'Kalender')],
        ),
        StatefulShellBranch(
          routes: [_tab('/laporan', Routes.reports, 'Laporan')],
        ),
        StatefulShellBranch(
          routes: [_tab('/profil', Routes.profile, 'Profil')],
        ),
      ],
    ),
  ],
);
