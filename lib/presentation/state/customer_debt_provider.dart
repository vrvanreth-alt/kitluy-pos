import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/customer_debt.dart';

final initialCustomerDebts = <CustomerDebt>[
  CustomerDebt(
    id: 'DEBT-CUST-001',
    customerName: 'លោក សុខ វិសាល',
    customerPhone: '012 345 678',
    plateNumber: 'ភ្នំពេញ 2BC-8899',
    totalDebtUSD: 190.0,
    paidAmountUSD: 50.0,
    notes: 'ជំពាក់ថ្លៃសំបកកង់ Michelin Primacy 4 (2 គ្រាប់)',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    dueDate: DateTime.now().add(const Duration(days: 7)),
    repayments: [
      DebtRepayment(
        id: 'REP-001',
        amountUSD: 50.0,
        exchangeRate: 4100,
        date: DateTime.now().subtract(const Duration(days: 1)),
        paymentMethod: 'khqr',
        staffName: 'ជា សុផល',
        note: 'បង់តាម KHQR ធនាគារកាណាឌីយ៉ា',
      ),
    ],
  ),
  CustomerDebt(
    id: 'DEBT-CUST-002',
    customerName: 'អ្នកស្រី ចិន្តា',
    customerPhone: '098 765 432',
    plateNumber: 'ភ្នំពេញ 2AY-4567',
    totalDebtUSD: 85.0,
    paidAmountUSD: 0.0,
    notes: 'ជំពាក់ថ្លៃប្រេងម៉ាស៊ីន Mobil 1 0W-20 និងថ្លៃឈ្នួលប្តូរ',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    dueDate: DateTime.now().add(const Duration(days: 10)),
    repayments: const [],
  ),
  CustomerDebt(
    id: 'DEBT-CUST-003',
    customerName: 'លោក បូរ៉ា',
    customerPhone: '077 999 111',
    plateNumber: 'កណ្តាល 2B-1122',
    totalDebtUSD: 128.0,
    paidAmountUSD: 128.0,
    notes: 'ថ្លៃអាគុយ Varta Silver Dynamic 80Ah DIN80',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    repayments: [
      DebtRepayment(
        id: 'REP-002',
        amountUSD: 128.0,
        exchangeRate: 4100,
        date: DateTime.now().subtract(const Duration(days: 1)),
        paymentMethod: 'cash',
        staffName: 'ជា សុផល',
        note: 'សងលុយសុទ្ធដាច់',
      ),
    ],
  ),
];

class CustomerDebtNotifier extends Notifier<List<CustomerDebt>> {
  @override
  List<CustomerDebt> build() => initialCustomerDebts;

  void addDebt({
    required String customerName,
    required String customerPhone,
    required String plateNumber,
    required double totalDebtUSD,
    required String notes,
    DateTime? dueDate,
  }) {
    final newDebt = CustomerDebt(
      id: 'DEBT-CUST-${DateTime.now().millisecondsSinceEpoch % 10000}',
      customerName: customerName,
      customerPhone: customerPhone,
      plateNumber: plateNumber,
      totalDebtUSD: totalDebtUSD,
      paidAmountUSD: 0.0,
      notes: notes,
      createdAt: DateTime.now(),
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 14)),
      repayments: const [],
    );

    state = [newDebt, ...state];
  }

  bool recordPayment({
    required String debtId,
    required double amountUSD,
    required double exchangeRate,
    required String paymentMethod,
    required String staffName,
    String? note,
  }) {
    final index = state.indexWhere((d) => d.id == debtId);
    if (index == -1) return false;

    final targetDebt = state[index];
    final repayment = DebtRepayment(
      id: 'REP-${DateTime.now().millisecondsSinceEpoch % 10000}',
      amountUSD: amountUSD,
      exchangeRate: exchangeRate,
      date: DateTime.now(),
      paymentMethod: paymentMethod,
      staffName: staffName,
      note: note,
    );

    final updatedDebt = targetDebt.copyWith(
      paidAmountUSD: targetDebt.paidAmountUSD + amountUSD,
      repayments: [...targetDebt.repayments, repayment],
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedDebt else state[i],
    ];
    return true;
  }
}

final customerDebtProvider = NotifierProvider<CustomerDebtNotifier, List<CustomerDebt>>(
  CustomerDebtNotifier.new,
);

/// KPI: Total Outstanding Customer Debt (USD)
final totalCustomerDebtOutstandingProvider = Provider<double>((ref) {
  final debts = ref.watch(customerDebtProvider);
  return debts.fold<double>(0.0, (sum, debt) => sum + debt.remainingUSD);
});
