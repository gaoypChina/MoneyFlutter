part of 'view_categories.dart';

extension ViewCategoriesDetailsPanels on ViewCategoriesState {
  /// Details panels Chart panel for Categories
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Map<String, num> map = <String, num>{};

    for (final Category item in getList()) {
      if (item.name.value != 'Split' && item.name.value != 'Xfer to Deleted Account') {
        final Category topCategory = Data().categories.getTopAncestor(item);
        if (map[topCategory.name.value] == null) {
          map[topCategory.name.value] = 0;
        }
        map[topCategory.name.value] = map[topCategory.name.value]! + item.sum.value.amount;
      }
    }
    final List<PairXY> list = <PairXY>[];
    map.forEach((final String key, final num value) {
      list.add(PairXY(key, value));
    });

    list.sort((final PairXY a, final PairXY b) {
      return (b.yValue.abs() - a.yValue.abs()).toInt();
    });

    return Chart(
      key: Key(selectedIds.toString()),
      list: list.take(10).toList(),
      variableNameHorizontal: 'Category',
      variableNameVertical: 'Balance',
    );
  }

  // Details Panel for Transactions Categories
  Widget _getSubViewContentForTransactions(final List<int> selectedIds) {
    final Category? category = getMoneyObjectFromFirstSelectedId<Category>(selectedIds, list);
    if (category != null) {
      final List<int> listOfDescendentCategories = <int>[];
      Data().categories.getTreeIdsRecursive(category.uniqueId, listOfDescendentCategories);

      return ListViewTransactions(
        key: Key(category.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdPayee),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
          filter: (final Transaction transaction) => listOfDescendentCategories.contains(transaction.categoryId.value),
        ),
      );
    }
    return CenterMessage.noTransaction();
  }
}
