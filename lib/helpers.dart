import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:money/models/constants.dart';

import 'package:flutter/foundation.dart';

num numValueOrDefault(final num? value, {final num defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

int intValueOrDefault(final int? value, {final int defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

double doubleValueOrDefault(final double? value, {final double defaultValueIfNull = 0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

bool boolValueOrDefault(final bool? value, {final bool defaultValueIfNull = false}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

bool isSmallWidth(
  final BoxConstraints constraints, {
  final num minWidth = Constants.narrowScreenWidthThreshold,
}) {
  if (constraints.maxWidth < minWidth) {
    return true;
  }
  return false;
}

ThemeData getTheme(final BuildContext context) {
  return Theme.of(context);
}

TextTheme getTextTheme(final BuildContext context) {
  return getTheme(context).textTheme;
}

ColorScheme getColorTheme(final BuildContext context) {
  return getTheme(context).colorScheme;
}

double roundDouble(final double value, final int places) {
  final num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

String getIntAsText(final int value) {
  return NumberFormat.decimalPattern().format(value);
}

String getCurrencyText(final double amount) {
  final NumberFormat formatCurrency = NumberFormat.simpleCurrency();
  return formatCurrency.format(amount);
}

String getNumberAsShorthandText(final num value, {final int decimalDigits = 0, final String symbol = ''}) {
  return NumberFormat.compactCurrency(
    decimalDigits: decimalDigits,
    symbol: symbol, // if you want to add currency symbol then pass that in this else leave it empty.
  ).format(value);
}

String getDateAsText(final DateTime date) {
  return date.toIso8601String().split('T').first;
}

int sortByStringIgnoreCase(final String textA, final String textB) {
  return textA.toUpperCase().compareTo(textB.toUpperCase());
}

int sortByString(final dynamic a, final dynamic b, final bool ascending) {
  if (ascending) {
    return sortByStringIgnoreCase(a as String, b as String);
  } else {
    return sortByStringIgnoreCase(b as String, a as String);
  }
}

int sortByValue(final num a, final num b, final bool ascending) {
  if (ascending) {
    return (b - a).toInt();
  } else {
    return (a - b).toInt();
  }
}

extension Range on num {
  bool isBetween(final num from, final num to) {
    return from < this && this < to;
  }

  bool isBetweenOrEqual(final num from, final num to) {
    return from < this && this < to;
  }
}

/// return the inverted color
Color invertColor(final Color color) {
  final int r = 255 - color.red;
  final int g = 255 - color.green;
  final int b = 255 - color.blue;

  return Color.fromARGB((color.opacity * 255).round(), r, g, b);
}

void debugLog(final String message) {
  if (kDebugMode) {
    print(message);
  }
}

Widget getViewExpandAndPadding(final Widget child) {
  return Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 0), child: child));
}

/// Return the first element of type T in a list given a list of possible index;
T? getFirstElement<T>(final List<int> indices, final List<dynamic> list) {
  if (indices.isNotEmpty) {
    final int index = indices.first;
    return list[index] as T?;
  }
  return null;
}
