/// Generator for National Bank of Cambodia (NBC) Bakong KHQR standard (EMVCo)
class KhqrGenerator {
  /// Format a Tag-Length-Value (TLV) string
  static String _formatTlv(String tag, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$tag$length$value';
  }

  /// Calculate CRC16-CCITT (polynomial 0x1021, init 0xFFFF)
  static String _calculateCrc16(String input) {
    int crc = 0xFFFF;
    final bytes = input.codeUnits;

    for (int b in bytes) {
      crc ^= (b << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Generate a dynamic EMVCo KHQR string
  /// [bakongAccount]: e.g., "kitluy_auto@aclb"
  /// [merchantName]: e.g., "KITLUY AUTO GARAGE"
  /// [merchantCity]: e.g., "Phnom Penh"
  /// [amount]: Transaction amount
  /// [currency]: "USD" or "KHR"
  /// [invoiceNo]: Bill/Invoice number e.g. "INV-1024"
  /// [terminal]: Terminal label e.g. "POS-01"
  static String generateDynamicKhqr({
    required String bakongAccount,
    required String merchantName,
    String merchantCity = 'Phnom Penh',
    required double amount,
    required String currency, // 'USD' or 'KHR'
    required String invoiceNo,
    String? terminal = 'POS-01',
    String? vehiclePlate,
  }) {
    final sb = StringBuffer();

    // 00: Payload Format Indicator
    sb.write(_formatTlv('00', '01'));

    // 01: Point of Initiation Method (12 = Dynamic QR)
    sb.write(_formatTlv('01', '12'));

    // 29: Merchant Account Info (Bakong format)
    final bakongInfo = StringBuffer();
    bakongInfo.write(_formatTlv('00', 'bakong@nbc'));
    bakongInfo.write(_formatTlv('01', bakongAccount));
    sb.write(_formatTlv('29', bakongInfo.toString()));

    // 52: Merchant Category Code (5533 = Automotive parts & accessories)
    sb.write(_formatTlv('52', '5533'));

    // 53: Transaction Currency (840 = USD, 116 = KHR)
    final currencyCode = currency.toUpperCase() == 'KHR' ? '116' : '840';
    sb.write(_formatTlv('53', currencyCode));

    // 54: Transaction Amount
    final amountStr = currency.toUpperCase() == 'KHR'
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    sb.write(_formatTlv('54', amountStr));

    // 58: Country Code
    sb.write(_formatTlv('58', 'KH'));

    // 59: Merchant Name
    final cleanMerchantName = merchantName.length > 25
        ? merchantName.substring(0, 25)
        : merchantName;
    sb.write(_formatTlv('59', cleanMerchantName));

    // 60: Merchant City
    sb.write(_formatTlv('60', merchantCity));

    // 62: Additional Data Field Template
    final additionalData = StringBuffer();
    additionalData.write(_formatTlv('01', invoiceNo)); // Bill number
    if (terminal != null && terminal.isNotEmpty) {
      additionalData.write(_formatTlv('07', terminal)); // Terminal ID
    }
    if (vehiclePlate != null && vehiclePlate.isNotEmpty) {
      additionalData.write(_formatTlv('05', vehiclePlate)); // Reference
    }
    sb.write(_formatTlv('62', additionalData.toString()));

    // 63: CRC placeholder (Tag 63, Length 04)
    final qrPayloadWithoutCrc = '${sb.toString()}6304';
    final crc = _calculateCrc16(qrPayloadWithoutCrc);

    return '$qrPayloadWithoutCrc$crc';
  }
}

