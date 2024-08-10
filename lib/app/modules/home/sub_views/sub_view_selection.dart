import 'package:flutter/material.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/data/models/constants.dart';

List<NavigationDestination> getAppBarDestinations() {
  final List<NavigationDestination> appBarDestinations = <NavigationDestination>[
    NavigationDestination(
      label: 'Cashflow',
      tooltip: 'Show your Cash Flow',
      icon: ViewId.viewCashFlow.getIcon(),
      selectedIcon: ViewId.viewCashFlow.getIcon(),
    ),
    NavigationDestination(
      label: 'Accounts',
      tooltip: 'Show Accounts',
      icon: ViewId.viewAccounts.getIcon(),
      selectedIcon: ViewId.viewAccounts.getIcon(),
    ),
    NavigationDestination(
      label: 'Categories',
      tooltip: 'Show Categories',
      icon: ViewId.viewCategories.getIcon(),
      selectedIcon: ViewId.viewCategories.getIcon(),
    ),
    NavigationDestination(
      label: 'Payees',
      tooltip: 'Show Payees',
      icon: ViewId.viewPayees.getIcon(),
      selectedIcon: ViewId.viewPayees.getIcon(),
    ),
    NavigationDestination(
      label: 'Aliases',
      tooltip: 'Show Aliases',
      icon: ViewId.viewAliases.getIcon(),
      selectedIcon: ViewId.viewAliases.getIcon(),
    ),
    NavigationDestination(
      label: 'Transactions',
      tooltip: 'Show Transactions',
      icon: ViewId.viewTransactions.getIcon(),
      selectedIcon: ViewId.viewTransactions.getIcon(),
    ),
    NavigationDestination(
      label: 'Transfers',
      tooltip: 'View transfers between accounts',
      icon: ViewId.viewTransfers.getIcon(),
      selectedIcon: ViewId.viewTransfers.getIcon(),
    ),
    NavigationDestination(
      label: 'Investments',
      tooltip: 'Investment transactions',
      icon: ViewId.viewInvestments.getIcon(),
      selectedIcon: ViewId.viewInvestments.getIcon(),
    ),
    NavigationDestination(
      label: 'Stocks',
      tooltip: 'Stocks tracking',
      icon: ViewId.viewStocks.getIcon(),
      selectedIcon: ViewId.viewStocks.getIcon(),
    ),
  ];
  if (PreferenceController.to.includeRentalManagement) {
    appBarDestinations.add(
      NavigationDestination(
        label: 'Rentals',
        tooltip: 'Rentals',
        icon: ViewId.viewRentals.getIcon(),
        selectedIcon: ViewId.viewRentals.getIcon(),
      ),
    );
  }

  return appBarDestinations;
}

List<NavigationRailDestination> getNavRailDestination() {
  final List<NavigationDestination> list = getAppBarDestinations();

  final Iterable<NavigationRailDestination> navRailDestinations = list.map(
    (final NavigationDestination destination) => NavigationRailDestination(
      icon: Tooltip(
        message: destination.label,
        child: destination.icon,
      ),
      selectedIcon: Tooltip(
        message: destination.label,
        child: destination.selectedIcon,
      ),
      label: Text(destination.label),
    ),
  );
  return navRailDestinations.toList();
}

class SubViewSelectionHorizontal extends StatefulWidget {
  const SubViewSelectionHorizontal({
    required this.onSelected,
    required this.selectedView,
    super.key,
  });

  final void Function(ViewId) onSelected;
  final ViewId selectedView;

  @override
  State<SubViewSelectionHorizontal> createState() => SubViewSelectionHorizontalState();
}

class SubViewSelectionHorizontalState extends State<SubViewSelectionHorizontal> {
  ViewId _selectedView = ViewId.viewCashFlow;

  @override
  void initState() {
    super.initState();
    _selectedView = widget.selectedView;
  }

  @override
  Widget build(final BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedView.index,
      onDestinationSelected: (final int index) {
        final view = ViewId.values[index];
        setState(() {
          _selectedView = view;
        });
        widget.onSelected(view);
      },
      destinations: getAppBarDestinations(),
      height: 52,
      indicatorColor: getColorTheme(context).onSecondary,
      backgroundColor: getColorTheme(context).secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    );
  }
}

class SubViewSelectionVertical extends StatefulWidget {
  const SubViewSelectionVertical({
    required this.onSelectItem,
    required this.selectedView,
    super.key,
    this.useIndicator = false,
  });

  final void Function(ViewId) onSelectItem;
  final ViewId selectedView;
  final bool useIndicator;

  @override
  State<SubViewSelectionVertical> createState() => SubViewSelectionVerticalState();
}

class SubViewSelectionVerticalState extends State<SubViewSelectionVertical> {
  ViewId _selectedView = ViewId.viewCashFlow;

  @override
  void initState() {
    super.initState();
    _selectedView = widget.selectedView;
  }

  @override
  Widget build(final BuildContext context) {
    final List<NavigationRailDestination> destinations = getNavRailDestination();
    return Container(
      color: getColorTheme(context).secondaryContainer,
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: NavigationRail(
            minWidth: 50,
            destinations: destinations,
            selectedIndex: _selectedView.index,
            useIndicator: widget.useIndicator,
            labelType: context.isWidthLarge ? NavigationRailLabelType.all : NavigationRailLabelType.none,
            indicatorColor: getColorTheme(context).onSecondary,
            backgroundColor: getColorTheme(context).secondaryContainer,
            onDestinationSelected: (final int index) {
              final view = ViewId.values[index];
              setState(() {
                _selectedView = view;
              });
              widget.onSelectItem(view);
            },
          ),
        ),
      ),
    );
  }
}
