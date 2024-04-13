import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/securities/security.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptable_list_view.dart';
import 'package:money/views/view.dart';
import 'package:money/views/view_stocks/stock_chart.dart';
import 'package:money/widgets/center_message.dart';

class ViewStocks extends ViewWidget {
  const ViewStocks({
    super.key,
  });

  @override
  State<ViewWidget> createState() => ViewStocksState();
}

class ViewStocksState extends ViewWidgetState {
  @override
  String getClassNamePlural() {
    return 'Stocks';
  }

  @override
  String getClassNameSingular() {
    return 'Stock';
  }

  @override
  String getDescription() {
    return 'Stocks tracking.';
  }

  @override
  Fields<Security> getFieldsForTable() {
    return Security.fields;
  }

  @override
  List<Security> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Security> list = Data().securities.iterableList(includeDeleted).toList();
    return list;
  }

  @override
  Widget getPanelForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Security? selected = getFirstSelectedItem() as Security?;
    if (selected != null) {
      final String symbol = selected.symbol.value;
      if (symbol.isNotEmpty) {
        return StockChartWidget(
          key: Key('stock_symbol_$symbol'),
          symbol: symbol,
        );
      }
    }
    return const Center(child: Text('No stock selected'));
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Security? security = getMoneyObjectFromFirstSelectedId<Security>(selectedIds, getList());
    if (security == null) {
      return const CenterMessage(message: 'No security selected.');
    }

    final List<Investment> list =
        Data().investments.iterableList().where((item) => item.security.value == security.uniqueId).toList();
    if (list.isEmpty) {
      return const CenterMessage(message: 'No transaction found.');
    }

    Investments.calculateRunningBalance(list);
    final exclude = ['Symbol', 'Load', 'Fees'];
    final fieldsToDisplay = Investment.fields.definitions
        .where((element) => element.useAsColumn && !exclude.contains(element.name))
        .toList();
    return AdaptableListView(
        fieldDefinitions: fieldsToDisplay,
        list: list,
        sortAscending: false,
        selectedItemsByUniqueId: ValueNotifier<List<int>>(<int>[]),
        onItemTap: (BuildContext __, int _) {
          copyToClipboardAndInformUser(context, MoneyObjects.getCsvFromList(list));
        });
  }
}
