import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';
import '../models/categories.dart';
import '../widgets/columns.dart';
import '../widgets/header.dart';

class ViewCategories extends StatefulWidget {
  final List<ColumnDefinition> columns = [
    ColumnDefinition("Name", TextAlign.left, () {}),
    ColumnDefinition("Type", TextAlign.left, () {}),
    ColumnDefinition("Balance", TextAlign.right, () {}),
  ];

  ViewCategories({super.key});

  @override
  State<ViewCategories> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends State<ViewCategories> {
  final formatCurrency = NumberFormat("#,##0.00", "en_US");
  num sortBy = 0;
  bool sortAscending = true;

  ViewCategoriesState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var list = Categories.list;
    switch (sortBy) {
      case 0:
        list.sort((a, b) {
          if (sortAscending) {
            return a.name.toUpperCase().compareTo(b.name.toUpperCase());
          } else {
            return b.name.toUpperCase().compareTo(a.name.toUpperCase());
          }
        });
        break;
      case 1:
        list.sort((a, b) {
          if (sortAscending) {
            return a.getTypeAsText().compareTo(b.getTypeAsText());
          } else {
            return b.getTypeAsText().compareTo(a.getTypeAsText());
          }
        });
        break;
      case 2:
        list.sort((a, b) {
          if (sortAscending) {
            return (a.balance - b.balance).toInt();
          } else {
            return (b.balance - a.balance).toInt();
          }
        });
        break;
    }
    if (sortAscending == false) {
      list.reversed;
    }

    List<Widget> headers = getHeadersWidgets(context, widget.columns, changeListSortOrder);
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(children: <Widget>[
              Header("Categories", numValueOrDefault(Categories.list.length), "Classification of your money transactions."),
              Row(children: headers),
              Expanded(
                  child: ListView.builder(
                      itemCount: list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(list[index].name, textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(list[index].getTypeAsText(), textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text(getCurrencyText(list[index].balance), textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }

  List<Widget> getHeadersWidgets(BuildContext context, columns, Function changeSort) {
    List<Widget> headers = [];
    for (var i = 0; i < columns.length; i++) {
      headers.add(
        headerButton(
          context,
          columns[i].name,
          columns[i].align,
          getSortIndicated(i),
          () {
            changeSort(i, !sortAscending);
          },
        ),
      );
    }
    return headers;
  }

  changeListSortOrder(newSortOrder, newSortAscending) {
    setState(() {
      sortBy = newSortOrder;
      sortAscending = newSortAscending;
    });
  }

  getSortIndicated(columnNumber) {
    if (columnNumber == sortBy) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }
}

enum SortIndicator { none, sortAscending, sortDescending }

getSortIconName(SortIndicator sortIndicator) {
  switch (sortIndicator) {
    case SortIndicator.sortAscending:
      return const Icon(Icons.arrow_upward, size: 20.0);
    case SortIndicator.sortDescending:
      return const Icon(Icons.arrow_downward, size: 20.0);
    case SortIndicator.none:
    default:
      return null;
  }
}

Widget headerButton(context, text, textAlign, SortIndicator sortIndicator, onClick) {
  return Expanded(
    child: Container(color: getColorTheme(context).secondaryContainer, child: textButtonOptionalIcon(context, text, textAlign, sortIndicator, onClick)),
  );
}

TextButton textButtonOptionalIcon(context, String text, textAlign, SortIndicator sortIndicator, onClick) {
  final textTheme = getTextTheme(context).apply(displayColor: getColorTheme(context).onSurface);
  var icon = getSortIconName(sortIndicator);
  if (icon == null) {
    return TextButton(
      onPressed: onClick,
      child: Text(text, textAlign: TextAlign.left, style: textTheme.titleMedium),
    );
  }
  return TextButton.icon(
    label: icon,
    onPressed: onClick,
    icon: Text(text, textAlign: TextAlign.left, style: textTheme.titleMedium),
  );
}
