// Imports
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item.dart';

// Exports
export 'package:money/app/data/models/fields/fields.dart';
export 'package:money/app/data/models/money_objects/money_object.dart';
export 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item.dart';
export 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';
export 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_header.dart';

class MyListView<T> extends StatefulWidget {
  const MyListView({
    required this.fields,
    required this.list,
    required this.selectedItemIds,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.displayAsColumn = true,
    this.onSelectionChanged,
    this.isMultiSelectionOn = false,
  });

  final Function(BuildContext, int)? onTap;
  final Function(BuildContext, int)? onDoubleTap;
  final Function(BuildContext, int)? onLongPress;
  final Function(int /* uniqueId */)? onSelectionChanged;
  final bool displayAsColumn;
  final FieldDefinitions fields;
  final bool isMultiSelectionOn;
  final List<T> list;
  final ValueNotifier<List<int>> selectedItemIds;

  @override
  State<MyListView<T>> createState() => MyListViewState<T>();
}

class MyListViewState<T> extends State<MyListView<T>> {
  double padding = 0;

  double _rowHeight = 30;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // render the list with the first selected item in view
    scrollFirstItemIntoView();
  }

  @override
  Widget build(final BuildContext context) {
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    if (widget.displayAsColumn) {
      _rowHeight = 30;
      padding = 8.0;
    } else {
      _rowHeight = 85;
      padding = 0;
    }

    return ListView.builder(
      primary: false,
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      itemCount: widget.list.length,
      itemExtent: textScaler.scale(_rowHeight),
      itemBuilder: (final BuildContext context, final int index) {
        final MoneyObject itemInstance = getMoneyObjectFromIndex(index);
        final isLastItemOfTheList = (index == widget.list.length - 1);
        final isSelected = widget.selectedItemIds.value.contains(itemInstance.uniqueId);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isMultiSelectionOn)
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedItem(itemInstance.uniqueId);
                      }
                      if (value == false) {
                        widget.selectedItemIds.value.remove(itemInstance.uniqueId);
                      }
                      widget.onSelectionChanged?.call(itemInstance.uniqueId);
                      FocusScope.of(context).requestFocus();
                    });
                  },
                ),
              Expanded(
                child: MyListItem(
                  onListViewKeyEvent: onListViewKeyEvent,
                  onTap: () {
                    if (widget.selectedItemIds.value.contains(itemInstance.uniqueId)) {
                      widget.selectedItemIds.value.remove(itemInstance.uniqueId);
                    } else {
                      if (widget.isMultiSelectionOn == false) {
                        // single selection
                        widget.selectedItemIds.value.clear();
                      }
                      widget.selectedItemIds.value.add(itemInstance.uniqueId);
                    }
                    widget.onSelectionChanged?.call(itemInstance.uniqueId);

                    FocusScope.of(context).requestFocus();
                  },
                  onLongPress: () {
                    widget.onLongPress?.call(context, itemInstance.uniqueId);
                    FocusScope.of(context).requestFocus();
                  },
                  autoFocus: index == widget.selectedItemIds.value.firstOrNull,
                  isSelected: isSelected,
                  adornmentColor: itemInstance.getMutationColor(),
                  child: _buildListItemContent(
                    isSelected,
                    itemInstance,
                    isLastItemOfTheList,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// return -1 if not found
  int getListIndexFromUniqueId(final int uniqueId) {
    return widget.list.indexWhere((element) => (element as MoneyObject).uniqueId == uniqueId);
  }

  /// don't make it flush to the top, we do this in order to give some clue that there's other item above,
  double getListOffsetOfItemIndex(final int index) => (index * _rowHeight); // * -1.5;

  MoneyObject getMoneyObjectFromIndex(int index) {
    return widget.list[index] as MoneyObject;
  }

  int getUniqueIdFromIndex(int index) {
    return getMoneyObjectFromIndex(index).uniqueId;
  }

// use this if total item count is known
  NumRange indexOfItemsInView() {
    final int itemCount = widget.list.length;
    final double scrollOffset = _scrollController.position.pixels;
    final double viewportHeight = _scrollController.position.viewportDimension;
    final double scrollRange = _scrollController.position.maxScrollExtent - _scrollController.position.minScrollExtent;

    final int firstVisibleItemIndex = (scrollOffset / (scrollRange + viewportHeight) * itemCount).ceil();
    final int lastVisibleItemIndex = firstVisibleItemIndex + numberOfItemOnViewPort() - 1;

    return NumRange(min: firstVisibleItemIndex, max: lastVisibleItemIndex);
  }

  bool isIndexInView(final int index) {
    if (index != -1) {
      final NumRange viewingIndexRange = indexOfItemsInView();
      if (index.isBetween(viewingIndexRange.min, viewingIndexRange.max)) {
        return true;
      }
    }
    return false;
  }

  int moveCurrentSelection(final int incrementBy) {
    int itemIdToSelect = -1;
    final int firstSelectedIndex = getListIndexFromUniqueId(widget.selectedItemIds.value.first);
    if (firstSelectedIndex != -1) {
      int newIndexToSelect = firstSelectedIndex + incrementBy; // go up
      if (isIndexInRange(widget.list, newIndexToSelect)) {
        final itemFoundAtNewIndexPosition = widget.list[newIndexToSelect];
        itemIdToSelect = (itemFoundAtNewIndexPosition as MoneyObject).uniqueId;
      }
    } else {
      itemIdToSelect = (widget.list.first as MoneyObject).uniqueId;
    }

    scrollToId(itemIdToSelect);
    return itemIdToSelect;
  }

  int numberOfItemOnViewPort() {
    final double viewportHeight = _scrollController.position.viewportDimension;
    final int numberOfItemDisplayed = (viewportHeight / _rowHeight).floor();
    return numberOfItemDisplayed;
  }

  KeyEventResult onListViewKeyEvent(
    final FocusNode node,
    final KeyEvent event,
  ) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (widget.selectedItemIds.value.isNotEmpty) {
            int itemIdToSelect = moveCurrentSelection(-1);
            if (itemIdToSelect != -1) {
              selectedItem(itemIdToSelect);
            }
          }
          return KeyEventResult.handled;

        case LogicalKeyboardKey.arrowDown:
          if (widget.selectedItemIds.value.isNotEmpty) {
            int itemIdToSelect = moveCurrentSelection(1);
            if (itemIdToSelect != -1) {
              selectedItem(itemIdToSelect);
            }
          }
          return KeyEventResult.handled;

        case LogicalKeyboardKey.home:
          final idToSelect = (widget.list.first as MoneyObject).uniqueId;
          selectedItem(idToSelect);
          _scrollController.jumpTo(getListOffsetOfItemIndex(0));
          return KeyEventResult.handled;

        case LogicalKeyboardKey.end:
          final idToSelect = (widget.list.last as MoneyObject).uniqueId;
          selectedItem(idToSelect);
          _scrollController.jumpTo(getListOffsetOfItemIndex(widget.list.length - 1));
          return KeyEventResult.handled;

        case LogicalKeyboardKey.pageUp:
        case LogicalKeyboardKey.pageDown:
          // TODO
          return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void scrollFirstItemIntoView() {
    double initialScrollOffset = 0;

    if (widget.selectedItemIds.value.isNotEmpty) {
      final int firstSelectedIndex = getListIndexFromUniqueId(widget.selectedItemIds.value.first);
      if (firstSelectedIndex != -1) {
        initialScrollOffset = getListOffsetOfItemIndex(firstSelectedIndex);
      }
    }
    _scrollController = ScrollController(initialScrollOffset: initialScrollOffset);
  }

  /// if the uniqueID is valid,
  /// if the index of this ID is valid
  /// if the item is not in view
  /// then and only then we scroll the item into view
  void scrollToId(final int uniqueId) {
    if (-1 != uniqueId) {
      final int index = getListIndexFromUniqueId(uniqueId);
      scrollToIndex(index);
    }
  }

  void scrollToIndex(final int index) {
    if (isIndexInRange(widget.list, index)) {
      final NumRange viewingIndexRange = indexOfItemsInView();
      if (isBetweenOrEqual(index, viewingIndexRange.min, viewingIndexRange.max)) {
        // item is already on the screen
        // print('$index is range $viewingIndexRange');
      } else {
        // item is outside the view port list

        //print('$index is Out of range $viewingIndexRange -----------');

        // make the default scroll near the top
        late double desiredNewPosition;
        if (index == viewingIndexRange.min - 1) {
          // scroll up by one
          desiredNewPosition = (_scrollController.offset - _rowHeight);
        } else {
          if (index == viewingIndexRange.max + 1) {
            desiredNewPosition = (_scrollController.offset + (_rowHeight));
          } else {
            desiredNewPosition = _rowHeight * index;
          }
        }
        int numberOfItems = (desiredNewPosition / _rowHeight).floor();
        desiredNewPosition = numberOfItems * _rowHeight;

        //print('current offset ${_scrollController.offset}, requesting $desiredNewPosition for index $index');
        _scrollController.jumpTo(desiredNewPosition);
      }
    }
  }

  void selectedItem(final int uniqueId) {
    if (widget.isMultiSelectionOn == false) {
      // single selection so remove any other selection before selecting an item
      widget.selectedItemIds.value.clear();
    }

    // only add if not already there
    if (!widget.selectedItemIds.value.contains(uniqueId)) {
      widget.selectedItemIds.value.add(uniqueId);
      widget.onSelectionChanged?.call(uniqueId);
    }
  }

  void selectedItemOffset(final int delta) {
    int newPosition = 0;
    if (widget.selectedItemIds.value.isNotEmpty) {
      newPosition = widget.selectedItemIds.value[0] + delta;
    }

    selectedItem(newPosition);
  }

  Widget _buildListItemContent(
    final bool isSelected,
    final MoneyObject itemInstance,
    final bool isLastItemOfTheList,
  ) {
    return widget.displayAsColumn
        ? itemInstance.buildFieldsAsWidgetForLargeScreen(widget.fields)
        : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? getColorTheme(context).primaryContainer : getColorTheme(context).surface,
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: isLastItemOfTheList ? Colors.transparent : Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: itemInstance.buildFieldsAsWidgetForSmallScreen(),
          );
  }
}
