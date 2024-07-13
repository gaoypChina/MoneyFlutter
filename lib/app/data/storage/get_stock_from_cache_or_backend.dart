import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';

class StockDatePrice {
  /// Constructor
  const StockDatePrice({required this.date, required this.price});

  final DateTime date;
  final double price;
}

const flagAsInvalidSymbol = 'invalid-symbol';

class StockPriceHistoryCache {
  StockPriceHistoryCache(this.symbol, this.status, [this.lastDateTime]);

  List<StockDatePrice> prices = [];
  StockLookupStatus status = StockLookupStatus.notFoundInCache;
  String symbol = '';

  DateTime? lastDateTime;
}

Future<StockPriceHistoryCache> getFromCacheOrBackend(
  String symbol,
) async {
  symbol = symbol.toLowerCase();

  StockPriceHistoryCache result = await _loadFromCache(symbol);

  if (result.status != StockLookupStatus.foundInCache) {
    result = await loadFomBackendAndSaveToCache(symbol);
  }
  return result;
}

Future<StockPriceHistoryCache> loadFomBackendAndSaveToCache(String symbol) async {
  StockPriceHistoryCache result = await _loadFromBackend(symbol);
  switch (result.status) {
    case StockLookupStatus.validSymbol:
      _saveToCache(symbol, result.prices);
      return await _loadFromCache(symbol);
    case StockLookupStatus.invalidSymbol:
      _saveToCacheInvalidSymbol(symbol);
    default:
  }
  return result;
}

enum StockLookupStatus {
  validSymbol,
  invalidSymbol,
  foundInCache,
  notFoundInCache,
  invalidApiKey,
}

Future<StockPriceHistoryCache> _loadFromCache(
  final String symbol,
) async {
  final StockPriceHistoryCache stockPriceHistoryCache =
      StockPriceHistoryCache(symbol, StockLookupStatus.foundInCache, null);

  final String mainFilenameStockSymbol = await _fullPathToCacheStockFile(symbol);

  String? csvContent;
  try {
    stockPriceHistoryCache.lastDateTime = await MyFileSystems.getFileModifiedTime(mainFilenameStockSymbol);
    csvContent = await MyFileSystems.readFile(mainFilenameStockSymbol);
    if (csvContent == flagAsInvalidSymbol) {
      // give up now
      stockPriceHistoryCache.status = StockLookupStatus.notFoundInCache;
    }
  } catch (_) {
    //
  }

  if (csvContent != null) {
    final List<String> csvLines = csvContent.split('\n');

    for (var row = 0; row < csvLines.length; row++) {
      if (row == 0) {
        // skip header
      } else {
        final List<String> twoColumns = csvLines[row].split(',');
        if (twoColumns.length == 2) {
          final StockDatePrice sp = StockDatePrice(
            date: DateTime.parse(twoColumns[0]),
            price: double.parse(twoColumns[1]),
          );
          stockPriceHistoryCache.prices.add(sp);
        }
      }
    }
    return stockPriceHistoryCache;
  }
  return StockPriceHistoryCache(symbol, StockLookupStatus.notFoundInCache);
}

Future<StockPriceHistoryCache> _loadFromBackend(
  String symbol,
) async {
  final result = StockPriceHistoryCache(symbol, StockLookupStatus.validSymbol);

  if (PreferenceController.to.apiKeyForStocks.isEmpty) {
    // No API Key to make the backend request
    return StockPriceHistoryCache(symbol, StockLookupStatus.invalidApiKey);
  }

  DateTime tenYearsInThePast = DateTime.now().subtract(const Duration(days: 365 * 10));

  final Uri uri = Uri.parse(
    'https://api.twelvedata.com/time_series?symbol=$symbol&interval=1day&start_date=${tenYearsInThePast.toIso8601String()}&apikey=${PreferenceController.to.apiKeyForStocks}',
  );

  final http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    try {
      final MyJson data = json.decode(response.body);
      if (data['code'] == 401) {
        //data['message'];
        result.status = StockLookupStatus.invalidApiKey;
        return result;
      }

      if (data['code'] == 404) {
        // SYMBOL NOT FOUND
        result.status = StockLookupStatus.invalidSymbol;
        return result;
      }
      final List<dynamic> values = data['values'];

      // Unfortunately for now (sometimes) the API may returns two entries with the same date
      // for this ensure that we only have one date and price, last one wins
      Map<String, StockDatePrice> mapByUniqueDate = {};

      for (final value in values) {
        final String dateAsText = value['datetime'];

        StockDatePrice sp = StockDatePrice(
          date: DateTime.parse(dateAsText),
          price: double.parse(value['close']),
        );
        mapByUniqueDate[dateAsText] = sp;
      }

      // this will ensure that we only have one value per dates
      for (final StockDatePrice sp in mapByUniqueDate.values) {
        result.prices.add(sp);
      }
    } catch (error) {
      debugLog(error.toString());
    }
  } else {
    debugLog('Failed to fetch data: ${response.toString()}');
  }
  return result;
}

void _saveToCache(final String symbol, List<StockDatePrice> prices) async {
  final String mainFilenameStockSymbol = await _fullPathToCacheStockFile(symbol);

  // CSV Header
  String csvContent = '"date","price"\n';

  // CSV Content
  for (final item in prices) {
    csvContent += '${dateToString(item.date)},${item.price.toString()}\n';
  }

  // Write CSV
  MyFileSystems.writeToFile(mainFilenameStockSymbol, csvContent);
}

void _saveToCacheInvalidSymbol(final String symbol) async {
  final String mainFilenameStockSymbol = await _fullPathToCacheStockFile(symbol);
  MyFileSystems.writeToFile(mainFilenameStockSymbol, flagAsInvalidSymbol);
}

Future<String> _fullPathToCacheStockFile(final String symbol) async {
  final String cacheFolderForStockFiles = await _pathToStockFiles();
  return MyFileSystems.append(cacheFolderForStockFiles, 'stock_$symbol.csv');
}

Future<String> _pathToStockFiles() async {
  String destinationFolder = await DataController.to.generateNextFolderToSaveTo();
  if (destinationFolder.isEmpty) {
    throw Exception('No container folder give for saving');
  }

  final String cacheFolderForStockFiles = MyFileSystems.append(destinationFolder, 'stocks');
  await MyFileSystems.ensureFolderExist(cacheFolderForStockFiles);

  return cacheFolderForStockFiles;
}
