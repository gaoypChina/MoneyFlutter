import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:money/views/view_cashflow.dart';
import 'package:money/views/view_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'helpers.dart';
import 'menu.dart';
import 'models/data.dart';
import 'views/view_accounts.dart';
import 'views/view_categories.dart';
import 'views/view_payees.dart';
import 'views/view_transactions.dart';

void main() {
  runApp(const MyMoney());
}

class MyMoney extends StatefulWidget {
  const MyMoney({super.key});

  @override
  State<MyMoney> createState() => _MyMoneyState();
}

class _MyMoneyState extends State<MyMoney> {
  ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: colorOptions[1] /* Blue */,
  );
  bool _isLoading = true;
  int colorSelected = 0;
  int screenIndex = 0;
  final Data data = Data();
  String? pathToDatabase;
  SharedPreferences? preferences;

  @override
  initState() {
    super.initState();
    loadLastPreference();
  }

  loadLastPreference() async {
    SharedPreferences.getInstance().then((preferences) {
      pathToDatabase = preferences.getString(prefLastLoadedPathToDatabase);
      loadData();
    });
  }

  shouldShowOpenInstructions() {
    if (pathToDatabase == null) {
      return true;
    }
    return false;
  }

  loadData() {
    data.init(pathToDatabase, (success) {
      _isLoading = success ? false : true;
      setState(() {
        _isLoading;
        data;
      });
    });
  }

  isDarkMode() {
    return themeData.brightness == Brightness.dark;
  }

  getThemeData(int colorIndex, bool useMaterial3, bool useDarkMode) {
    return ThemeData(
      colorSchemeSeed: colorOptions[colorIndex],
      useMaterial3: useMaterial3,
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void handleFileOpen() async {
    FilePickerResult? fileSelected = await FilePicker.platform.pickFiles();
    if (fileSelected != null) {
      pathToDatabase = fileSelected.paths[0];
      if (pathToDatabase != null) {
        preferences?.setString(prefLastLoadedPathToDatabase, pathToDatabase.toString());
        loadData();
      }
    }
  }

  void handleUseDemoData() async {
    pathToDatabase = Constants.demoData;
    loadData();
  }

  void handleMaterialVersionChange(useVersion3) {
    SharedPreferences.getInstance().then((preferences) {
      var version = themeData.useMaterial3 ? 2 : 3;
      preferences.setInt(prefMaterialVersion, version);
      setState(() {
        themeData = getThemeData(colorSelected, version == 3, isDarkMode());
      });
    });
  }

  void handleBrightnessChange() {
    SharedPreferences.getInstance().then((preferences) {
      setState(() {
        var useDarkMode = !isDarkMode();
        preferences.setBool(prefDarkMode, useDarkMode);
        themeData = getThemeData(
          colorSelected,
          themeData.useMaterial3,
          useDarkMode,
        );
      });
    });
  }

  void handleColorSelect(int value) {
    if (value == 1002) {
      handleMaterialVersionChange(false);
      return;
    }
    if (value == 1003) {
      handleMaterialVersionChange(true);
      return;
    }

    SharedPreferences.getInstance().then((preferences) {
      preferences.setInt(prefColor, value);
      setState(() {
        colorSelected = value;
        themeData = getThemeData(colorSelected, themeData.useMaterial3, isDarkMode());
      });
    });
  }

  showLoading() {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  Widget getWidgetForMainContent(BuildContext context, int screenIndex, bool showNavBarExample) {
    if (_isLoading) {
      return showLoading();
    }

    switch (screenIndex) {
      case 0:
        return const ViewCashFlow();
      case 1:
        return const ViewAccounts();
      case 2:
        return const ViewCategories();
      case 3:
        return const ViewPayees();
      case 4:
        return const ViewTransactions();
      case 5:
      default:
        return const ViewTest();
    }
  }

  welcomePanel(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(),
      body: Row(children: <Widget>[
        renderWelcomeAndOpen(context),
      ]),
    );
  }

  renderWelcomeAndOpen(BuildContext context) {
    var textTheme = getTextTheme(context);
    return Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Welcome to MyMoney", textAlign: TextAlign.left, style: textTheme.headline5),
      const SizedBox(height: 40),
      Text("No data loaded", textAlign: TextAlign.left, style: textTheme.caption),
      const SizedBox(height: 40),
      Wrap(
        spacing: 10,
        children: [OutlinedButton(onPressed: handleFileOpen, child: const Text("Open File ...")), OutlinedButton(onPressed: handleUseDemoData, child: const Text("Use Demo Data"))],
      ),
    ]));
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: widgetMainTitle(),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_open),
          onPressed: handleFileOpen,
          tooltip: "Open mmdb file",
        ),
        IconButton(
          icon: isDarkMode() ? const Icon(Icons.wb_sunny_outlined) : const Icon(Icons.wb_sunny),
          onPressed: handleBrightnessChange,
          tooltip: "Toggle brightness",
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) {
            var l = List.generate(colorOptions.length, (index) {
              return PopupMenuItem(
                  value: index,
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          index == colorSelected ? Icons.color_lens : Icons.color_lens_outlined,
                          color: colorOptions[index],
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 20), child: Text(colorText[index]))
                    ],
                  ));
            });
            l.add(PopupMenuItem(value: 1002, child: Text(!themeData.useMaterial3 ? "Using Material2" : "Switch to Material2")));
            l.add(PopupMenuItem(value: 1003, child: Text(themeData.useMaterial3 ? "Using Material3" : "Switch to Material3")));
            return l;
          },
          onSelected: handleColorSelect,
        ),
      ],
    );
  }

  String getTitle() {
    if (pathToDatabase == null) {
      return "No file loaded";
    } else {
      return pathToDatabase.toString();
    }
  }

  widgetMainTitle() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text("MyMoney", textAlign: TextAlign.left), Text(getTitle(), textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10))]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
        future: getThemeDataFromPreference(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MyMoney',
                theme: snapshot.data,
                home: LayoutBuilder(builder: (context, constraints) {
                  if (shouldShowOpenInstructions()) {
                    return welcomePanel(context);
                  }
                  if (isSmallWidth(constraints)) {
                    return getScaffoldingForSmallSurface(context);
                  } else {
                    return getScaffoldingForLargeSurface(context);
                  }
                }));
          } else {
            // Return loading screen while reading preferences
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  getScaffoldingForSmallSurface(context) {
    return Scaffold(
      appBar: createAppBar(),
      body: Row(children: <Widget>[
        getWidgetForMainContent(context, screenIndex, false),
      ]),
      bottomNavigationBar: NavigationBars(onSelectItem: handleScreenChanged, selectedIndex: screenIndex),
    );
  }

  getScaffoldingForLargeSurface(context) {
    return Scaffold(
      appBar: createAppBar(),
      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: <Widget>[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: NavigationRailSection(onSelectItem: handleScreenChanged, selectedIndex: screenIndex)),
            const VerticalDivider(thickness: 1, width: 1),
            getWidgetForMainContent(context, screenIndex, true),
          ],
        ),
      ),
    );
  }
}
