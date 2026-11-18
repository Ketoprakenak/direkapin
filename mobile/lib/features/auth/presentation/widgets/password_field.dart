import 'package:flutter/material.dart';

/// Kolom password dengan tombol mata untuk mengecek isinya.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    this.controller,
    this.autofillHints,
    this.textInputAction,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _hidden,
    autofillHints: widget.autofillHints,
    textInputAction: widget.textInputAction,
    validator: widget.validator,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Tampilkan password' : 'Sembunyikan password',
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        ),
      ),
    ),
  );
}
