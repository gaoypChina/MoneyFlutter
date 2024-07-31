import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

class Categories extends MoneyObjects<Category> {
  Categories() {
    collectionName = 'Categories';
  }

  @override
  Category instanceFromSqlite(final MyJson row) {
    return Category.fromJson(row);
  }

  @override
  void onAllDataLoaded() {
    // reset to zero all counters and sums
    for (final Category category in iterableList()) {
      category.fieldTransactionCount.value = 0;
      category.fieldSum.value.setAmount(0);

      category.fieldTransactionCountRollup.value = 0;
      category.fieldSumRollup.value.setAmount(0);
    }

    // first tally the direct category transactions
    for (final Transaction t in Data().transactions.iterableList()) {
      final Category? item = get(t.fieldCategoryId.value);
      if (item != null) {
        item.fieldTransactionCount.value++;
        item.fieldSum.value += t.fieldAmount.value.toDouble();
        item.fieldTransactionCountRollup.value++;
        item.fieldSumRollup.value += t.fieldAmount.value.toDouble();

        List<Category> ancestors = [];
        item.getAncestors(ancestors);
        for (final ancestorCategory in ancestors) {
          ancestorCategory.fieldTransactionCountRollup.value++;
          ancestorCategory.fieldSumRollup.value += t.fieldAmount.value;
        }
      }
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  static int idOfSplitCategory = -1;

  /// Add a new Category ensure that the name is unique under the parent or root
  Category addNewCategory({final int parentId = -1, final String name = 'New Cagtegory'}) {
    Category? parent = Data().categories.get(parentId);
    // find next available name
    String prefixName = parent == null ? name : '${parent.fieldName.value}:$name';
    String nextAvailableName = prefixName;
    int next = 1;
    while ((getByName(nextAvailableName) != null)) {
      // already taken
      nextAvailableName = '$name $next';
      // the the next one
      next++;
    }

    CategoryType typeToUse = CategoryType.expense;

    if (parent != null) {
      typeToUse = parent.fieldType.value;
    }

    // add a new Category
    final Category category = Category(
      id: -1,
      parentId: parentId,
      name: nextAvailableName,
      type: typeToUse,
    );

    Data().categories.appendNewMoneyObject(category);

    return category;
  }

  Category appenNewCategory({
    required int parentId,
    required String name,
    required final CategoryType type,
  }) {
    final category = Category(
      id: -1,
      parentId: parentId,
      name: name,
      type: type,
    );

    appendNewMoneyObject(category);
    return category;
  }

  Category ensureAncestorExist(
    final String categoryName,
    final CategoryType typeToUseIfMissing,
  ) {
    final List<String> categoryNameParts = categoryName.split(':');

    int parentCategoryId = -1;
    String cumulativeCategoryName = '';

    for (final String part in categoryNameParts) {
      cumulativeCategoryName = cumulativeCategoryName.isEmpty ? part : '$cumulativeCategoryName:$part';

      Category category = getByName(cumulativeCategoryName) ??
          appenNewCategory(
            parentId: parentCategoryId,
            name: cumulativeCategoryName,
            type: typeToUseIfMissing,
          );
      parentCategoryId = category.uniqueId;
    }
    return getByName(categoryName)!;
  }

  Category? getByName(final String name) {
    return iterableList().firstWhereOrNull((final Category category) => category.fieldName.value == name);
  }

  List<Category> getCategoriesWithThisParent(final int parentId) {
    final List<Category> list = <Category>[];
    for (final Category item in iterableList()) {
      if (item.fieldParentId.value == parentId) {
        list.add(item);
      }
    }
    return list;
  }

  List<Category> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.fieldName.value, b.fieldName.value, true));
    return list;
  }

  String getNameFromId(final int id) {
    if (id == -1) {
      return '';
    }

    if (id == splitCategoryId()) {
      return '<Split>';
    }
    return Category.getName(get(id));
  }

  Category getOrCreate(
    final String name,
    final CategoryType type,
  ) {
    Category? category = getByName(name);

    if (category == null) {
      category = ensureAncestorExist(name, type);
    } else {
      if (category.isDeleted) {
        category.mutation = MutationType.none; // Bring it back to life
      }
    }

    return category;
  }

  Category getTopAncestor(final Category category) {
    if (category.fieldParentId.value == -1) {
      return category; // this is the top
    }
    final Category? parent = get(category.fieldParentId.value);
    if (parent == null) {
      return category;
    }
    return getTopAncestor(parent);
  }

  List<Category> getTree(final Category rootCategoryToStartFrom) {
    final List<Category> list = <Category>[];
    getTreeRecursive(rootCategoryToStartFrom, list);
    return list;
  }

  List<int> getTreeIds(final int rootIdToStartFrom) {
    final List<int> list = <int>[];
    if (rootIdToStartFrom > 0) {
      getTreeIdsRecursive(rootIdToStartFrom, list);
    }
    return list;
  }

  void getTreeIdsRecursive(final int categoryId, final List<int> list) {
    if (categoryId > 0) {
      list.add(categoryId);
      final List<Category> descendants = getCategoriesWithThisParent(categoryId);
      for (final Category c in descendants) {
        getTreeIdsRecursive(c.fieldId.value, list);
      }
    }
  }

  void getTreeRecursive(final Category category, final List<Category> list) {
    list.add(category);
    final List<Category> descendants = getCategoriesWithThisParent(category.uniqueId);
    for (final Category c in descendants) {
      getTreeRecursive(c, list);
    }
  }

  Category get interestEarned {
    return getOrCreate('Savings:Interest', CategoryType.income);
  }

  Category get investmentBonds {
    return getOrCreate('Investments:Bonds', CategoryType.expense);
  }

  Category get investmentCredit {
    return getOrCreate('Investments:Credit', CategoryType.income);
  }

  Category get investmentDebit {
    return getOrCreate('Investments:Debit', CategoryType.expense);
  }

  Category get investmentDividends {
    return getOrCreate('Investments:Dividends', CategoryType.income);
  }

  Category get investmentFees {
    return getOrCreate('Investments:Fees', CategoryType.expense);
  }

  Category get investmentInterest {
    return getOrCreate('Investments:Interest', CategoryType.income);
  }

  Category get investmentLongTermCapitalGainsDistribution {
    return getOrCreate('Investments:Long Term Capital Gains Distribution', CategoryType.income);
  }

  Category get investmentMiscellaneous {
    return getOrCreate('Investments:Miscellaneous', CategoryType.expense);
  }

  Category get investmentMutualFunds {
    return getOrCreate('Investments:Mutual Funds', CategoryType.expense);
  }

  Category get investmentOptions {
    return getOrCreate('Investments:Options', CategoryType.expense);
  }

  Category get investmentOther {
    return getOrCreate('Investments:Other', CategoryType.expense);
  }

  Category get investmentReinvest {
    return getOrCreate('Investments:Reinvest', CategoryType.none);
  }

  Category get investmentShortTermCapitalGainsDistribution {
    return getOrCreate('Investments:Short Term Capital Gains Distribution', CategoryType.income);
  }

  Category get investmentStocks {
    return getOrCreate('Investments:Stocks', CategoryType.expense);
  }

  Category get investmentTransfer {
    return getOrCreate('Investments:Transfer', CategoryType.none);
  }

  bool isCategoryAnExpense(final int categoryId) {
    final Category? category = get(categoryId);
    if (category == null) {
      return false;
    }
    return category.fieldType.value == CategoryType.expense ||
        category.fieldType.value == CategoryType.recurringExpense;
  }

  void reparentCategory(final Category categoryToReparent, final Category newParentCategory) {
    categoryToReparent.stashValueBeforeEditing();
    categoryToReparent.fieldParentId.value = newParentCategory.uniqueId;

    final descendants = getTreeIds(categoryToReparent.uniqueId);
    for (final id in descendants) {
      final category = get(id);
      if (category != null) {
        category.updateNameBaseOnParent();
      }
    }

    Data().updateAll();
  }

  Category get salesTax {
    return getOrCreate('Taxes:Sales Tax', CategoryType.expense);
  }

  Category get savings {
    return getOrCreate('Savings', CategoryType.income);
  }

  Category get split {
    return getOrCreate('Split', CategoryType.none);
  }

  int splitCategoryId() {
    if (idOfSplitCategory == -1) {
      final Category? cat = getByName('Split');
      if (cat != null) {
        idOfSplitCategory = cat.fieldId.value;
      }
    }
    return idOfSplitCategory;
  }

  Category get transfer {
    return getOrCreate('Transfer', CategoryType.none);
  }

  Category get transferFromDeletedAccount {
    return getOrCreate('Xfer from Deleted Account', CategoryType.none);
  }

  Category get transferToDeletedAccount {
    return getOrCreate('Xfer to Deleted Account', CategoryType.none);
  }

  Category get unassignedSplit {
    return getOrCreate('UnassignedSplit', CategoryType.none);
  }

  Category get unknown {
    return getOrCreate('Unknown', CategoryType.none);
  }
}
