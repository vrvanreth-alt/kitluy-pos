import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _usdFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    customPattern: '\$#,##0.00',
  );

  static final NumberFormat _khrFormat = NumberFormat.currency(
    symbol: '៛',
    decimalDigits: 0,
    customPattern: '#,##0 ៛',
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  /// Format USD (e.g., $15.50)
  static String formatUSD(double amount) {
    return _usdFormat.format(amount);
  }

  /// Format KHR (e.g., 63,550 ៛)
  static String formatKHR(num amount) {
    return _khrFormat.format(amount);
  }

  /// Format plain number with commas
  static String formatNumber(num amount) {
    return _numberFormat.format(amount);
  }

  /// Format dual currency display (e.g., "$15.00 / 61,500 ៛")
  static String formatDual(double amountUSD, double exchangeRate) {
    final khr = usdToKhr(amountUSD, exchangeRate);
    return '${formatUSD(amountUSD)}  (${formatKHR(khr)})';
  }

  /// Convert USD to KHR
  static int usdToKhr(double usd, double rate) {
    return (usd * rate).round();
  }

  /// Convert KHR to USD
  static double khrToUsd(double khr, double rate) {
    if (rate <= 0) return 0.0;
    return khr / rate;
  }

  /// Round KHR to nearest 100 riels (standard Cambodian cash rounding)
  static int roundCashKhr(int khr) {
    return ((khr + 50) ~/ 100) * 100;
  }
}

