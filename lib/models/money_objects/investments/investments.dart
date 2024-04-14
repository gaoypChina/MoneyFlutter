import 'package:money/models/money_objects/investments/investment.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/storage/data/data.dart';

// Exports
export 'package:money/models/money_objects/investments/investment.dart';

class Investments extends MoneyObjects<Investment> {
  Investments() {
    collectionName = 'Investments';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(Investment.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {
    for (final investment in iterableList()) {
      // hydrate the transaction instance associated to the investments
      investment.transactionInstance = Data().transactions.get(investment.uniqueId);
    }
  }

  static void calculateRunningBalance(List<Investment> investments) {
    // first sort by date, TradeType, Amount
    investments.sort((a, b) => Investment.sortByDateAndInvestmentType(a, b, true, true));

    double runningBalance = 0;
    for (final investment in investments) {
      runningBalance += investment.finalAmount;
      investment.runningBalance.value.amount = runningBalance;
    }
  }

  static double getProfit(List<Investment> investments) {
    // first sort by date, TradeType, Amount
    investments.sort((a, b) => Investment.sortByDateAndInvestmentType(a, b, true, true));

    double runningBalance = 0;
    for (final investment in investments) {
      runningBalance += investment.finalAmount;
    }
    return runningBalance;
  }

  static getInvestmentsFromSecurity(final int securityId) {
    return Data().investments.iterableList().where((item) => item.security.value == securityId).toList();
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
