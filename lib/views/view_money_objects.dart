import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptable_view_with_list.dart';
import 'package:money/views/adaptive_view/adaptive_list/column_filter_panel.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';
import 'package:money/views/adaptive_view/adaptive_list/multiple_selection_context.dart';
import 'package:money/views/view_header.dart';
import 'package:money/views/view_transactions/money_object_card.dart';
import 'package:money/widgets/details_panel/info_panel.dart';
import 'package:money/widgets/details_panel/info_panel_header.dart';
import 'package:money/widgets/details_panel/info_panel_views_enum.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/widgets/widgets.dart';

import '../models/fields/field_filter.dart';

class ViewForMoneyObjects extends StatefulWidget {
  const ViewForMoneyObjects({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewForMoneyObjectsState();
}

class ViewForMoneyObjectsState extends State<ViewForMoneyObjects> {
  // list management
  List<MoneyObject> list = <MoneyObject>[];
  final ValueNotifier<List<int>> _selectedItemsByUniqueId = ValueNotifier<List<int>>([]);
  Fields<MoneyObject> _fieldToDisplay = Fields<MoneyObject>();
  List<String> listOfUniqueString = <String>[];
  List<ValueSelection> listOfValueSelected = [];
  int _lastSelectedItemId = -1;
  int _sortByFieldIndex = 0;
  bool _sortAscending = true;

  // Multi selection support
  bool supportsMultiSelection = false;
  bool _isMultiSelectionOn = false;
  VoidCallback? onMultiSelect;

  VoidCallback? onAddNewEntry;
  VoidCallback? onEdit;
  VoidCallback? onDelete;
  VoidCallback? onCopyInfoPanelTransactions;

  Function(BuildContext, MoneyObject)? onMergeToItem;

  // detail panel
  Object? subViewSelectedItem;
  InfoPanelSubViewEnum _selectedBottomTabId = InfoPanelSubViewEnum.details;
  int _selectedCurrency = 0;

  // header
  String _filterByText = '';
  final List<FieldFilter> _filterByFieldsValue = [];
  Timer? _deadlineTimer;
  Function? onAddTransaction;

  ViewForMoneyObjectsState() {
    // support Edit by default
    // if not the desired UX, the derived class can set [onEdit] to null
    onEdit = () {
      showDialogAndActionsForMoneyObjects(
        context,
        getSelectedItemFromSelectedList(_selectedItemsByUniqueId.value),
      );
    };

    // support Delete by default
    // if not the desired UX, the derived class can set [onDelete] to null
    onDelete = () {
      onDeleteRequestedByUser(
        context,
        getFirstSelectedItem() as MoneyObject,
      );
    };
  }

  /// Derived class will override to customize the fields to display in the Adaptive Table
  Fields<MoneyObject> getFieldsForTable() {
    return Fields<MoneyObject>();
  }

  @override
  void initState() {
    super.initState();

    var all = getFieldsForTable();
    _fieldToDisplay = Fields<MoneyObject>();
    _fieldToDisplay.setDefinitions(all.definitions.where((element) => element.useAsColumn).toList());

    final MyJson? viewSetting = Settings().views[getClassNameSingular()];
    if (viewSetting != null) {
      _sortByFieldIndex = viewSetting.getInt(settingKeySortBy, 0);
      _sortAscending = viewSetting.getBool(settingKeySortAscending, true);
      _lastSelectedItemId = viewSetting.getInt(settingKeySelectedListItemId, -1);
      final int subViewIndex =
          viewSetting.getInt(settingKeySelectedDetailsPanelTab, InfoPanelSubViewEnum.details.index);
      _selectedBottomTabId = InfoPanelSubViewEnum.values[subViewIndex];
    }

    list = getList();

    /// restore selection of items
    setSelectedItem(_lastSelectedItemId);
  }

  @override
  Widget build(final BuildContext context) {
    return buildViewContent(
      AdaptiveViewWithList(
        top: buildHeader(),
        fieldDefinitions: _fieldToDisplay.definitions,
        list: list,
        selectedItemsByUniqueId: _selectedItemsByUniqueId,
        sortByFieldIndex: _sortByFieldIndex,
        sortAscending: _sortAscending,
        isMultiSelectionOn: _isMultiSelectionOn,
        onColumnHeaderTap: changeListSortOrder,
        onColumnHeaderLongPress: onCustomizeColumn,
        onSelectionChanged: () {
          _selectedItemsByUniqueId.value = _selectedItemsByUniqueId.value.toList();
        },
        onItemTap: onItemTap,
        flexBottom: Settings().isDetailsPanelExpanded ? 1 : 0,
        bottom: InfoPanel(
          isExpanded: Settings().isDetailsPanelExpanded,
          onExpanded: (final bool isExpanded) {
            setState(() {
              Settings().isDetailsPanelExpanded = isExpanded;
              Settings().store();
            });
          },
          selectedItems: _selectedItemsByUniqueId,

          // SubView
          subPanelSelected: _selectedBottomTabId,
          subPanelSelectionChanged: updateBottomContent,
          subPanelContent: getInfoPanelContent,

          // Currency
          getCurrencyChoices: getCurrencyChoices,
          currencySelected: _selectedCurrency,
          currencySelectionChanged: (final int selected) {
            setState(() {
              _selectedCurrency = selected;
            });
          },

          /// Actions
          actionButtons: [
            /// Add
            if (onAddTransaction != null)
              InfoPanelHeader.buildAddButton(
                onAddTransaction!,
              ),

            const Spacer(),

            /// Copy
            if (_selectedBottomTabId == InfoPanelSubViewEnum.transactions && onCopyInfoPanelTransactions != null)
              InfoPanelHeader.buildCopyButton(
                onCopyInfoPanelTransactions!,
              ),
          ],
        ),
      ),
    );
  }

  void onSelectAll(final bool selectAll) {
    setState(() {
      _selectedItemsByUniqueId.value.clear();
      if (selectAll) {
        for (final item in list) {
          _selectedItemsByUniqueId.value.add(item.uniqueId);
        }
      }
    });
  }

  Widget buildViewContent(final Widget child) {
    return Container(
      color: getColorTheme(context).surface,
      child: child,
    );
  }

  Widget buildHeader([final Widget? child]) {
    ViewHeaderMultipleSelection? multipleSelectionOptions;
    if (supportsMultiSelection) {
      multipleSelectionOptions = ViewHeaderMultipleSelection(
        selectedItems: _selectedItemsByUniqueId,
        isMultiSelectionOn: _isMultiSelectionOn,
        onToggleMode: () {
          setState(() {
            _isMultiSelectionOn = !_isMultiSelectionOn;
            if (!_isMultiSelectionOn) {
              setSelectedItem(-1);
            }
          });
        },
      );
    }

    return ViewHeader(
      key: Key(_selectedItemsByUniqueId.value.length.toString()),
      title: getClassNamePlural(),
      itemCount: list.length,
      selectedItems: _selectedItemsByUniqueId,
      description: getDescription(),
      multipleSelection: multipleSelectionOptions,
      onAddNewEntry: onAddNewEntry,
      onEdit: onEdit,
      onDelete: onDelete,
      onFilterChanged: onFilterTextChanged,
      child: child,
    );
  }

  String getClassNameSingular() {
    return 'Item';
  }

  String getClassNamePlural() {
    return 'Items';
  }

  String getDescription() {
    return 'Default list of items';
  }

  String getCurrency() {
    // default currency for this view
    return Constants.defaultCurrency;
  }

  List<MoneyObject> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return <MoneyObject>[];
  }

  void clearSelection() {
    _selectedItemsByUniqueId.value = [];
  }

  void onSort() {
    if (isIndexInRange(_fieldToDisplay.definitions, _sortByFieldIndex)) {
      final Field<dynamic> fieldDefinition = _fieldToDisplay.definitions[_sortByFieldIndex];
      if (fieldDefinition.sort == null) {
        // No sorting function found, fallback to String sorting
        list.sort((final MoneyObject a, final MoneyObject b) {
          return sortByString(
            fieldDefinition.valueFromInstance(a).toString(),
            fieldDefinition.valueFromInstance(b).toString(),
            _sortAscending,
          );
        });
      } else {
        list.sort((final MoneyObject a, final MoneyObject b) {
          return fieldDefinition.sort!(a, b, _sortAscending);
        });
      }
    }
  }

  void onDeleteRequestedByUser(final BuildContext context, final MoneyObject? myMoneyObjectInstance) {
    if (myMoneyObjectInstance != null) {
      showDialog(
        context: context,
        builder: (final BuildContext context) {
          return Center(
            child: DeleteConfirmationDialog(
              title: 'Delete ${getClassNameSingular()}',
              question: 'Are you sure you want to delete this ${getClassNameSingular()}?',
              content: Column(
                children: myMoneyObjectInstance.buildWidgets(onEdit: null, compact: true),
              ),
              onConfirm: () {
                onDeleteConfirmedByUser(myMoneyObjectInstance);
              },
            ),
          );
        },
      );
    }
  }

  void onDeleteConfirmedByUser(final MoneyObject instance) {
    // Derived view need to make the actual delete operation
  }

  void onFilterTextChanged(final String text) {
    _deadlineTimer?.cancel();
    _deadlineTimer = Timer(const Duration(milliseconds: 500), () {
      _deadlineTimer = null;
      setState(() {
        _filterByText = text.toLowerCase();
        list = getList();
      });
    });
  }

  bool isMatchingFilters(final MoneyObject instance) {
    if (_filterByText.isEmpty && _filterByFieldsValue.isEmpty) {
      // nothing to filter by
      return true;
    }

    // apply filtering
    return getFieldsForTable().applyFilters(
      instance,
      _filterByText,
      _filterByFieldsValue,
    );
  }

  void updateBottomContent(final InfoPanelSubViewEnum tab) {
    setState(() {
      _selectedBottomTabId = tab;
      saveLastUserActionOnThisView();
    });
  }

  Widget getInfoPanelContent(final InfoPanelSubViewEnum subViewId, final List<int> selectedIds) {
    switch (subViewId) {
      /// Details
      case InfoPanelSubViewEnum.details:
        return getInfoPanelViewDetails(selectedIds: selectedIds, isReadOnly: false);

      /// Chart
      case InfoPanelSubViewEnum.chart:
        return getInfoPanelViewChart(selectedIds: selectedIds, showAsNativeCurrency: _selectedCurrency == 0);

      /// Transactions
      case InfoPanelSubViewEnum.transactions:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: getInfoPanelViewTransactions(selectedIds: selectedIds, showAsNativeCurrency: _selectedCurrency == 0),
        );
      default:
        return const Text('- empty -');
    }
  }

  /// Override in your view
  List<String> getCurrencyChoices(final InfoPanelSubViewEnum subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case InfoPanelSubViewEnum.details:
      case InfoPanelSubViewEnum.chart:
      case InfoPanelSubViewEnum.transactions:
      default:
        return [];
    }
  }

  void setSelectedItem(final int uniqueId) {
    // This will cause a UI update and the bottom details will get rendered if its expanded
    setState(() {
      //
      if (uniqueId == -1) {
        // clear
        _selectedItemsByUniqueId.value.clear();
      } else {
        if (!_selectedItemsByUniqueId.value.contains(uniqueId)) {
          // _selectedItemsByUniqueId.value = <int>[uniqueId];
          _selectedItemsByUniqueId.value.add(uniqueId);
        }
      }

      // call this to persist the last selected item index
      saveLastUserActionOnThisView();
    });
  }

  void onItemTap(final BuildContext context, final int uniqueId) {
    if (isMobile()) {
      myShowDialog(
        context: context,
        title: '${getClassNameSingular()} #${uniqueId + 1}',
        actionButtons: [],
        child: getInfoPanelViewDetails(selectedIds: <int>[uniqueId], isReadOnly: true),
      );
    }
  }

  MoneyObject? getFirstSelectedItem() {
    return getFirstSelectedItemFromSelectedList(_selectedItemsByUniqueId.value);
  }

  MoneyObject? getFirstSelectedItemFromSelectedList(final List<int> selectedList) {
    return getMoneyObjectFromFirstSelectedId<MoneyObject>(selectedList, list);
  }

  List<MoneyObject> getSelectedItemFromSelectedList(final List<int> selectedList) {
    List<MoneyObject> moneyObjects = [];

    for (int uniqueId in selectedList) {
      moneyObjects.add(list.firstWhere((moneyObject) => moneyObject.uniqueId == uniqueId));
    }
    return moneyObjects;
  }

  int? getUniqueIdOfFirstSelectedItem() {
    return _selectedItemsByUniqueId.value.firstOrNull;
  }

  Widget getInfoPanelHeader(final BuildContext context, final num index, final MoneyObject item) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getInfoPanelViewDetails({required final List<int> selectedIds, required final bool isReadOnly}) {
    if (selectedIds.length > 1) {
      return CenterMessage(message: 'Multiple selection.(${selectedIds.length})');
    }

    final MoneyObject? moneyObject = findObjectById(selectedIds.firstOrNull, list);

    if (moneyObject == null) {
      return const CenterMessage(message: 'No item selected.');
    }

    return SingleChildScrollView(
      key: Key('detail_panel_${moneyObject.uniqueId}'),
      child: MoneyObjectCard(
        title: getClassNameSingular(),
        moneyObject: moneyObject,
        onMergeWith: onMergeToItem,
        onEdit: showDialogAndActionsForMoneyObject,
        onDelete: onDeleteRequestedByUser,
      ),
    );
  }

  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No chart to display'));
  }

  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No transactions'));
  }

  void changeListSortOrder(final int columnNumber) {
    setState(() {
      if (columnNumber == _sortByFieldIndex) {
        // toggle order
        _sortAscending = !_sortAscending;
      } else {
        _sortByFieldIndex = columnNumber;
      }

      // Persist users choice
      saveLastUserActionOnThisView();
    });
  }

  void saveLastUserActionOnThisView() {
    // Persist users choice
    Settings().views[getClassNameSingular()] = <String, dynamic>{
      settingKeySortBy: _sortByFieldIndex,
      settingKeySortAscending: _sortAscending,
      settingKeySelectedListItemId: getUniqueIdOfFirstSelectedItem(),
      settingKeySelectedDetailsPanelTab: _selectedBottomTabId.index,
    };

    Settings().store();
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == _sortByFieldIndex) {
      return _sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  /// Compile the list of single data value for a column/field definition
  List<String> getUniqueInstances(final Field<dynamic> columnToCustomerFilterOn) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      String fieldValue = columnToCustomerFilterOn.valueFromInstance(moneyObject).toString();
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  List<double> getMinMaxValues(final Field<dynamic> fieldDefinition) {
    double min = 0.0;
    double max = 0.0;
    final List<MoneyObject> list = getList(applyFilter: false);
    for (int i = 0; i < list.length; i++) {
      dynamic fieldValue = fieldDefinition.valueFromInstance(list[i]);

      if (fieldDefinition.type == FieldType.amount && fieldValue is String) {
        fieldValue = attemptToGetDoubleFromText(fieldValue) ?? 0;
      }

      if (min > fieldValue) {
        min = fieldValue;
      }
      if (max < fieldValue) {
        max = fieldValue;
      }
    }

    return <double>[min, max];
  }

  List<String> getMinMaxDates(final Field<dynamic> columnToCustomerFilterOn) {
    String min = '';
    String max = '';

    for (final item in getList(applyFilter: false)) {
      final String fieldValue = columnToCustomerFilterOn.valueFromInstance(item) as String;
      if (min.isEmpty || min.compareTo(fieldValue) == 1) {
        min = fieldValue;
      }
      if (max.isEmpty || max.compareTo(fieldValue) == -1) {
        max = fieldValue;
      }
    }

    return <String>[min, max];
  }

  void onCustomizeColumn(final Field<dynamic> fieldDefinition) {
    Widget content;

    switch (fieldDefinition.type) {
      case FieldType.amount:
        {
          final List<double> minMax = getMinMaxValues(fieldDefinition);
          content = SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(Currency.getAmountAsStringUsingCurrency(minMax[0])),
                Text(Currency.getAmountAsStringUsingCurrency(minMax[1])),
              ],
            ),
          );
        }

      case FieldType.date:
        {
          final List<String> minMax = getMinMaxDates(fieldDefinition);
          content = SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(minMax[0]),
                Text(minMax[1]),
              ],
            ),
          );
        }
      case FieldType.text:
      default:
        {
          listOfUniqueString = getUniqueInstances(fieldDefinition);
          listOfValueSelected.clear();
          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }
          content = ColumnFilterPanel(listOfUniqueInstances: listOfValueSelected);
        }
    }

    myShowDialog(
      context: context,
      title: 'Column Filter (${fieldDefinition.name})',
      child: content,
      actionButtons: [
        DialogActionButton(
          text: 'Apply',
          onPressed: () {
            Navigator.of(context).pop(false);
            setState(() {
              _filterByFieldsValue.clear();
              for (final value in listOfValueSelected) {
                if (value.isSelected) {
                  FieldFilter fieldFilter = FieldFilter(
                    fieldName: fieldDefinition.name,
                    filterTextInLowerCase: value.name,
                  );
                  _filterByFieldsValue.add(fieldFilter);
                }
              }
              if (_filterByFieldsValue.length == listOfValueSelected.length) {
                // all unique values are selected so clear the column filter;
                _filterByFieldsValue.clear();
              }
              list = getList();
            });
          },
        )
      ],
    );
  }
}
