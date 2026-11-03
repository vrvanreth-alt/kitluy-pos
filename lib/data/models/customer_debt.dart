class DebtRepayment {
  final String id;
  final double amountUSD;
  final double exchangeRate;
  final DateTime date;
  final String paymentMethod; // 'cash', 'khqr', 'card'
  final String staffName;
  final String? note;

  const DebtRepayment({
    required this.id,
    required this.amountUSD,
    this.exchangeRate = 4100,
    required this.date,
    required this.paymentMethod,
    required this.staffName,
    this.note,
  });

  double get amountKHR => amountUSD * exchangeRate;
}

enum DebtStatus {
  unpaid('មិនទាន់សង', 0xFFEF4444),
  partial('សងខ្លះ', 0xFFF59E0B),
  paid('សងដាច់', 0xFF10B981);

  final String titleKh;
  final int colorHex;

  const DebtStatus(this.titleKh, this.colorHex);
}

class CustomerDebt {
  final String id;
  final String customerName;
  final String customerPhone;
  final String plateNumber;
  final double totalDebtUSD;
  final double paidAmountUSD;
  final String notes;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<DebtRepayment> repayments;

  const CustomerDebt({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.plateNumber,
    required this.totalDebtUSD,
    this.paidAmountUSD = 0.0,
    required this.notes,
    required this.createdAt,
    this.dueDate,
    this.repayments = const [],
  });

  double get remainingUSD => (totalDebtUSD - paidAmountUSD).clamp(0.0, double.infinity);

  DebtStatus get status {
    if (remainingUSD <= 0.01) return DebtStatus.paid;
    if (paidAmountUSD > 0.01) return DebtStatus.partial;
    return DebtStatus.unpaid;
  }

  CustomerDebt copyWith({
    double? paidAmountUSD,
    List<DebtRepayment>? repayments,
  }) {
    return CustomerDebt(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      plateNumber: plateNumber,
      totalDebtUSD: totalDebtUSD,
      paidAmountUSD: paidAmountUSD ?? this.paidAmountUSD,
      notes: notes,
      createdAt: createdAt,
      dueDate: dueDate,
      repayments: repayments ?? this.repayments,
    );
  }
}
