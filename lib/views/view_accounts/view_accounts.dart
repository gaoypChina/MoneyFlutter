import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/details_panel/details_panel.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';

part 'view_accounts_details_panels.dart';

part 'view_accounts_helpers.dart';

final List<bool> _selectedPivot = <bool>[false, false, false, false, true];

/// Main view for all Accounts
class ViewAccounts extends ViewWidget<Account> {
  const ViewAccounts({super.key});

  @override
  State<ViewWidget<Account>> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewWidgetState<Account> {
  final List<Widget> pivots = <Widget>[];

  @override
  void initState() {
    super.initState();

    onAddNewEntry = () {
      // add a new Account
      Data().accounts.addNewAccount('New Bank Account');
      Settings().selectedView = ViewId.viewAccounts;
      Settings().isDetailsPanelExpanded = true;
    };

    onAddTransaction = () {
      showImportTransactions(context);
    };

    pivots.add(
      ThreePartLabel(
        text1: 'Banks',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(0))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Investments',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(1))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Credit',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(2))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(3))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getAmountAsStringUsingCurrency(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(-1))),
      ),
    );
  }

  @override
  String getClassNameSingular() {
    return 'Account';
  }

  @override
  String getClassNamePlural() {
    return 'Accounts';
  }

  @override
  String getDescription() {
    return 'Your main assets.';
  }

  // default currency for this view
  @override
  List<String> getCurrencyChoices(final SubViews subViewId, final List<int> selectedItems) {
    switch (subViewId) {
      case SubViews.chart: // Chart
      case SubViews.transactions: // Transactions
        final Account? account = getFirstSelectedItemFromSelectedList(selectedItems);
        if (account != null) {
          if (account.currency.value != Constants.defaultCurrency) {
            // only offer currency toggle if the account is not USD based
            return [account.currency.value, Constants.defaultCurrency];
          }
        }

        return [Constants.defaultCurrency];
      default:
        return [];
    }
  }

  @override
  Widget buildHeader([final Widget? child]) {
    return super.buildHeader(renderToggles());
  }

  @override
  List<Account> getList([bool includeDeleted = false]) {
    return Data()
        .accounts
        .activeAccount(
          getSelectedAccountType(),
          isActive: Settings().includeClosedAccounts ? null : true,
        )
        .where((final Account instance) => isMatchingFilterText(instance))
        .toList();
  }

  @override
  void setSelectedItem(final int uniqueId) {
    final Account? account = getMoneyObjectFromFirstSelectedId<Account>(<int>[uniqueId], list);
    if (account != null && account.id.value > -1) {
      Settings().mostRecentlySelectedAccount = account;
    }
    super.setSelectedItem(uniqueId);
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final Account? account = getMoneyObjectFromFirstSelectedId<Account>(selectedIds, list);
    if (account == null) {
      return const CenterMessage(message: 'No account selected.');
    } else {
      return _getSubViewContentForTransactions(
        account: account,
        showAsNativeCurrency: showAsNativeCurrency,
      );
    }
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().accounts.deleteItem(instance);
    });
  }
}
