import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';

class Categories extends MoneyObjects<Category> {
  Categories() {
    collectionName = 'Categories';
  }

  @override
  Category instanceFromSqlite(final MyJson row) {
    return Category.fromJson(row);
  }

  static int idOfSplitCategory = -1;

  List<Category> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.name.value, b.name.value, true));
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

  int splitCategoryId() {
    if (idOfSplitCategory == -1) {
      final Category? cat = getByName('Split');
      if (cat != null) {
        idOfSplitCategory = cat.id.value;
      }
    }
    return idOfSplitCategory;
  }

  Category? getByName(final String name) {
    return iterableList().firstWhereOrNull((final Category category) => category.name.value == name);
  }

  bool isCategoryAnExpense(final int categoryId) {
    final Category? category = get(categoryId);
    if (category == null) {
      return false;
    }
    return category.type.value == CategoryType.expense || category.type.value == CategoryType.recurringExpense;
  }

  Category getTopAncestor(final Category category) {
    if (category.parentId.value == -1) {
      return category; // this is the top
    }
    final Category? parent = get(category.parentId.value);
    if (parent == null) {
      return category;
    }
    return getTopAncestor(parent);
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
        getTreeIdsRecursive(c.id.value, list);
      }
    }
  }

  List<Category> getCategoriesWithThisParent(final int parentId) {
    final List<Category> list = <Category>[];
    for (final Category item in iterableList()) {
      if (item.parentId.value == parentId) {
        list.add(item);
      }
    }
    return list;
  }

  Category getOrCreateCategory(
    final String name,
    final CategoryType type,
  ) {
    Category? category = getByName(name);

    if (category == null) {
      category = Category(
        id: -1,
        name: name,
        type: type,
      );

      appendNewMoneyObject(category);
    }
    // TODO
    // else if (result.IsDeleted) {
    //   result.Undelete();
    // }
    return category;
  }

  Category get split {
    return getOrCreateCategory('Split', CategoryType.none);
  }

  Category get salesTax {
    return getOrCreateCategory('Taxes:Sales Tax', CategoryType.expense);
  }

  Category get interestEarned {
    return getOrCreateCategory('Savings:Interest', CategoryType.income);
  }

  Category get savings {
    return getOrCreateCategory('Savings', CategoryType.income);
  }

  Category get investmentCredit {
    return getOrCreateCategory('Investments:Credit', CategoryType.income);
  }

  Category get investmentDebit {
    return getOrCreateCategory('Investments:Debit', CategoryType.expense);
  }

  Category get investmentInterest {
    return getOrCreateCategory('Investments:Interest', CategoryType.income);
  }

  Category get investmentDividends {
    return getOrCreateCategory('Investments:Dividends', CategoryType.income);
  }

  Category get investmentTransfer {
    return getOrCreateCategory('Investments:Transfer', CategoryType.none);
  }

  Category get investmentFees {
    return getOrCreateCategory('Investments:Fees', CategoryType.expense);
  }

  Category get investmentMutualFunds {
    return getOrCreateCategory('Investments:Mutual Funds', CategoryType.expense);
  }

  Category get investmentStocks {
    return getOrCreateCategory('Investments:Stocks', CategoryType.expense);
  }

  Category get investmentOther {
    return getOrCreateCategory('Investments:Other', CategoryType.expense);
  }

  Category get investmentBonds {
    return getOrCreateCategory('Investments:Bonds', CategoryType.expense);
  }

  Category get investmentOptions {
    return getOrCreateCategory('Investments:Options', CategoryType.expense);
  }

  Category get investmentReinvest {
    return getOrCreateCategory('Investments:Reinvest', CategoryType.none);
  }

  Category get investmentLongTermCapitalGainsDistribution {
    return getOrCreateCategory('Investments:Long Term Capital Gains Distribution', CategoryType.income);
  }

  Category get investmentShortTermCapitalGainsDistribution {
    return getOrCreateCategory('Investments:Short Term Capital Gains Distribution', CategoryType.income);
  }

  Category get investmentMiscellaneous {
    return getOrCreateCategory('Investments:Miscellaneous', CategoryType.expense);
  }

  Category get transferToDeletedAccount {
    return getOrCreateCategory('Xfer to Deleted Account', CategoryType.none);
  }

  Category get transferFromDeletedAccount {
    return getOrCreateCategory('Xfer from Deleted Account', CategoryType.none);
  }

  Category get transfer {
    return getOrCreateCategory('Transfer', CategoryType.none);
  }

  Category get unknown {
    return getOrCreateCategory('Unknown', CategoryType.none);
  }

  Category get unassignedSplit {
    return getOrCreateCategory('UnassignedSplit', CategoryType.none);
  }

  @override
  void loadDemoData() {
    clear();
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Food',
      description: '',
      type: CategoryType.expense,
      color: '#FF1122FF',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Paychecks',
      description: '',
      type: CategoryType.income,
      color: '#FFAAFFBB',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Investment',
      description: '',
      type: CategoryType.investment,
      color: '#FFA1A2A3',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Interests',
      description: '',
      type: CategoryType.income,
      color: '#FFFF2233',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Rental',
      description: '',
      type: CategoryType.income,
      color: '#FF11FF33',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Mortgage',
      description: '',
      type: CategoryType.expense,
      color: '#FFBB2233',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Saving',
      description: '',
      type: CategoryType.income,
      color: '#FFBB2233',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Bills',
      description: '',
      type: CategoryType.expense,
      color: '#FF11DD33',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'Taxes',
      description: '',
      type: CategoryType.expense,
      color: '#FF1122DD',
    ));
    appendNewMoneyObject(Category(
      id: -1,
      name: 'School',
      description: '',
      type: CategoryType.expense,
    ));
  }

  @override
  void onAllDataLoaded() {
    for (final Category category in iterableList()) {
      category.count.value = 0;
      category.sum.value.amount = 0;
    }

    for (final Transaction t in Data().transactions.iterableList()) {
      final Category? item = get(t.categoryId.value);
      if (item != null) {
        item.count.value++;
        item.sum.value.amount += t.amount.value.amount;
      }
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  Category addNewCategory(final String name) {
    // find next available name
    String nextAvailableName = name;
    int next = 1;
    while ((getByName(nextAvailableName) != null)) {
      // already taken
      nextAvailableName = '$name $next';
      // the the next one
      next++;
    }

    // add a new Category
    final Category category = Category(id: -1, name: nextAvailableName, type: CategoryType.expense);

    Data().categories.appendNewMoneyObject(category);

    return category;
  }

  void reparentCategory(final Category categoryToReparent, final Category newParentCategory) {
    categoryToReparent.stashValueBeforeEditing();
    categoryToReparent.parentId.value = newParentCategory.uniqueId;

    final descendants = getTreeIds(categoryToReparent.uniqueId);
    for (final id in descendants) {
      final category = get(id);
      if (category != null) {
        category.updateNameBaseOnParent();
        Data().notifyMutationChanged(
          mutation: MutationType.changed,
          moneyObject: category,
          fireNotification: false,
        );
      }
    }

    Data().recalculateBalances();
    Settings().rebuild();
  }

/*

 /// <summary>
 /// Replace the parent of the given category with a new parent.
 /// </summary>
 /// <param name="category">The category to change</param>
 /// <param name="oldParent">The old parent we are removing</param>
 /// <param name="newParent">The new parent we are inserting</param>
 /// <returns>The new updated category</returns>
 public Category ReParent(Category category, Category oldParent, Category newParent)
 {
     if (category == oldParent)
     {
         return newParent;
     }

     string name = category.Name;
     string oldname = oldParent.Name;
     Debug.Assert(name.Length > oldname.Length);

     string tail = name.Substring(oldname.Length);
     string newname = newParent.Name + tail;

     Category c = this.FindCategory(newname);
     if (c == null)
     {
         c = this.GetOrCreateCategory(newname, category.Type);
         c.Color = category.Color;
         c.Budget = category.Budget;
         c.BudgetRange = category.BudgetRange;
         c.Balance = category.Balance;
         c.Description = category.Description;
         c.TaxRefNum = category.TaxRefNum;
     }
     return c;
 }

   */
}
