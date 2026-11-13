import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/activity/data/activity_models.dart';
import '../../features/activity/presentation/activity_form_screen.dart';
import '../../features/archive/presentation/archive_screen.dart';
import '../../features/attachment/presentation/photo_viewer_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/category/presentation/categories_screen.dart';
import '../../features/settings/presentation/theme_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/day/presentation/day_screen.dart';
import '../../features/memories/presentation/memories_screen.dart';
import '../../features/recurring/data/recurring_models.dart';
import '../../features/recurring/presentation/recurring_form_screen.dart';
import '../../features/recurring/presentation/recurring_list_screen.dart';
import '../../features/report/presentation/category_transactions_screen.dart';
import '../../features/report/presentation/report_screen.dart';
import '../../features/report/presentation/wrapped_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/shell/presentation/animated_branch_container.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/transaction/data/transaction_models.dart';
import '../../features/transaction/presentation/item_detail_screen.dart';
import '../../features/transaction/presentation/transaction_form_screen.dart';
import '../../features/transaction/presentation/transaction_search_screen.dart';
import '../../features/transaction/presentation/wallet_transactions_screen.dart';
import '../../features/wallet/data/wallet_models.dart';
import '../../features/wallet/presentation/transfers_screen.dart';
import '../../features/wallet/presentation/wallets_screen.dart';
import '../auth/session_provider.dart';

part 'router.g.dart';

abstract final class Routes {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const home = 'home';
  static const calendar = 'calendar';
  static const reports = 'reports';
  static const profile = 'profile';
  static const transactionForm = 'transactionForm';
  static const wallets = 'wallets';
  static const walletTransactions = 'walletTransactions';
  static const transfers = 'transfers';
  static const categories = 'categories';
  static const themes = 'themes';
  static const day = 'day';
  static const transactionDetail = 'transactionDetail';
  static const transferDetail = 'transferDetail';
  static const photoViewer = 'photoViewer';
  static const activityForm = 'activityForm';
  static const activityDetail = 'activityDetail';
  static const categoryTransactions = 'categoryTransactions';
  static const archives = 'archives';
  static const transactionSearch = 'transactionSearch';
  static const budgets = 'budgets';
  static const recurring = 'recurring';
  static const recurringForm = 'recurringForm';
  static const wrapped = 'wrapped';
  static const memories = 'memories';
}

const _splashPath = '/';
const _loginPath = '/masuk';
const _registerPath = '/daftar';
const _forgotPath = '/lupa-password';
const _homePath = '/beranda';

// go_router 18 memeriksa MaterialApp dari package:material_ui, jadi rute
// `builder:` jatuh ke NoTransitionPage; MaterialPage memakai pageTransitionsTheme.
Page<void> _page(GoRouterState state, Widget child) =>
    MaterialPage<void>(key: state.pageKey, child: child);

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
      final onAuthScreen =
          location == _loginPath ||
          location == _registerPath ||
          location == _forgotPath;
      if (session.value != true) return onAuthScreen ? null : _loginPath;
      return onAuthScreen || location == _splashPath ? _homePath : null;
    },
    routes: [
      GoRoute(
        path: _splashPath,
        name: Routes.splash,
        pageBuilder: (context, state) => _page(state, const SplashScreen()),
      ),
      GoRoute(
        path: _loginPath,
        name: Routes.login,
        pageBuilder: (context, state) => _page(state, const LoginScreen()),
      ),
      GoRoute(
        path: _forgotPath,
        name: Routes.forgotPassword,
        pageBuilder: (context, state) =>
            _page(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: _registerPath,
        name: Routes.register,
        pageBuilder: (context, state) => _page(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/transaksi/baru',
        name: Routes.transactionForm,
        pageBuilder: (context, state) => _page(
          state,
          TransactionFormScreen(
            args:
                state.extra as TransactionFormArgs? ??
                const TransactionFormArgs(),
          ),
        ),
      ),
      GoRoute(
        path: '/transaksi/detail',
        name: Routes.transactionDetail,
        pageBuilder: (context, state) => _page(
          state,
          TransactionDetailScreen(transaction: state.extra! as Transaction),
        ),
      ),
      GoRoute(
        path: '/transfer/detail',
        name: Routes.transferDetail,
        pageBuilder: (context, state) => _page(
          state,
          TransferDetailScreen(transfer: state.extra! as Transfer),
        ),
      ),
      GoRoute(
        path: '/cari',
        name: Routes.transactionSearch,
        pageBuilder: (context, state) =>
            _page(state, const TransactionSearchScreen()),
      ),
      GoRoute(
        path: '/laporan/budget',
        name: Routes.budgets,
        pageBuilder: (context, state) =>
            _page(state, BudgetScreen(initialMonth: state.extra! as String)),
      ),
      GoRoute(
        path: '/berulang',
        name: Routes.recurring,
        pageBuilder: (context, state) =>
            _page(state, const RecurringListScreen()),
      ),
      GoRoute(
        path: '/berulang/form',
        name: Routes.recurringForm,
        pageBuilder: (context, state) =>
            _page(state, RecurringFormScreen(rule: state.extra as Recurring?)),
      ),
      GoRoute(
        path: '/kenangan',
        name: Routes.memories,
        pageBuilder: (context, state) =>
            _page(state, MemoriesScreen(initialMonth: state.extra as String?)),
      ),
      GoRoute(
        path: '/laporan/rekap',
        name: Routes.wrapped,
        pageBuilder: (context, state) =>
            _page(state, WrappedScreen(month: state.extra! as String)),
      ),
      GoRoute(
        path: '/laporan/kategori',
        name: Routes.categoryTransactions,
        pageBuilder: (context, state) => _page(
          state,
          CategoryTransactionsScreen(
            args: state.extra! as CategoryTransactionsArgs,
          ),
        ),
      ),
      GoRoute(
        path: '/kegiatan/baru',
        name: Routes.activityForm,
        pageBuilder: (context, state) => _page(
          state,
          ActivityFormScreen(
            args: state.extra as ActivityFormArgs? ?? const ActivityFormArgs(),
          ),
        ),
      ),
      GoRoute(
        path: '/kegiatan/detail',
        name: Routes.activityDetail,
        pageBuilder: (context, state) => _page(
          state,
          ActivityDetailScreen(activity: state.extra! as Activity),
        ),
      ),
      GoRoute(
        path: '/foto',
        name: Routes.photoViewer,
        pageBuilder: (context, state) => _page(
          state,
          PhotoViewerScreen(args: state.extra! as PhotoViewerArgs),
        ),
      ),
      GoRoute(
        path: '/hari/:date',
        name: Routes.day,
        pageBuilder: (context, state) =>
            _page(state, DayScreen(date: state.pathParameters['date']!)),
      ),
      GoRoute(
        path: '/arsip',
        name: Routes.archives,
        pageBuilder: (context, state) => _page(state, const ArchiveScreen()),
      ),
      GoRoute(
        path: '/dompet',
        name: Routes.wallets,
        pageBuilder: (context, state) => _page(state, const WalletsScreen()),
        routes: [
          GoRoute(
            path: ':id/transaksi',
            name: Routes.walletTransactions,
            pageBuilder: (context, state) => _page(
              state,
              WalletTransactionsScreen(
                walletId: state.pathParameters['id']!,
                walletName: state.uri.queryParameters['nama'] ?? 'Dompet',
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/transfer',
        name: Routes.transfers,
        pageBuilder: (context, state) => _page(state, const TransfersScreen()),
      ),
      GoRoute(
        path: '/kategori',
        name: Routes.categories,
        pageBuilder: (context, state) => _page(state, const CategoriesScreen()),
      ),
      GoRoute(
        path: '/tema',
        name: Routes.themes,
        pageBuilder: (context, state) => _page(state, const ThemeScreen()),
      ),
      StatefulShellRoute(
        pageBuilder: (context, state, shell) =>
            _page(state, AppShell(shell: shell)),
        navigatorContainerBuilder: (context, shell, children) =>
            AnimatedBranchContainer(
              currentIndex: shell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: _homePath,
                name: Routes.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kalender',
                name: Routes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/laporan',
                name: Routes.reports,
                builder: (context, state) => const ReportScreen(),
              ),
            ],
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
