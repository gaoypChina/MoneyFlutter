import 'package:flutter/material.dart';
import 'package:money/helpers/accumulator.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/payees/payees.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_payees/picker_payee.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/gaps.dart';

class MergeTransactionsDialog extends StatefulWidget {
  const MergeTransactionsDialog({
    super.key,
    required this.currentPayee,
    required this.transactions,
  });

  final Payee currentPayee;
  final List<Transaction> transactions;

  @override
  State<MergeTransactionsDialog> createState() => _MergeTransactionsDialogState();
}

class _MergeTransactionsDialogState extends State<MergeTransactionsDialog> {
  Payee? _selectedPayee;

  int? _estimatedCategory;
  AccumulatorSum<int, int> categoryIdsFound = AccumulatorSum<int, int>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Row(
            children: [
              const SizedBox(width: 100, child: Text('From payee')),
              Chip(label: Text(widget.currentPayee.name.value)),
            ],
          ),
          gapLarge(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 100, child: Text('To payee')),
              Expanded(
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
        if (t.payee.value == _selectedPayee!.uniqueId) {
          categoryIdsFound.cumulate(t.categoryId.value, 1);
        }
      }
      _estimatedCategory = categoryIdsFound.getKeyWithLargestSum();
    }
  }

  Widget _buildCatetgoryChoices() {
    if (categoryIdsFound.values.isEmpty) {
      return const SizedBox();
    }

    List<Widget> radioButtonChoices = [];

    categoryIdsFound.values.forEach((keyId, valueSum) {
      final categoryName = Data().categories.getNameFromId(keyId).trim();
      if (categoryName.isNotEmpty) {
        radioButtonChoices.add(ListTile(
          leading: Radio<int?>(
            value: keyId,
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
                'Category',
                style: getTextTheme(context).bodySmall,
              ),
              gapMedium(),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Badge(
                    textColor: getColorTheme(context).onPrimaryContainer,
                    backgroundColor: getColorTheme(context).primaryContainer,
                    label: Text(getIntAsText(valueSum)),
                    child: Chip(
                      clipBehavior: Clip.hardEdge,
                      label: Text(
                        Data().categories.getNameFromId(keyId),
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
        ));
      }
    });

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
          title: const Text('Keep current categories'),
        ),
      );
    }

    return Column(
      children: radioButtonChoices,
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
    fromPayeeIds.add(t.payee.value);

    t.stashValueBeforeEditing();

    t.payee.value = toPayeeId;
    if (categoryId != null) {
      t.categoryId.value = categoryId;
    }

    Data().notifyMutationChanged(
      mutation: MutationType.changed,
      moneyObject: t,
      fireNotification: false,
    );
  }
  Payees.removePayeesThatHaveNoTransactions(fromPayeeIds.toList());
  Data().updateAll();
}
