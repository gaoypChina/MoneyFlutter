import 'package:flutter/material.dart';
import 'package:money/widgets/gaps.dart';

class NumberPicker extends StatefulWidget {
  final String title;
  final int selectedNumber;
  final Function(int) onChanged;

  const NumberPicker({
    super.key,
    required this.title,
    required this.onChanged,
    required this.selectedNumber,
  });

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late int _selectedNumber = widget.selectedNumber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('${widget.title}:'),
          gapSmall(),
          DropdownButton<int>(
            value: _selectedNumber,
            items: List.generate(
                12,
                (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    )),
            onChanged: (int? value) {
              setState(() {
                _selectedNumber = value!;
                widget.onChanged(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
