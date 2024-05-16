import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_cashflow/recurring/recurring_payment.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/date_range_time_line.dart';
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
      color: getColorTheme(context).surface,
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
    List<Pair<int, double>> sumByDays = Transactions.transactionSumByTime(payment.transactions);

    return Box(
      title: 'Timeline',
      padding: 21,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 50,
            child: MiniTimelineDaily(
              values: sumByDays,
              yearStart: dateRangeSearch.min!.year,
              yearEnd: dateRangeSearch.max!.year,
              offsetStartingDay: dateRangeSearch.min!.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay,
              color: getColorTheme(context).primary,
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          _buildDateRangeRow(payment.dateRangeFound, 100, 100, false),
          gapLarge(),
          _buildTextAmountRow(
              context, '${getIntAsText(payment.frequency)} transactions averaging', payment.total / payment.frequency),
        ],
      ),
    );
  }

  Widget _buildDateRangeRow(
    final DateRange dateRange,
    final double paddingLeft,
    final double paddingRight,
    final bool showTicks,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
      child: DateRangeTimeline(
        startDate: dateRange.min!,
        endDate: dateRange.max!,
        showTicks: showTicks,
      ),
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
