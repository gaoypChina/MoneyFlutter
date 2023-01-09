import 'package:flutter/material.dart';
import 'package:money/helpers.dart';

import '../models/rentals.dart';
import '../widgets/columns.dart';
import '../widgets/widget_view.dart';

class ViewRentals extends ViewWidget {
  const ViewRentals({super.key, super.setDetailsPanelContent});

  @override
  State<ViewWidget> createState() => ViewRentalsState();
}

class ViewRentalsState extends ViewWidgetState {
  @override
  getClassNamePlural() {
    return "Rentals";
  }

  @override
  getClassNameSingular() {
    return "Rental";
  }

  @override
  String getDescription() {
    return "Properties to rent.";
  }

  getColumnForName() {
    return ColumnDefinition(
      "Name",
      ColumnType.text,
      TextAlign.left,
      (index) {
        return list[index].name;
      },
      (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      },
    );
  }

  getColumnForAddress() {
    return ColumnDefinition(
      "Address",
      ColumnType.text,
      TextAlign.left,
      (index) {
        return list[index].address;
      },
      (a, b, sortAscending) {
        return sortByString(a.address, b.address, sortAscending);
      },
    );
  }

  getColumnForNote() {
    return ColumnDefinition(
      "Note",
      ColumnType.text,
      TextAlign.left,
      (index) {
        return list[index].note;
      },
      (a, b, sortAscending) {
        return sortByString(a.note, b.note, sortAscending);
      },
    );
  }

  @override
  ColumnDefinitions getColumnDefinitionsForTable() {
    return ColumnDefinitions([
      getColumnForName(),
      getColumnForAddress(),
      getColumnForNote(),
      ColumnDefinition(
        "Count",
        ColumnType.numeric,
        TextAlign.right,
        (index) {
          return list[index].count;
        },
        (a, b, sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      ColumnDefinition(
        "Balance",
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].balance;
        },
        (a, b, sortAscending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      )
    ]);
  }

  @override
  ColumnDefinitions getColumnDefinitionsForDetailsPanel() {
    var fields = ColumnDefinitions([getColumnForName(), getColumnForAddress(), getColumnForNote()]);

    fields.add(ColumnDefinition(
      "Unit",
      ColumnType.amount,
      TextAlign.right,
      (index) {
        return getUnitsAsString(list[index].units);
      },
      (a, b, sortAscending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      },
    ));

    return fields;
  }

  getUnitsAsString(listOfUnits) {
    var text = "";
    listOfUnits.forEach((item) => {text += item.renter + ","});

    return text;
  }

  @override
  getList() {
    return Rentals.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }
}

class ViewRentUnits extends ViewWidget {
  const ViewRentUnits({super.key, super.setDetailsPanelContent});

  @override
  State<ViewWidget> createState() => ViewRentUnitsState();
}

class ViewRentUnitsState extends ViewWidgetState {
  @override
  getClassNamePlural() {
    return "Rentals";
  }

  @override
  getClassNameSingular() {
    return "Rental";
  }

  @override
  String getDescription() {
    return "Properties to rent.";
  }

  @override
  ColumnDefinitions getColumnDefinitionsForTable() {
    return ColumnDefinitions([
      ColumnDefinition(
        "Name",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].name;
        },
        (a, b, sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      ColumnDefinition(
        "Address",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].Address;
        },
        (a, b, sortAscending) {
          return sortByString(a.Address, b.Address, sortAscending);
        },
      ),
      ColumnDefinition(
        "Note",
        ColumnType.text,
        TextAlign.left,
        (index) {
          return list[index].note;
        },
        (a, b, sortAscending) {
          return sortByString(a.note, b.note, sortAscending);
        },
      ),
      ColumnDefinition(
        "Count",
        ColumnType.numeric,
        TextAlign.right,
        (index) {
          return list[index].count;
        },
        (a, b, sortAscending) {
          return sortByValue(a.count, b.count, sortAscending);
        },
      ),
      ColumnDefinition(
        "Balance",
        ColumnType.amount,
        TextAlign.right,
        (index) {
          return list[index].balance;
        },
        (a, b, sortAscending) {
          return sortByValue(a.balance, b.balance, sortAscending);
        },
      ),
    ]);
  }

  @override
  getList() {
    return Rentals.moneyObjects.getAsList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }
}
