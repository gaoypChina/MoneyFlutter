import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_pending_changes/bage_pending_changes.dart';
import 'package:money/widgets/gaps.dart';

class AppCaption extends StatelessWidget {
  final Widget child;

  const AppCaption({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: [
          const Text('MyMoney', textAlign: TextAlign.left),
          const SizedBox(width: 8),
          BadgePendingChanges(
            itemsAdded: Settings().trackMutations.added,
            itemsChanged: Settings().trackMutations.changed,
            itemsDeleted: Settings().trackMutations.deleted,
          )
        ]),
        child,
      ],
    );
  }
}

class LoadedDataFileAndTime extends StatelessWidget {
  final String filePath;
  final DateTime? lastModifiedDateTime;

  const LoadedDataFileAndTime({
    super.key,
    required this.filePath,
    required this.lastModifiedDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      // controller: _scrollController,
      scrollDirection: Axis.horizontal,
      dragStartBehavior: DragStartBehavior.down,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            filePath,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
          gapMedium(),
          Text(
            geDateAndTimeAsText(lastModifiedDateTime),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          gapMedium(),
        ],
      ),
    );
  }
}
