import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/aliases/alias.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';

class ViewAliases extends ViewWidget {
  const ViewAliases({super.key});

  @override
  State<ViewWidget> createState() => ViewAliasesState();
}

class ViewAliasesState extends ViewWidgetState {
  @override
  String getClassNamePlural() {
    return 'Aliases';
  }

  @override
  String getClassNameSingular() {
    return 'Alias';
  }

  @override
  String getDescription() {
    return 'Payee aliases.';
  }

  @override
  Fields<Alias> getFieldsForTable() {
    return Alias.fields!;
  }

  @override
  List<Alias> getList([bool includeDeleted = false]) {
    return Data().aliases.iterableList(includeDeleted).toList();
  }

  @override
  Widget getPanelForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return const Text('No chart for Aliases');
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Alias? alias = getMoneyObjectFromFirstSelectedId<Alias>(selectedIds, list);
    if (alias != null && alias.id.value > -1) {
      return ListViewTransactions(
        key: Key(alias.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
          filter: (final Transaction transaction) => transaction.payee.value == alias.payeeId.value,
        ),
      );
    }
    return CenterMessage.noTransaction();
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().aliases.deleteItem(instance);
    });
  }
}
