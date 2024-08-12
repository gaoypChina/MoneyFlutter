import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money/app/controller/theme_controller.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_header.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  group('App Test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Full app test', (WidgetTester tester) async {
      // Use an empty SharedPreferences to get the same results each time
      SharedPreferences.setMockInitialValues(<String, Object>{});

      app.main();
      await tester.pumpAndSettle();

      ThemeController.to.setAppSizeToLarge();
      await tester.pumpAndSettle();

      //------------------------------------------------------------------------
      // Welcome screen - Policy
      await testWelcomeScreen(tester);

      //------------------------------------------------------------------------
      // Close the file
      await tapOnKeyString(tester, 'key_menu_button');
      await tapOnText(tester, 'Close file');

      //------------------------------------------------------------------------
      // Open a Demo Data
      await tapOnText(tester, 'Use Demo Data');

      //------------------------------------------------------------------------
      // Themes
      await testTheme(tester);

      //------------------------------------------------------------------------
      // The Settings dialog
      await testSettings(tester);

      //------------------------------------------------------------------------
      // Cash Flow
      await testCashFlow(tester);

      //------------------------------------------------------------------------
      // Accounts
      await testAccounts(tester);

      //------------------------------------------------------------------------
      // Categories
      await testCategories(tester);

      //------------------------------------------------------------------------
      // Payees
      await testPayees(tester);

      //------------------------------------------------------------------------
      // Aliases
      await testAliases(tester);

      //------------------------------------------------------------------------
      // Transactions
      await testTransactions(tester);

      //------------------------------------------------------------------------
      // Transfers
      await tapOnText(tester, 'Transfers');
      await infoTabs(tester);

      //------------------------------------------------------------------------
      // Investments
      await tapOnText(tester, 'Investments');
      await tapOnTextFromParentType(tester, ListView, 'Fidelity');
      await infoTabs(tester);

      //------------------------------------------------------------------------
      // Stocks
      await testStocks(tester);

      //------------------------------------------------------------------------
      // Rentals
      await tapOnText(tester, 'Rentals');
      await tapOnTextFromParentType(tester, ListView, 'AirBnB');
      await infoTabs(tester);

      //------------------------------------------------------------------------
      // Pending Changes
      await testPendingChanges(tester);
    });
  });
}

Future<void> testSettings(WidgetTester tester) async {
  await tapOnKey(tester, Constants.keySettingsButton);
  await tapOnKeyString(tester, 'key_settings');

  // Turn on Rentals
  {
    // Find the SwitchListTile using the text label provided in the Semantics
    final Finder switchTileFinder = find.byWidgetPredicate(
      (Widget widget) => widget is SwitchListTile && widget.title is Text && (widget.title as Text).data == 'Rental',
    );

    // Verify initial state is OFF (false)
    SwitchListTile switchTile = tester.widget(switchTileFinder);
    expect(switchTile.value, isFalse);

    // Toggle the switch to "On"
    await tester.tap(switchTileFinder);
    await tester.pumpAndSettle(); // Wait for the state to update
    await Future.delayed(const Duration(seconds: 1));
  }
  await tapBackButton(tester);
}

Future<void> testTheme(WidgetTester tester) async {
  // Turn Dark-Mode on
  await tapOnKeyString(tester, 'key_toggle_mode');
  await Future.delayed(const Duration(seconds: 1));

  // Turn back Light-Mode
  await tapOnKeyString(tester, 'key_toggle_mode');
  await Future.delayed(const Duration(seconds: 1));
}

Future<void> testWelcomeScreen(WidgetTester tester) async {
  //------------------------------------------------------------------------
  // Welcome screen - Policy
  await tapOnText(tester, 'Privacy Policy');
  await tapBackButton(tester);

  //------------------------------------------------------------------------
  // Welcome screen - Licenses
  await tapOnText(tester, 'Licenses');
  await tapBackButton(tester);

  //------------------------------------------------------------------------
  // Welcome screen - MRU
  await tapOnKey(tester, Constants.keyMruButton);
  await tapOnText(tester, 'Close');

  //------------------------------------------------------------------------
  // Tap the "New File"
  await tapOnText(tester, 'New File ...');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> testCashFlow(WidgetTester tester) async {
  await tapOnText(tester, 'Cashflow');
  await Future.delayed(const Duration(seconds: 1));

  await tapOnText(tester, 'NetWorth');
  await Future.delayed(const Duration(seconds: 1));

  await tapOnText(tester, 'Incomes');
  await Future.delayed(const Duration(seconds: 1));

  await tapOnText(tester, 'Expenses');
  await Future.delayed(const Duration(seconds: 1));
}

Future<void> testAliases(WidgetTester tester) async {
  await tapOnText(tester, 'Aliases');
  await tapOnTextFromParentType(tester, ListView, 'ABC');
  await infoTabs(tester);
}

Future<void> testAccounts(WidgetTester tester) async {
  await tapOnText(tester, 'Accounts');

  await tapOnKey(tester, Constants.keyInfoPanelExpando);
  await infoTabs(tester);

  // Select one of the row
  await tapOnTextFromParentType(tester, ListView, 'Checking');

  // CopyToCLipboard from the Info Panel Header
  await tapOnKey(tester, Constants.keyCopyListToClipboardHeaderInfoPanel);

  // Accounts - Add new
  await tapOnKey(tester, Constants.keyAddNewAccount);

  // Accounts - Edit
  await tapOnKey(tester, Constants.keyEditSelectedItems);
  await tapOnText(tester, 'Cancel');

  // Delete selected item
  await tapOnKey(tester, Constants.keyDeleteSelectedItems);
  await tapOnText(tester, 'Delete');

  // CopyToCLipboard from the Main Header
  await tapOnKey(tester, Constants.keyCopyListToClipboardHeaderMain);
}

Future<void> testCategories(WidgetTester tester) async {
  await tapOnText(tester, 'Categories');
  await tapOnFirstRowOfListView(tester);
  await tapOnKey(tester, Constants.keyMergeButton);
  await tapOnText(tester, 'Cancel');
  await infoTabs(tester);

  // trigger sort by Level
  await tester.longPress(find.text('Level').first);
  await tapOnText(tester, 'Close');
}

Future<void> testPayees(WidgetTester tester) async {
  await tapOnText(tester, 'Payees');
  await tapOnFirstRowOfListView(tester);
  await tapOnKey(tester, Constants.keyMergeButton);
  await tapOnText(tester, 'Cancel');

  await infoTabs(tester);
}

Future<void> testStocks(WidgetTester tester) async {
  await tapOnText(tester, 'Stocks');
  await tapOnTextFromParentType(tester, ListView, 'AAPL');
  await infoTabs(tester);

  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Chart');
  await tapOnText(tester, 'Set API Key');
  await tapOnText(tester, 'Cancel');
}

Future<void> testTransactions(WidgetTester tester) async {
  await tapOnText(tester, 'Transactions');

  // Select one of the rows
  await tapOnTextFromParentType(tester, ListView, 'Bank Of America');

  // Edit
  await tapOnKey(tester, Constants.keyEditSelectedItems);
  await tapOnText(tester, 'Cancel');

  await infoTabs(tester);

  // trigger sort by Date
  await tapOnText(tester, 'Date');

  // trigger sort by  Account
  await tapOnText(tester, 'Account');

  // trigger sort by  Account
  await tapOnText(tester, 'Payee/Transfer');

  // trigger sort by  Category
  await tapOnText(tester, 'Category');

  // trigger sort by  Status
  await tapOnText(tester, 'Status');

  // trigger sort by  Currency
  await tapOnText(tester, 'Currency');

  // trigger sort by  Amount
  await tapOnText(tester, 'Amount');

  // trigger sort by  Amount(USD)
  await tapOnText(tester, 'Amount(USD)');

  // trigger sort by  Balance(USD)
  await tapOnText(tester, 'Balance(USD)');

  // input a filter text that will return no match
  await filterBy(tester, 'some text that will not return any match');

  // Not expecting to fnd any match, look for and tap the "reset the filters" button
  await tapOnText(tester, 'Clear Filters');

  await filterBy(tester, '12');

  await tester.longPress(find.text('Category').first);
  await tapOnText(tester, 'Close');
}

Future<void> infoTabs(WidgetTester tester) async {
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Details');
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Chart');
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Transactions');
}

Future<void> filterBy(WidgetTester tester, final String textToFilterBy) async {
  final filterInput = find.byType(TextField).first;
  await tester.enterText(filterInput, textToFilterBy);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle(Durations.long4);
}

Future<void> testPendingChanges(WidgetTester tester) async {
  await tapOnKey(tester, Constants.keyPendingChanges);

  await tapOnTextFromParentType(tester, Wrap, 'Aliases');
  await tapOnTextFromParentType(tester, Wrap, 'Categories');
  await tapOnTextFromParentType(tester, Wrap, 'Currencies');
  await tapOnTextFromParentType(tester, Wrap, 'LoanPayments');
  await tapOnTextFromParentType(tester, Wrap, 'Payees');
  await tapOnTextFromParentType(tester, Wrap, 'Transactions');
  await tapOnTextFromParentType(tester, Wrap, 'Splits');
  await tapOnTextFromParentType(tester, Wrap, 'Accounts');

  await tapOnText(tester, 'None modified');

  await tapOnText(tester, '1 deleted');

  // close the panel
  await tapOnText(tester, 'Save to CSV');
}
