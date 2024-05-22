import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/dialog/dialog_full_screen.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;

  const MyAlertDialog({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    required this.child,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      icon: icon == null ? null : Icon(icon!),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(
          color: getColorTheme(context).primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      content: Container(
        constraints: const BoxConstraints(
          minHeight: 500,
          maxHeight: 700,
        ),
        width: 400,
        child: child,
      ),
      actions: actions,
    );
  }
}

void adaptiveScreenSizeDialog({
  required final BuildContext context,
  required final String title,
  required final Widget child,
  List<Widget>? actionButtons,
  final bool showCloseButton = true,
}) {
  actionButtons ??= [];
  if (isSmallDevice(context)) {
    // Full screen also comes with a Close (X) button
    Navigator.of(context).push(
      MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return FullScreenDialog(
            title: title,
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  } else {
    // in modal always offer a close button
    if (showCloseButton) {
      actionButtons.add(DialogActionButton(
          text: 'Close',
          onPressed: () {
            Navigator.of(context).pop(false);
          }));
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) {
          return MyAlertDialog(
            title: title,
            scrollable: true,
            actions: actionButtons,
            child: child,
          );
        });
  }
}
