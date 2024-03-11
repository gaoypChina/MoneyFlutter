import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/settings.dart';
import 'package:money/models/value_parser.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/views/view_accounts/account_selection.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/import_transactions_list.dart';
import 'package:money/widgets/message_box.dart';

/// use for free style text to transaction import
class ImportTransactionsPanel extends StatefulWidget {
  final Account account;
  final String inputText;
  final Function(Account accountSelected) onAccountChanged;
  final Function(ValuesParser parser) onTransactionsFound;

  const ImportTransactionsPanel({
    super.key,
    required this.account,
    required this.inputText,
    required this.onAccountChanged,
    required this.onTransactionsFound,
  });

  @override
  ImportTransactionsPanelState createState() => ImportTransactionsPanelState();
}

class ImportTransactionsPanelState extends State<ImportTransactionsPanel> {
  late Account account;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<ValuesQuality> values = [];

  @override
  void initState() {
    super.initState();
    account = widget.account;
    _controller.text = widget.inputText;
  }

  @override
  Widget build(BuildContext context) {
    convertAndNotify(context);

    return LayoutBuilder(
      builder: (
        final BuildContext context,
        final BoxConstraints constraints,
      ) {
        return Column(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Import transaction to account'),
                gapMedium(),
                buildAccountSelection(
                  account,
                  (final Account? accountSelected) {
                    setState(
                      () {
                        account = accountSelected!;
                        widget.onAccountChanged(account);
                      },
                    );
                  },
                ),
              ],
            ),
            gapLarge(),
            // Text Input
            Center(
              child: SizedBox(
                width: 600,
                height: 100,
                child: TextField(
                  focusNode: _focusNode,
                  autofocus: true,
                  maxLines: null,
                  // Set maxLines to null for multiline TextField
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Date; Description; Amount',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      convertAndNotify(context);
                    });
                  },
                ),
              ),
            ),

            // Results
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 400,
                  width: 600,
                  child: ImportTransactionsList(values: values),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void convertAndNotify(BuildContext context) {
    ValuesParser parser = ValuesParser();
    parser.convertInputTextToTransactionList(
      context,
      _controller.text,
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

void showImportTransactions(
  final BuildContext context, [
  String? initialText,
]) {
  initialText ??= '${dateToString(DateTime.now())} memo 1.00';

  Account? account = Settings().mostRecentlySelectedAccount;
  account ??= Data().accounts.firstItem();

  if (account == null) {
    messageBox(context, 'No account to import transaction to.');
  } else {
    importTransactionFromText(
      context,
      initialText,
      account,
    );
  }
}
