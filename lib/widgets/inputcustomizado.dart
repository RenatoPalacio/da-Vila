import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatelessWidget {

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) validator;
  final Function(String) onSaved;
  final Function(String) onChanged;
  final String initialValue;
  final String labelText;
  final String prefixText;

  InputCustomizado({
    @required this.controller,
    @required this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.type = TextInputType.text,
    this.inputFormatters,
    this.maxLines,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.initialValue,
    this.labelText,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: this.obscure,
      autofocus: this.autofocus,
      keyboardType: this.type,
      inputFormatters: this.inputFormatters,
      validator: this.validator,
      maxLines: this.maxLines,
      onSaved: this.onSaved,
      onChanged: this.onChanged,
      initialValue: this.initialValue,
      style: TextStyle(fontSize: 17),
      decoration: InputDecoration(
          prefixText: this.prefixText,
          labelText: this.labelText,
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: this.hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6)
          )
      ),
    );
  }
}
