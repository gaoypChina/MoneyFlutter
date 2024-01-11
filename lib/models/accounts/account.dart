import 'package:money/models/money_entity.dart';

class Account extends MoneyEntity {
  int count = 0;
  double openingBalance = 0.00;
  double balance = 0.00;
  int flags = 0;
  String accountId = '';
  String ofxAccountId = '';
  String description = '';
  AccountType type = AccountType.checking;

  Account(super.id, super.name);

  bool isClosed() {
    return (flags & AccountFlags.closed.index) != 0;
  }

  bool isActive() {
    return !isClosed();
  }

  bool matchType(final List<AccountType> types) {
    if (types.isEmpty) {
      // All accounts except these
      return type != AccountType._notUsed_7 && type != AccountType.categoryFund;
    }
    return types.contains(type);
  }

  bool isBankAccount() {
    return type == AccountType.savings || type == AccountType.checking || type == AccountType.cash;
  }

  bool isActiveBankAccount() {
    return isBankAccount() && isActive();
  }

  getTypeAsText() {
    switch (type) {
      case AccountType.savings:
        return 'Savings';
      case AccountType.checking:
        return 'Checking';
      case AccountType.moneyMarket:
        return 'MoneyMarket';
      case AccountType.cash:
        return 'Cash';
      case AccountType.credit:
        return 'Credit';
      case AccountType.investment:
        return 'Investment';
      case AccountType.retirement:
        return 'Retirement';
      case AccountType.asset:
        return 'Asset';
      case AccountType.categoryFund:
        return 'CategoryFund';
      case AccountType.loan:
        return 'Loan';
      case AccountType.creditLine:
        return 'CreditLine';
      default:
        break;
    }

    return 'other $type';
  }

  static AccountType getTypeFromText(final String text) {
    switch (text.toLowerCase()) {
      case 'savings':
        return AccountType.savings;
      case 'checking':
        return AccountType.checking;
      case 'moneymarket':
        return AccountType.moneyMarket;
      case 'cash':
        return AccountType.cash;
      case 'credit':
      case 'creditcard': // as seen in OFX <ACCTTYPE>
        return AccountType.credit;
      case 'investment':
        return AccountType.investment;
      case 'retirement':
        return AccountType.retirement;
      case 'asset':
        return AccountType.asset;
      case 'categoryfund':
        return AccountType.categoryFund;
      case 'loan':
        return AccountType.loan;
      case 'creditLine':
        return AccountType.creditLine;
      default:
        return AccountType._notUsed_7;
    }
  }

  List<dynamic> toCSV() {
    return <dynamic>[
      accountId,
      flags,
      ofxAccountId,
      description,
      type.index,
    ];
  }
}

enum AccountType {
  savings,
  checking,
  moneyMarket,
  cash,
  credit,
  investment,
  retirement,
  _notUsed_7, // There is a hole here from deleted type which we can fill when we invent new types, but the types 8-10 have to keep those numbers or else we mess up the existing databases.
  asset, // Used for tracking Assets like "House, Car, Boat, Jewelry, this helps to make NetWorth more accurate
  categoryFund, // a pseudo account for managing category budgets
  loan,
  creditLine
}

enum AccountFlags { none, budgeted, closed, raxDeferred }
