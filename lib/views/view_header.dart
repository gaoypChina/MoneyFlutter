import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/settings.dart';
import 'package:money/widgets/filter_input.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_context.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_toggle.dart';
import 'package:money/widgets/three_part_label.dart';

class ViewHeader extends StatelessWidget {
  final String title;
  final num count;
  final String description;

  // Optional, used for multi-selection UX
  final ViewHeaderMultipleSelection? multipleSelection;

  final void Function(String)? onFilterChanged;
  final VoidCallback? onAddNewEntry;

  final Widget? child;

  const ViewHeader({
    super.key,
    required this.title,
    required this.count,
    required this.description,

    // optionals
    this.multipleSelection,
    this.onFilterChanged,
    this.onAddNewEntry,
    this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return buildViewHeaderContainer(
      context,
      Settings().isSmallScreen ? _buildSmall(context) : _buildLarge(context),
    );
  }

  static buildViewHeaderContainer(final BuildContext context, final Widget child) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: getColorTheme(context).surfaceVariant,
          border: Border.all(color: getColorTheme(context).outline),
          // borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: child);
  }

  Widget _buildLarge(final BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10.0, // Adjust spacing between child elements
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IntrinsicWidth(
                      child: Row(
                    children: [
                      ThreePartLabel(text1: title, text2: getIntAsText(count.toInt())),
                      if (onAddNewEntry != null)
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAddNewEntry)
                    ],
                  )),
                  IntrinsicWidth(
                      child: Text(description,
                          style: getTextTheme(context)
                              .bodySmall!
                              .copyWith(color: getColorTheme(context).onSurfaceVariant))),
                ],
              ),
              if (child != null) child!,
              if (multipleSelection != null) MultipleSelectionToggle(multipleSelection: multipleSelection),
              if (onFilterChanged != null)
                SizedBox(
                  width: 200,
                  child: FilterInput(
                      hintText: 'Filter',
                      onChanged: (final String text) {
                        onFilterChanged!(text);
                      }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmall(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: ThreePartLabel(text1: title, text2: getIntAsText(count.toInt())),
            ),
          ),
        ],
      ),
    );
  }
}
