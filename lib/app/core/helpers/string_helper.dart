import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:path_provider/path_provider.dart';

int countOccurrences(String input, String char) {
  if (char.length != 1) {
    throw ArgumentError('The character to count must be a single character.');
  }

  int count = 0;
  for (int i = 0; i < input.length; i++) {
    if (input[i] == char) {
      count++;
    }
  }
  return count;
}

String doubleToCurrency(final double value, {final String symbol = '\$', final bool showPlusSign = false}) {
  NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: symbol);
  // Format the double value as currency text
  return (showPlusSign ? getPlusSignIfPositive(value) : '') + currencyFormatter.format(value);
}

String getPlusSignIfPositive(final num value) {
  if (value > 0) {
    return '+';
  }
  return '';
}

String escapeString(String input) {
  return input.replaceAll("'", "''");
}

String formatDoubleTimeZeroFiveNine(double value, {bool showPlusSign = false}) {
  final formatter = NumberFormat('#,##0.#####', 'en_US');
  return getPrefixPlusSignIfNeeded(value, showPlusSign: showPlusSign) + formatter.format(value);
}

String formatDoubleTrimZeros(double value) {
  final formatter = NumberFormat('#,##0.##', 'en_US');
  return formatter.format(value);
}

String getAmountAsShorthandText(
  final num value, {
  final int decimalDigits = 0,
  final String symbol = '',
}) {
  return NumberFormat.compactCurrency(
    decimalDigits: decimalDigits,
    symbol: symbol, // if you want to add currency symbol then pass that in this else leave it empty.
  ).format(value);
}

List<String> getColumnInCsvLine(final String csvLine) {
  List<String> items = csvLine.split(RegExp(r',|;(?=(?:[^"]*"[^"]*")*[^"]*$)'));
  // remove quotes around elements
  items = items.map((item) => item.replaceAll('"', '')).toList();
  return items;
}

/// return a ISO 3166-1 Alpha2  US | CA | ES
String getCountryFromLocale(final String locale) {
  if (locale.isEmpty) {
    return 'US'; // default to US
  }
  final tokens = locale.replaceAll('-', '_').split('_');
  return tokens.last;
}

Future<String> getDocumentDirectory() async {
  if (kIsWeb) {
    return '';
  }
  final Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String getInitials(String fullName) {
  return fullName.split(' ').map((word) => word[0].toUpperCase()).join('');
}

String getIntAsText(final int value, {showPlusSign = false}) {
  return getPrefixPlusSignIfNeeded(value, showPlusSign: showPlusSign) + NumberFormat.decimalPattern().format(value);
}

String getPrefixPlusSignIfNeeded(final num value, {showPlusSign = false}) {
  return (showPlusSign ? getPlusSignIfPositive(value) : '');
}

/// Parses a raw text string and splits it into rows and columns based on a specified separator character.
///
/// The function handles quoted fields and escaped quotes within the text. It returns a list of rows,
/// where each row is represented as a list of strings (fields).
///
/// [content] The raw text string to be parsed.
/// [separator] The character used to separate fields within a row. Defaults to a comma `,`.
///
/// Returns a `List<List<String>>` representing the parsed rows and fields.
List<List<String>> getLinesFromRawTextWithSeparator(final String content, [final String separator = ',']) {
  List<List<String>> rows = [];
  List<String> currentRow = [];
  StringBuffer currentField = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < content.length; i++) {
    String char = content[i];

    if (char == '"' && (i + 1 < content.length && content[i + 1] == '"')) {
      // Handle escaped quotes
      currentField.write('"');
      i++; // Skip the next quote
    } else if (char == '"') {
      inQuotes = !inQuotes; // Toggle the inQuotes state
    } else if ((char == separator) && !inQuotes) {
      // End of a field
      currentRow.add(currentField.toString());
      currentField = StringBuffer();
    } else if ((char == '\n' || char == '\r') && !inQuotes) {
      // End of a row (handle both \n and \r\n)
      if (currentField.isNotEmpty || currentRow.isNotEmpty) {
        currentRow.add(currentField.toString());
        rows.add(currentRow);
        currentRow = [];
        currentField = StringBuffer();
      }
    } else {
      // Normal character
      currentField.write(char);
    }
  }

  // Add the last row if it exists
  if (currentField.isNotEmpty || currentRow.isNotEmpty) {
    currentRow.add(currentField.toString());
    rows.add(currentRow);
  }

  return rows;
}

/// Clean up input string by removing "white noise"
String getNormalizedValue(final String? s) {
  if (s == null) {
    return '';
  }

  return s.replaceAll('\r\n', ' ').replaceAll('\r', ' ').replaceAll('\n', ' ').trim();
}

String getNumberShorthandText(final num value) {
  return NumberFormat.compact().format(value);
}

String getSingularPluralText(
  final String title,
  final int quantity,
  final String singular,
  final String plural,
) {
  return '$title ${quantity == 1 ? singular : plural}';
}

String getStringContentBetweenTwoTokens(
  final String input,
  final String start,
  final String end,
) {
  final int indexStart = input.indexOf(start);
  if (indexStart != -1) {
    final int indexEnd = input.indexOf(end);
    if (indexEnd != -1) {
      return input.substring(indexStart + start.length, indexEnd);
    }
  }
  return '';
}

String getStringDelimitedStartEndTokens(
  final String input,
  final String start,
  final String end,
) {
  final String content = getStringContentBetweenTwoTokens(input, start, end);
  return start + content + end;
}

int getLineCount(final String text) {
  if (text.trim().isEmpty) {
    return 0;
  }
  return text.trim().split('\n').length;
}

/// Split the text into lines
List<String> getLinesOfText(final String inputText, {bool includeEmptyLines = true}) {
  List<String> lines = inputText.split('\n');
  if (includeEmptyLines == false) {
    // Filter out the empty lines
    return lines.where((line) => line.trim().isNotEmpty).toList();
  }
  return lines;
}

String removeEmptyLines(String text) {
  // Filter out the empty lines
  List<String> nonEmptyLines = getLinesOfText(text, includeEmptyLines: false);

  // Join the non-empty lines back together
  String result = nonEmptyLines.join('\n');

  return result;
}

String shortenLongText(String fullName, [int maxLength = 5]) {
  assert(maxLength >= 0);
  if (fullName.length <= maxLength) {
    // No need to shorten
    return fullName;
  }

  final words = fullName.split(' ');
  if (words.length >= 2) {
    return words.map((word) => word[0].toUpperCase()).join('.');
  }
  return fullName.substring(0, maxLength);
}

int stringCompareIgnoreCasing1(final String textA, final String textB) {
  return textA.toUpperCase().compareTo(textB.toUpperCase());
}

int stringCompareIgnoreCasing2(final String str1, final String str2) {
  if (str1 == str2) {
    return 0;
  }

  final int length1 = str1.length;
  final int length2 = str2.length;

  final int minLength = min(length1, length2);

  for (int i = 0; i < minLength; i++) {
    final int result = str1[i].toLowerCase().compareTo(str2[i].toLowerCase());
    if (result != 0) {
      return result;
    }
  }

  return length1.compareTo(length2);
}

int compareStringsAsNumbers(final String a, final String b) {
  if (a.length == b.length) {
    return a.compareTo(b);
  }
  return a.length.compareTo(b.length);
}

int compareStringsAsAmount(final String a, final String b) {
  final valueA = attemptToGetDoubleFromText(a) ?? 0.00;
  final valueB = attemptToGetDoubleFromText(b) ?? 0.00;

  return valueA.compareTo(valueB);
}

String concat(
  final String existingValue,
  final String valueToConcat, [
  final String separatorIfNeeded = '; ',
  bool doNotConcactIfPresent = false,
]) {
  if (valueToConcat.isEmpty) {
    // Nothing to concat
    return existingValue;
  }

  if (existingValue.isEmpty) {
    return valueToConcat;
  } else {
    if (doNotConcactIfPresent && existingValue.contains(separatorIfNeeded)) {
      return existingValue;
    }
    return existingValue + separatorIfNeeded + valueToConcat;
  }
}

String removeUtf8Bom(String text) {
  const bom = '\u{FEFF}';
  if (text.startsWith(bom)) {
    return text.substring(1);
  }
  return text;
}

double? parseUSDAmount(String input) {
  input = input.replaceAll('\$', '');
  input = input.replaceAll('USD', '');
  final usdPattern = RegExp(r'^[+-]?(\d+(\,\d{3})*(\.\d+)?|\.\d+)(\s*USD)?$');
  final match = usdPattern.firstMatch(input);

  if (match != null) {
    final numericPart = match.group(1)?.replaceAll(',', '');
    if (numericPart != null) {
      final sign = input.startsWith('-') ? -1.0 : 1.0;
      return double.parse(numericPart) * sign;
    }
  }

  return null;
}

double? parseEuroAmount(String input) {
  final euroPattern = RegExp(r'^([+-]?(?:\d+(?:\.\d{3})*|\d+))(,\d+)?\s*€?$');
  final match = euroPattern.firstMatch(input);

  if (match != null) {
    final integerPart = match.group(1)?.replaceAll('.', '');
    final decimalPart = match.group(2)?.replaceAll(',', '.');

    if (integerPart != null) {
      final numericPart = integerPart + (decimalPart ?? '');
      return double.parse(numericPart);
    }
  }

  return null;
}

String convertParateseToNegativeString(String amountText) {
  amountText = amountText.trim();
  if (amountText.contains('(') && amountText.contains(')')) {
    amountText = amountText.replaceAll('(', '');
    amountText = amountText.replaceAll(')', '');
    amountText = '-$amountText';
  }
  return amountText;
}

double? parseAmount(String amountAsText, final String currency) {
  amountAsText = convertParateseToNegativeString(amountAsText);
  switch (currency.toLowerCase()) {
    case 'eur':
      return parseEuroAmount(amountAsText);
    case 'usd':
    case 'cad':
    default:
      return parseUSDAmount(amountAsText);
  }
}

/// Remove any characters not in the alloedChars argument
String cleanString(String inputStr, String allowedChars) {
  return inputStr.split('').where((char) => allowedChars.contains(char)).join();
}

String validIntToCurrencu(final num value) {
  return getIntAsText(isNumber(value) ? value.toInt() : 0, showPlusSign: true);
}

String validDoubleToCurrencu(final num value) {
  return doubleToCurrency(isNumber(value) ? value.toDouble() : 0.0, showPlusSign: true);
}

bool isNumber(num value) {
  return value.isFinite && !value.isNaN;
}
