import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/preferences_helper.dart';
import 'package:money/views/adaptive_view/adaptive_list/transactions/list_view_transactions.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/view_payees/merge_payees.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/widgets/date_range_time_line.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/mini_timeline_daily.dart';

part 'view_payees_details_panels.dart';

class ViewPayees extends ViewForMoneyObjects {
  const ViewPayees({super.key});

  @override
  State<ViewForMoneyObjects> createState() => ViewPayeesState();
}

class ViewPayeesState extends ViewForMoneyObjectsState {
  ViewPayeesState() {
    viewId = ViewId.viewPayees;
  }

  /// add more top leve action buttons
  @override
  List<Widget> getActionsForSelectedItems(final bool forInfoPanelTransactions) {
    final list = super.getActionsForSelectedItems(forInfoPanelTransactions);
    if (!forInfoPanelTransactions) {
      /// Merge
      final MoneyObject? moneyObject = getFirstSelectedItem();
      if (moneyObject != null) {
        list.add(
          buildMergeButton(
            () {
              // let the user pick another Payee and merge change the transaction of the current selected payee to the destination
              final payee = (moneyObject as Payee);
              final transactions =
                  Data().transactions.iterableList(includeDeleted: true).where((t) => t.payee.value == payee.uniqueId);

              adaptiveScreenSizeDialog(
                context: context,
                title: 'Merge ${transactions.length} transactions',
                captionForClose: null, // this will hide the close button
                child: MergeTransactionsDialog(
                  currentPayee: payee,
                  transactions: transactions.toList(),
                ),
              );
            },
          ),
        );
      }

      // this can go last
      if (getFirstSelectedItem() != null) {
        list.add(
          buildJumpToButton(
            [
              InternalViewSwitching(
                ViewId.viewTransactions.getIconData(),
                'Switch to Transactions',
                () {
                  final Payee? payee = getFirstSelectedItem() as Payee?;
                  if (payee != null) {
                    // Prepare the Transaction view to show only the selected account
                    FieldFilters filterByAccount = FieldFilters();
                    filterByAccount.add(FieldFilter(
                        fieldName: Constants.viewTransactionFieldnamePayee,
                        filterTextInLowerCase: payee.name.value.toLowerCase()));

                    PreferencesHelper().setStringList(
                      ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
                      filterByAccount.toStringList(),
                    );

                    // Switch view
                    Settings().selectedView = ViewId.viewTransactions;
                  }
                },
              ),
            ],
          ),
        );
      }
    }
    return list;
  }

  @override
  String getClassNamePlural() {
    return 'Payees';
  }

  @override
  String getClassNameSingular() {
    return 'Payee';
  }

  @override
  String getDescription() {
    return 'Who is getting your money.';
  }

  @override
  String getViewId() {
    return Data().payees.getTypeName();
  }

  @override
  List<Payee> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return Data()
        .payees
        .iterableList(includeDeleted: includeDeleted)
        .where((instance) => (applyFilter == false || isMatchingFilters(instance)))
        .toList();
  }

  @override
  Widget getInfoPanelViewChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForChart(
      selectedIds: selectedIds,
      showAsNativeCurrency: showAsNativeCurrency,
    );
  }

  @override
  Widget getInfoPanelViewTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    return _getSubViewContentForTransactions(selectedIds);
  }

  @override
  List<MoneyObject> getInfoTransactions() {
    final Payee? payee = getFirstSelectedItem() as Payee?;
    if (payee != null && payee.id.value > -1) {
      return getTransactions(
        filter: (final Transaction transaction) => transaction.payee.value == payee.id.value,
      );
    }
    return [];
  }

  @override
  Fields<Payee> getFieldsForTable() {
    return Payee.fields;
  }
}
