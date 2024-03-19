import 'package:flutter/material.dart';

class PickerLetters extends StatefulWidget {
  final List<String> options;
  final String? selected;
  final Function(String selectedValue) onSelected;
  final bool vertical;

  const PickerLetters({
    super.key,
    required this.options,
    this.selected,
    required this.onSelected,
    this.vertical = true,
  });

  @override
  State<PickerLetters> createState() => _PickerLettersState();
}

class _PickerLettersState extends State<PickerLetters> {
  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    for (final String option in widget.options) {
      final letter = option.isEmpty ? ' ' : option[0];
      final bool isSelected = widget.selected == letter;
      final theme = Theme.of(context);
      buttons.add(
        TextButton(
          onPressed: () {
            if (isSelected) {
              // already select, so unselected
              widget.onSelected('');
            } else {
              widget.onSelected(letter);
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            // Remove padding
            minimumSize: const Size(30, 20),
            maximumSize: const Size(30, 20),
            foregroundColor: isSelected ? theme.primaryColor : theme.dividerColor,
            backgroundColor: isSelected ? theme.dividerColor : theme.primaryColor,
          ),
          child: Text(letter, style: const TextStyle(fontSize: 8)),
        ),
      );
    }

    if (widget.vertical) {
      return Column(children: buttons);
    } else {
      return Row(children: buttons);
    }
  }
}
