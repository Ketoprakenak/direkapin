Map<String, Object?> recurringJson({String id = 'r1', int amount = 150000}) => {
  'id': id,
  'type': 'EXPENSE',
  'amount': amount,
  'note': null,
  'dayOfMonth': 5,
  'startMonth': '2026-11',
  'endMonth': null,
  'lastHandledMonth': null,
  'wallet': {
    'id': 'w1',
    'name': 'Cash',
    'icon': 'account_balance_wallet_rounded',
    'color': '#14B8A6',
  },
  'category': {
    'id': 'c1',
    'name': 'Listrik',
    'icon': 'restaurant_rounded',
    'color': '#F97316',
  },
  'next': {'month': '2026-11', 'dueDate': '2026-11-05'},
};
