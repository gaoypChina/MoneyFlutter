import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_context.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_toggle.dart';
import 'package:money/widgets/filter_input.dart';
import 'package:money/widgets/three_part_label.dart';

class ViewHeader extends StatelessWidget {
  final String title;
  final num itemCount;
  final ValueNotifier<List<int>> selectedItems;
  final String description;

  // Optional, used for multi-selection UX
  final ViewHeaderMultipleSelection? multipleSelection;

  final List<Widget> Function(bool)? getActionButtonsForSelectedItems;

  final VoidCallback? onAddMoneyObject;
  final VoidCallback? onMergeMoneyObject;
  final VoidCallback? onEditMoneyObject;
  final VoidCallback? onDeleteMoneyObject;

  final void Function(String)? onFilterChanged;

  final Widget? child;

  const ViewHeader({
    super.key,
    required this.title,
    required this.itemCount,
    required this.selectedItems,
    required this.description,

    // optionals
    this.multipleSelection,
    this.onFilterChanged,
    this.getActionButtonsForSelectedItems,
    this.onAddMoneyObject,
    this.onMergeMoneyObject,
    this.onEditMoneyObject,
    this.onDeleteMoneyObject,
    this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: selectedItems,
      builder: (final BuildContext context, final List<int> listOfSelectedItemIndex, final _ /*widget*/) {
        return buildViewHeaderContainer(
          context,
          _buildContent(context),
        );
      },
    );
  }

  static buildViewHeaderContainer(final BuildContext context, final Widget child) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: getColorTheme(context).surfaceContainerHighest,
          border: Border.all(color: getColorTheme(context).outline),
          // borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: child);
  }

  Widget _buildContent(final BuildContext context) {
    final List<Widget> widgets = [];

    widgets.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IntrinsicWidth(
              child: Row(
            children: [
              ThreePartLabel(text1: title, text2: getIntAsText(itemCount.toInt())),
            ],
          )),
          IntrinsicWidth(
              child: Text(description,
                  style: getTextTheme(context).bodySmall!.copyWith(color: getColorTheme(context).onSurfaceVariant))),
        ],
      ),
    );

    if (multipleSelection != null ||
        onAddMoneyObject != null ||
        (selectedItems.value.isNotEmpty && getActionButtonsForSelectedItems != null)) {
      final listOfActionButtons = getActionButtonsForSelectedItems!(false);

      // Multiple-Selection
      if (multipleSelection != null) {
        listOfActionButtons.insert(
          0,
          MultipleSelectionToggle(
            multipleSelection: multipleSelection,
          ),
        );
      }

      widgets.add(
        IntrinsicWidth(
          child: SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: listOfActionButtons,
            ),
          ),
        ),
      );
    }

    if (child != null) {
      widgets.add(child!);
    }

    if (onFilterChanged != null) {
      widgets.add(
        SizedBox(
          width: 200,
          child: FilterInput(
              hintText: 'Filter',
              onChanged: (final String text) {
                onFilterChanged!(text);
              }),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10.0, // Adjust spacing between child elements
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            children: widgets,
          ),
        ),
      ],
    );
  }
}
