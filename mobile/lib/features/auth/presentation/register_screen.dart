import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/router/router.dart';
import '../providers/auth_providers.dart';
import 'validators.dart';
import 'widgets/auth_form.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _inviteCode = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(authRepositoryProvider)
        .register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          inviteCode: _inviteCode.text.trim(),
        );
    ref.read(sessionProvider.notifier).markLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Buat akun Direkapin',
      submitLabel: 'Daftar',
      onSubmit: _submit,
      fields: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nama'),
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.next,
          validator: validateName,
        ),
        TextFormField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          validator: validateEmail,
        ),
        TextFormField(
          controller: _password,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          validator: validateNewPassword,
        ),
        TextFormField(
          controller: _inviteCode,
          decoration: const InputDecoration(labelText: 'Kode undangan'),
          validator: validateInviteCode,
        ),
      ],
      footer: TextButton(
        onPressed: () => context.goNamed(Routes.login),
        child: const Text('Sudah punya akun? Masuk'),
      ),
    );
  }
}
