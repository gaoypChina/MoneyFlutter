import 'dart:io';

import 'package:money/models/rentals.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './accounts.dart';
import './categories.dart';
import './payees.dart';
import './transactions.dart';
import 'constants.dart';
import 'splits.dart';

class Data {
  Accounts accounts = Accounts();
  Payees payees = Payees();
  Categories categories = Categories();
  Rentals rentals = Rentals();
  RentUnits rentUnits = RentUnits();
  Splits splits = Splits();
  Transactions transactions = Transactions();

  init(filePathToLoad, callbackWhenLoaded) async {
    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Not supported on Web so generate some random data to see in the views
      accounts.loadDemoData();
      categories.loadDemoData();
      payees.loadDemoData();
      rentals.loadDemoData();
      splits.loadDemoData();
      transactions.loadDemoData();
    } else {
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

          // Rentals
          {
            var result = await db.query('RentBuildings');
            await rentals.load(result);
          }

          // RentUnits
          {
            var result = await db.query('RentUnits');
            await rentUnits.load(result);
          }

          // Splits
          {
            var result = await db.query('Splits');
            await splits.load(result);
          }

          // Transactions
          {
            var result = await db.query('Transactions');
            await transactions.load(result);
          }

          await db.close();
        }
      } catch (e) {
        callbackWhenLoaded(false);
        return;
      }
    }

    Accounts.onAllDataLoaded();
    Categories.onAllDataLoaded();
    Payees.onAllDataLoaded();
    Rentals.onAllDataLoaded();
    callbackWhenLoaded(true);
  }

  close() {
    accounts.clear();
    categories.clear();
    payees.clear();
    rentals.clear();
    splits.clear();
    transactions.clear();
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
