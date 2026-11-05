import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/activity/data/activity_models.dart';
import '../../features/activity/presentation/activity_form_screen.dart';
import '../../features/attachment/presentation/photo_viewer_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/category/presentation/categories_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/day/presentation/day_screen.dart';
import '../../features/report/presentation/category_transactions_screen.dart';
import '../../features/report/presentation/report_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/transaction/data/transaction_models.dart';
import '../../features/transaction/presentation/item_detail_screen.dart';
import '../../features/transaction/presentation/transaction_form_screen.dart';
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
  static const home = 'home';
  static const calendar = 'calendar';
  static const reports = 'reports';
  static const profile = 'profile';
  static const transactionForm = 'transactionForm';
  static const wallets = 'wallets';
  static const walletTransactions = 'walletTransactions';
  static const transfers = 'transfers';
  static const categories = 'categories';
  static const day = 'day';
  static const transactionDetail = 'transactionDetail';
  static const transferDetail = 'transferDetail';
  static const photoViewer = 'photoViewer';
  static const activityForm = 'activityForm';
  static const activityDetail = 'activityDetail';
  static const categoryTransactions = 'categoryTransactions';
}

const _splashPath = '/';
const _loginPath = '/masuk';
const _registerPath = '/daftar';
const _homePath = '/beranda';

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
      GoRoute(
        path: '/transaksi/baru',
        name: Routes.transactionForm,
        builder: (context, state) => TransactionFormScreen(
          args:
              state.extra as TransactionFormArgs? ??
              const TransactionFormArgs(),
        ),
      ),
      GoRoute(
        path: '/transaksi/detail',
        name: Routes.transactionDetail,
        builder: (context, state) =>
            TransactionDetailScreen(transaction: state.extra! as Transaction),
      ),
      GoRoute(
        path: '/transfer/detail',
        name: Routes.transferDetail,
        builder: (context, state) =>
            TransferDetailScreen(transfer: state.extra! as Transfer),
      ),
      GoRoute(
        path: '/laporan/kategori',
        name: Routes.categoryTransactions,
        builder: (context, state) => CategoryTransactionsScreen(
          args: state.extra! as CategoryTransactionsArgs,
        ),
      ),
      GoRoute(
        path: '/kegiatan/baru',
        name: Routes.activityForm,
        builder: (context, state) => ActivityFormScreen(
          args: state.extra as ActivityFormArgs? ?? const ActivityFormArgs(),
        ),
      ),
      GoRoute(
        path: '/kegiatan/detail',
        name: Routes.activityDetail,
        builder: (context, state) =>
            ActivityDetailScreen(activity: state.extra! as Activity),
      ),
      GoRoute(
        path: '/foto',
        name: Routes.photoViewer,
        builder: (context, state) =>
            PhotoViewerScreen(args: state.extra! as PhotoViewerArgs),
      ),
      GoRoute(
        path: '/hari/:date',
        name: Routes.day,
        builder: (context, state) =>
            DayScreen(date: state.pathParameters['date']!),
      ),
      GoRoute(
        path: '/dompet',
        name: Routes.wallets,
        builder: (context, state) => const WalletsScreen(),
        routes: [
          GoRoute(
            path: ':id/transaksi',
            name: Routes.walletTransactions,
            builder: (context, state) => WalletTransactionsScreen(
              walletId: state.pathParameters['id']!,
              walletName: state.uri.queryParameters['nama'] ?? 'Dompet',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/transfer',
        name: Routes.transfers,
        builder: (context, state) => const TransfersScreen(),
      ),
      GoRoute(
        path: '/kategori',
        name: Routes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
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
