// Aturan dan pesan: docs/PRD.md bagian 15.

String? validateName(String? value) {
  final length = (value ?? '').trim().length;
  if (length < 2) return 'Nama minimal 2 karakter';
  if (length > 50) return 'Nama maksimal 50 karakter';
  return null;
}

String? validateEmail(String? value) {
  final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim());
  return valid ? null : 'Email tidak valid';
}

String? validateNewPassword(String? value) {
  final password = value ?? '';
  final valid =
      password.length >= 8 &&
      password.contains(RegExp(r'[A-Za-z]')) &&
      password.contains(RegExp(r'\d'));
  return valid ? null : 'Password minimal 8 karakter dengan huruf dan angka';
}

String? validateLoginPassword(String? value) =>
    (value ?? '').isEmpty ? 'Password wajib diisi' : null;

String? validateInviteCode(String? value) =>
    (value ?? '').trim().isEmpty ? 'Kode undangan wajib diisi' : null;
