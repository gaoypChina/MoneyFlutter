import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/theme/theme_controler.dart';
import 'package:money/app/modules/home/views/app_title.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/data/storage/import/import_transactions_from_text.dart';
import 'package:money/app/data/storage/import/import_wizard.dart';
import 'package:money/app/core/widgets/color_palette.dart';
import 'package:money/app/core/widgets/dialog/dialog_button.dart';
import 'package:money/app/core/widgets/three_part_label.dart';
import 'package:money/app/core/widgets/zoom.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
  });

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  final ThemeController themeController = Get.find();

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      backgroundColor: getColorTheme(context).secondaryContainer,

      // Menu
      leading: _buildPopupMenu(),

      // Center Title
      title: AppTitle(),

      // Button on the right side
      actions: <Widget>[
        // Hide/Show closed accounts
        if (!GeneralController().isSmallScreen) _buildButtonToggleViewClosedAccounts(),

        // Dark / Light mode
        IconButton(
          icon: themeController.isDarkTheme.value ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
          onPressed: () {
            final ThemeController themeController = Get.find();
            themeController.toggleTheme();
          },
          tooltip: 'Toggle brightness',
        ),
        _buildSettingsMenu(),
      ],
    );
  }

  Widget _buildButtonToggleViewClosedAccounts() {
    return IconButton(
      icon: _buildButtonToggleViewClosedAccountsIcon(),
      onPressed: () {
        GeneralController().ctlPref.includeClosedAccounts = !GeneralController().ctlPref.includeClosedAccounts;
      },
      tooltip: GeneralController().ctlPref.includeClosedAccounts ? 'Hide closed accounts' : 'View closed accounts',
    );
  }

  Widget _buildButtonToggleViewClosedAccountsIcon() {
    return Opacity(
      opacity: GeneralController().ctlPref.includeClosedAccounts ? 1.0 : 0.5,
      child: const Icon(
        Icons.inventory,
        size: 18,
      ),
    );
  }

  Widget _buildPopupMenu() {
    final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
    // New
    addMenuItem(list, Constants.commandFileNew, 'New', Icons.note_add_outlined);

    // Open
    addMenuItem(list, Constants.commandFileOpen, 'Open...', Icons.file_open_outlined);

    // Add Transactions
    addMenuItem(list, Constants.commandAddTransactions, 'Add transactions...', Icons.post_add_outlined);

    if (!kIsWeb) {
      // File Location
      addMenuItem(list, Constants.commandFileLocation, 'File location...', Icons.folder_open_outlined);

      // Save CSV
      addMenuItem(list, Constants.commandFileSaveCsv, 'Save to CSV', Icons.save);

      // Save SQL
      addMenuItem(list, Constants.commandFileSaveSql, 'Save to SQL', Icons.save);
    }

    // Close
    addMenuItem(list, Constants.commandFileClose, 'Close file', Icons.close);

    return myPopupMenuIconButton(
      icon: Icons.menu,
      tooltip: 'File menu',
      list: list,
      onSelected: (final int index) {
        switch (index) {
          case Constants.commandFileNew:
            GeneralController().closeFile();
            Get.offAllNamed(Constants.routeHomePage);

          case Constants.commandFileOpen:
            GeneralController().onFileOpen().then((_) {
              Get.offAllNamed(Constants.routeHomePage);
            });

          case Constants.commandFileLocation:
            GeneralController().onShowFileLocation();

          case Constants.commandAddTransactions:
            showImportTransactionsWizard(context);

          case Constants.commandFileSaveCsv:
            GeneralController().onSaveToCsv();

          case Constants.commandFileSaveSql:
            GeneralController().onSaveToSql();

          case Constants.commandFileClose:
            GeneralController().closeFile();
            Get.offAllNamed(Constants.routeWelcomePage);

          default:
            debugPrint('unhandled $index');
        }
      },
    );
  }

  void addMenuItem(final list, final int id, final String caption, final IconData iconData) {
    list.add(
      PopupMenuItem<int>(
        value: id,
        child: ThreePartLabel(
          icon: Icon(iconData),
          text1: caption,
          small: true,
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    final List<PopupMenuItem<int>> actionList = [];

    actionList.add(
      PopupMenuItem<int>(
        value: Constants.commandIncludeClosedAccount,
        child: ThreePartLabel(
          text1: GeneralController().ctlPref.includeClosedAccounts ? 'Hide closed accounts' : 'Include closed account',
          icon: _buildButtonToggleViewClosedAccountsIcon(),
          small: true,
        ),
      ),
    );

    actionList.add(
      const PopupMenuItem<int>(
        value: Constants.commandSettings,
        child: ThreePartLabel(
          text1: 'Settings...',
          icon: Icon(Icons.settings, color: Colors.grey),
          small: true,
        ),
      ),
    );

    final colorPallette = List<PopupMenuItem<int>>.generate(colorOptions.length, (final int index) {
      final bool isSelected = index == themeController.colorSelected.value;
      return PopupMenuItem<int>(
        value: index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? getColorTheme(context).secondaryContainer : null,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: ThreePartLabel(
            icon: Icon(index == themeController.colorSelected.value ? Icons.color_lens : Icons.color_lens_outlined,
                color: colorOptions[index]),
            text1: colorText[index],
            small: true,
          ),
        ),
      );
    });

    actionList.addAll(colorPallette);

    actionList.add(
      PopupMenuItem<int>(
        value: Constants.commandTextZoom,
        child: ZoomIncreaseDecrease(
          title: 'Zoom',
          onDecrease: () {
            GeneralController().fontScaleDecrease();
          },
          onIncrease: () {
            GeneralController().fontScaleIncrease();
          },
        ),
      ),
    );

    if (kDebugMode) {
      addColorPalette(actionList);
    }

    return myPopupMenuIconButton(
      icon: Icons.settings_outlined,
      tooltip: 'Settings',
      list: actionList,
      onSelected: (final int value) {
        onAppBarAction(value);
      },
    );
  }

  void addColorPalette(List<PopupMenuItem<int>> actionList) {
    actionList.add(
      const PopupMenuItem<int>(
        value: -1,
        child: SizedBox(
          height: 300,
          child: SingleChildScrollView(
            child: ColorPalette(),
          ),
        ),
      ),
    );
  }

  void onAppBarAction(
    final int value,
  ) {
    switch (value) {
      case Constants.commandAddTransactions:
        showImportTransactionsFromTextInput(context);
      case Constants.commandSettings:
        Get.toNamed(Constants.routeSettingsPage);
      case Constants.commandIncludeClosedAccount:
        GeneralController().ctlPref.includeClosedAccounts = !GeneralController().ctlPref.includeClosedAccounts;
      default:
        final ThemeController themeController = Get.find();
        themeController.setThemeColor(value);
    }
    GeneralController().preferrenceSave();
  }
}
