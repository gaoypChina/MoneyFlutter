import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/circle.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/money_widget.dart';
import 'package:money/app/data/models/money_model.dart';

class Distribution {
  Distribution({
    required this.title,
    required this.amount,
    this.color = Colors.transparent,
  });

  final double amount;
  final Color color;
  final String title;

  double percentage = 0;
}

class DistributionBar extends StatelessWidget {
  DistributionBar({required this.segments, super.key});

  final List<Widget> detailRowWidgets = [];
  final List<Widget> segmentWidgets = [];
  final List<Distribution> segments;

  @override
  Widget build(BuildContext context) {
    double sum = segments.fold(
      0,
      (previousValue, element) => previousValue + element.amount.abs(),
    );
    if (sum > 0) {
      for (final segment in segments) {
        segment.percentage = segment.amount.abs() / sum;
      }
    }
    // Sort descending by percentage
    segments.sort((a, b) => b.percentage.compareTo(a.percentage));

    initWidgets(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHorizontalBar(),
        gapSmall(),
        _buildRowOfDetails(),
      ],
    );
  }

  void initWidgets(final BuildContext context) {
    for (final segment in segments) {
      Color backgroundColorOfSegment = segment.color;
      Color foregroundColorOfSegment = contrastColor(backgroundColorOfSegment);

      if (backgroundColorOfSegment.opacity == 0) {
        backgroundColorOfSegment = Colors.grey;
        foregroundColorOfSegment = Colors.white;
      }

      segmentWidgets.add(
        Expanded(
          // use the percentage to determine the relative width
          flex: (segment.percentage * 100).toInt().abs(),
          child: Tooltip(
            message: segment.title,
            child: Container(
              alignment: Alignment.center,
              color: backgroundColorOfSegment,
              margin: EdgeInsets.only(right: segment == segments.last ? 0.0 : 1.0),
              child: _builtSegmentOverlayText(
                segment.percentage,
                foregroundColorOfSegment,
              ),
            ),
          ),
        ),
      );

      detailRowWidgets.add(
        _buildDetailRow(
          context,
          segment.title,
          MyCircle(colorFill: segment.color, size: 16),
          segment.amount,
        ),
      );
    }
  }

  Widget _buildDetailRow(
    final BuildContext context,
    final String label,
    final Widget colorWidget,
    final double value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        colorWidget,
        gapSmall(),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: getTextTheme(context).labelMedium,
            textAlign: TextAlign.justify,
            textWidthBasis: TextWidthBasis.longestLine,
            softWrap: false,
          ),
        ),
        Expanded(
          child: MoneyWidget(
            amountModel: MoneyModel(
              amount: value,
            ),
            asTile: false,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3), // Radius for rounded ends
      child: SizedBox(
        height: 20,
        child: Row(
          children: segmentWidgets,
        ),
      ),
    );
  }

  Widget _buildRowOfDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: detailRowWidgets,
    );
  }

  Widget _builtSegmentOverlayText(final double percentage, final Color color) {
    int value = (percentage * 100).toInt();
    if (value <= 0) {
      return const SizedBox();
    }
    return Text(
      '$value%',
      softWrap: false,
      overflow: TextOverflow.clip,
      style: TextStyle(color: color, fontSize: 9),
    );
  }
}
