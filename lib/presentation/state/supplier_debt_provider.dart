import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/supplier_debt.dart';

final initialSupplierDebts = <SupplierDebt>[
  SupplierDebt(
    id: 'SUP-001',
    supplierName: 'ក្រុមហ៊ុន GS Battery Cambodia',
    invoiceNumber: 'INV-GS-2024-104',
    contactPhone: '023 888 777',
    totalAmountUSD: 1450.0,
    paidAmountUSD: 800.0,
    purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
    dueDate: DateTime.now().add(const Duration(days: 15)),
    notes: 'ទិញអាគុយ GS 70Ah ចំនួន 15 គ្រាប់ និង 45Ah ចំនួន 10 គ្រាប់',
    payments: [
      SupplierPayment(
        id: 'SPAY-001',
        amountUSD: 800.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        paidByStaffName: 'ស៊ុំ វ៉ាន់ណារ៉ែត',
        paymentMethod: 'Bank Transfer (ABA)',
        note: 'បង់ដំណាក់កាលទី ១',
      ),
    ],
  ),
  SupplierDebt(
    id: 'SUP-002',
    supplierName: 'ក្រុមហ៊ុន Bridgestone Tire Cambodia',
    invoiceNumber: 'BST-2024-552',
    contactPhone: '023 999 123',
    totalAmountUSD: 2800.0,
    paidAmountUSD: 1200.0,
    purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
    dueDate: DateTime.now().add(const Duration(days: 8)),
    notes: 'ទិញសំបកកង់ Bridgestone Dueler A/T ចំនួន 16 សំបក',
    payments: [
      SupplierPayment(
        id: 'SPAY-002',
        amountUSD: 1200.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        paidByStaffName: 'ស៊ុំ វ៉ាន់ណារ៉ែត',
        paymentMethod: 'Bank Transfer (Canadia)',
        note: 'កក់ប្រាក់លើកទី ១',
      ),
    ],
  ),
  SupplierDebt(
    id: 'SUP-003',
    supplierName: 'ក្រុមហ៊ុន Mobil Lubricants Cambodia',
    invoiceNumber: 'MOB-2024-890',
    contactPhone: '012 444 888',
    totalAmountUSD: 750.0,
    paidAmountUSD: 750.0,
    purchaseDate: DateTime.now().subtract(const Duration(days: 14)),
    dueDate: DateTime.now().subtract(const Duration(days: 2)),
    notes: 'ទិញប្រេងម៉ាស៊ីន Mobil 1 Advanced Fuel Economy 0W-20 (15 ធុង)',
    payments: [
      SupplierPayment(
        id: 'SPAY-003',
        amountUSD: 750.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        paidByStaffName: 'ស៊ុំ វ៉ាន់ណារ៉ែត',
        paymentMethod: 'Bank Transfer (ABA)',
        note: 'ទូទាត់ផ្តាច់វិក្កយបត្រ',
      ),
    ],
  ),
];

class SupplierDebtNotifier extends Notifier<List<SupplierDebt>> {
  @override
  List<SupplierDebt> build() => initialSupplierDebts;

  void addSupplierDebt({
    required String supplierName,
    required String invoiceNumber,
    required String contactPhone,
    required double totalAmountUSD,
    required String notes,
    DateTime? dueDate,
  }) {
    final newDebt = SupplierDebt(
      id: 'SUP-${DateTime.now().millisecondsSinceEpoch % 10000}',
      supplierName: supplierName,
      invoiceNumber: invoiceNumber,
      contactPhone: contactPhone,
      totalAmountUSD: totalAmountUSD,
      paidAmountUSD: 0.0,
      purchaseDate: DateTime.now(),
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 30)),
      notes: notes,
      payments: const [],
    );

    state = [newDebt, ...state];
  }

  bool recordPayment({
    required String debtId,
    required double amountUSD,
    required String paidByStaffName,
    required String paymentMethod,
    String? note,
  }) {
    final index = state.indexWhere((d) => d.id == debtId);
    if (index == -1) return false;

    final targetDebt = state[index];
    final payment = SupplierPayment(
      id: 'SPAY-${DateTime.now().millisecondsSinceEpoch % 10000}',
      amountUSD: amountUSD,
      date: DateTime.now(),
      paidByStaffName: paidByStaffName,
      paymentMethod: paymentMethod,
      note: note,
    );

    final updatedDebt = targetDebt.copyWith(
      paidAmountUSD: targetDebt.paidAmountUSD + amountUSD,
      payments: [...targetDebt.payments, payment],
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedDebt else state[i],
    ];
    return true;
  }
}

final supplierDebtProvider = NotifierProvider<SupplierDebtNotifier, List<SupplierDebt>>(
  SupplierDebtNotifier.new,
);

/// KPI: Total Outstanding Supplier Debt (USD)
final totalSupplierDebtOutstandingProvider = Provider<double>((ref) {
  final debts = ref.watch(supplierDebtProvider);
  return debts.fold<double>(0.0, (sum, debt) => sum + debt.remainingUSD);
});
