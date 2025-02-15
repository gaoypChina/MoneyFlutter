import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class QuantityWidget extends StatelessWidget {
  /// Constructor
  const QuantityWidget({
    required this.quantity,
    super.key,
    this.align = TextAlign.right,
  });

  final TextAlign align;

  /// Amount to display
  final double quantity;

  @override
  Widget build(final BuildContext context) {
    final style = TextStyle(
      fontFamily: 'RobotoMono',
      color: getTextColorToUseQuantity(quantity),
      fontWeight: FontWeight.w900,
    );

    final originalString = formatDoubleUpToFiveZero(quantity, showPlusSign: true);

    final leftSideOfDecimalPoint = quantity.truncate();
    final leftSideOfDecimalPointAsString =
        formatDoubleUpToFiveZero(leftSideOfDecimalPoint.toDouble(), showPlusSign: true);
    final rightOfDecimalPoint = originalString.substring(leftSideOfDecimalPointAsString.length);

    return SelectableText.rich(
      maxLines: 1,
      textAlign: align,
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: leftSideOfDecimalPointAsString,
          ),
          if (rightOfDecimalPoint.isNotEmpty)
            TextSpan(
              text: rightOfDecimalPoint,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
