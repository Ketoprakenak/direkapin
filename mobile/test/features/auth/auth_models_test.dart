import 'package:direkapin/features/auth/data/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('membaca AuthTokens sesuai openapi.yaml', () {
    final tokens = AuthTokens.fromJson({
      'accessToken': 'a',
      'refreshToken': 'r',
      'expiresIn': 900,
      'user': {
        'id': '7b1f4a52-0000-4000-8000-000000000000',
        'name': 'Desta',
        'email': 'desta@example.test',
        'timezone': 'Asia/Jakarta',
        'reminderTime': '21:00',
        'hasAvatar': false,
        'createdAt': '2026-11-04T02:30:00.000Z',
      },
    });

    expect(tokens.expiresIn, 900);
    expect(tokens.user.name, 'Desta');
    expect(tokens.user.createdAt, DateTime.utc(2026, 11, 4, 2, 30));
    expect(tokens.user.createdAt.isUtc, isTrue);
  });
}
