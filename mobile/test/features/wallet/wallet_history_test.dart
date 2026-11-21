import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/transaction/data/transaction_models.dart';
import 'package:direkapin/features/transaction/providers/transaction_providers.dart';
import 'package:direkapin/features/wallet/data/wallet_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

Map<String, Object?> _ref(String id, String name) => {
  'id': id,
  'name': name,
  'icon': 'account_balance_rounded',
  'color': '#3B82F6',
};

Map<String, Object?> _transaction(String id, int amount, String at) => {
  'id': id,
  'type': 'EXPENSE',
  'amount': amount,
  'occurredAt': at,
  'note': null,
  'wallet': _ref('w1', 'BCA'),
  'category': {
    'id': 'c1',
    'name': 'Makan',
    'icon': 'restaurant_rounded',
    'color': '#F97316',
  },
  'attachments': <Object>[],
  'receivableId': null,
  'createdAt': at,
  'updatedAt': at,
};

Map<String, Object?> _transfer(
  String id,
  String from,
  String to,
  int amount,
  String at,
) => {
  'id': id,
  'fromWallet': _ref(from, from == 'w1' ? 'BCA' : 'GoPay'),
  'toWallet': _ref(to, to == 'w1' ? 'BCA' : 'GoPay'),
  'amount': amount,
  'occurredAt': at,
  'note': null,
};

Transaction _tx(String id, String at) =>
    Transaction.fromJson(_transaction(id, 1000, at));
Transfer _tr(String id, String at) =>
    Transfer.fromJson(_transfer(id, 'w1', 'w2', 1000, at));

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  testWidgets('riwayat dompet: transfer keluar/masuk bertanda + saldo awal', (
    tester,
  ) async {
    final server = FakeServer({
      '/wallets': {
        'items': [
          {
            ...walletJson('w1', 'BCA', balance: 1350000),
            'initialBalance': 1700000,
          },
        ],
        'totalBalance': 1350000,
      },
      '/transactions': {
        'items': [_transaction('t1', 50000, '2026-11-10T05:00:00.000Z')],
        'nextCursor': null,
      },
      '/transfers': {
        'items': [
          _transfer('x1', 'w1', 'w2', 350000, '2026-11-12T05:00:00.000Z'),
          _transfer('x2', 'w2', 'w1', 50000, '2026-11-08T05:00:00.000Z'),
        ],
        'nextCursor': null,
      },
    });
    await pumpRoutedApp(
      tester,
      server,
      routeName: Routes.walletTransactions,
      pathParameters: {'id': 'w1'},
    );

    expect(find.text('Ke GoPay'), findsOneWidget);
    expect(find.text('−Rp350.000'), findsOneWidget);
    expect(find.text('Dari GoPay'), findsOneWidget);
    expect(find.text('+Rp50.000'), findsOneWidget);
    expect(find.text('Makan'), findsOneWidget);
    expect(find.text('−Rp50.000'), findsOneWidget);
    expect(find.text('Saldo awal'), findsOneWidget);
    expect(find.text('Rp1.700.000'), findsOneWidget);
    expect(find.text('Muat lagi'), findsNothing);
    expect(
      server.reads.where((u) => u.path == '/transfers').single.queryParameters,
      containsPair('wallet', 'w1'),
    );
  });

  testWidgets('Muat lagi: ambil halaman berikutnya lewat cursor', (
    tester,
  ) async {
    final server = FakeServer({
      '/transactions': {
        'items': [_transaction('t1', 50000, '2026-11-10T05:00:00.000Z')],
        'nextCursor': null,
      },
      '/transfers': {
        'items': [
          _transfer('x1', 'w1', 'w2', 350000, '2026-11-12T05:00:00.000Z'),
        ],
        'nextCursor': 'x1',
      },
    });
    await pumpRoutedApp(
      tester,
      server,
      routeName: Routes.walletTransactions,
      pathParameters: {'id': 'w1'},
    );
    // Transaksi lebih lama dari transfer terakhir ditahan sampai halaman berikutnya.
    expect(find.text('Makan'), findsNothing);
    expect(find.text('Saldo awal'), findsNothing);

    await tester.tap(find.text('Muat lagi'));
    await tester.pumpAndSettle();
    final transferReads = server.reads.where((u) => u.path == '/transfers');
    expect(transferReads.last.queryParameters, containsPair('cursor', 'x1'));
    expect(server.reads.where((u) => u.path == '/transactions'), hasLength(1));
  });

  test(
    'riwayat gabungan berhenti di item terakhir sumber yang belum habis',
    () {
      final history = WalletHistory(
        transactions: (
          items: [
            _tx('t1', '2026-11-10T00:00:00Z'),
            _tx('t2', '2026-11-01T00:00:00Z'),
          ],
          nextCursor: null,
        ),
        // Transfer masih ada halaman berikutnya; yang lebih lama dari x2 belum pasti urut.
        transfers: (
          items: [
            _tr('x1', '2026-11-12T00:00:00Z'),
            _tr('x2', '2026-11-05T00:00:00Z'),
          ],
          nextCursor: 'x2',
        ),
      );
      expect(history.hasMore, isTrue);
      expect(history.entries.map((e) => (e as dynamic).id), ['x1', 't1', 'x2']);

      final done = WalletHistory(
        transactions: history.transactions,
        transfers: (items: history.transfers.items, nextCursor: null),
      );
      expect(done.hasMore, isFalse);
      expect(done.entries.map((e) => (e as dynamic).id), [
        'x1',
        't1',
        'x2',
        't2',
      ]);
    },
  );
}
