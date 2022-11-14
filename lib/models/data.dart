import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './accounts.dart';
import './payees.dart';
import './transactions.dart';
import './categories.dart';

class Data {
  Accounts accounts = Accounts();
  Payees payees = Payees();
  Categories categories = Categories();
  Transactions transactions = Transactions();

  init(filePathToLoad, callbackWhenLoaded) async {
    if (kIsWeb) {
      // Not supported on Web so generate some random data to see in the views
      accounts.loadScale();
      categories.loadScale();
      payees.loadScale();
      transactions.loadScale();
      callbackWhenLoaded(true);
      return;
    }

    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
      }

      var databaseFactory = databaseFactoryFfi;
      String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);
      if (pathToDatabaseFile != null) {
        var db = await databaseFactory.openDatabase(pathToDatabaseFile);

        // Accounts
        {
          var result = await db.query('Accounts');
          await accounts.load(result);
        }

        // Categories
        {
          var result = await db.query('Categories');
          await categories.load(result);
        }

        // Payees
        {
          var result = await db.query('Payees');
          await payees.load(result);
        }

        // Transactions
        {
          var result = await db.query('Transactions');
          await transactions.load(result);
        }

        await db.close();

        callbackWhenLoaded(true);
      }
    } catch (e) {
      callbackWhenLoaded(false);
    }
  }

  Future<String?> validateDataBasePathIsValidAndExist(filePath) async {
    try {
      if (filePath != null) {
        if (File(filePath).existsSync()) {
          return filePath;
        }
      }
    } catch (e) {
      // next line will handle things
    }
    return null;
  }
}
