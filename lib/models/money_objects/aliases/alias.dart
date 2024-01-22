import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/widgets/table_view/table_row_compact.dart';

class Alias extends MoneyObject<Alias> {
  @override
  int get uniqueId => id.value;

  /// ID
  /// 0    Id       INT            0                 1
  FieldId<Alias> id = FieldId<Alias>(
    importance: 0,
    valueForSerialization: (final Alias instance) => instance.id.value,
  );

  /// Pattern
  /// 1    Pattern  nvarchar(255)  1                 0
  Field<Alias, String> pattern = Field<Alias, String>(
    type: FieldType.text,
    importance: 2,
    name: 'Pattern',
    serializeName: 'Pattern',
    defaultValue: '',
    valueFromInstance: (final Alias instance) => instance.pattern.value,
    valueForSerialization: (final Alias instance) => instance.pattern.value,
  );

  /// 2    Flags    INT            1                 0
  Field<Alias, int> flags = Field<Alias, int>(
    type: FieldType.text,
    align: TextAlign.center,
    importance: 3,
    name: 'Flag',
    serializeName: 'Flag',
    defaultValue: 0,
    valueFromInstance: (final Alias instance) => instance.type.name,
    valueForSerialization: (final Alias instance) => instance.flags.value,
  );

  /// Payee
  /// 3 Payee INT 1 0
  Field<Alias, int> payeeId = Field<Alias, int>(
    type: FieldType.text,
    importance: 1,
    name: 'Payee',
    serializeName: 'Payee',
    defaultValue: 0,
    valueFromInstance: (final Alias instance) => Payee.getName(instance.payeeInstance),
    valueForSerialization: (final Alias instance) => instance.payeeId,
  );

  // Not persisted
  Payee? payeeInstance;
  RegExp? regex;

  Alias({
    required final int id,
    required final String pattern,
    required final int flags,
    required final int payeeId,
  }) {
    this.id.value = id;
    this.pattern.value = pattern;
    this.flags.value = flags;
    this.payeeId.value = payeeId;
    buildListWidgetForSmallScreen = () => TableRowCompact(
          leftTopAsString: Payee.getName(payeeInstance),
          leftBottomAsString: this.pattern.value,
          rightBottomAsString: type.name,
        );
  }

  /// Constructor from a SQLite row
  factory Alias.fromSqlite(final Json row) {
    return Alias(
      id: jsonGetInt(row, 'Id'),
      pattern: jsonGetString(row, 'Pattern'),
      flags: jsonGetInt(row, 'Flags'),
      payeeId: jsonGetInt(row, 'Payee'),
    );
  }

  AliasType get type {
    return flags.value == 0 ? AliasType.none : AliasType.regex;
  }

  bool isMatch(final String text) {
    if (type == AliasType.regex) {
      // just in time creation of RegEx property
      regex ??= RegExp(pattern.value);
      final Match? matched = regex?.firstMatch(text);
      if (matched != null) {
        debugLog('First email found: ${matched.group(0)}');
        return true;
      }
    } else {
      if (stringCompareIgnoreCasing2(pattern.value, text) == 0) {
        return true;
      }
    }
    return false;
  }
}

enum AliasType {
  none, // 0
  regex, // 1
}
