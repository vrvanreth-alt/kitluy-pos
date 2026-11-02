enum PaymentMethod {
  cashUSD('សាច់ប្រាក់ USD', 'Cash (USD)'),
  cashKHR('សាច់ប្រាក់ ៛ (រៀល)', 'Cash (KHR)'),
  splitCash('ទូទាត់ចម្រុះ (USD + KHR)', 'Split Cash'),
  bakongKHQR('ស្កេន Bakong KHQR', 'Bakong KHQR'),
  bankTransfer('ផ្ទេរតាមធនាគារ', 'Bank Transfer');

  final String titleKh;
  final String titleEn;
  const PaymentMethod(this.titleKh, this.titleEn);
}

class PaymentRecord {
  final PaymentMethod method;
  final double paidUSD;
  final int paidKHR;
  final double changeUSD;
  final int changeKHR;
  final String changePreference; // 'USD' or 'KHR'
  final String? khqrReference;
  final DateTime paidAt;

  PaymentRecord({
    required this.method,
    this.paidUSD = 0.0,
    this.paidKHR = 0,
    this.changeUSD = 0.0,
    this.changeKHR = 0,
    this.changePreference = 'USD',
    this.khqrReference,
    DateTime? paidAt,
  }) : paidAt = paidAt ?? DateTime.now();
}

