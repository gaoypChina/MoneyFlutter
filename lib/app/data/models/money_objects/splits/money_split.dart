// ignore_for_file: unrelated_type_equality_checks, unnecessary_this

import 'dart:ui';

import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

/*
  SQLite table definition

  0|Transaction|bigint|1||0
  1|Id|INT|1||0
  2|Category|INT|0||0
  3|Payee|INT|0||0
  4|Amount|money|1||0
  5|Transfer|bigint|0||0
  6|Memo|nvarchar(255)|0||0
  7|Flags|INT|0||0
  8|BudgetBalanceDate|datetime|0||0
 */

class MoneySplit extends MoneyObject {
  /// Constructor
  MoneySplit({
    // 1
    required int id,
    // 0
    required int transactionId,
    // 2
    required int categoryId,
    // 3
    required int payeeId,
    // 4
    required double amount,
    // 5
    required int transferId,
    // 6
    required String memo,
    // 7
    required int flags,
    // 8
    required DateTime? budgetBalanceDate,
  }) {
    this.fieldId.value = id;
    this.fieldTransactionId.value = transactionId;
    this.fieldCategoryId.value = categoryId;
    this.fieldPayeeId.value = payeeId;
    this.fieldAmount.value.setAmount(amount);
    this.fieldTransferId.value = transferId;
    this.fieldMemo.value = memo;
    this.fieldFlags.value = flags;
    this.fieldBudgetBalanceDate.value = budgetBalanceDate;
  }

  factory MoneySplit.fromJson(final MyJson row) {
    return MoneySplit(
      // 0
      transactionId: row.getInt('Transaction', -1),
      // 1
      id: row.getInt('Id', -1),
      // 2
      categoryId: row.getInt('Category', -1),
      // 3
      payeeId: row.getInt('Payee', -1),
      // 4
      amount: row.getDouble('Amount'),
      // 5
      transferId: row.getInt('Transfer', -1),
      // 6
      memo: row.getString('Memo'),
      // 7
      flags: row.getInt('Flags'),
      // 8
      budgetBalanceDate: row.getDate('BudgetBalanceDate'),
    );
  }

  // 4
  FieldMoney fieldAmount = FieldMoney(
    name: 'Amount',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).fieldAmount.value,
  );

  // 8
  FieldDate fieldBudgetBalanceDate = FieldDate(
    name: 'Budgeted Date',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).fieldBudgetBalanceDate.value,
  );

  // 2
  FieldInt fieldCategoryId = FieldInt(
    name: 'Category',
    type: FieldType.text,
    align: TextAlign.left,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().categories.getNameFromId((instance as MoneySplit).fieldCategoryId.value),
  );

  // 7
  FieldInt fieldFlags = FieldInt(
    name: 'Flags',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).fieldFlags.value,
  );

  // 1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as MoneySplit).uniqueId,
  );

  // 6
  FieldString fieldMemo = FieldString(
    name: 'Memo',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).fieldMemo.value,
  );

  // 3
  FieldInt fieldPayeeId = FieldInt(
    name: 'Payee',
    type: FieldType.text,
    align: TextAlign.left,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().payees.getNameFromId((instance as MoneySplit).fieldPayeeId.value),
  );

  // 0
  FieldInt fieldTransactionId = FieldInt(
    name: 'Transaction',
    getValueForDisplay: (final MoneyObject instance) => (instance as MoneySplit).fieldTransactionId.value,
  );

  // 5
  FieldInt fieldTransferId = FieldInt(
    name: 'Transfer',
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  static final _fields = Fields<MoneySplit>();

  static Fields<MoneySplit> get fields {
    if (_fields.isEmpty) {
      final tmp = MoneySplit.fromJson({});
      _fields.setDefinitions([
        tmp.fieldPayeeId,
        tmp.fieldCategoryId,
        tmp.fieldMemo,
        tmp.fieldAmount,
      ]);
    }
    return _fields;
  }

  Transaction? getTransferTransaction() {
    return Data().transactions.get(this.fieldTransactionId.value);
  }
}
