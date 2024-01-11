import 'package:collection/collection.dart';
import 'package:money/models/aliases/alias.dart';
import 'package:money/models/money_entity.dart';
import 'package:money/models/payees/payee.dart';

class Aliases {
  static MoneyObjects<Alias> moneyObjects = MoneyObjects<Alias>();

  static Alias? get(final num id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final num id) {
    return moneyObjects.getNameFromId(id);
  }

  static Payee? findByMatch(final String text) {
    final Alias? aliasFound = moneyObjects.getAsList().firstWhereOrNull((final Alias item) => item.isMatch(text));
    if (aliasFound == null) {
      return null;
    }
    return aliasFound.payee;
  }

  clear() {
    moneyObjects.clear();
  }

  int length() {
    return moneyObjects.getAsList().length;
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();
    for (final Map<String, Object?> row in rows) {
      final AliasType type = row['Flags'] == 0 ? AliasType.none : AliasType.regex;
      moneyObjects.addEntry(Alias(
        // id
        row['Id'] as int,
        // name
        row['Pattern'].toString(),
        type: type,
        payeeId: row['Payee'] as int,
      ));
    }
  }

  loadDemoData() {
    clear();

    final List<String> names = <String>[];
    for (int i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Alias(i, names[i]));
    }
  }

  static onAllDataLoaded() {}

  static String toCSV() {
    final StringBuffer csv = StringBuffer();

    // CSV Header
    csv.writeln(Alias.getFieldDefinitions().getCsvHeader());

    // CSV Rows
    for (final Alias item in Aliases.moneyObjects.getAsList()) {
      csv.writeln(Alias.getFieldDefinitions().getCsvRowValues(item));
    }

    // Add the UTF-8 BOM for Excel
    // This does not affect clients like Google sheets
    return '\uFEFF$csv';
  }
}
