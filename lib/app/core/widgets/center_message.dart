import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/box.dart';
import 'package:money/app/data/models/constants.dart';

/// a basic text that is centered in the parent container
class CenterMessage extends StatelessWidget {
  /// constructor
  const CenterMessage({required this.message, this.child, super.key});

  factory CenterMessage.noTransaction() {
    return const CenterMessage(message: 'No transactions.');
  }
  factory CenterMessage.noItems() {
    return const CenterMessage(message: 'No items');
  }
  final String message;
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Box(
        width: 400,
        height: 60,
        child: Center(
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(message),
                ),
                if (child != null)
                  Padding(
                    padding: const EdgeInsets.only(left: SizeForPadding.huge),
                    child: child!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
