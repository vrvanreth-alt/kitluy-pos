class SupplierPayment {
  final String id;
  final double amountUSD;
  final DateTime date;
  final String paidByStaffName;
  final String paymentMethod;
  final String? note;

  const SupplierPayment({
    required this.id,
    required this.amountUSD,
    required this.date,
    required this.paidByStaffName,
    required this.paymentMethod,
    this.note,
  });
}

enum SupplierDebtStatus {
  unpaid('មិនទាន់ទូទាត់', 0xFFEF4444),
  partial('ទូទាត់ខ្លះ', 0xFFF59E0B),
  paid('ទូទាត់រួចរាល់', 0xFF10B981);

  final String titleKh;
  final int colorHex;

  const SupplierDebtStatus(this.titleKh, this.colorHex);
}

class SupplierDebt {
  final String id;
  final String supplierName;
  final String invoiceNumber;
  final String contactPhone;
  final double totalAmountUSD;
  final double paidAmountUSD;
  final DateTime purchaseDate;
  final DateTime? dueDate;
  final String notes;
  final List<SupplierPayment> payments;

  const SupplierDebt({
    required this.id,
    required this.supplierName,
    required this.invoiceNumber,
    required this.contactPhone,
    required this.totalAmountUSD,
    this.paidAmountUSD = 0.0,
    required this.purchaseDate,
    this.dueDate,
    required this.notes,
    this.payments = const [],
  });

  double get remainingUSD => (totalAmountUSD - paidAmountUSD).clamp(0.0, double.infinity);

  SupplierDebtStatus get status {
    if (remainingUSD <= 0.01) return SupplierDebtStatus.paid;
    if (paidAmountUSD > 0.01) return SupplierDebtStatus.partial;
    return SupplierDebtStatus.unpaid;
  }

  SupplierDebt copyWith({
    double? paidAmountUSD,
    List<SupplierPayment>? payments,
  }) {
    return SupplierDebt(
      id: id,
      supplierName: supplierName,
      invoiceNumber: invoiceNumber,
      contactPhone: contactPhone,
      totalAmountUSD: totalAmountUSD,
      paidAmountUSD: paidAmountUSD ?? this.paidAmountUSD,
      purchaseDate: purchaseDate,
      dueDate: dueDate,
      notes: notes,
      payments: payments ?? this.payments,
    );
  }
}
