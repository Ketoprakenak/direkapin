import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/api/api_client.dart';
import 'package:direkapin/core/api/api_error.dart';
import 'package:direkapin/core/auth/session_provider.dart';
import 'package:direkapin/core/notifications/reminder_service.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/auth/data/auth_repository.dart';
import 'package:direkapin/features/auth/providers/auth_providers.dart';
import 'package:direkapin/features/category/presentation/categories_screen.dart';
import 'package:direkapin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:direkapin/features/shell/presentation/animated_branch_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

class _OkAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('', 200);

  @override
  void close({bool force = false}) {}
}

class _FakeAuth implements AuthRepository {
  ApiException? failure;
  String? loginEmail;
  String? registerInvite;
  bool loggedOut = false;

  @override
  Future<void> login({required String email, required String password}) async {
    if (failure != null) throw failure!;
    loginEmail = email;
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    if (failure != null) throw failure!;
    registerInvite = inviteCode;
  }

  @override
  Future<void> logout() async => loggedOut = true;
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  late _FakeAuth auth;

  // Tema polos: google_fonts butuh jaringan, yang tidak ada di test.
  Future<void> pumpApp(WidgetTester tester, Map<String, String> stored) async {
    FlutterSecureStorage.setMockInitialValues(stored);
    auth = _FakeAuth();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          apiClientProvider.overrideWithValue(
            Dio(BaseOptions(baseUrl: 'https://example.test'))
              ..httpClientAdapter = _OkAdapter(),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          reminderServiceProvider.overrideWithValue(FakeReminderService()),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: testTheme,
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('sesi', () {
    testWidgets('tanpa token masuk ke Login', (tester) async {
      await pumpApp(tester, {});
      expect(find.text('Masuk ke Direkapin'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('punya token masuk ke Beranda dengan 4 tab', (tester) async {
      await pumpApp(tester, {'refreshToken': 'r'});
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.widgetWithText(AppBar, 'Beranda'), findsOneWidget);
    });

    testWidgets('tap tab berpindah layar', (tester) async {
      await pumpApp(tester, {'refreshToken': 'r'});
      for (final tab in ['Kalender', 'Laporan', 'Profil', 'Beranda']) {
        await tester.tap(find.widgetWithText(NavigationDestination, tab));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(AppBar, tab), findsOneWidget);
      }
    });

    testWidgets('Keluar kembali ke Login', (tester) async {
      await pumpApp(tester, {'refreshToken': 'r'});
      await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Keluar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(auth.loggedOut, isTrue);
      expect(find.text('Masuk ke Direkapin'), findsOneWidget);
    });

    testWidgets('sesi kedaluwarsa dari interceptor kembali ke Login', (
      tester,
    ) async {
      await pumpApp(tester, {'refreshToken': 'r'});
      final context = tester.element(find.byType(NavigationBar));
      ProviderScope.containerOf(context)
          .read(sessionProvider.notifier)
          .markLoggedOut();
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Direkapin'), findsOneWidget);
    });
  });

  group('transisi tab', () {
    Finder tab(String label) =>
        find.widgetWithText(NavigationDestination, label);

    Future<void> pumpHome(WidgetTester tester) => pumpRoutedApp(
      tester,
      FakeServer({
        '/dashboard': dashboardJson(
          wallets: [
            for (var i = 0; i < 12; i++) walletJson('w$i', 'Dompet $i'),
          ],
        ),
      }),
      routeName: null,
    );

    testWidgets('pindah tab menjaga posisi scroll Beranda', (tester) async {
      await pumpHome(tester);
      final list = find.byType(Scrollable).first;
      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
      final before = tester.state<ScrollableState>(list).position.pixels;
      expect(before, greaterThan(0));

      await tester.tap(tab('Kalender'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Beranda'));
      await tester.pumpAndSettle();

      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        before,
      );
    });

    testWidgets('tap tab cepat berturut-turut → tab terakhir tampil', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(tab('Kalender'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(tab('Laporan'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(tab('Profil'));
      await tester.pumpAndSettle();

      // Default finder melewati Offstage: hanya tab aktif yang terlihat.
      expect(find.widgetWithText(AppBar, 'Profil'), findsOneWidget);
      for (final other in ['Beranda', 'Kalender', 'Laporan']) {
        expect(find.widgetWithText(AppBar, other), findsNothing);
      }
      await tester.ensureVisible(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(find.text('Keluar').hitTestable(), findsOneWidget);
    });

    testWidgets('ke tab kanan: konten baru masuk dari kanan, lama ke kiri', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(tab('Kalender'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final offsets = tester
          .widgetList<SlideTransition>(
            find.descendant(
              of: find.byType(AnimatedBranchContainer),
              matching: find.byType(SlideTransition),
            ),
          )
          .map((s) => s.position.value.dx);
      expect(offsets.where((dx) => dx > 0), isNotEmpty);
      expect(offsets.where((dx) => dx < 0), isNotEmpty);
      await tester.pumpAndSettle();
    });

    testWidgets('pindah tab melepas fokus dari tab yang ditinggal', (
      tester,
    ) async {
      await pumpHome(tester);
      // Kunjungi Kalender dulu: kunjungan pertama membuat route baru yang
      // memang mengambil fokus, jadi tidak membuktikan apa-apa.
      await tester.tap(tab('Kalender'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Beranda'));
      await tester.pumpAndSettle();
      // Ambil FocusNode milik IconButton pertama di Beranda.
      final focus = find
          .descendant(
            of: find.byType(DashboardScreen),
            matching: find.byType(Focus),
          )
          .first;
      final node = Focus.of(
        createDependency: false,
        tester.element(
          find
              .descendant(
                of: focus,
                matching: find.byWidgetPredicate((_) => true),
              )
              .first,
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);

      // Lewat router, bukan tap: tap tombol nav sendiri bisa memindah fokus.
      ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
          .read(appRouterProvider)
          .goNamed(Routes.calendar);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Kalender'), findsOneWidget);

      expect(node.hasFocus, isFalse);
    });

    testWidgets('tap di tengah animasi: tab keluar lanjut dari kondisinya', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(tab('Kalender'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(tab('Laporan'));
      // Frame pertama: router memproses tap; frame kedua: animasi baru mulai.
      await tester.pump();
      await tester.pump();

      // Kalender (keluar) masih setengah tampak, tidak melompat ke opasitas 1.
      // Wrapper cabang = FadeTransition terluar di atas AppBar Kalender.
      final kalender = tester
          .widgetList<FadeTransition>(
            find.ancestor(
              of: find.widgetWithText(AppBar, 'Kalender'),
              matching: find.descendant(
                of: find.byType(AnimatedBranchContainer),
                matching: find.byType(FadeTransition),
              ),
            ),
          )
          .last
          .opacity
          .value;
      expect(kalender, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
    });

    Future<void> pushCategories(WidgetTester tester) async {
      await pumpHome(tester);
      unawaited(
        ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
            .read(appRouterProvider)
            .pushNamed(Routes.categories),
      );
      // Frame pertama: go_router memproses push; frame kedua: route terpasang.
      await tester.pump();
      await tester.pump();
    }

    Iterable<double> slidesAbove(WidgetTester tester, Finder finder) => tester
        .widgetList<SlideTransition>(
          find.ancestor(of: finder, matching: find.byType(SlideTransition)),
        )
        .map((s) => s.position.value.dx);

    testWidgets('layar dalam masuk dari kanan, layar bawah geser ke kiri', (
      tester,
    ) async {
      await pushCategories(tester);
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        slidesAbove(
          tester,
          find.byType(CategoriesScreen),
        ).where((dx) => dx > 0),
        isNotEmpty,
      );
      expect(
        slidesAbove(tester, find.byType(NavigationBar)).where((dx) => dx < 0),
        isNotEmpty,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('disableAnimations: layar dalam tanpa animasi', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pushCategories(tester);

      expect(find.byType(CategoriesScreen), findsOneWidget);
      expect(
        slidesAbove(
          tester,
          find.byType(CategoriesScreen),
        ).where((dx) => dx != 0),
        isEmpty,
      );
      expect(
        tester
            .widgetList<FadeTransition>(
              find.ancestor(
                of: find.byType(CategoriesScreen),
                matching: find.byType(FadeTransition),
              ),
            )
            .where((f) => f.opacity.value < 1),
        isEmpty,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('disableAnimations: pindah tab tanpa animasi', (tester) async {
      // Sama dengan setelan "kurangi animasi" HP: MediaQuery.disableAnimations.
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpHome(tester);

      await tester.tap(tab('Kalender'));
      await tester.pump();

      expect(find.widgetWithText(AppBar, 'Kalender'), findsOneWidget);
      final slides = tester.widgetList<SlideTransition>(
        find.descendant(
          of: find.byType(AnimatedBranchContainer),
          matching: find.byType(SlideTransition),
        ),
      );
      for (final slide in slides) {
        expect(slide.position.value, Offset.zero);
      }
      final fades = tester.widgetList<FadeTransition>(
        find.descendant(
          of: find.byType(AnimatedBranchContainer),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fades.where((f) => f.opacity.value < 1), isEmpty);
      await tester.pumpAndSettle();
    });
  });

  group('maskot ngintip', () {
    Finder tab(String label) =>
        find.widgetWithText(NavigationDestination, label);
    final mascot = find.byKey(const ValueKey('nav-peek-mascot'));

    Future<void> pumpHome(WidgetTester tester) => pumpRoutedApp(
      tester,
      FakeServer({'/dashboard': dashboardJson()}),
      routeName: null,
    );

    void expectAbove(WidgetTester tester, String label) => expect(
      tester.getCenter(mascot).dx,
      moreOrLessEquals(tester.getCenter(tab(label)).dx, epsilon: 2),
    );

    testWidgets('maskot ngintip berada di atas tab aktif', (tester) async {
      await pumpHome(tester);
      expect(mascot, findsOneWidget);
      expectAbove(tester, 'Beranda');
      // Menonjol ke atas dari tepi atas menu bawah.
      expect(
        tester.getTopLeft(mascot).dy,
        lessThan(tester.getTopLeft(find.byType(NavigationBar)).dy),
      );

      await tester.tap(tab('Laporan'));
      await tester.pumpAndSettle();
      expectAbove(tester, 'Laporan');
    });

    testWidgets('maskot tidak menghalangi tap', (tester) async {
      await pumpHome(tester);
      expect(
        find.ancestor(
          of: mascot,
          matching: find.byWidgetPredicate(
            (w) => w is IgnorePointer && w.ignoring,
          ),
        ),
        findsWidgets,
      );
      expect(
        find.ancestor(of: mascot, matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );

      await tester.tap(tab('Kalender'));
      await tester.pumpAndSettle();
      // Bagian bawah maskot menumpuk di atas tab Kalender.
      final point =
          tester.getCenter(mascot) +
          Offset(0, tester.getSize(mascot).height / 4);
      final hits = tester.hitTestOnBinding(point).path.map((e) => e.target);
      expect(
        hits,
        isNot(
          contains(
            tester.renderObject(
              find.descendant(of: mascot, matching: find.byType(CustomPaint)),
            ),
          ),
        ),
      );
      expect(hits, contains(tester.renderObject(tab('Kalender'))));
      await tester.tapAt(point);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Kalender'), findsOneWidget);
      expectAbove(tester, 'Kalender');
    });

    testWidgets('tanpa animasi saat disableAnimations', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpHome(tester);

      await tester.tap(tab('Profil'));
      await tester.pump();
      expectAbove(tester, 'Profil');
      await tester.pumpAndSettle();
    });
  });

  group('Login', () {
    testWidgets('form kosong menampilkan validasi tanpa memanggil server', (
      tester,
    ) async {
      await pumpApp(tester, {});
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pump();

      expect(find.text('Email tidak valid'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(auth.loginEmail, isNull);
    });

    testWidgets('berhasil masuk ke Beranda', (tester) async {
      await pumpApp(tester, {});
      await tester.enterText(field('Email'), ' uji@example.test ');
      await tester.enterText(field('Password'), 'rahasia123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(auth.loginEmail, 'uji@example.test');
      expect(find.widgetWithText(AppBar, 'Beranda'), findsOneWidget);
    });

    testWidgets('pesan server ditampilkan dan tetap di Login', (tester) async {
      await pumpApp(tester, {});
      auth.failure = const ApiException(
        'RATE_LIMITED',
        'Terlalu banyak percobaan. Coba lagi dalam 15 menit.',
      );
      await tester.enterText(field('Email'), 'uji@example.test');
      await tester.enterText(field('Password'), 'x');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(
        find.text('Terlalu banyak percobaan. Coba lagi dalam 15 menit.'),
        findsOneWidget,
      );
      expect(find.text('Masuk ke Direkapin'), findsOneWidget);
    });
  });

  group('Daftar', () {
    Future<void> openRegister(WidgetTester tester) async {
      await pumpApp(tester, {});
      await tester.tap(find.text('Belum punya akun? Daftar'));
      await tester.pumpAndSettle();
    }

    Future<void> fillAndSubmit(WidgetTester tester) async {
      await tester.enterText(field('Nama'), 'Desta');
      await tester.enterText(field('Email'), 'uji@example.test');
      await tester.enterText(field('Password'), 'rahasia123');
      await tester.enterText(field('Kode undangan'), ' ABC ');
      await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
      await tester.pumpAndSettle();
    }

    testWidgets('berhasil langsung masuk ke Beranda', (tester) async {
      await openRegister(tester);
      await fillAndSubmit(tester);

      expect(auth.registerInvite, 'ABC');
      expect(find.widgetWithText(AppBar, 'Beranda'), findsOneWidget);
    });

    testWidgets('kode salah menampilkan pesan server', (tester) async {
      await openRegister(tester);
      auth.failure = const ApiException(
        'INVITE_INVALID',
        'Kode undangan tidak valid',
      );
      await fillAndSubmit(tester);

      expect(find.text('Kode undangan tidak valid'), findsOneWidget);
      expect(find.text('Buat akun Direkapin'), findsOneWidget);
    });

    testWidgets('details validasi lebih diutamakan dari pesan umum', (
      tester,
    ) async {
      await openRegister(tester);
      auth.failure = const ApiException(
        'VALIDATION_ERROR',
        'Data belum valid',
        {'email': 'Email tidak valid'},
      );
      await fillAndSubmit(tester);

      expect(find.text('Email tidak valid'), findsOneWidget);
      expect(find.text('Data belum valid'), findsNothing);
    });
  });
}
