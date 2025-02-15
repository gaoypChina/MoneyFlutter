import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/reveal_content.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/mru_dropdown.dart';
import 'package:money/app/modules/pending_changes/badge_pending_changes.dart';

class AppTitle extends StatelessWidget {
  AppTitle({
    super.key,
  }) {
    netWorth = Data().getNetWorth();
  }

  late final MoneyModel netWorth;

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find();

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                IntrinsicWidth(child: _buildNetWorthToggle(context)),
                gapSmall(),
                Obx(() {
                  return BadgePendingChanges(
                    key: Constants.keyPendingChanges,
                    itemsAdded: dataController.trackMutations.added.value,
                    itemsChanged: dataController.trackMutations.changed.value,
                    itemsDeleted: dataController.trackMutations.deleted.value,
                  );
                }),
              ],
            ),
            const MruDropdown(),
          ],
        );
      },
    );
  }

  Widget _buildNetWorthToggle(
    final BuildContext context,
  ) {
    return RevealContent(
      textForClipboard: netWorth.toString(),
      widgets: [
        _buildRevealContentOption(context, 'MyMoney', true),
        _buildRevealContentOption(context, netWorth.toShortHand(), false),
        _buildRevealContentOption(context, netWorth.toString(), false),
      ],
    );
  }
}

Widget _buildRevealContentOption(
  final BuildContext context,
  String text,
  final bool hidden,
) {
  Color color = getColorTheme(context).onSurface;
  TextStyle textStyle = TextStyle(fontSize: SizeForText.normal, color: color);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(text, style: textStyle),
      gapSmall(),
      Opacity(
        opacity: 0.8,
        child: Icon(
          hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 16,
          color: color,
        ),
      ),
    ],
  );
}
