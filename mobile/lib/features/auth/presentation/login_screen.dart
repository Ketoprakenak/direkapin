import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/router/router.dart';
import '../providers/auth_providers.dart';
import 'validators.dart';
import 'widgets/auth_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(authRepositoryProvider)
        .login(email: _email.text.trim(), password: _password.text);
    ref.read(sessionProvider.notifier).markLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Masuk ke Direkapin',
      submitLabel: 'Masuk',
      onSubmit: _submit,
      fields: [
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
          autofillHints: const [AutofillHints.password],
          validator: validateLoginPassword,
        ),
      ],
      footer: TextButton(
        onPressed: () => context.goNamed(Routes.register),
        child: const Text('Belum punya akun? Daftar'),
      ),
    );
  }
}
