import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/settings.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class MoneyWidget extends StatelessWidget {
  /// Amount to display
  final MoneyModel amountModel;
  final bool asTile;

  /// Constructor
  const MoneyWidget({
    super.key,
    required this.amountModel,
    this.asTile = false,
  });

  @override
  Widget build(final BuildContext context) {
    if (amountModel.showCurrency) {
      return Row(
        children: [
          _amountAsText(context),
          const SizedBox(width: 10),
          Currency.buildCurrencyWidget(amountModel.iso4217),
        ],
      );
    } else {
      return _amountAsText(context);
    }
  }

  Widget _amountAsText(final BuildContext context) {
    return SelectableText(
      maxLines: 1,
      Currency.getAmountAsStringUsingCurrency(
        isAlmostZero(amountModel.amount) ? 0.00 : amountModel.amount,
        iso4217code: amountModel.iso4217,
      ),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        color: getTextColorToUse(amountModel.amount, amountModel.autoColor),
        fontSize: asTile ? getTextTheme(context).titleMedium!.fontSize : null,
      ),
    );
  }
}

Color? getTextColorToUse(
  final double amount,
  final bool autoColor,
) {
  final bool isDarkModeOne = Settings().useDarkMode;
  if (autoColor) {
    if (isAlmostZero(amount)) {
      return Colors.grey.withOpacity(0.8);
    }
    if (amount < 0) {
      if (isDarkModeOne) {
        return const Color.fromRGBO(255, 160, 160, 1);
      } else {
        return const Color.fromRGBO(160, 0, 0, 1);
      }
    } else {
      if (isDarkModeOne) {
        return const Color.fromRGBO(160, 255, 160, 1);
      } else {
        return const Color.fromRGBO(0, 100, 0, 1);
      }
    }
  }
  return null;
}
