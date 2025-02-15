import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/widgets/picker_edit_box.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/storage/data/data.dart';

Widget pickerPayee({
  required final Payee? itemSelected,
  required final Function(Payee?) onSelected,
}) {
  final List<String> options = Data().payees.getListSorted().map((element) => element.fieldName.value).toList();
  options.sort((a, b) => sortByString(a, b, true));

  String selectedName = itemSelected == null ? '' : itemSelected.fieldName.value;

  return PickerEditBox(
    title: 'Payee',
    items: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Payee? found = Data().payees.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
    onAddNew: (String newPayeeText) {
      final Payee found = Data().payees.getOrCreate(newPayeeText);
      onSelected(found);
    },
  );
}
