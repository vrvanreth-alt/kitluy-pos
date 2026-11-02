import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

class ExchangeRateNotifier extends Notifier<double> {
  @override
  double build() => AppConstants.defaultExchangeRate;

  void updateRate(double newRate) {
    if (newRate > 0) {
      state = newRate;
    }
  }
}

final exchangeRateProvider = NotifierProvider<ExchangeRateNotifier, double>(
  ExchangeRateNotifier.new,
);
