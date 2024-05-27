import 'package:flutter/material.dart';

class FilterInput extends StatelessWidget {
  final String hintText;
  final String initialValue;
  final Function(String) onChanged;

  const FilterInput({
    super.key,
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        labelText: hintText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
