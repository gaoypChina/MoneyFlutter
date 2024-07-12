// ignore_for_file: unnecessary_this

import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/investments/security_fifo_queue.dart';
import 'package:money/app/data/models/money_objects/investments/security_purchase.dart';
import 'package:money/app/data/models/money_objects/investments/security_sales.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';

/// <summary>
/// We implement a first-in first-out FIFO queue for securities, the assumption is that when
/// securities are sold you will first sell the security you have been holding the longest
/// in order to minimize capital gains taxes.
/// </summary>
class AccountHoldings {
  Account? account;
  Map<Security, SecurityFifoQueue> queues = <Security, SecurityFifoQueue>{};

  /// <summary>
  /// Record an Add or Buy for a given security.
  /// </summary>
  ///<param name="s">The security we are buying</param>
  /// <param name="datePurchased">The date of the purchase</param>
  /// <param name="units">THe number of units purchased</param>
  /// <param name="costBasis">The cost basis for the purchase (usually what you paid for it including trading fees)</param>
  void buy(Security s, DateTime datePurchased, double units, double costBasis) {
    SecurityFifoQueue? queue = queues[s];

    if (queue == null) {
      queue = SecurityFifoQueue();
      queue.security = s;
      queue.account = account;
      queues[s] = queue;
    }

    queue.buy(datePurchased, units, costBasis);
  }

  /// <summary>
  /// Get current holdings to date.
  /// </summary>
  /// <returns></returns>
  List<SecurityPurchase> getHoldings() {
    List<SecurityPurchase> result = [];
    for (final SecurityFifoQueue queue in this.queues.values) {
      for (SecurityPurchase p in queue.getHoldings()) {
        result.add(p);
      }
    }
    return result;
  }

  List<SecuritySale> getPendingSales() {
    List<SecuritySale> result = [];
    for (var queue in this.queues.values) {
      for (SecuritySale sale in queue.getPendingSales()) {
        result.add(sale);
      }
    }
    return result;
  }

  List<SecuritySale> getPendingSalesForSecurity(Security s) {
    List<SecuritySale> result = [];
    SecurityFifoQueue? queue = queues[s];
    if (queue != null) {
      for (final SecuritySale sale in queue.getPendingSales()) {
        result.add(sale);
      }
    }
    return result;
  }

  /// <summary>
  /// Get current purchases for the given security
  /// </summary>
  /// <returns></returns>
  List<SecurityPurchase> getPurchases(Security security) {
    List<SecurityPurchase> result = [];

    SecurityFifoQueue? queue = queues[security];

    if (queue != null) {
      for (final SecurityPurchase p in queue.getHoldings()) {
        result.add(p);
      }
    }
    return result;
  }

  List<SecuritySale> processPendingSales(Security s) {
    SecurityFifoQueue? queue = queues[s];
    if (queue != null) {
      return queue.processPendingSales();
    } else {}
    return [];
  }

  /// <summary>
  /// Find the oldest holdings that still have UnitsRemaining, and decrement them by the
  /// number of units we are selling.  This might have to sell from multiple SecurityPurchases
  /// in order to cover the requested number of units.  If there are not enough units to cover
  /// the sale then we have a problem.
  /// </summary>
  /// <param name="dateSold">The date of the sale</param>
  /// <param name="units">The number of units sold</param>
  /// <param name="amount">The total amount we received from the sale</param>
  /// <returns></returns>
  List<SecuritySale> sell(
    Security s,
    DateTime dateSold,
    double units,
    double amount,
  ) {
    SecurityFifoQueue? queue = queues[s];

    if (queue == null) {
      queue = SecurityFifoQueue();
      queue.security = s;
      queue.account = account;
      queues[s] = queue;
    }

    return queue.sell(dateSold, units, amount);
  }
}
