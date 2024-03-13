import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/accounts/accounts.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/center_message.dart';
import 'package:money/widgets/details_panel/details_panel.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/widgets/list_view/transactions/list_view_transactions.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';

part 'view_accounts_details_panels.dart';

part 'view_accounts_helpers.dart';

/// Main view for all Accounts
class ViewAccounts extends ViewWidget<Account> {
  const ViewAccounts({super.key});

  @override
  State<ViewWidget<Account>> createState() => ViewAccountsState();
}

class ViewAccountsState extends ViewWidgetState<Account> {
  final List<Widget> pivots = <Widget>[];
  final List<bool> _selectedPivot = <bool>[false, false, false, false, true];

  @override
  void initState() {
    super.initState();

    onAddTransaction = () {
      setState(() {
        final Transaction t = Transaction();
        t.id.value = Data().transactions.getNextTransactionId();
        t.accountId.value = getLastUsedOrFirstAccount().uniqueId;
        t.dateTime.value = DateTime.now();

        Data().transactions.addEntry(t, isNewEntry: true);
      });
    };

    pivots.add(
      ThreePartLabel(
        text1: 'Banks',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(0))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Investments',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(1))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Credit',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(2))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'Assets',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(3))),
      ),
    );
    pivots.add(
      ThreePartLabel(
        text1: 'All',
        small: true,
        isVertical: true,
        text2: Currency.getCurrencyText(getTotalBalanceOfAccounts(getSelectedAccountTypesByIndex(-1))),
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
        final int? selectedAccountIndex = selectedItems.firstOrNull;
        if (selectedAccountIndex != null && selectedAccountIndex < list.length) {
          if (list[selectedAccountIndex].currency.value != Constants.defaultCurrency) {
            // only offer currency toggle if the account is not USD based
            return [list[selectedAccountIndex].currency.value, Constants.defaultCurrency];
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
  void setSelectedItem(final int index) {
    final Account? account = getFirstElement<Account>(<int>[index], list);
    if (account != null && account.id.value > -1) {
      Settings().mostRecentlySelectedAccount = account;
    }
    super.setSelectedItem(index);
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions({
    required final List<int> selectedItems,
    required final bool showAsNativeCurrency,
  }) {
    if (Settings().mostRecentlySelectedAccount != null) {
      return _getSubViewContentForTransactions(
        account: Settings().mostRecentlySelectedAccount!,
        showAsNativeCurrency: showAsNativeCurrency,
      );
    }
    return const CenterMessage(message: 'No item selected.');
  }

  @override
  void onDeleteConfirmedByUser(final MoneyObject instance) {
    setState(() {
      Data().accounts.deleteItem(instance);
    });
  }
}
