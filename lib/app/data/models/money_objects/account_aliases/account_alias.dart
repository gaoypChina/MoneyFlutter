import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

/*

  0    Id         INT            0                    1
  1    Pattern    nvarchar(255)  1                    0
  2    Flags      INT            1                    0
  3    AccountId  nchar(20)      1                    0

 */
class AccountAlias extends MoneyObject {
  /// Constructor
  AccountAlias() {
    // body
  }

  /// Constructor from a SQLite row
  @override
  factory AccountAlias.fromJson(final MyJson row) {
    return AccountAlias()
      ..id.value = row.getInt('Id', -1)
      ..pattern.value = row.getString('Pattern')
      ..flags.value = row.getInt('Flag', 0)
      ..accountId.value = row.getString('AccountId');
  }

  // 3
  Field<String> accountId = Field<String>(
    serializeName: 'AccountId',
    defaultValue: '',
  );

  // 2
  Field<int> flags = Field<int>(
    serializeName: 'Flags',
    defaultValue: 0,
  );

  // 0
  Field<int> id = Field<int>(
    serializeName: 'Id',
    defaultValue: -1,
    getValueForSerialization: (final MoneyObject instance) => (instance as AccountAlias).uniqueId,
  );

  // 1
  Field<String> pattern = Field<String>(
    serializeName: 'Pattern',
    defaultValue: '',
  );

  @override
  String getRepresentation() {
    return '${pattern.value} ${accountId.value}';
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final _fields = Fields<AccountAlias>();

  static Fields<AccountAlias> get fields {
    if (_fields.isEmpty) {
      final tmp = AccountAlias.fromJson({});
      _fields.setDefinitions(
        [
          tmp.id,
          tmp.pattern,
          tmp.flags,
          tmp.accountId,
        ],
      );
    }
    return _fields;
  }

  static Fields<AccountAlias> get fieldsForColumnView {
    if (_fields.isEmpty) {
      final tmp = AccountAlias.fromJson({});
      _fields.setDefinitions(
        [
          tmp.pattern,
          tmp.flags,
          tmp.accountId,
        ],
      );
    }
    return _fields;
  }
}
