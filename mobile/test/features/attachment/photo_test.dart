import 'dart:io';
import 'dart:typed_data';

import 'package:direkapin/core/media/photo_service.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/attachment/data/attachment_models.dart';
import 'package:direkapin/features/attachment/presentation/photo_viewer_screen.dart';
import 'package:direkapin/features/transaction/data/transaction_models.dart';
import 'package:direkapin/features/transaction/presentation/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

class _FakePhotos implements PhotoService {
  _FakePhotos(this.path);

  final String? path;

  @override
  Future<String?> pick(ImageSource source) async {
    final result = path;
    if (result == null) throw Exception('izin ditolak');
    return result;
  }
}

Map<String, Object?> attachmentJson(String id, {bool archived = false}) => {
  'id': id,
  'thumbUrl': '/api/v1/attachments/$id?size=thumb',
  'fullUrl': archived ? null : '/api/v1/attachments/$id?size=full',
  'isArchived': archived,
  'archiveMonth': archived ? '2026-09' : null,
  'width': 800,
  'height': 600,
  'sizeBytes': 1000,
  'createdAt': '2026-11-04T02:30:00.000Z',
};

Map<String, Object?> transactionJson(
  List<Map<String, Object?>> attachments,
) => {
  'id': 't1',
  'type': 'EXPENSE',
  'amount': 25000,
  'occurredAt': '2026-11-04T02:30:00.000Z',
  'note': null,
  'wallet': {'id': 'w1', 'name': 'Cash', 'icon': 'x', 'color': '#14B8A6'},
  'category': {'id': 'c1', 'name': 'Makan', 'icon': 'x', 'color': '#F97316'},
  'attachments': attachments,
};

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('compressUntilSmall', () {
    XFile sized(int bytes) => XFile.fromData(Uint8List(bytes));

    test('berhenti di kualitas pertama yang cukup kecil', () async {
      final tried = <int>[];
      final result = await compressUntilSmall((quality) async {
        tried.add(quality);
        return sized(quality == 70 ? maxPhotoBytes : maxPhotoBytes + 1);
      });
      expect(tried, [80, 70]);
      expect(await result!.length(), maxPhotoBytes);
    });

    test('tetap memakai hasil kualitas 60 walau masih besar', () async {
      final tried = <int>[];
      final result = await compressUntilSmall((quality) async {
        tried.add(quality);
        return sized(maxPhotoBytes + quality);
      });
      expect(tried, [80, 70, 60]);
      expect(await result!.length(), maxPhotoBytes + 60);
    });

    test('kompres gagal mengembalikan null', () async {
      expect(await compressUntilSmall((_) async => null), isNull);
    });
  });

  test('Attachment terbaca dari JSON, termasuk yang diarsip', () {
    final attachment = Attachment.fromJson(
      attachmentJson('a1', archived: true),
    );
    expect(attachment.fullUrl, isNull);
    expect(attachment.isArchived, isTrue);
    expect(attachment.archiveMonth, '2026-09');
  });

  group('Form transaksi dengan foto', () {
    late String photoPath;

    setUpAll(() {
      final dir = Directory.systemTemp.createTempSync('direkapin-test');
      photoPath = '${dir.path}/foto.jpg';
      File(photoPath).writeAsBytesSync([1, 2, 3]);
    });

    FakeServer formServer() => FakeServer({
      '/dashboard': dashboardJson(),
      '/wallets': {
        'items': [walletJson('w1', 'Cash')],
        'totalBalance': 0,
      },
      '/categories': {
        'items': [categoryJson('c1', 'Makan')],
      },
      '/transactions': {'items': <Object>[], 'nextCursor': null},
    });

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    Future<void> addPhoto(WidgetTester tester) async {
      await tapText(tester, 'Tambah foto');
      await tapText(tester, 'Galeri');
    }

    Future<void> fillForm(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nominal'),
        '25000',
      );
      await tester.tap(find.text('Makan'));
      await tester.pump();
    }

    List<String> paths(FakeServer server) =>
        server.writes.map((write) => '${write.method} ${write.path}').toList();

    testWidgets('transaksi disimpan dulu, lalu fotonya diupload', (
      tester,
    ) async {
      final server = formServer();
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.transactionForm,
        photoService: _FakePhotos(photoPath),
      );
      await fillForm(tester);
      await addPhoto(tester);
      await tapText(tester, 'Simpan');

      expect(paths(server), ['POST /transactions', 'POST /attachments']);
      expect(find.text('Transaksi tersimpan'), findsOneWidget);
      expect(find.text('Tambah transaksi'), findsNothing);
    });

    testWidgets('upload gagal: "Coba lagi" tidak membuat transaksi kedua', (
      tester,
    ) async {
      final server = formServer()..failingPaths.add('/attachments');
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.transactionForm,
        photoService: _FakePhotos(photoPath),
      );
      await fillForm(tester);
      await addPhoto(tester);
      await tapText(tester, 'Simpan');

      expect(
        find.text('Foto gagal diupload. Transaksi tetap tersimpan.'),
        findsOneWidget,
      );
      expect(find.text('Simpan'), findsNothing);
      expect(find.text('Tambah transaksi'), findsOneWidget);

      server.failingPaths.clear();
      await tapText(tester, 'Coba lagi');

      expect(paths(server), [
        'POST /transactions',
        'POST /attachments',
        'POST /attachments',
      ]);
      expect(find.text('Transaksi tersimpan'), findsOneWidget);
      expect(find.text('Tambah transaksi'), findsNothing);
    });

    testWidgets('upload gagal: "Lewati" menutup form', (tester) async {
      final server = formServer()..failingPaths.add('/attachments');
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.transactionForm,
        photoService: _FakePhotos(photoPath),
      );
      await fillForm(tester);
      await addPhoto(tester);
      await tapText(tester, 'Simpan');
      await tapText(tester, 'Lewati');

      expect(find.text('Tambah transaksi'), findsNothing);
      expect(paths(server), ['POST /transactions', 'POST /attachments']);
    });

    testWidgets('upload gagal: tombol kembali menutup form tanpa kirim ulang', (
      tester,
    ) async {
      final server = formServer()..failingPaths.add('/attachments');
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.transactionForm,
        photoService: _FakePhotos(photoPath),
      );
      await fillForm(tester);
      await addPhoto(tester);
      await tapText(tester, 'Simpan');

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Tambah transaksi'), findsNothing);
      expect(paths(server), hasLength(2));
    });

    testWidgets('foto gagal diambil menampilkan pesan, form tetap utuh', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        formServer(),
        routeName: Routes.transactionForm,
        photoService: _FakePhotos(null),
      );
      await addPhoto(tester);

      expect(
        find.text(
          'Foto nggak bisa diambil. Cek izin kamera atau coba foto lain.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tambah foto'), findsOneWidget);
    });

    testWidgets('edit: foto lama dihapus baru setelah Simpan', (tester) async {
      final server = formServer();
      final transaction = Transaction.fromJson(
        transactionJson([attachmentJson('a1')]),
      );
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.transactionForm,
        extra: TransactionFormArgs(transaction: transaction),
      );

      await tester.ensureVisible(find.byTooltip('Hapus foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Hapus foto'));
      await tester.pumpAndSettle();
      expect(server.writes, isEmpty);

      await tapText(tester, 'Simpan');

      expect(paths(server), [
        'PATCH /transactions/t1',
        'DELETE /attachments/a1',
      ]);
    });

    testWidgets('sudah 3 foto: tombol tambah hilang', (tester) async {
      final transaction = Transaction.fromJson(
        transactionJson([
          attachmentJson('a1'),
          attachmentJson('a2'),
          attachmentJson('a3'),
        ]),
      );
      await pumpRoutedApp(
        tester,
        formServer(),
        routeName: Routes.transactionForm,
        extra: TransactionFormArgs(transaction: transaction),
      );
      expect(find.text('Tambah foto'), findsNothing);
    });

    testWidgets('mode Transfer tidak punya foto', (tester) async {
      await pumpRoutedApp(
        tester,
        formServer(),
        routeName: Routes.transactionForm,
      );
      expect(find.text('Tambah foto'), findsOneWidget);

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah foto'), findsNothing);
    });
  });

  group('Tampilan foto', () {
    testWidgets('Detail menampilkan galeri, tap membuka viewer', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        FakeServer({}),
        routeName: Routes.transactionDetail,
        extra: Transaction.fromJson(
          transactionJson([attachmentJson('a1'), attachmentJson('a2')]),
        ),
      );
      final second = find.bySemanticsLabel('Lihat foto 2 dari 2');
      expect(second, findsOneWidget);

      await tester.tap(second);
      await tester.pumpAndSettle();
      expect(find.text('Foto 2 dari 2'), findsOneWidget);
    });

    testWidgets('Detail tanpa foto tidak menampilkan galeri', (tester) async {
      await pumpRoutedApp(
        tester,
        FakeServer({}),
        routeName: Routes.transactionDetail,
        extra: Transaction.fromJson(transactionJson([])),
      );
      expect(find.bySemanticsLabel(RegExp('Lihat foto')), findsNothing);
    });

    testWidgets('foto diarsip memberi tahu bahwa yang tampil versi kecil', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        FakeServer({}),
        routeName: Routes.photoViewer,
        extra: PhotoViewerArgs(
          attachments: [
            Attachment.fromJson(attachmentJson('a1', archived: true)),
          ],
        ),
      );
      expect(find.textContaining('sudah pindah ke arsip'), findsOneWidget);
    });
  });
}
