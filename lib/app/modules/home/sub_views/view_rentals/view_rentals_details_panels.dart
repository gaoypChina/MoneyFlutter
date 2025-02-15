part of 'view_rentals.dart';

extension ViewRentalsDetailsPanels on ViewRentalsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      final List<PairXY> list = <PairXY>[];
      for (final RentBuilding entry in getList()) {
        list.add(PairXY(entry.fieldName.value, entry.fieldProfit.value.toDouble()));
      }
      return Chart(
        list: list,
        variableNameHorizontal: 'Rental',
        variableNameVertical: 'Profit',
      );
    }

    RentBuilding? rental = getFirstSelectedItem() as RentBuilding?;
    if (rental != null) {
      // show PnL for the selected rental property, per year
      List<Widget> pnlCards = [];

      if (!rental.dateRangeOfOperation.hasNullDates) {
        for (int year = rental.dateRangeOfOperation.min!.year; year <= rental.dateRangeOfOperation.max!.year; year++) {
          var pnl = rental.pnlOverYears[year];
          pnl ??= RentalPnL(date: DateTime(year, 1, 1));
          pnlCards.add(RentalPnLCard(pnl: pnl));
        }
      }

      pnlCards.add(
        RentalPnLCard(
          pnl: rental.lifeTimePnL,
          customTitle: 'Life Time P&L',
        ),
      );

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: pnlCards,
        ),
      );
    }
    return const Text('No Rental property selected');
  }

  void getPnLOverYears(RentBuilding rental) {
    for (final transaction in Data().transactions.iterableList()) {
      if (rental.categoryForIncomeTreeIds.contains(transaction.fieldCategoryId.value)) {}
    }
  }

  List<Transaction> getTransactionLastSelectedItem() {
    if (lastSelectedRental != null) {
      return getTransactions(
        filter: (final Transaction transaction) => filterByRentalCategories(
          transaction,
          lastSelectedRental!,
        ),
      );
    }
    return [];
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    lastSelectedRental = getMoneyObjectFromFirstSelectedId<RentBuilding>(indices, list);
    final SelectionController selectionController = Get.put(SelectionController());
    return ListViewTransactions(
      columnsToInclude: <Field>[
        Transaction.fields.getFieldByName(columnIdDate),
        Transaction.fields.getFieldByName(columnIdAccount),
        Transaction.fields.getFieldByName(columnIdPayee),
        Transaction.fields.getFieldByName(columnIdCategory),
        Transaction.fields.getFieldByName(columnIdMemo),
        Transaction.fields.getFieldByName(columnIdAmount),
      ],
      getList: () => getTransactionLastSelectedItem(),
      selectionController: selectionController,
    );
  }

  bool filterByRentalCategories(
    final Transaction t,
    final RentBuilding rental,
  ) {
    final num categoryIdToMatch = t.fieldCategoryId.value;

    if (t.isSplit) {
      for (final MoneySplit split in t.splits) {
        if (isMatchingCategories(split.fieldCategoryId.value, rental)) {
          return true;
        }
      }
      return false;
    }

    return isMatchingCategories(categoryIdToMatch, rental);
  }

  bool isMatchingCategories(
    final num categoryIdToMatch,
    final RentBuilding rental,
  ) {
    Data().categories.getTreeIds(rental.categoryForIncome.value);

    return rental.categoryForIncomeTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForManagementTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForRepairsTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForMaintenanceTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForTaxesTreeIds.contains(categoryIdToMatch) ||
        rental.categoryForInterestTreeIds.contains(categoryIdToMatch);
  }
}
