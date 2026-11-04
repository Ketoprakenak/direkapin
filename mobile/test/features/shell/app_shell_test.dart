import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/api/api_client.dart';
import 'package:direkapin/core/api/api_error.dart';
import 'package:direkapin/core/auth/session_provider.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/auth/data/auth_repository.dart';
import 'package:direkapin/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

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
  late _FakeAuth auth;

  // Tema polos: google_fonts butuh jaringan, yang tidak ada di test.
  Future<void> pumpApp(WidgetTester tester, Map<String, String> stored) async {
    FlutterSecureStorage.setMockInitialValues(stored);
    auth = _FakeAuth();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(
            Dio(BaseOptions(baseUrl: 'https://example.test'))
              ..httpClientAdapter = _OkAdapter(),
          ),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: Consumer(
          builder: (context, ref, _) =>
              MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
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
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(auth.loggedOut, isTrue);
      expect(find.text('Masuk ke Direkapin'), findsOneWidget);
    });

    testWidgets('sesi kedaluwarsa dari interceptor kembali ke Login', (tester) async {
      await pumpApp(tester, {'refreshToken': 'r'});
      final context = tester.element(find.byType(NavigationBar));
      ProviderScope.containerOf(context).read(sessionProvider.notifier).markLoggedOut();
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Direkapin'), findsOneWidget);
    });
  });

  group('Login', () {
    testWidgets('form kosong menampilkan validasi tanpa memanggil server', (tester) async {
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
      auth.failure = const ApiException('INVITE_INVALID', 'Kode undangan tidak valid');
      await fillAndSubmit(tester);

      expect(find.text('Kode undangan tidak valid'), findsOneWidget);
      expect(find.text('Buat akun Direkapin'), findsOneWidget);
    });

    testWidgets('details validasi lebih diutamakan dari pesan umum', (tester) async {
      await openRegister(tester);
      auth.failure = const ApiException('VALIDATION_ERROR', 'Data belum valid', {
        'email': 'Email tidak valid',
      });
      await fillAndSubmit(tester);

      expect(find.text('Email tidak valid'), findsOneWidget);
      expect(find.text('Data belum valid'), findsNothing);
    });
  });
}
