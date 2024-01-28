import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/widgets/table_view/list_item_card.dart';

class LoanPayment extends MoneyObject<LoanPayment> {
  @override
  int get uniqueId => id.value;

  /// ID
  /// 0|Id|INT|1||0
  FieldId<LoanPayment> id = FieldId<LoanPayment>(
    importance: 0,
    valueForSerialization: (final LoanPayment instance) => instance.id.value,
  );

  /// 1|AccountId|INT|1||0
  Field<LoanPayment, int> accountId = Field<LoanPayment, int>(
    importance: 1,
    name: 'Account',
    serializeName: 'AccountId',
    defaultValue: -1,
    valueFromInstance: (final LoanPayment instance) => Account.getName(instance.accountInstance),
    valueForSerialization: (final LoanPayment instance) => instance.accountId.value,
  );

  /// Date
  /// 2|Date|datetime|1||0
  Field<LoanPayment, DateTime> date = Field<LoanPayment, DateTime>(
    importance: 2,
    type: FieldType.date,
    serializeName: 'Date',
    useAsColumn: false,
    defaultValue: DateTime.parse('1970-01-01'),
    valueFromInstance: (final LoanPayment instance) => instance.date.value.toIso8601String(),
    valueForSerialization: (final LoanPayment instance) => instance.date.value.toIso8601String(),
  );

  /// 3
  /// 3|Principal|money|0||0
  FieldAmount<LoanPayment> principal = FieldAmount<LoanPayment>(
    importance: 3,
    name: 'Principal',
    serializeName: 'Principal',
    valueFromInstance: (final LoanPayment instance) => instance.principal.value,
    valueForSerialization: (final LoanPayment instance) => instance.principal.value,
  );

  /// Interest
  /// 4|Interest|money|0||0
  FieldAmount<LoanPayment> interest = FieldAmount<LoanPayment>(
    importance: 4,
    name: 'Interest',
    serializeName: 'Interest',
    valueFromInstance: (final LoanPayment instance) => instance.interest.value,
    valueForSerialization: (final LoanPayment instance) => instance.interest.value,
  );

  // 5
  // 5|Memo|nvarchar(255)|0||0
  Field<LoanPayment, String> memo = Field<LoanPayment, String>(
    importance: 99,
    type: FieldType.text,
    name: 'Memo',
    serializeName: 'Memo',
    defaultValue: '',
    valueFromInstance: (final LoanPayment instance) => instance.memo.value,
    valueForSerialization: (final LoanPayment instance) => instance.memo.value,
  );

  // Not persisted
  Account? accountInstance;

  LoanPayment({
    required final int accountId,
    required final DateTime date,
    required final double principal,
    required final double interest,
    required final String memo,
  }) {
    this.accountId.value = accountId;
    accountInstance = Data().accounts.get(this.accountId.value);
    this.date.value = date;
    this.principal.value = principal;
    this.interest.value = interest;

    buildListWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: Account.getName(accountInstance),
          rightTopAsString: getCurrencyText(principal),
          rightBottomAsString: getCurrencyText(interest),
        );
  }

  /// Constructor from a SQLite row
  factory LoanPayment.fromJson(final MyJson row) {
    return LoanPayment(
      // 1
      accountId: row.getInt('AccountId'),
      // 2
      date: row.getDate('Date'),
      // 3
      principal: row.getDouble('Principal'),
      // 4
      interest: row.getDouble('Interest'),
      // 3
      memo: row.getString('Memo'),
    )..id.value = row.getInt('Id');
  }
}
