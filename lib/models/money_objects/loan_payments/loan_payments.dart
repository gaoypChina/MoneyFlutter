import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/loan_payments/loan_payment.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Export
export 'package:money/models/money_objects/loan_payments/loan_payment.dart';

class LoanPayments extends MoneyObjects<LoanPayment> {
  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      addEntry(LoanPayment.fromJson(row));
    }
  }

  @override
  void loadDemoData() {
    clear();
    final Account? accountForLoan =
        Data().accounts.getList().firstWhereOrNull((final Account element) => element.type.value == AccountType.loan);
    if (accountForLoan != null) {
      for (int i = 0; i < 12 * 20; i++) {
        getList().add(LoanPayment(
          id: i,
          accountId: accountForLoan.id.value,
          date: DateTime.now(),
          principal: 100,
          interest: 10,
          memo: '',
        ));
      }
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
