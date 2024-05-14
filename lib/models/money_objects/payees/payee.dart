import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/widgets/money_widget.dart';

export 'package:money/models/money_objects/money_object.dart';

/*
  SQLite table definition

  0|Id|INT|0||1
  1|Name|nvarchar(255)|1||0
 */
class Payee extends MoneyObject {
  static final _fields = Fields<Payee>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = Payee.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.name,
        tmp.count,
        tmp.sum,
      ]);
    }
    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    // TODO
    return name.value;
  }

  // 0
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Payee).uniqueId,
  );

  // 1
  Field<String> name = Field<String>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Payee).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Payee).name.value,
  );

  FieldQuantity count = FieldQuantity(
    name: 'Transactions',
    columnWidth: ColumnWidth.small,
    valueFromInstance: (final MoneyObject instance) => (instance as Payee).count.value,
  );

  FieldMoney sum = FieldMoney(
    name: 'Sum',
    valueFromInstance: (final MoneyObject instance) => (instance as Payee).sum.value,
  );

  Payee() {
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          rightTopAsWidget: MoneyWidget(amountModel: sum.value, asTile: true),
          rightBottomAsString: getAmountAsShorthandText(count.value),
        );
  }

  factory Payee.fromJson(final MyJson row) {
    return Payee();
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  static String getName(final Payee? payee) {
    return payee == null ? '' : payee.name.value;
  }
}
