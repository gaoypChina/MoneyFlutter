import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/box.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/payees/payees.dart';
import 'package:money/app/data/models/money_objects/transactions/transactions.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/view_payees/picker_payee.dart';

void showMergePayee(
  final BuildContext context,
  Payee payee,
) {
  final transactions =
      Data().transactions.iterableList(includeDeleted: true).where((t) => t.fieldPayee.value == payee.uniqueId);

  adaptiveScreenSizeDialog(
    context: context,
    title: 'Merge ${transactions.length} transactions',
    captionForClose: null, // this will hide the close button
    child: MergeTransactionsDialog(
      currentPayee: payee,
      transactions: transactions.toList(),
    ),
  );
}

class MergeTransactionsDialog extends StatefulWidget {
  const MergeTransactionsDialog({
    required this.currentPayee,
    required this.transactions,
    super.key,
  });

  final Payee currentPayee;
  final List<Transaction> transactions;

  @override
  State<MergeTransactionsDialog> createState() => _MergeTransactionsDialogState();
}

class _MergeTransactionsDialogState extends State<MergeTransactionsDialog> {
  AccumulatorSum<int, int> categoryIdsFound = AccumulatorSum<int, int>();

  int? _estimatedCategory;
  Payee? _selectedPayee;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Row(
            children: [
              const SizedBox(width: 100, child: Text('From payee')),
              Expanded(
                child: Box(child: Text(widget.currentPayee.fieldName.value)),
              ),
            ],
          ),
          gapLarge(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 100, child: Text('To payee')),
              Expanded(
                child: Box(
                  child: pickerPayee(
                    itemSelected: widget.currentPayee,
                    onSelected: (final Payee? selectedPayee) {
                      setState(() {
                        _selectedPayee = selectedPayee;
                        getAssociatedCategories();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          gapLarge(),
          _buildCatetgoryChoices(),
          const Spacer(),
          dialogActionButtons(
            [
              DialogActionButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              if (_selectedPayee != null && _selectedPayee != widget.currentPayee)
                DialogActionButton(
                  text: 'Merge',
                  onPressed: () {
                    mutateTransactionsToPayee(
                      widget.transactions,
                      _selectedPayee!.uniqueId,
                      _estimatedCategory,
                    );
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void getAssociatedCategories() {
    if (_selectedPayee != null) {
      categoryIdsFound.clear();
      for (final t in Data().transactions.iterableList(includeDeleted: true)) {
        if (t.fieldPayee.value == _selectedPayee!.uniqueId) {
          categoryIdsFound.cumulate(t.fieldCategoryId.value, 1);
        }
      }
    }
  }

  Widget _buildCatetgoryChoices() {
    if (categoryIdsFound.values.isEmpty) {
      return const SizedBox();
    }

    List<Widget> radioButtonChoices = [];
    final sortedDecendingListOfCategories = categoryIdsFound.getEntries();
    sortedDecendingListOfCategories.sort((a, b) => sortByValue(a.value, b.value, false));

    for (final entry in sortedDecendingListOfCategories) {
      final categoryId = entry.key;
      final categoryCounts = entry.value;

      final categoryName = Data().categories.getNameFromId(categoryId).trim();
      if (categoryName.isNotEmpty) {
        radioButtonChoices.add(
          ListTile(
            leading: Radio<int?>(
              value: categoryId,
              groupValue: _estimatedCategory,
              onChanged: (int? value) {
                setState(() {
                  _estimatedCategory = value;
                });
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'or change to category',
                  style: getTextTheme(context).bodySmall,
                ),
                gapMedium(),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Badge(
                      textColor: getColorTheme(context).onPrimaryContainer,
                      backgroundColor: getColorTheme(context).primaryContainer,
                      label: Text(getIntAsText(categoryCounts)),
                      child: Box(
                        child: Text(
                          Data().categories.getNameFromId(categoryId),
                          maxLines: 1,
                          // overflow: TextOverflow.clip, // Clip the overflow text
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (radioButtonChoices.isNotEmpty) {
      radioButtonChoices.insert(
        0,
        ListTile(
          leading: Radio<int?>(
            value: null,
            groupValue: _estimatedCategory,
            onChanged: (int? value) {
              setState(() {
                _estimatedCategory = value;
              });
            },
          ),
          title: const Text('Keep all transactions to their current categories'),
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        child: Column(
          children: radioButtonChoices,
        ),
      ),
    );
  }
}

void mutateTransactionsToPayee(
  final List<Transaction> transactions,
  final int toPayeeId,
  final int? categoryId,
) {
  Set<int> fromPayeeIds = {};

  for (final t in transactions) {
    // keep track of the payeeIds that we remove transactions from
    fromPayeeIds.add(t.fieldPayee.value);

    t.stashValueBeforeEditing();
    t.stashOriginalPayee();

    t.fieldPayee.value = toPayeeId;
    if (categoryId != null) {
      t.fieldCategoryId.value = categoryId;
    }

    Data().notifyMutationChanged(
      mutation: MutationType.changed,
      moneyObject: t,
      recalculateBalances: false,
    );
  }
  Payees.removePayeesThatHaveNoTransactions(fromPayeeIds.toList());
  Data().updateAll();
}
