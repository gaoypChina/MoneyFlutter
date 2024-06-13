// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';
import 'package:money/views/view_cashflow/panel_sankey.dart';
import 'package:money/views/view_cashflow/recurring/panel_recurring.dart';
import 'package:money/views/view_header.dart';
import 'package:money/views/view_transactions/no_transactions.dart';
import 'package:money/widgets/pick_number.dart';
import 'package:money/widgets/sankey/sankey.dart';
import 'package:money/widgets/years_range_selector.dart';

class ViewCashFlow extends ViewWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends ViewWidgetState {
  late DateRange dateRangeTransactions;

  late int selectedYearStart;
  late int selectedYearEnd;

  List<Account> accountsOpened = Data().accounts.getOpenAccounts();
  double totalIncomes = 0.00;
  double totalExpenses = 0.00;
  double totalSavings = 0.00;
  double totalInvestments = 0.00;
  double totalNones = 0.00;
  double padding = 10.0;
  double totalHeight = 0.0;

  Map<Category, double> mapOfIncomes = <Category, double>{};
  Map<Category, double> mapOfExpenses = <Category, double>{};
  List<SanKeyEntry> sanKeyListOfIncomes = <SanKeyEntry>[];
  List<SanKeyEntry> sanKeyListOfExpenses = <SanKeyEntry>[];

  Debouncer debouncer = Debouncer();

  ViewCashFlowState();

  @override
  void initState() {
    super.initState();
    dateRangeTransactions = DateRange.fromStarEndYears(
      Data().transactions.dateRangeActiveAccount.min?.year ?? DateTime.now().year,
      Data().transactions.dateRangeActiveAccount.max?.year ?? DateTime.now().year,
    );

    this.selectedYearStart = dateRangeTransactions.min!.year;
    this.selectedYearEnd = dateRangeTransactions.max!.year;
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header
        ViewHeader.buildViewHeaderContainer(context, _buildHeaderContent()),
        // View
        Expanded(
          child: Container(
            key: Key(Settings().cashflowViewAs.toString() + selectedYearStart.toString() + selectedYearEnd.toString()),
            // rebuild if the date changes
            color: getColorTheme(context).surface,
            child: getView(),
          ),
        ),
      ],
    );
  }

  Widget getView() {
    if (Data().transactions.isEmpty) {
      return const NoTransaction();
    }

    switch (Settings().cashflowViewAs) {
      case CashflowViewAs.sankey:
        return PanelSanKey(minYear: this.selectedYearStart, maxYear: this.selectedYearEnd);
      case CashflowViewAs.recurringIncomes:
        return PanelRecurrings(
          dateRangeSearch: dateRangeTransactions,
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
          viewRecurringAs: Settings().cashflowViewAs,
        );
      case CashflowViewAs.recurringExpenses:
        return PanelRecurrings(
          dateRangeSearch: dateRangeTransactions,
          minYear: this.selectedYearStart,
          maxYear: this.selectedYearEnd,
          viewRecurringAs: Settings().cashflowViewAs,
        );
    }
  }

  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: SizeForPadding.medium,
          spacing: SizeForPadding.large,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cash Flow', style: getTextTheme(context).titleLarge, textAlign: TextAlign.start),
            _buildSelectView(),
            if (Settings().cashflowViewAs != CashflowViewAs.sankey)
              NumberPicker(
                title: 'Occurrence',
                selectedNumber: Settings().cashflowRecurringOccurrences,
                onChanged: (int value) {
                  Settings().cashflowRecurringOccurrences = value;
                  Settings().preferrenceSave();
                },
              ),
          ],
        ),
        if (!Data().transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: YearRangeSlider(
              minYear: dateRangeTransactions.min!.year,
              maxYear: dateRangeTransactions.max!.year,
              onChanged: (minYear, maxYear) {
                debouncer.run(() {
                  if (mounted) {
                    setState(() {
                      this.selectedYearStart = minYear;
                      this.selectedYearEnd = maxYear;
                    });
                  }
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectView() {
    return SegmentedButton<CashflowViewAs>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
      segments: const <ButtonSegment<CashflowViewAs>>[
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.sankey,
          label: Text('Sankey'),
        ),
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.recurringIncomes,
          label: Text('Incomes'),
        ),
        ButtonSegment<CashflowViewAs>(
          value: CashflowViewAs.recurringExpenses,
          label: Text('Expenses'),
        ),
      ],
      selected: <CashflowViewAs>{Settings().cashflowViewAs},
      onSelectionChanged: (final Set<CashflowViewAs> newSelection) {
        setState(() {
          Settings().cashflowViewAs = newSelection.first;
          Settings().preferrenceSave();
        });
      },
    );
  }
}
