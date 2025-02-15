import 'package:flutter/material.dart';
import 'package:money/app/controller/theme_controller.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/switch_views.dart';

class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final IconData? icon;
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    Widget child = icon == null
        ? Text(text)
        : IntrinsicWidth(
            child: Row(
              children: [
                Opacity(opacity: 0.5, child: Icon(icon)),
                gapSmall(),
                Text(text),
              ],
            ),
          );
    return OutlinedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

Widget dialogActionButtons(final List<Widget> actionsButtons) {
  return Wrap(
    alignment: WrapAlignment.end,
    spacing: SizeForPadding.medium,
    runSpacing: SizeForPadding.medium,
    children: actionsButtons,
  );
}

Widget buildMergeButton(final Function callback) {
  return IconButton(
    key: Constants.keyMergeButton,
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.merge_outlined),
    tooltip: 'Merge item(s)',
  );
}

Widget buildAddItemButton(
  final Function callback,
  final String tooltip,
) {
  return IconButton(
    key: Constants.keyAddNewItem,
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.add_circle_outline),
    tooltip: tooltip,
  );
}

Widget buildAddTransactionsButton(final Function callback) {
  return IconButton(
    onPressed: () {
      callback();
    },
    icon: const Icon(Icons.post_add_outlined),
    tooltip: 'Add a new transactions',
  );
}

Widget buildEditButton(final Function callback) {
  return IconButton(
    key: Constants.keyEditSelectedItems,
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.edit_outlined),
    tooltip: 'Edit selected item(s)',
  );
}

Widget buildDeleteButton(final Function callback) {
  return IconButton(
    key: Constants.keyDeleteSelectedItems,
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.delete_outline),
    tooltip: 'Delete selected item(s)',
  );
}

Widget buildCopyButton(final Function callback, [final key = Constants.keyCopyListToClipboardHeaderMain]) {
  return IconButton(
    key: key,
    onPressed: () {
      callback.call();
    },
    icon: const Icon(Icons.copy_all),
    tooltip: 'Copy list to clipboard',
  );
}

Widget buildJumpToButton(final List<InternalViewSwitching> listOfViewToJumpTo) {
  final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
  for (var i = 0; i < listOfViewToJumpTo.length; i++) {
    list.add(
      PopupMenuItem<int>(
        value: i,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(listOfViewToJumpTo[i].icon),
            gapLarge(),
            Expanded(child: Text(listOfViewToJumpTo[i].title)),
          ],
        ),
      ),
    );
  }
  return myPopupMenuIconButton(
    icon: Icons.open_in_new_outlined,
    tooltip: 'Switch view',
    list: list,
    onSelected: (final index) {
      listOfViewToJumpTo[index].onPressed();
    },
  );
}

PopupMenuButton<int> myPopupMenuIconButton({
  final Key? key,
  required final IconData icon,
  required final String tooltip,
  required final List<PopupMenuItem<int>> list,
  required final Function(int) onSelected,
}) {
  return PopupMenuButton<int>(
    key: key,
    icon: Icon(icon),
    tooltip: tooltip,
    position: PopupMenuPosition.under,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: ThemeController.to.primaryColor,
        width: 2,
      ), // Set the border color and width
      borderRadius: BorderRadius.circular(8), // Set the border radius
    ),
    itemBuilder: (final BuildContext context) {
      return list;
    },
    onSelected: onSelected,
  );
}
