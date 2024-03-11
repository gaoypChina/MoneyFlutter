import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category.dart';

Widget pickerCategory(
  Category? selected,
  final Function(Category?) onSelected,
) {
  final list = Data().categories.iterableList();

  bool selectionWasFound = false;
  final dropDownItems = list.map<DropdownMenuItem<Category>>((item) {
    if (selected?.name.value == item.name.value) {
      selectionWasFound = true;
    }
    return DropdownMenuItem<Category>(
      value: item,
      child: Text(Category.getName(item)),
    );
  }).toList();

  if (!selectionWasFound) {
    selected = list.first;
  }

  return DropdownButton<Category>(
    value: selected,
    isExpanded: true,
    onChanged: onSelected,
    items: dropDownItems,
  );
}
