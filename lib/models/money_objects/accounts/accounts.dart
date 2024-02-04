import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Accounts extends MoneyObjects<Account> {
  @override
  Account instanceFromSqlite(final MyJson row) {
    return Account.fromJson(row);
  }

  @override
  void loadDemoData() {
    clear();
    final List<MyJson> demoAccounts = <MyJson>[
      // ignore: always_specify_types
      {
        'Id': 0,
        'AccountId': 'BankAccountIdForTesting',
        'Name': 'U.S. Bank',
        'Type': AccountType.savings.index,
        'Currency': 'USD'
      },
      // ignore: always_specify_types
      {'Id': 1, 'Name': 'Bank Of America', 'Type': AccountType.checking.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 2, 'Name': 'KeyBank', 'Type': AccountType.moneyMarket.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 3, 'Name': 'Mattress', 'Type': AccountType.cash.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 4, 'Name': 'Revolut UK', 'Type': AccountType.credit.index, 'Currency': 'GBP'},
      // ignore: always_specify_types
      {'Id': 5, 'Name': 'Fidelity', 'Type': AccountType.investment.index, 'Currency': 'USD'},
      // ignore: always_specify_types
      {'Id': 6, 'Name': 'Bank of Japan', 'Type': AccountType.retirement.index, 'Currency': 'JPY'},
      // ignore: always_specify_types
      {'Id': 7, 'Name': 'James Bonds', 'Type': AccountType.asset.index, 'Currency': 'GBP'},
      // ignore: always_specify_types
      {'Id': 8, 'Name': 'KickStarter', 'Type': AccountType.loan.index, 'Currency': 'CAD'},
      // ignore: always_specify_types
      {'Id': 9, 'Name': 'Home Remodel', 'Type': AccountType.creditLine.index, 'Currency': 'USD'},
    ];
    for (final MyJson demoAccount in demoAccounts) {
      addEntry(Account.fromJson(demoAccount));
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Account account in iterableList()) {
      account.count.value = 0;
      account.balance.value = account.openingBalance.value;
      account.balanceNormalized.value = account.openingBalance.value * account.getCurrencyRatio();
    }

    for (final Transaction t in Data().transactions.iterableList()) {
      final Account? item = get(t.accountId.value);
      if (item != null) {
        item.count.value++;
        item.balance.value += t.amount.value;
        item.balanceNormalized.value += t.getNormalizedAmount();
      }
    }
  }

  List<Account> getOpenAccounts() {
    return iterableList().where((final Account item) => activeBankAccount(item)).toList();
  }

  bool activeBankAccount(final Account element) {
    return element.isActiveBankAccount();
  }

  List<Account> activeAccount(
    final List<AccountType> types, {
    final bool? isActive = true,
  }) {
    return iterableList().where((final Account item) {
      if (!item.matchType(types)) {
        return false;
      }
      if (isActive == null) {
        return true;
      }
      return item.isActive() == isActive;
    }).toList();
  }

  String getNameFromId(final num id) {
    final Account? account = get(id);
    if (account == null) {
      return id.toString();
    }
    return account.name.value;
  }

  Account? findByIdAndType(
    final String accountId,
    final AccountType accountType,
  ) {
    return iterableList().firstWhereOrNull((final Account item) {
      return item.accountId.value == accountId && item.type.value == accountType;
    });
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
