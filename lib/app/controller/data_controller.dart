// ignore_for_file: unnecessary_this
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/data/data_mutations.dart';
import 'package:path/path.dart' as p;

class DataController extends GetxController {
  Rxn<DateTime> currentLoadedFileDateTime = Rxn<DateTime>();
  RxString currentLoadedFileName = Constants.untitledFileName.obs;
  RxList<String> data = <String>[].obs;
  String fileName = '';
  // Observable variables
  RxBool isLoading = true.obs;

  // Tracking changes
  DataMutations trackMutations = DataMutations();

  void closeFile([bool rebuild = true]) {
    Data().close();
    dataFileIsClosed();
    trackMutations.reset();
    isLoading.value = false;
  }

  void dataFileIsClosed() {
    currentLoadedFileName.value = Constants.untitledFileName;
    currentLoadedFileDateTime.value = null;
  }

  Future<String> defaultFolderToSaveTo(final String defaultFileName) async {
    return MyFileSystems.append(await getDocumentDirectory(), defaultFileName);
  }

  Future<String> generateNextFolderToSaveTo() async {
    if (currentLoadedFileName.value.isNotEmpty) {
      if (p.extension(currentLoadedFileName.value) == 'mmcsv' || p.extension(currentLoadedFileName.value) == 'mmdb') {
        return p.dirname(currentLoadedFileName.value);
      }
    }
    return await getDocumentDirectory();
  }

  String get getUniqueState => '${trackMutations.lastDateTimeChanged}';

  bool get isUntitled => currentLoadedFileName.value == Constants.untitledFileName;

  Future<void> loadDemoData() async {
    isLoading.value = true;
    Data().loadFromDemoData();
    isLoading.value = false;
  }

  Future<void> loadFile(final DataSource dataSource) async {
    this.closeFile(false); // ensure that we closed current file and state

    await Data().loadFromPath(dataSource).then((final bool success) async {
      if (success) {
        setCurrentFileName(dataSource.filePath);
        currentLoadedFileDateTime.value = await MyFileSystems.getFileModifiedTime(dataSource.filePath);
        Future.delayed(Duration.zero, () {
          Get.offNamed(Constants.routeHomePage);
        });
      }
      isLoading.value = false;
    });
  }

  Future<void> loadFileFromPath(final DataSource dataSource) async {
    loadFile(dataSource);
  }

  // Async method to fetch data
  Future<void> loadLastFileSaved() async {
    try {
      isLoading.value = true;

      if (PreferenceController.to.mru.isNotEmpty) {
        await loadFile(
          DataSource(
            filePath: PreferenceController.to.mru.first,
          ),
        );
        return;
      } else {
        // Once the file is loaded, navigate to the main screen
        isLoading.value = false;

        Future.delayed(Duration.zero, () {
          Get.offNamed(Constants.routeWelcomePage);
        });
      }
    } catch (e) {
      // Handle error
      logger.e('Error fetching data: $e');
    }
  }

  void onFileNew() async {
    this.closeFile();

    final newAccount = Data().accounts.addNewAccount('New Bank Account');
    PreferenceController.to.jumpToView(
      viewId: ViewId.viewAccounts,
      selectedId: newAccount.uniqueId,
      columnFilter: [],
      textFilter: '',
    );
  }

  Future<bool> onFileOpen() async {
    FilePickerResult? pickerResult;

    const supportedFileTypes = <String>[
      'mmdb',
      'mmcsv',
      'sdf',
      'qfx',
      'ofx',
      'json',
    ];

    try {
      // WEB
      if (kIsWeb) {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );
      } else
      // Mobile
      if (Platform.isAndroid || Platform.isIOS) {
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
      } else
      // Desktop
      {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: supportedFileTypes,
        );
      }
    } catch (e) {
      logger.e(e.toString());
      SnackBarService.displayError(message: e.toString());
      return false;
    }

    if (pickerResult != null && pickerResult.files.isNotEmpty) {
      try {
        final String? fileExtension = pickerResult.files.single.extension;

        if (fileExtension == 'mmdb' || fileExtension == 'mmcsv') {
          late DataSource dataSource;
          if (kIsWeb) {
            PlatformFile file = pickerResult.files.first;
            dataSource = DataSource(filePath: file.name, fileBytes: file.bytes!);
          } else {
            dataSource = DataSource(filePath: pickerResult.files.single.path ?? '');
          }

          loadFile(dataSource);
          return true;
        }
      } catch (e) {
        logger.e(e.toString());
        SnackBarService.displayError(message: e.toString());
      }
    }
    return false;
  }

  void onSaveToCsv() async {
    final String fullPathToFileName = await Data().saveToCsv();

    PreferenceController.to.addToMRU(fullPathToFileName);

    trackMutations.reset();
  }

  void onSaveToSql() async {
    String fileNameAndPath = currentLoadedFileName.value;

    if (fileNameAndPath.isEmpty) {
      // this happens if the user started with a new file and click save to SQL
      fileNameAndPath = await defaultFolderToSaveTo('mymoney.mmdb');
    }

    Data().saveToSql(
      filePath: fileNameAndPath,
      onSaveCompleted: (final bool success, final String message) {
        if (success) {
          trackMutations.reset();
        } else {
          SnackBarService.displayError(autoDismiss: false, message: message);
        }
      },
    );

    PreferenceController.to.addToMRU(fileNameAndPath);
  }

  void onShowFileLocation() async {
    String path = await generateNextFolderToSaveTo();
    showLocalFolder(path);
  }

  void setCurrentFileName(final String filenameLoaded) {
    currentLoadedFileName.value = filenameLoaded;
    final PreferenceController preferenceController = Get.find();
    preferenceController.addToMRU(filenameLoaded);
  }

  static DataController get to => Get.find();
}

class DataSource {
  DataSource({
    this.filePath = '',
    Uint8List? fileBytes,
  }) : _fileBytes = fileBytes ?? Uint8List(0);

  final String filePath;

  final Uint8List _fileBytes;

  Uint8List get fileBytes => _fileBytes;

  bool get isByteFile => _fileBytes.isNotEmpty && filePath.isNotEmpty;

  bool get isLocalFile => _fileBytes.isEmpty && filePath.isNotEmpty && filePath.contains(MyFileSystems.pathSeparator);
}
