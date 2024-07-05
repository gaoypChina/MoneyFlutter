import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/columns/columns_input.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/import_transactions_list.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/modules/home/sub_views/view_accounts/picker_account.dart';

/// use for free style text to transaction import
class ImportTransactionsPanel extends StatefulWidget {
  const ImportTransactionsPanel({
    required this.account,
    required this.inputText,
    required this.onAccountChanged,
    required this.onTransactionsFound,
    super.key,
  });
  final Account account;
  final String inputText;
  final Function(Account accountSelected) onAccountChanged;
  final Function(ValuesParser parser) onTransactionsFound;

  @override
  ImportTransactionsPanelState createState() => ImportTransactionsPanelState();
}

class ImportTransactionsPanelState extends State<ImportTransactionsPanel> {
  late Account account;
  late String textToParse;
  final List<String> possibleDateFormats = [
    'yyyy-MM-dd',
    'yyyy/MM/dd',
    'yyyy-dd-MM',
    'yyyy/dd/MM',
    'MM-dd-yyyy',
    'MM/dd/yyyy',
    'MM-dd-yy',
    'MM/dd/yy',
    'dd-MM-yyyy',
    'dd/MM/yyyy',
    'dd-MM-yy',
    'dd/MM/yy',
  ];
  late String userChoiceOfDateFormat = possibleDateFormats.first;

  final _focusNode = FocusNode();

  List<ValuesQuality> values = [];

  @override
  void initState() {
    super.initState();
    account = widget.account;
    textToParse = widget.inputText;
    convertAndNotify(context, textToParse);
  }

  @override
  Widget build(BuildContext context) {
    ValuesParser.evaluateExistence(values);

    return SizedBox(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderAndAccountPicker(),

          gapMedium(),

          Expanded(
            flex: 1,
            child: ColumnInput(
              inputText: textToParse,
              dateFormat: userChoiceOfDateFormat,
              currency: account.getAccountCurrencyAsText(),
              onChange: (String newTextInput) {
                setState(() {
                  convertAndNotify(context, newTextInput);
                  textToParse = newTextInput;
                });
              },
            ),
          ),
          if (values.isNotEmpty)
            Row(
              children: [
                _buildChoiceOfDateFormat(),
                const Spacer(),
                _buildChoiceOfAmountFormat(),
              ],
            ),

          gapLarge(),

          // Results
          Expanded(
            flex: 2,
            child: ImportTransactionsList(
              values: values,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndAccountPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Import transaction to account',
          style: getTextTheme(context).bodyMedium,
        ),
        gapLarge(),
        Expanded(
          child: pickerAccount(
            selected: account,
            onSelected: (final Account? accountSelected) {
              setState(
                () {
                  account = accountSelected!;
                  widget.onAccountChanged(account);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceOfDateFormat() {
    bool textToParseContainsSlash = textToParse.contains('/');
    bool textToParseContainsDash = textToParse.contains('-');

    Iterable<String> choiceOfDateFormat = possibleDateFormats.where(
      (item) => (item.contains('/') && textToParseContainsSlash) || (item.contains('-') && textToParseContainsDash),
    );

    if (choiceOfDateFormat.isEmpty) {
      choiceOfDateFormat = possibleDateFormats;
    }

    // make sure that the choice is valid
    if (!choiceOfDateFormat.contains(userChoiceOfDateFormat)) {
      userChoiceOfDateFormat = choiceOfDateFormat.first;
    }

    return DropdownButton<String>(
      value: userChoiceOfDateFormat,
      items: choiceOfDateFormat
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (final String? value) {
        setState(() {
          userChoiceOfDateFormat = value!;
          convertAndNotify(context, textToParse);
        });
      },
    );
  }

  Widget _buildChoiceOfAmountFormat() {
    return account.getAccountCurrencyAsWidget();
  }

  void convertAndNotify(BuildContext context, String inputText) {
    ValuesParser parser = ValuesParser(
      dateFormat: userChoiceOfDateFormat,
      currency: account.getAccountCurrencyAsText(),
    );
    parser.convertInputTextToTransactionList(
      context,
      inputText,
    );
    values = parser.lines;
    widget.onTransactionsFound(parser);
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void removeFocus() {
    _focusNode.unfocus();
  }
}
