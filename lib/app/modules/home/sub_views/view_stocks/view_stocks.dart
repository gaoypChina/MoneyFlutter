import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/center_message.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/app/modules/home/sub_views/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/stock_chart.dart';

class ViewStocks extends ViewForMoneyObjects {
  const ViewStocks({
    super.key,
  });

  @override
  State<ViewForMoneyObjects> createState() => ViewStocksState();
}

class ViewStocksState extends ViewForMoneyObjectsState {
  ViewStocksState() {
    viewId = ViewId.viewStocks;
  }

  Security? lastSecuritySelected;

  final ValueNotifier<SortingInstruction> _sortingInstruction = ValueNotifier<SortingInstruction>(SortingInstruction());

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
  Widget getInfoPanelViewChart({
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
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    lastSecuritySelected = getFirstSelectedItem() as Security?;

    if (lastSecuritySelected == null) {
      return const CenterMessage(message: 'No security selected.');
    }
    final included = [
      'Date',
      'Account',
      'Activity',
      'Units',
      'Price',
      'Commission',
      'ActivityAmount',
      'Holding',
      'HoldingValue',
    ];
    final List<Field> fieldsToDisplay = Investment.fields.definitions
        .where(
          (element) => element.useAsColumn && included.contains(element.name),
        )
        .toList();

    return ValueListenableBuilder<SortingInstruction>(
      valueListenable: _sortingInstruction,
      builder: (
        final BuildContext context,
        final SortingInstruction sortInstructions,
        final Widget? _,
      ) {
        List<Investment> list = getListOfInvestment(lastSecuritySelected!);

        MoneyObjects.sortList(
          list,
          fieldsToDisplay,
          sortInstructions.column,
          sortInstructions.ascending,
        );

        return AdaptiveListColumnsOrRowsSingleSelection(
          // list related
          list: list,
          fieldDefinitions: fieldsToDisplay,
          filters: FieldFilters(),
          sortByFieldIndex: sortInstructions.column,
          sortAscending: sortInstructions.ascending,
          selectedId: -1,
          // Field & Columns related
          displayAsColumns: true,
          backgoundColorForHeaderFooter: Colors.transparent,
          onColumnHeaderTap: (int columnHeaderIndex) {
            if (columnHeaderIndex == sortInstructions.column) {
              // toggle order
              sortInstructions.ascending = !sortInstructions.ascending;
            } else {
              sortInstructions.column = columnHeaderIndex;
            }
            _sortingInstruction.value = sortInstructions.clone();
          },
        );
      },
    );
  }

  @override
  List<Security> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    final List<Security> list = Data().securities.iterableList(includeDeleted: includeDeleted).toList();

    return list;
  }

  @override
  String getViewId() {
    return Data().securities.getTypeName();
  }

  List<Investment> getListOfInvestment(Security security) {
    final List<Investment> list = Investments.getInvestmentsForThisSecurity(security.uniqueId);
    Investments.calculateRunningSharesAndBalance(list);
    return list;
  }
}

class SortingInstruction {
  bool ascending = false;
  int column = 0;

  SortingInstruction clone() {
    // Create a new instance with the same properties
    return SortingInstruction()
      // ignore: unnecessary_this
      ..column = this.column
      // ignore: unnecessary_this
      ..ascending = this.ascending;
  }
}
