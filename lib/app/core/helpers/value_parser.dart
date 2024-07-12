import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/money_widget.dart';
import 'package:money/app/core/widgets/semantic_text.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

class ValueQuality {
  const ValueQuality(
    this.valueAsString, {
    this.dateFormat = 'MM/DD/YYYY',
    this.currency = Constants.defaultCurrency,
    this.reverseAmountValue = false,
  });

  final String currency;
  final String dateFormat;
  final bool reverseAmountValue;
  final String valueAsString;
  final String warningMessage = '';

  double asAmount() {
    return (parseAmount(valueAsString, currency) ?? 0.00) * (reverseAmountValue ? -1 : 1);
  }

  DateTime? asDate() {
    return DateFormat(dateFormat).tryParse(valueAsString);
  }

  String asString() {
    return valueAsString;
  }

  bool get hasError {
    return warningMessage.isNotEmpty;
  }

  Widget valueAsAmountWidget(final BuildContext context) {
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no amount >');
    }

    double? amount = parseAmount(valueAsString, currency);
    if (amount == null) {
      return buildWarning(context, valueAsString);
    }

    MoneyModel mm = MoneyModel(amount: asAmount(), iso4217: currency);
    return MoneyWidget(amountModel: mm);
  }

  Widget valueAsDateWidget(final BuildContext context) {
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no date >');
    }

    final parsedDate = asDate();
    if (parsedDate == null) {
      return buildWarning(context, valueAsString);
    }

    String dateText = DateFormat('yyyy-MM-dd').format(parsedDate);
    return SelectableText(dateText);
  }

  Widget valueAsTextWidget(final BuildContext context) {
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no description >');
    }
    return SelectableText(valueAsString);
  }
}

class ValuesQuality {
  ValuesQuality({
    required this.date,
    required this.description,
    required this.amount,
    this.reverseAmountValue = false,
  });

  factory ValuesQuality.empty() {
    return ValuesQuality(
      date: const ValueQuality(''),
      description: const ValueQuality(''),
      amount: const ValueQuality(''),
    );
  }

  final ValueQuality amount;
  final ValueQuality date;
  final ValueQuality description;
  bool exist = false;
  final bool reverseAmountValue;

  bool checkIfExistAlready({required final int accountId}) {
    exist = isTransactionAlreadyInTheSystem(
      accountId: accountId,
      dateTime: date.asDate() ?? DateTime.now(),
      amount: amount.asAmount(),
    );
    return exist;
  }

  bool containsErrors() {
    return date.hasError || description.hasError || amount.hasError;
  }

  static DateRange getDateRange(final List<ValuesQuality> list) {
    DateRange range = DateRange();
    for (final v in list) {
      range.inflate(v.date.asDate());
    }
    return range;
  }

  static void sort(
    final List<ValuesQuality> list,
    final int sortBy,
    final bool ascending,
  ) {
    list.sort((a, b) {
      switch (sortBy) {
        case 0:
          return sortByDate(a.date.asDate(), b.date.asDate(), ascending);
        case 1:
          return sortByString(
            a.description.asString(),
            b.description.asString(),
            ascending,
          );
        case 2:
          return sortByValue(
            a.amount.asAmount(),
            b.amount.asAmount(),
            ascending,
          );
      }
      return 0;
    });
  }
}

/// The `ValuesParser` class is responsible for parsing input data and extracting
/// relevant values from it. It provides methods for parsing, transforming, and
/// validating the extracted values.
class ValuesParser {
  ValuesParser({required this.dateFormat, required this.currency, this.reverseAmountValue = false});

  final String currency; // USD, EUR
  final String dateFormat;
  String errorMessage = '';
  final bool reverseAmountValue;
  List<Widget> rows = [];

  List<ValuesQuality> _values = [];

  void add(final ValuesQuality item) {
    _values.add(item);
  }

  static String assembleIntoSingleTextBuffer(
    final String multiStringDates,
    final String multiStringDescriptions,
    final String multiStringAmounts,
  ) {
    int maxLines = 0;
    List<String> dates = multiStringDates.split('\n');
    maxLines = max(maxLines, dates.length);
    List<String> descriptions = multiStringDescriptions.split('\n');
    maxLines = max(maxLines, descriptions.length);
    List<String> amounts = multiStringAmounts.split('\n');
    maxLines = max(maxLines, amounts.length);

    // Make them all the same length
    dates = padList(dates, maxLines, '');
    descriptions = padList(descriptions, maxLines, '');
    amounts = padList(amounts, maxLines, '');

    String singleText = '';
    for (int line = 0; line < maxLines; line++) {
      singleText += '${dates[line]}; ${descriptions[line]}; ${amounts[line]}\n';
    }
    return singleText;
  }

  ValuesQuality attemptToExtractTriples(
    String line,
  ) {
    String dateAsText = '';
    String descriptionAsText = '';
    String amountAsText = '';

    line.trim();
    List<String> threeValues = line.split(RegExp(r'\t|;|\|')).where((token) => token.trim().isNotEmpty).toList();

    // We are looking for these 3 values
    // Date | Description | Amount
    switch (threeValues.length) {
      // no value
      case 0:
        return ValuesQuality.empty();

      // Only one value
      case 1:
        dateAsText = threeValues.first;

      // Only two values
      case 2:
        dateAsText = threeValues.first;
        descriptionAsText = threeValues[1];

      // Perfect
      case 3:
      default: // 4 or more
        dateAsText = threeValues.first;
        descriptionAsText = threeValues.sublist(1, threeValues.length - 1).join(' ');
        amountAsText = cleanString(threeValues.last, '-+0123456789(),.');
    }

    return ValuesQuality(
      // date
      date: ValueQuality(
        dateAsText.trim(),
        dateFormat: dateFormat,
      ),

      // description
      description: ValueQuality(
        descriptionAsText.trim(),
      ),

      // amount
      amount: ValueQuality(
        amountAsText.trim(),
        currency: currency,
        reverseAmountValue: reverseAmountValue,
      ),
      reverseAmountValue: reverseAmountValue,
    );
  }

  Widget buildPresentation(context) {
    List<Widget> rows = [];

    if (lines.isNotEmpty) {
      for (var line in lines) {
        rows.add(
          Row(
            children: [
              SizedBox(width: 100, child: line.date.valueAsDateWidget(context)),
              // Date
              SizedBox(
                width: 300,
                child: line.description.valueAsTextWidget(context),
              ),
              // Description
              SizedBox(
                width: 100,
                child: line.amount.valueAsAmountWidget(context),
              ),
              // Amount
            ],
          ),
        );
      }
    }

    return rows.isEmpty
        ? buildWarning(context, 'Not input text')
        : Column(mainAxisAlignment: MainAxisAlignment.start, children: rows);
  }

  bool containsErrors() {
    return null != _values.firstWhereOrNull((element) => element.containsErrors());
  }

  void convertInputTextToTransactionList(
    BuildContext context,
    String inputString,
  ) {
    // start by fresh
    _values.clear();

    inputString = inputString.trim();

    final List<String> lines = getLinesOfText(inputString, includeEmptyLines: false);

    if (lines.isEmpty) {
      return; // nothing here
    }

    // are we dealing with friendly 3 column values separated by ';'
    if (countOccurrences(lines.first, ';') >= 2) {
      //
      // Date ; Description ; Amount
      //
      List<String> lines = getLinesOfText(inputString, includeEmptyLines: false);
      if (lines.isNotEmpty) {
        for (final String line in lines) {
          add(attemptToExtractTriples(line));
        }
      }
    } else {
      //
      // CSV like text but use space as seperator ' ', instead of ',' this is necesary because some currency use comma in the Amount value
      //
      List<List<String>> lines = getLinesFromRawTextWithSeparator(inputString, ' ');
      if (lines.isNotEmpty) {
        for (final List<String> line in lines) {
          if (line.isNotEmpty) {
            add(attemptToExtractTriples(line.join(';')));
          }
        }
      }
    }
  }

  static void evaluateExistence({
    required final int accountId,
    required final List<ValuesQuality> values,
  }) {
    for (final vq in values) {
      vq.checkIfExistAlready(accountId: accountId);
    }
  }

  List<String> getListOfAmountString() {
    final List<String> list = [];
    for (final value in _values) {
      list.add(value.amount.valueAsString);
    }
    return list;
  }

  List<String> getListOfDatesString() {
    final List<String> list = [];
    for (final value in _values) {
      list.add(value.date.valueAsString);
    }
    return list;
  }

  List<String> getListOfDescriptionString() {
    final List<String> list = [];
    for (final value in _values) {
      list.add(value.description.valueAsString);
    }
    return list;
  }

  bool get isEmpty {
    return onlyNewTransactions.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  // ignore: unnecessary_getters_setters
  List<ValuesQuality> get lines {
    //
    return _values;
  }

  set lines(List<ValuesQuality> value) {
    //
    _values = value;
  }

  List<ValuesQuality> get onlyNewTransactions {
    return _values.where((item) => !item.exist).toList();
  }

  DateTime? parseForDate(final String input) {
    return DateFormat(dateFormat).tryParse(input);
  }

  String removeUnneededChart(final String input, final String validCharacters) {
    return input.replaceAll('\$', ''); // clean up
  }
}

bool isTransactionAlreadyInTheSystem({
  required final int accountId,
  required final DateTime dateTime,
  required final double amount,
}) {
  return null !=
      Data().transactions.findExistingTransaction(
            accountId: accountId,
            dateRange: DateRange(min: dateTime.startOfDay, max: dateTime.endOfDay),
            amount: amount,
          );
}
