import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/router.dart';
import '../providers/auth_providers.dart';
import 'validators.dart';
import 'widgets/auth_form.dart';

/// Lupa password (AUTH-06, D-75): email → kode 6 angka + password baru.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    await ref.read(authRepositoryProvider).forgotPassword(_email.text.trim());
    if (mounted) setState(() => _codeSent = true);
  }

  Future<void> _reset() async {
    await ref
        .read(authRepositoryProvider)
        .resetPassword(
          email: _email.text.trim(),
          code: _code.text.trim(),
          newPassword: _password.text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password diganti. Silakan masuk.')),
    );
    context.goNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final back = TextButton(
      onPressed: () => context.goNamed(Routes.login),
      child: const Text('Kembali ke Masuk'),
    );
    if (!_codeSent) {
      return AuthForm(
        key: const ValueKey('email'),
        title: 'Lupa password',
        submitLabel: 'Kirim kode',
        onSubmit: _sendCode,
        fields: [
          const Text('Kami kirim kode 6 angka ke email akunmu.'),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: validateEmail,
          ),
        ],
        footer: back,
      );
    }
    return AuthForm(
      key: const ValueKey('reset'),
      title: 'Masukkan kode',
      submitLabel: 'Ganti password',
      onSubmit: _reset,
      fields: [
        Text(
          'Kalau ${_email.text.trim()} terdaftar, kodenya sudah dikirim. '
          'Cek juga folder spam. Kode berlaku 15 menit.',
        ),
        TextFormField(
          controller: _code,
          decoration: const InputDecoration(labelText: 'Kode 6 angka'),
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofillHints: const [AutofillHints.oneTimeCode],
          validator: (value) =>
              RegExp(r'^\d{6}$').hasMatch((value ?? '').trim())
              ? null
              : 'Kode harus 6 angka',
        ),
        TextFormField(
          controller: _password,
          decoration: const InputDecoration(labelText: 'Password baru'),
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          validator: validateNewPassword,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Ulangi password baru'),
          obscureText: true,
          validator: (value) =>
              value == _password.text ? null : 'Password tidak sama',
        ),
      ],
      footer: Column(
        children: [
          TextButton(
            onPressed: () => setState(() {
              _codeSent = false;
              _code.clear();
            }),
            child: const Text('Kirim ulang kode'),
          ),
          back,
        ],
      ),
    );
  }
}
