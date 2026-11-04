import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../auth/session_provider.dart';

part 'router.g.dart';

abstract final class Routes {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const calendar = 'calendar';
  static const reports = 'reports';
  static const profile = 'profile';
}

const _splashPath = '/';
const _loginPath = '/masuk';
const _registerPath = '/daftar';
const _homePath = '/beranda';

GoRoute _tab(String path, String name, String title) => GoRoute(
  path: path,
  name: name,
  builder: (context, state) => EmptyTab(title: title),
);

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final sessionChanged = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => sessionChanged.value++);
  ref.onDispose(sessionChanged.dispose);

  return GoRouter(
    initialLocation: _splashPath,
    refreshListenable: sessionChanged,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      if (session.isLoading && !session.hasValue) {
        return location == _splashPath ? null : _splashPath;
      }
      final onAuthScreen = location == _loginPath || location == _registerPath;
      if (session.value != true) return onAuthScreen ? null : _loginPath;
      return onAuthScreen || location == _splashPath ? _homePath : null;
    },
    routes: [
      GoRoute(
        path: _splashPath,
        name: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: _loginPath,
        name: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: _registerPath,
        name: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [_tab(_homePath, Routes.home, 'Beranda')],
          ),
          StatefulShellBranch(
            routes: [_tab('/kalender', Routes.calendar, 'Kalender')],
          ),
          StatefulShellBranch(
            routes: [_tab('/laporan', Routes.reports, 'Laporan')],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profil',
                name: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
