import 'package:flutter/material.dart';

import '../../../../core/api/api_error.dart';
import '../../../../core/theme/tokens.dart';

/// Kerangka form Login dan Daftar: validasi, state loading, dan pesan error.
class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.title,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    required this.footer,
  });

  final String title;
  final List<Widget> fields;
  final String submitLabel;
  final Future<void> Function() onSubmit;
  final Widget footer;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.details.values.firstOrNull ?? e.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.xxl),
                Text(widget.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: Spacing.xl),
                for (final field in widget.fields) ...[
                  field,
                  const SizedBox(height: Spacing.md),
                ],
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                ],
                const SizedBox(height: Spacing.sm),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: Spacing.xl,
                          child: CircularProgressIndicator(),
                        )
                      : Text(widget.submitLabel),
                ),
                const SizedBox(height: Spacing.sm),
                widget.footer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
