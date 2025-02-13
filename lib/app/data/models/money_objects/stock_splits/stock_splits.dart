import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';

// Exports
export 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';

class StockSplits extends MoneyObjects<StockSplit> {
  StockSplits() {
    collectionName = 'Stock Splits';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(StockSplit.fromJson(row));
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  void clearSplitForSecurity(final int securityId) {
    final listOfSplitsFound = iterableList().where((split) => split.fieldSecurity.value == securityId);
    for (final ss in listOfSplitsFound) {
      deleteItem(ss);
    }
  }

  List<StockSplit> getStockSplitsForSecurity(final Security s) {
    List<StockSplit> list = [];
    for (StockSplit split in iterableList()) {
      if (!s.isDeleted && split.fieldSecurity.value == s.uniqueId) {
        list.add(split);
      }
    }
    list.sort((final StockSplit a, final StockSplit b) {
      return a.fieldDate.value!.compareTo(b.fieldDate.value!);
    });

    return list;
  }

  /// Only add, no removal of existing splits
  void setStockSplits(final int securityId, final List<StockSplit> values) {
    final List<StockSplit> listOfSplitsFound =
        iterableList().where((split) => split.fieldSecurity.value == securityId).toList();
    for (final StockSplit ss in values) {
      final StockSplit? foundMatch = listOfSplitsFound.firstWhereOrNull(
        (existingSplit) => isSameDateWithoutTime(existingSplit.fieldDate.value, ss.fieldDate.value),
      );
      if (foundMatch == null) {
        appendNewMoneyObject(ss, fireNotification: false);
      }
    }
  }
}
