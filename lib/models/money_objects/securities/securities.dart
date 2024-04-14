import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/securities/security.dart';
import 'package:money/storage/data/data.dart';

// Exports
export 'package:money/models/money_objects/securities/security.dart';

class Securities extends MoneyObjects<Security> {
  Securities() {
    collectionName = 'Securities';
  }

  String getSymbolFromId(final int securityId) {
    final Security? security = get(securityId);
    if (security == null) {
      return '?$security?';
    }
    return security.symbol.value;
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(Security.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Security security in iterableList()) {
      final List<Investment> list = Investments.getInvestmentsFromSecurity(security.uniqueId);
      security.counts.value = list.length;
      security.balance.value.amount = Investments.getProfit(list);
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
