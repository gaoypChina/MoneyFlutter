import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/picker_panel.dart';

class PickerEditBox extends StatefulWidget {
  const PickerEditBox({
    required this.title,
    required this.items,
    required this.onChanged,
    this.onAddNew, // optional, allow to add new entries
    super.key,
    this.initialValue,
  });

  final String title;
  final List<String> items;
  final String? initialValue;
  final Function(String) onChanged;
  final Function(String)? onAddNew;

  @override
  PickerEditBoxState createState() => PickerEditBoxState();
}

class PickerEditBoxState extends State<PickerEditBox> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: getColorTheme(context).tertiaryContainer.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: getColorTheme(context).outline)),
        // borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onChanged: (final String value) {
                setState(() {
                  widget.onChanged(value);
                });
              },
            ),
          ),
          _buildrDropDownButton(),
          _buildrAddNew(),
        ],
      ),
    );
  }

  Widget _buildrDropDownButton() {
    return IconButton(
      onPressed: () {
        showPopupSelection(
          title: widget.title,
          context: context,
          items: widget.items,
          selectedItem: _textController.text,
          onSelected: (final String text) {
            setState(() {
              _textController.text = text;
              widget.onChanged(text);
            });
          },
        );
      },
      icon: const Icon(Icons.arrow_drop_down),
    );
  }

  Widget _buildrAddNew() {
    // Only show the Add New button if there's text not in the existing list of items
    if (widget.onAddNew == null || _textController.text.trim().isEmpty || widget.items.contains(_textController.text)) {
      return const SizedBox();
    }

    return IconButton(
      onPressed: () {
        widget.onAddNew?.call(_textController.text.trim());
      },
      icon: const Icon(Icons.add_circle_outline),
    );
  }
}
