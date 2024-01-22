import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

class TableRowCompact extends StatelessWidget {
  final String? leftTopAsString;
  final String? leftBottomAsString;
  final String? rightTopAsString;
  final String? rightBottomAsString;

  final Widget? leftTopAsWidget;
  final Widget? leftBottomAsWidget;
  final Widget? rightTopAsWidget;
  final Widget? rightBottomAsWidget;

  /// Constructor
  const TableRowCompact({
    super.key,
    this.leftTopAsString,
    this.leftBottomAsString,
    this.rightTopAsString,
    this.rightBottomAsString,
    this.leftTopAsWidget,
    this.leftBottomAsWidget,
    this.rightTopAsWidget,
    this.rightBottomAsWidget,
  });

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              either(
                leftTopAsWidget,
                leftTopAsString,
                Theme.of(context).textTheme.titleMedium,
                TextAlign.left,
              ),
              either(
                leftBottomAsWidget,
                leftBottomAsString,
                adjustOpacityOfTextStyle(Theme.of(context).textTheme.bodyMedium!),
                TextAlign.left,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            either(
              rightTopAsWidget,
              rightTopAsString,
              Theme.of(context).textTheme.titleLarge,
              TextAlign.right,
            ),
            either(
              rightBottomAsWidget,
              rightBottomAsString,
              adjustOpacityOfTextStyle(Theme.of(context).textTheme.bodyMedium!),
              TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  Widget either(
    final Widget? a,
    final String? b,
    final TextStyle? style,
    final TextAlign? align,
  ) {
    if (a != null) {
      return a;
    }
    if (b != null) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: 1,
        child: Text(
          b,
          overflow: TextOverflow.ellipsis,
          style: style,
          textAlign: align,
        ),
      );
    }
    return const Text('');
  }
}

Widget rowTile(final BuildContext context, final String text) {
  return Text(
    text,
    textAlign: TextAlign.left,
    style: Theme.of(context).textTheme.bodyLarge,
  );
}
