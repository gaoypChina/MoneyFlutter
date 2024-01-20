import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/chart.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/table_view/table_transactions.dart';

part 'view_loans_details_panels.dart';

class ViewLoans extends ViewWidget<LoanPayment> {
  const ViewLoans({super.key});

  @override
  State<ViewWidget<LoanPayment>> createState() => ViewLoansState();
}

class ViewLoansState extends ViewWidgetState<LoanPayment> {
  @override
  getClassNameSingular() {
    return 'Loan';
  }

  @override
  getClassNamePlural() {
    return 'Loans';
  }

  @override
  String getDescription() {
    return 'Properties to rent.';
  }

  @override
  List<LoanPayment> getList() {
    return Data().loanPayments.getList();
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  Widget getPanelForChart(final List<int> indices) {
    return _getSubViewContentForChart(indices);
  }

  @override
  Widget getPanelForTransactions(final List<int> indices) {
    return _getSubViewContentForTransactions(indices);
  }
}
