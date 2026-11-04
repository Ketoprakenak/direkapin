import 'package:direkapin/features/auth/presentation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nama 2-50 karakter setelah di-trim', () {
    expect(validateName('Ab'), isNull);
    expect(validateName(' A '), 'Nama minimal 2 karakter');
    expect(validateName('a' * 50), isNull);
    expect(validateName('a' * 51), 'Nama maksimal 50 karakter');
    expect(validateName(null), isNotNull);
  });

  test('format email', () {
    expect(validateEmail('a@b.co'), isNull);
    expect(validateEmail(' a@b.co '), isNull);
    expect(validateEmail('a@b'), 'Email tidak valid');
    expect(validateEmail('a b@c.co'), 'Email tidak valid');
    expect(validateEmail(''), 'Email tidak valid');
  });

  test('password baru minimal 8 karakter dengan huruf dan angka', () {
    const message = 'Password minimal 8 karakter dengan huruf dan angka';
    expect(validateNewPassword('rahasia12'), isNull);
    expect(validateNewPassword('rahas1a'), message);
    expect(validateNewPassword('hanyahuruf'), message);
    expect(validateNewPassword('12345678'), message);
  });

  test('password login dan kode undangan wajib diisi', () {
    expect(validateLoginPassword('x'), isNull);
    expect(validateLoginPassword(''), isNotNull);
    expect(validateInviteCode(' ABC '), isNull);
    expect(validateInviteCode('   '), isNotNull);
  });
}
