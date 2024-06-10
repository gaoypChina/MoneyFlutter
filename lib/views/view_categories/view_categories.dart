import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/view_categories/merge_categories.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/three_part_label.dart';

part 'view_categories_details_panels.dart';

class ViewCategories extends ViewForMoneyObjects {
  const ViewCategories({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends ViewForMoneyObjectsState {
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, false, false, false, true];

  ViewCategoriesState() {
    onAddItem = () {
      // add a new Account
      final newItem = Data().categories.addNewCategory('New Category');
      updateListAndSelect(newItem.uniqueId);
    };
  }

  @override
  void initState() {
    super.initState();

    pivots.add(ThreePartLabel(
        text1: 'None',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.none]))));
    pivots.add(ThreePartLabel(
        text1: 'Expense',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
            getTotalBalanceOfAccounts(<CategoryType>[CategoryType.expense, CategoryType.recurringExpense]))));
    pivots.add(ThreePartLabel(
        text1: 'Income',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.income]))));
    pivots.add(ThreePartLabel(
        text1: 'Saving',
        small: true,
        isVertical: true,
        text2:
            Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[CategoryType.saving]))));
    pivots.add(ThreePartLabel(
        text1: 'Investment',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(
            getTotalBalanceOfAccounts(<CategoryType>[CategoryType.investment]))));
    pivots.add(ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(<CategoryType>[]))));
  }

  double getTotalBalanceOfAccounts(final List<CategoryType> types) {
    double total = 0.0;
    getList().forEach((final Category category) {
      if (types.isEmpty || (category).type.value == types.first) {
        total += category.sum.value.amount;
      }
    });
    return total;
  }

  @override
  String getClassNamePlural() {
    return 'Categories';
  }

  @override
  String getClassNameSingular() {
    return 'Category';
  }

  @override
  String getDescription() {
    return 'Classification of your money transactions.';
  }

  @override
  String getViewId() {
    return Data().categories.getTypeName();
  }

  @override
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(renderToggles());
  }

  /// add more top leve action buttons
  @override
  List<Widget> getActionsForSelectedItems(final bool forInfoPanelTransactions) {
    final list = super.getActionsForSelectedItems(forInfoPanelTransactions);
    if (!forInfoPanelTransactions) {
      /// Merge
      final MoneyObject? moneyObject = getFirstSelectedItem();
      if (moneyObject != null) {
        list.add(
          buildMergeButton(
            () {
              // let the user pick another Category and move the transactions of the current selected Category to the destination
              adaptiveScreenSizeDialog(
                  context: context,
                  title: 'Move Category',
                  captionForClose: 'Cancel', // this will hide the close button
                  child: MergeCategoriesTransactionsDialog(categoryToMove: getFirstSelectedItem() as Category));
            },
          ),
        );
      }
    }
    return list;
  }

  @override
  Fields<Category> getFieldsForTable() {
    return Category.fields ?? Fields<Category>();
  }

  @override
  List<Category> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<CategoryType> filterType = getSelectedCategoryType();
    return Data()
        .categories
        .iterableList(includeDeleted: includeDeleted)
        .where((final Category instance) =>
            (filterType.isEmpty || filterType.contains(instance.type.value)) &&
            (applyFilter == false || isMatchingFilters(instance)))
        .toList();
  }

  List<CategoryType> getSelectedCategoryType() {
    if (_selectedPivot[0]) {
      return [CategoryType.none];
    }
    if (_selectedPivot[1]) {
      return [CategoryType.expense, CategoryType.recurringExpense];
    }
    if (_selectedPivot[2]) {
      return [CategoryType.income];
    }
    if (_selectedPivot[3]) {
      return [CategoryType.saving];
    }
    if (_selectedPivot[4]) {
      return [CategoryType.investment];
    }

    return []; // all
  }

  Widget renderToggles() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (final int index) {
            setState(() {
              for (int i = 0; i < _selectedPivot.length; i++) {
                _selectedPivot[i] = i == index;
              }
              list = getList();
              clearSelection();
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 100.0,
          ),
          isSelected: _selectedPivot,
          children: pivots,
        ));
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(selectedIds: selectedIds, showAsNativeCurrency: showAsNativeCurrency);
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }
}
