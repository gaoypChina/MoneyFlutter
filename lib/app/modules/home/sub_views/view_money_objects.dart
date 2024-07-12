import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/dialog/dialog_mutate_money_object.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/info_panel/info_panel.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_views_enum.dart';
import 'package:money/app/core/widgets/message_box.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/core/widgets/working.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptable_view_with_list.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/column_filter_panel.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/multiple_selection_context.dart';
import 'package:money/app/modules/home/sub_views/money_object_card.dart';
import 'package:money/app/modules/home/sub_views/view_header.dart';

class ViewForMoneyObjects extends StatefulWidget {
  const ViewForMoneyObjects({super.key, this.includeClosedAccount = false});

  final bool includeClosedAccount;

  @override
  State<ViewForMoneyObjects> createState() => ViewForMoneyObjectsState();
}

class ViewForMoneyObjectsState extends State<ViewForMoneyObjects> {
  bool firstLoadCompleted = false;
  // list management
  List<MoneyObject> list = <MoneyObject>[];

  List<String> listOfUniqueString = <String>[];
  List<ValueSelection> listOfValueSelected = [];
  Function? onAddTransaction;
  VoidCallback? onDeleteItems;
  VoidCallback? onEditItems;
  VoidCallback? onMultiSelect;
  PreferenceController preferenceController = Get.find();
  // detail panel
  Object? subViewSelectedItem;

  // Multi selection support
  bool supportsMultiSelection = false;

  late final ViewId viewId;

  Fields<MoneyObject> _fieldToDisplay = Fields<MoneyObject>();
  FieldFilters _filterByFieldsValue = FieldFilters();
  // header
  String _filterByText = '';

  bool _isMultiSelectionOn = false;
  int _lastSelectedItemId = -1;
  InfoPanelSubViewEnum _selectedBottomTabId = InfoPanelSubViewEnum.details;
  int _selectedCurrency = 0;
  final ValueNotifier<List<int>> _selectedItemsByUniqueId = ValueNotifier<List<int>>([]);
  bool _sortAscending = true;
  int _sortByFieldIndex = 0;

  @override
  void initState() {
    super.initState();

    firstLoad();
  }

  @override
  Widget build(final BuildContext context) {
    return buildViewContent(
      Obx(() {
        final key = Key(
          '${preferenceController.includeClosedAccounts}|${list.length}|${areFiltersOn()}',
        );
        if (firstLoadCompleted == false) {
          return const WorkingIndicator();
        }
        if (list.isEmpty) {
          return centerEmptyList(key);
        }
        return AdaptiveViewWithList(
          key: key,
          top: buildHeader(),
          list: list,
          fieldDefinitions: _fieldToDisplay.definitions,
          filters: _filterByFieldsValue,
          selectedItemsByUniqueId: _selectedItemsByUniqueId,
          sortByFieldIndex: _sortByFieldIndex,
          sortAscending: _sortAscending,
          isMultiSelectionOn: _isMultiSelectionOn,
          onColumnHeaderTap: changeListSortOrder,
          onColumnHeaderLongPress: onCustomizeColumn,
          getColumnFooterWidget: getColumnFooterWidget,
          onSelectionChanged: (int _) {
            _selectedItemsByUniqueId.value = _selectedItemsByUniqueId.value.toList();
            saveLastUserChoicesOfView();
          },
          onItemTap: onItemTap,
          flexBottom: preferenceController.isDetailsPanelExpanded.value ? 1 : 0,
          bottom: InfoPanel(
            isExpanded: preferenceController.isDetailsPanelExpanded.value,
            onExpanded: (final bool isExpanded) {
              setState(() {
                preferenceController.isDetailsPanelExpanded = isExpanded;
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
            getActionButtons: getActionsButtons,
          ),
        );
      }),
    );
  }

  bool areFiltersOn() {
    if (_filterByText.isEmpty && _filterByFieldsValue.isEmpty) {
      return false;
    }
    return true;
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
      getActionButtons: getActionsButtons,
      onEditMoneyObject: onEditItems,
      onDeleteMoneyObject: onDeleteItems,
      filterText: _filterByText,
      onFilterChanged: onFilterTextChanged,
      onClearAllFilters: areFiltersOn()
          ? () {
              // remove any filters from the view
              setState(() {
                resetFiltersAndGetList();
              });
            }
          : null,
      child: child,
    );
  }

  Widget buildViewContent(final Widget child) {
    return Container(
      color: getColorTheme(context).surface,
      child: child,
    );
  }

  Widget centerEmptyList(Key key) {
    String message = 'No ${getClassNamePlural()}';
    Widget? widgetForClearFilter;
    if (areFiltersOn()) {
      message += ' found';
      widgetForClearFilter = OutlinedButton(
        onPressed: () {
          setState(() {
            resetFiltersAndGetList();
          });
        },
        child: Row(
          children: [
            const Text('Clear Filters'),
            gapSmall(),
            const Icon(Icons.filter_alt_off_outlined),
          ],
        ),
      );
    }
    return CenterMessage(
      key: key,
      message: message,
      child: widgetForClearFilter,
    );
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
      saveLastUserChoicesOfView();
    });
  }

  void clearSelection() {
    _selectedItemsByUniqueId.value = [];
    saveLastUserChoicesOfView();
  }

  void firstLoad() async {
    var all = getFieldsForTable();

    _fieldToDisplay = Fields<MoneyObject>();
    _fieldToDisplay.setDefinitions(
      all.definitions.where((element) => element.useAsColumn).toList(),
    );

    // restore last user choices for this view
    _sortByFieldIndex = preferenceController.getInt(getPreferenceKey(settingKeySortBy), 0);
    _sortAscending = preferenceController.getBool(
      getPreferenceKey(settingKeySortAscending),
      true,
    );
    _lastSelectedItemId = preferenceController.getInt(
      getPreferenceKey(settingKeySelectedListItemId),
      -1,
    );

    final int subViewIndex = PreferenceController.to.getInt(
      getPreferenceKey(settingKeySelectedDetailsPanelTab),
      InfoPanelSubViewEnum.details.index,
    );

    _selectedBottomTabId = InfoPanelSubViewEnum.values[subViewIndex];

    // Filters

    // load text filter
    _filterByText = preferenceController.getString(
      getPreferenceKey(settingKeyFilterText),
      '',
    );

    // load the column filters
    var tmpList = await preferenceController.getStringList(getPreferenceKey(settingKeyFilterColumnsText));
    _filterByFieldsValue = FieldFilters.fromList(tmpList);

    list = getList();

    /// restore selection of items
    setSelectedItem(_lastSelectedItemId);
    firstLoadCompleted = true;
  }

  List<Widget> getActionsButtons(final bool forInfoPanelTransactions) {
    List<Widget> widgets = [];

    /// Info panel header
    if (forInfoPanelTransactions) {
      if (_selectedBottomTabId == InfoPanelSubViewEnum.transactions) {
        /// Add Transactions
        if (onAddTransaction != null) {
          widgets.add(buildAddTransactionsButton(onAddTransaction!));
        }

        /// Copy Info List
        widgets.add(buildCopyButton(onCopyListFromInfoPanel));
      }
    }

    /// Main header
    else {
      /// only when there is one or more selection
      if (_selectedItemsByUniqueId.value.isNotEmpty) {
        ///  Edit
        widgets.add(
          buildEditButton(() {
            myShowDialogAndActionsForMoneyObjects(
              context: context,
              title: _selectedItemsByUniqueId.value.length == 1 ? getClassNameSingular() : getClassNamePlural(),
              moneyObjects: getSelectedItemsFromSelectedList(
                _selectedItemsByUniqueId.value,
              ),
            );
          }),
        );

        /// Delete
        widgets.add(
          buildDeleteButton(
            () {
              onUserRequestedToDelete(
                context,
                getSelectedItemsFromSelectedList(
                  _selectedItemsByUniqueId.value,
                ),
              );
            },
          ),
        );

        /// Copy List
        widgets.add(buildCopyButton(onCopyListFromMainView));
      }
    }

    return widgets;
  }

  String getClassNamePlural() {
    return 'Items';
  }

  String getClassNameSingular() {
    return 'Item';
  }

  /// to be overrident by derived class
  Widget? getColumnFooterWidget(final Field field) {
    return null;
  }

  String getCurrency() {
    // default currency for this view
    return Constants.defaultCurrency;
  }

  /// Override in your view
  List<String> getCurrencyChoices(
    final InfoPanelSubViewEnum subViewId,
    final List<int> selectedItems,
  ) {
    switch (subViewId) {
      case InfoPanelSubViewEnum.details:
      case InfoPanelSubViewEnum.chart:
      case InfoPanelSubViewEnum.transactions:
      default:
        return [];
    }
  }

  String getDescription() {
    return 'Default list of items';
  }

  /// Derived class will override to customize the fields to display in the Adaptive Table
  Fields<MoneyObject> getFieldsForTable() {
    return Fields<MoneyObject>();
  }

  MoneyObject? getFirstSelectedItem() {
    if (_selectedItemsByUniqueId.value.isNotEmpty) {
      final firstId = _selectedItemsByUniqueId.value.firstOrNull;
      if (firstId != null) {
        return list.firstWhereOrNull((moneyObject) => moneyObject.uniqueId == firstId);
      }
    }
    return null;
  }

  MoneyObject? getFirstSelectedItemFromSelectedList(
    final List<int> selectedList,
  ) {
    return getMoneyObjectFromFirstSelectedId<MoneyObject>(selectedList, list);
  }

  Widget getInfoPanelContent(
    final InfoPanelSubViewEnum subViewId,
    final List<int> selectedIds,
  ) {
    switch (subViewId) {
      /// Details
      case InfoPanelSubViewEnum.details:
        return getInfoPanelViewDetails(
          selectedIds: selectedIds,
          isReadOnly: false,
        );

      /// Chart
      case InfoPanelSubViewEnum.chart:
        return getInfoPanelViewChart(
          selectedIds: selectedIds,
          showAsNativeCurrency: _selectedCurrency == 0,
        );

      /// Transactions
      case InfoPanelSubViewEnum.transactions:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: getInfoPanelViewTransactions(
            selectedIds: selectedIds,
            showAsNativeCurrency: _selectedCurrency == 0,
          ),
        );
      default:
        return const Text('- empty -');
    }
  }

  Widget getInfoPanelHeader(
    final BuildContext context,
    final num index,
    final MoneyObject item,
  ) {
    return Center(child: Text('${getClassNameSingular()} #${index + 1}'));
  }

  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No chart to display'));
  }

  Widget getInfoPanelViewDetails({
    required final List<int> selectedIds,
    required final bool isReadOnly,
  }) {
    if (selectedIds.length > 1) {
      return CenterMessage(
        message: 'Multiple selection.(${selectedIds.length})',
      );
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
        onEdit: onUserRequestToEdit,
        onDelete: onUserRequestedToDelete,
      ),
    );
  }

  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Center(child: Text('No transactions'));
  }

  List<MoneyObject> getInfoTransactions() {
    return [];
  }

  Transaction? getLastInfoPanelTransactionSelection() {
    int selectedItemId = PreferenceController.to.getInt(getPreferenceKey('info_$settingKeySelectedListItemId'), -1);
    if (selectedItemId == -1) {
      return null;
    }
    return Data().transactions.get(selectedItemId);
  }

  List<MoneyObject> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    return <MoneyObject>[];
  }

  String getPreferenceKey(final String suffix) {
    return viewId.getViewPreferenceId(suffix);
  }

  List<MoneyObject> getSelectedItemsFromSelectedList(
    final List<int> selectedList,
  ) {
    if (selectedList.isEmpty) {
      return [];
    }

    final Set<int> selectedIds = selectedList.toSet();
    return list.where((moneyObject) => selectedIds.contains(moneyObject.uniqueId)).toList();
  }

  int? getUniqueIdOfFirstSelectedItem() {
    return _selectedItemsByUniqueId.value.firstOrNull;
  }

  /// Compile the list of single data value for a column/field definition
  List<String> getUniqueInstances(
    final Field<dynamic> columnToCustomerFilterOn,
  ) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      String fieldValue = columnToCustomerFilterOn.getValueForDisplay(moneyObject).toString();
      set.add(fieldValue);
    }
    return set.toList();
  }

  /// Compile the list of single date value for a column/field definition
  List<String> getUniqueInstancesOfDates(
    final Field<dynamic> columnToCustomerFilterOn,
  ) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      final String fieldValue = dateToString(
        columnToCustomerFilterOn.getValueForDisplay(moneyObject),
      );
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  /// Compile the list of single date value for a column/field definition
  List<String> getUniqueInstancesOfNumbers(
    final Field<dynamic> columnToCustomerFilterOn,
  ) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      final String fieldValue = formatDoubleTrimZeros(
        columnToCustomerFilterOn.getValueForDisplay(moneyObject),
      );
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort((a, b) => compareStringsAsNumbers(a, b));
    return uniqueValues;
  }

  /// Compile the list of single date value for a column/field definition
  List<String> getUniqueInstancesOfWidgets(
    final Field<dynamic> columnToCustomerFilterOn,
  ) {
    final Set<String> set = <String>{}; // This is a Set()
    final List<MoneyObject> list = getList(applyFilter: false);
    for (final moneyObject in list) {
      final String fieldValue = columnToCustomerFilterOn.getValueForSerialization(moneyObject).toString();
      set.add(fieldValue);
    }
    final List<String> uniqueValues = set.toList();
    uniqueValues.sort();
    return uniqueValues;
  }

  /// must override this in each view
  String getViewId() {
    return '_id_';
  }

  bool isMatchingFilters(final MoneyObject instance) {
    if (areFiltersOn()) {
      // apply filtering
      return getFieldsForTable().applyFilters(
        instance,
        _filterByText,
        _filterByFieldsValue,
      );
    }
    return true;
  }

  void onCopyListFromInfoPanel() {
    final listToCopy = getInfoTransactions();
    copyToClipboardAndInformUser(
      context,
      MoneyObjects.getCsvFromList(listToCopy, forSerialization: true),
    );
  }

  void onCopyListFromMainView() {
    copyToClipboardAndInformUser(
      context,
      MoneyObjects.getCsvFromList(list, forSerialization: false),
    );
  }

  void onCustomizeColumn(final Field<dynamic> fieldDefinition) {
    Widget content;
    listOfValueSelected.clear();

    switch (fieldDefinition.type) {
      case FieldType.quantity:
        {
          listOfUniqueString = getUniqueInstancesOfNumbers(fieldDefinition);

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: TextAlign.right,
          );
        }

      case FieldType.date:
        {
          listOfUniqueString = getUniqueInstancesOfDates(fieldDefinition);

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: TextAlign.left,
          );
        }

      case FieldType.widget:
        {
          listOfUniqueString = getUniqueInstancesOfWidgets(fieldDefinition);

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: TextAlign.left,
          );
        }

      case FieldType.text:
      default:
        {
          listOfUniqueString = getUniqueInstances(fieldDefinition);

          if (fieldDefinition.type == FieldType.amount) {
            listOfUniqueString.sort((a, b) => compareStringsAsAmount(a, b));
          } else {
            listOfUniqueString.sort();
          }

          for (final item in listOfUniqueString) {
            listOfValueSelected.add(ValueSelection(name: item, isSelected: true));
          }

          content = ColumnFilterPanel(
            listOfUniqueInstances: listOfValueSelected,
            textAlign: fieldDefinition.type == FieldType.amount ? TextAlign.right : TextAlign.left,
          );
        }
    }

    adaptiveScreenSizeDialog(
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

              saveLastUserChoicesOfView();

              list = getList();
            });
          },
        ),
      ],
    );
  }

  void onFilterTextChanged(final String text) {
    setState(() {
      _filterByText = text.toLowerCase();
      saveLastUserChoicesOfView();
      list = getList();
    });
  }

  void onItemTap(final BuildContext context, final int uniqueId) {
    if (isMobile()) {
      adaptiveScreenSizeDialog(
        context: context,
        title: '${getClassNameSingular()} #${uniqueId + 1}',
        actionButtons: [],
        child: getInfoPanelViewDetails(
          selectedIds: <int>[uniqueId],
          isReadOnly: true,
        ),
      );
    }
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

  void onSort() {
    MoneyObjects.sortList(
      list,
      _fieldToDisplay.definitions,
      _sortByFieldIndex,
      _sortAscending,
    );
  }

  void onUserRequestToEdit(
    final BuildContext context,
    final List<MoneyObject> moneyObjects,
  ) {
    myShowDialogAndActionsForMoneyObjects(
      context: context,
      title: getSingularPluralText(
        'Edit',
        moneyObjects.length,
        getClassNameSingular(),
        getClassNamePlural(),
      ),
      moneyObjects: moneyObjects,
    );
  }

  void onUserRequestedToDelete(
    final BuildContext context,
    final List<MoneyObject> moneyObjects,
  ) {
    if (moneyObjects.isEmpty) {
      messageBox(context, 'No items to delete');
      return;
    }

    final String nameSingular = getClassNameSingular();
    final String namePlural = getClassNamePlural();

    final String title = getSingularPluralText(
      'Delete',
      moneyObjects.length,
      nameSingular,
      namePlural,
    );

    final String question = moneyObjects.length == 1
        ? 'Are you sure you want to delete this $nameSingular?'
        : 'Are you sure you want to delete the ${moneyObjects.length} selected $namePlural?';
    final content = moneyObjects.length == 1
        ? Column(
            children: moneyObjects.first.buildListOfNamesValuesWidgets(onEdit: null, compact: true),
          )
        : Center(
            child: Text(
              '${getIntAsText(moneyObjects.length)} $namePlural',
              style: getTextTheme(context).displaySmall,
            ),
          );

    showConfirmationDialog(
      context: context,
      title: title,
      question: question,
      content: content,
      buttonText: 'Delete',
      onConfirmation: () {
        Data().deleteItems(moneyObjects);
      },
    );
  }

  void resetFiltersAndGetList() {
    _filterByText = '';
    _filterByFieldsValue.clear();

    saveLastUserChoicesOfView();
    list = getList();
  }

  void saveLastUserChoicesOfView() {
    // Persist users choice
    preferenceController.setInt(
      getPreferenceKey(settingKeySortBy),
      _sortByFieldIndex,
    );
    preferenceController.setBool(
      getPreferenceKey(settingKeySortAscending),
      _sortAscending,
    );
    PreferenceController.to.setInt(
      getPreferenceKey(settingKeySelectedListItemId),
      getUniqueIdOfFirstSelectedItem() ?? -1,
    );
    preferenceController.setInt(
      getPreferenceKey(settingKeySelectedDetailsPanelTab),
      _selectedBottomTabId.index,
    );
    preferenceController.setString(
      getPreferenceKey(settingKeyFilterText),
      _filterByText,
    );
    PreferenceController.to.setStringList(
      getPreferenceKey(settingKeyFilterColumnsText),
      _filterByFieldsValue.toStringList(),
    );
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

      // persist the last selected item index
      preferenceController.setInt(
        getPreferenceKey(settingKeySelectedListItemId),
        _lastSelectedItemId,
      );
    });
  }

  void updateBottomContent(final InfoPanelSubViewEnum tab) {
    setState(() {
      _selectedBottomTabId = tab;
      saveLastUserChoicesOfView();
    });
  }

  void updateListAndSelect(final int uniqueId) {
    setState(() {
      clearSelection();
      list = getList();
      firstLoadCompleted = true;
      setSelectedItem(uniqueId);
    });
  }
}
