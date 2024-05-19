// Imports
// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/categories/category_types.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/color_picker.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/money_widget.dart';
import 'package:money/widgets/rectangle.dart';

// Exports
export 'package:money/models/money_objects/categories/category_types.dart';

class Category extends MoneyObject {
  static final _fields = Fields<Category>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = Category.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.parentId,
        tmp.name,
        tmp.description,
        tmp.type,
        tmp.color,
        tmp.level,
        tmp.budget,
        tmp.budgetBalance,
        tmp.frequency,
        tmp.taxRefNum,
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
    return name.value;
  }

  /// Id
  /// 0|Id|INT|0||1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Category).uniqueId,
  );

  /// 1|ParentId|INT|0||0
  FieldInt parentId = FieldInt(
    importance: 1,
    serializeName: 'ParentId',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).parentId.value,
  );

  /// Name
  /// 2|Name|nvarchar(80)|1||0
  Field<String> name = Field<String>(
    importance: 2,
    type: FieldType.text,
    columnWidth: ColumnWidth.largest,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Category).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).name.value,
  );

  /// Description
  /// 3|Description|nvarchar(255)|0||0
  Field<String> description = Field<String>(
    importance: 3,
    type: FieldType.text,
    columnWidth: ColumnWidth.large,
    name: 'Description',
    serializeName: 'Description',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Category).description.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).description.value,
  );

  /// Type
  /// 4|Type|INT|1||0
  Field<CategoryType> type = Field<CategoryType>(
    importance: 4,
    type: FieldType.text,
    align: TextAlign.center,
    serializeName: 'Type',
    defaultValue: CategoryType.none,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).getTypeAsText(),
    valueForSerialization: (final MoneyObject instance) => (instance as Category).type.value.index,
  );

  /// Color
  /// 5|Color|nchar(10)|0||0
  Field<String> color = Field<String>(
    importance: 5,
    serializeName: 'Color',
    type: FieldType.widget,
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Category).getColorWidget(),
    valueForSerialization: (final MoneyObject instance) => (instance as Category).color.value,
    setValue: (final MoneyObject instance, final dynamic value) {
      (instance as Category).color.value = value as String;
    },
    getEditWidget: (final MoneyObject instance, Function onEdited) {
      return MutateFieldColor(
        colorAsHex: (instance as Category).color.value,
        onEdited: (String newValue) {
          instance.color.value = newValue;
          Data().notifyMutationChanged(mutation: MutationType.changed, moneyObject: instance, fireNotification: false);
          onEdited();
        },
      );
    },
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByString((a as Category).color.value, (b as Category).color.value, ascending),
  );

  /// Budget
  /// 6|Budget|money|0||0
  FieldMoney budget = FieldMoney(
    importance: 99,
    name: 'Budget',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).budget.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).budget.value,
  );

  /// Budget Balance
  /// 7|Balance|money|0||0
  FieldMoney budgetBalance = FieldMoney(
    importance: 80,
    name: 'BudgetBalance',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).budgetBalance.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).budgetBalance.value,
  );

  /// 8|Frequency|INT|0||0
  FieldInt frequency = FieldInt(
    importance: 80,
    serializeName: 'Frequency',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).frequency.value,
  );

  /// 9|TaxRefNum|INT|0||0
  FieldInt taxRefNum = FieldInt(
    importance: 80,
    serializeName: 'TaxRefNum',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).taxRefNum.value,
  );

  //-----------------------------------
  // These properties are not persisted

  /// Level
  FieldQuantity level = FieldQuantity(
    importance: 80,
    name: 'Level',
    columnWidth: ColumnWidth.nano,
    valueFromInstance: (final MoneyObject instance) =>
        countOccurrences((instance as Category).name.value, ':').toDouble() + 1,
  );

  /// Count
  FieldQuantity count = FieldQuantity(
    importance: 98,
    name: 'Transactions',
    columnWidth: ColumnWidth.tiny,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).count.value,
  );

  /// Running Balance
  FieldMoney sum = FieldMoney(
    importance: 99,
    name: 'Sum',
    valueFromInstance: (final MoneyObject instance) => (instance as Category).sum.value,
  );

  Category({
    required final int id,
    final int parentId = -1,
    required final String name,
    final String description = '',
    final String color = '',
    required final CategoryType type,
    final double budget = 0,
    final double budgetBalance = 0,
    final int frequency = 0,
    final int taxRefNum = 0,
  }) {
    this.id.value = id;
    this.parentId.value = parentId;
    this.name.value = name;
    this.description.value = description;
    this.color.value = color;
    this.type.value = type;
    this.budget.value.amount = budget;
    this.budgetBalance.value.amount = budgetBalance;
    this.frequency.value = frequency;
    this.taxRefNum.value = taxRefNum;

    buildFieldsAsWidgetForSmallScreen = () {
      String top = '';
      String bottom = '';

      if (this.parentId.value == -1) {
        top = this.name.value;
        bottom = '';
      } else {
        top = getName(Data().categories.get(this.parentId.value));
        bottom = this.name.value.substring(top.length);
      }

      return MyListItemAsCard(
        leftTopAsString: top,
        leftBottomAsString: bottom,
        rightTopAsWidget: MoneyWidget(amountModel: sum.value, asTile: true),
        rightBottomAsWidget: Row(
          children: <Widget>[
            Text(getTypeAsText()),
            const SizedBox(
              width: 8,
            ),
            getColorWidget(),
          ],
        ),
      );
    };
  }

  Color getColorOrAncestorsColor() {
    final pair = getColorAndLevel(0);
    return pair.first;
  }

  Pair<Color, int> getColorAndLevel(int level) {
    if (this.color.value.isNotEmpty) {
      return Pair<Color, int>(getColorFromString(this.color.value), level);
    }
    if (this.parentId.value != -1) {
      final Category? parentCategory = Data().categories.get(this.parentId.value);
      if (parentCategory != null) {
        return parentCategory.getColorAndLevel(level + 1);
      }
    }
    // reach the top
    return Pair<Color, int>(Colors.transparent, 0);
  }

  Widget getColorWidget() {
    final Color fillColor = getColorOrAncestorsColor();
    final Color textColor = fillColor.opacity == 0 ? Colors.grey : contrastColor(fillColor);

    return Stack(
      alignment: Alignment.center,
      children: [
        MyCircle(colorFill: fillColor, size: 12),
        if (this.color.value.isNotEmpty && this.level.valueFromInstance(this) > 1)
          Text('#', style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }

  Widget getRectangleWidget() {
    return MyRectangle(colorFill: getColorFromString(this.color.value), size: 12);
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  factory Category.fromJson(final MyJson row) {
    return Category(
      id: row.getInt('Id', -1),
      parentId: row.getInt('ParentId', -1),
      name: row.getString('Name'),
      description: row.getString('Description'),
      color: row.getString('Color').trim(),
      type: Category.getTypeFromInt(row.getInt('Type')),
      budget: row.getDouble('Budget'),
      budgetBalance: row.getDouble('Balance'),
      frequency: row.getInt('Frequency'),
      taxRefNum: row.getInt('TaxRefNum'),
    );
  }

  static String getName(final Category? instance) {
    return instance == null ? '' : (instance).name.value;
  }

  static CategoryType getTypeFromInt(final int index) {
    if (isBetween(index, -1, CategoryType.values.length)) {
      return CategoryType.values[index];
    }
    return CategoryType.none;
  }

  String getTypeAsText() {
    switch (type.value) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.recurringExpense:
        return 'ExpenseRecurring';
      case CategoryType.saving:
        return 'Saving';
      case CategoryType.reserved:
        return 'Reserved';
      case CategoryType.transfer:
        return 'Transfer';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.none:
        return 'None';
      default:
        return '<unknown>';
    }
  }
}

class MutateFieldColor extends StatefulWidget {
  const MutateFieldColor({
    super.key,
    required this.colorAsHex,
    required this.onEdited,
  });

  final String colorAsHex;
  final Function(String) onEdited;

  @override
  State<MutateFieldColor> createState() => _MutateFieldColorState();
}

class _MutateFieldColorState extends State<MutateFieldColor> {
  late TextEditingController controllerForText = TextEditingController(text: widget.colorAsHex);

  @override
  Widget build(BuildContext context) {
    late Color color = getColorFromString(controllerForText.text);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controllerForText,
            onChanged: (String colorText) {
              setState(() {
                color = getColorFromString(colorText);
                widget.onEdited(controllerForText.text);
              });
            },
          ),
        ),
        gapLarge(),
        MyCircle(
          colorFill: color,
          colorBorder: Colors.grey,
          size: 40,
        ),
        gapLarge(),
        Expanded(
          child: ColorPicker(
            color: color,
            onColorChanged: (Color color) {
              setState(() {
                controllerForText.text = colorToHexString(color, includeAlpha: false);
                widget.onEdited(controllerForText.text);
              });
            },
          ),
        ),
      ],
    );
  }
}
