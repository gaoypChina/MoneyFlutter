import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_model.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/distribution_bar.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/mini_timeline_daily.dart';
import 'package:money/widgets/mini_timeline_twelve_months.dart';
import 'package:money/widgets/money_widget.dart';

class RecurringCard extends StatelessWidget {
  final int index;
  final RecurringPayment payment;
  final DateRange dateRangeSelected;
  final DateRange dateRangeSearch;

  final bool forIncomeTransaction;

  const RecurringCard({
    super.key,
    required this.index,
    required this.dateRangeSearch,
    required this.dateRangeSelected,
    required this.payment,
    required this.forIncomeTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getColorTheme(context).background,
      margin: const EdgeInsets.only(bottom: 21),
      elevation: 4,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(context),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 21,
              runSpacing: 21,
              children: [
                // Time line
                _buildBoxTimelinePerDayOverYears(context),

                // break down the numbers
                _buildBoxAverages(context),

                // Category Distributions
                _buildBoxDistribution(context),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context) {
    TextTheme textTheme = getTextTheme(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Opacity(opacity: 0.5, child: Text('#$index ')),
        Expanded(
          child: SelectableText(
            Data().payees.getNameFromId(payment.payeeId),
            maxLines: 1,
            style: textTheme.titleMedium,
          ),
        ),
        gapLarge(),
        MoneyWidget(amountModel: MoneyModel(amount: payment.total)),
      ],
    );
  }

  Widget _buildBoxTimelinePerDayOverYears(final BuildContext context) {
    List<Pair<int, double>> timeAndAmounts = [];
    for (final t in payment.transactions) {
      timeAndAmounts.add(Pair<int, double>(
        (t.dateTime.value!.millisecondsSinceEpoch - dateRangeSearch.min!.millisecondsSinceEpoch) ~/
            Duration.millisecondsPerDay,
        t.amount.value.amount,
      ));
    }
    timeAndAmounts.sort((a, b) => a.first.compareTo(b.first));

    return Box(
      title: 'Timeline',
      padding: 21,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MiniTimelineDaily(
            values: timeAndAmounts,
            yearStart: dateRangeSearch.min!.year,
            yearEnd: dateRangeSearch.max!.year,
            color: getColorTheme(context).primary,
          ),
          const Divider(
            height: 2,
            thickness: 2,
          ),
          Opacity(
            opacity: 0.8,
            child: _buildDataRangRows(context),
          ),
          gapLarge(),
          _buildTextAmountRow(
              context, '${getIntAsText(payment.frequency)} transactions averaging', payment.total / payment.frequency),
        ],
      ),
    );
  }

  Widget _buildDataRangRows(final BuildContext context) {
    TextStyle style = getTextTheme(context).labelSmall!;

    bool identicalSelectedAndFound = dateRangeSearch.min!.year == payment.dateRangeFound.min!.year &&
        dateRangeSearch.max!.year == payment.dateRangeFound.max!.year;

    bool identicalSelectedAndSearch = dateRangeSearch.min!.year == dateRangeSelected.min!.year &&
        dateRangeSearch.max!.year == dateRangeSelected.max!.year;

    // Level 1 paddings between Select and Payment
    double paddingLevel1Left = 0;
    double paddingLevel1Right = 0;
    {
      if (dateRangeSelected.min!.year != payment.dateRangeFound.min!.year) {
        paddingLevel1Left += 50;
      }
      if (dateRangeSelected.max!.year != payment.dateRangeFound.max!.year) {
        paddingLevel1Right += 50;
      }
    }

    // Level 2 paddings between Selected and Search
    double paddingLevel2Left = 0;
    double paddingLevel2Right = 0;
    {
      if (dateRangeSelected.min!.year != dateRangeSearch.min!.year) {
        paddingLevel1Left += 60;
        paddingLevel2Left += 60;
      }
      if (dateRangeSelected.max!.year != dateRangeSearch.max!.year) {
        paddingLevel1Right += 60;
        paddingLevel2Right += 60;
      }
    }

    return Column(children: [
      _buildDateRangeRow(payment.dateRangeFound, style, paddingLevel1Left, paddingLevel1Right),
      // Avoid showing twice the same information, we may need only need one data span row of information
      if (!identicalSelectedAndFound)
        _buildDateRangeRow(dateRangeSelected, style, paddingLevel2Left, paddingLevel2Right),
      if (!identicalSelectedAndSearch) _buildDateRangeRow(dateRangeSearch, style, 0, 0),
    ]);
  }

  Widget _buildDateRangeRow(
      final DateRange dateRange, final TextStyle style, final double paddingLeft, final double paddingRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: paddingLeft),
            child: Text(dateRange.min!.year.toString(), style: style),
          ),
        ),
        Expanded(
            child: Text(
          dateRange.durationInYearsText,
          style: style,
          textAlign: TextAlign.center,
        )),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: paddingRight),
            child: Text(
              dateRange.max!.year.toString(),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoxAverages(final BuildContext context) {
    return Box(
      title: 'Averages',
      padding: 21,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 55,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: MiniTimelineTwelveMonths(
              values: payment.averagePerMonths,
              color: getColorTheme(context).primary,
            ),
          ),

          // Average per yearS
          _buildTextAmountRow(context, 'Year', payment.total / (payment.dateRangeFound.durationInYears)),
          // Average per month
          _buildTextAmountRow(context, 'Month', payment.total / (payment.dateRangeFound.durationInMonths)),
          // Average per day
          _buildTextAmountRow(context, 'Day', payment.total / (payment.dateRangeFound.durationInDays)),
        ],
      ),
    );
  }

  Widget _buildBoxDistribution(final BuildContext context) {
    return Box(
      title: 'Categories',
      padding: 21,
      child: DistributionBar(segments: payment.categoryDistribution),
    );
  }
}

Widget _buildTextAmountRow(final BuildContext context, final String title, final double amount) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: getTextTheme(context).labelMedium),
      MoneyWidget(amountModel: MoneyModel(amount: amount)),
    ],
  );
}
