import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/box.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/my_text_input.dart';
import 'package:money/app/core/widgets/text_title.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';

import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/app_scaffold.dart';

class SettingsPage extends GetView<GetxController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return myScaffold(
      context,
      AppBar(
        title: const TextTitle('Settings'),
        centerTitle: true,
      ),
      Center(
        child: Box(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Rental'),
                subtitle: const Text(
                  'Manage the expenses and rental income of properties.',
                ),
                value: PreferenceController.to.includeRentalManagement,
                onChanged: (bool value) {
                  PreferenceController.to.includeRentalManagement = !PreferenceController.to.includeRentalManagement;
                  // setState(() {
                  //   _isRentalEnabled = value;
                  // });
                },
              ),
              gapLarge(),
              MyTextInput(
                hintText: 'Stock service API key',
                controller: TextEditingController()..text = PreferenceController.to.apiKeyForStocks,
              ),
              gapLarge(),
              MyTextInput(
                hintText: 'Currencies',
              ),
              gapMedium(),
              buildCurrenciesPanel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCurrenciesPanel(final BuildContext context) {
    final List<Widget> widgets = <Widget>[];

    for (final Currency currency in Data().currencies.iterableList()) {
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: getColorTheme(context).surfaceContainerHighest,
            border: Border.all(color: getColorTheme(context).outline),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(4),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(currency.fieldName.value),
                  Currency.buildCurrencyWidget(currency.fieldSymbol.value),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(currency.fieldRatio.value.toString()),
                  Text(currency.fieldCultureCode.value),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
