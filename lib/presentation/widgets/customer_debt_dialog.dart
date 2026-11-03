import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/customer_debt.dart';
import '../state/customer_debt_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../state/staff_provider.dart';

class CustomerDebtDialog extends ConsumerStatefulWidget {
  const CustomerDebtDialog({super.key});

  @override
  ConsumerState<CustomerDebtDialog> createState() => _CustomerDebtDialogState();
}

class _CustomerDebtDialogState extends ConsumerState<CustomerDebtDialog> {
  int _selectedFilterIndex = 0; // 0: All, 1: Unpaid, 2: Partial, 3: Paid
  String _searchQuery = '';

  void _showAddDebtDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_alt_1, color: AppColors.accent),
            ),
            const SizedBox(width: 10),
            Text(
              'កត់ត្រាបំណុលអតិថិជនថ្មី',
              style: GoogleFonts.kantumruyPro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel(context, 'ឈ្មោះអតិថិជន *'),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: 'ឧ. លោក សុខ វិសាល'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(context, 'លេខទូរស័ព្ទ'),
                          TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(hintText: '012 345 678'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(context, 'ផ្លាកលេខឡាន'),
                          TextField(
                            controller: plateCtrl,
                            decoration: const InputDecoration(hintText: 'ភ្នំពេញ 2BC-8899'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFieldLabel(context, 'ចំនួនប្រាក់ជំពាក់ (\$ USD) *'),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(height: 12),
                _buildFieldLabel(context, 'មុខទំនិញ / កំណត់សម្គាល់'),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'ឧ. ជំពាក់ថ្លៃសំបកកង់ Michelin 2 គ្រាប់...'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: context.textMutedColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text);
              if (nameCtrl.text.trim().isNotEmpty && amount != null && amount > 0) {
                ref.read(customerDebtProvider.notifier).addDebt(
                  customerName: nameCtrl.text.trim(),
                  customerPhone: phoneCtrl.text.trim(),
                  plateNumber: plateCtrl.text.trim().isEmpty ? 'មិនបញ្ជាក់' : plateCtrl.text.trim(),
                  totalDebtUSD: amount,
                  notes: noteCtrl.text.trim().isEmpty ? 'ជំពាក់ថ្លៃទំនិញ/សេវា' : noteCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('បានកត់ត្រាបំណុលជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('រក្សាទុក', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRepayDialog(BuildContext context, CustomerDebt debt) {
    final amountCtrl = TextEditingController(text: debt.remainingUSD.toStringAsFixed(2));
    final noteCtrl = TextEditingController();
    String paymentMethod = 'khqr'; // 'khqr', 'cash', 'card'
    final rate = ref.read(exchangeRateProvider);
    final staff = ref.read(currentStaffProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final enteredUSD = double.tryParse(amountCtrl.text) ?? 0.0;
          final enteredKHR = enteredUSD * rate;

          return AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payment, color: AppColors.success),
                ),
                const SizedBox(width: 10),
                Text(
                  'កត់ត្រាការសងប្រាក់បំណុល',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surfaceMutedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              debt.customerName,
                              style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '${debt.plateNumber} • ${debt.customerPhone}',
                              style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textSecondaryColor),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('នៅខ្វះសរុប', style: GoogleFonts.kantumruyPro(fontSize: 11, color: context.textMutedColor)),
                            Text(
                              '\$${debt.remainingUSD.toStringAsFixed(2)}',
                              style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.danger),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel(context, 'ចំនួនទឹកប្រាក់ដែលសង (\$ USD) *'),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      suffixText: '≈ ${CurrencyFormatter.formatKHR(enteredKHR)}',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel(context, 'វិធីសាស្ត្រទូទាត់ប្រាក់'),
                  Row(
                    children: [
                      _buildMethodChip(
                        label: 'Bakong KHQR',
                        icon: Icons.qr_code_2,
                        isSelected: paymentMethod == 'khqr',
                        onTap: () => setModalState(() => paymentMethod = 'khqr'),
                      ),
                      const SizedBox(width: 8),
                      _buildMethodChip(
                        label: 'លុយសុទ្ធ (Cash)',
                        icon: Icons.money,
                        isSelected: paymentMethod == 'cash',
                        onTap: () => setModalState(() => paymentMethod = 'cash'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel(context, 'ចំណាំលើការសង'),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(hintText: 'ឧ. សងតាម KHQR ឬសងមួយផ្នែក...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: context.textMutedColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text);
                  if (amount != null && amount > 0) {
                    ref.read(customerDebtProvider.notifier).recordPayment(
                      debtId: debt.id,
                      amountUSD: amount,
                      exchangeRate: rate,
                      paymentMethod: paymentMethod,
                      staffName: staff.nameKh,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('បានកត់ត្រាការសងប្រាក់ជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Text('បញ្ជាក់ការសងប្រាក់', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMethodChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : context.surfaceMutedColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.primary : context.textSecondaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.kantumruyPro(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : context.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.textPrimaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(customerDebtProvider);
    final rate = ref.watch(exchangeRateProvider);
    final totalOutstanding = ref.watch(totalCustomerDebtOutstandingProvider);

    final filteredDebts = debts.where((d) {
      if (_selectedFilterIndex == 1 && d.status != DebtStatus.unpaid) return false;
      if (_selectedFilterIndex == 2 && d.status != DebtStatus.partial) return false;
      if (_selectedFilterIndex == 3 && d.status != DebtStatus.paid) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return d.customerName.toLowerCase().contains(q) ||
            d.customerPhone.contains(q) ||
            d.plateNumber.toLowerCase().contains(q) ||
            d.notes.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 880,
        height: 640,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'គ្រប់គ្រងបំណុលអតិថិជន (Customer Debts)',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'Accounts Receivable • បំណុលត្រូវប្រមូលពីអតិថិជន',
                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Total Outstanding Summary Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.money_off, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'បំណុលនៅសល់សរុប',
                                style: GoogleFonts.kantumruyPro(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${totalOutstanding.toStringAsFixed(2)} (${CurrencyFormatter.formatKHR(totalOutstanding * rate)})',
                                style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.danger),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDebtDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('+ កត់បំណុលថ្មី', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.textMutedColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Search Bar & Filter Tabs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ស្វែងរកឈ្មោះអតិថិជន, លេខទូរស័ព្ទ, ផ្លាកលេខឡាន...',
                      prefixIcon: Icon(Icons.search, color: context.textMutedColor),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildFilterChip(0, 'ទាំងអស់ (${debts.length})'),
                    _buildFilterChip(1, 'មិនទាន់សង (${debts.where((d) => d.status == DebtStatus.unpaid).length})'),
                    _buildFilterChip(2, 'សងខ្លះ (${debts.where((d) => d.status == DebtStatus.partial).length})'),
                    _buildFilterChip(3, 'សងដាច់ (${debts.where((d) => d.status == DebtStatus.paid).length})'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Debts List
            Expanded(
              child: filteredDebts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 56, color: context.textMutedColor),
                          const SizedBox(height: 10),
                          Text(
                            'មិនមានទិន្នន័យបំណុលក្នុងផ្នែកនេះទេ!',
                            style: GoogleFonts.kantumruyPro(fontSize: 15, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredDebts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final debt = filteredDebts[index];
                        final status = debt.status;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.surfaceMutedColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              // Avatar / Icon
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(status.colorHex).withValues(alpha: 0.15),
                                child: Icon(
                                  status == DebtStatus.paid
                                      ? Icons.check_circle
                                      : (status == DebtStatus.partial ? Icons.timelapse : Icons.warning_amber),
                                  color: Color(status.colorHex),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Customer & Vehicle Info
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          debt.customerName,
                                          style: GoogleFonts.kantumruyPro(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: context.textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            debt.plateNumber,
                                            style: GoogleFonts.kantumruyPro(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${debt.customerPhone} • ${debt.notes}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),

                              // Amounts
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ជំពាក់សរុប: ',
                                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                                        ),
                                        Text(
                                          '\$${debt.totalDebtUSD.toStringAsFixed(2)}',
                                          style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'សងបាន: ',
                                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                                        ),
                                        Text(
                                          '\$${debt.paidAmountUSD.toStringAsFixed(2)}',
                                          style: GoogleFonts.kantumruyPro(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Remaining & Status
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(status.colorHex).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.titleKh,
                                        style: GoogleFonts.kantumruyPro(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(status.colorHex),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'នៅខ្វះ: \$${debt.remainingUSD.toStringAsFixed(2)}',
                                      style: GoogleFonts.kantumruyPro(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: debt.remainingUSD > 0 ? AppColors.danger : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Action Button
                              if (debt.remainingUSD > 0)
                                ElevatedButton.icon(
                                  onPressed: () => _showRepayDialog(context, debt),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.payment, size: 16),
                                  label: Text('សងប្រាក់', style: GoogleFonts.kantumruyPro(fontSize: 12)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'រួចរាល់ ✓',
                                    style: GoogleFonts.kantumruyPro(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
      label: Text(
        label,
        style: GoogleFonts.kantumruyPro(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : context.textPrimaryColor,
        ),
      ),
      selectedColor: AppColors.primary,
      backgroundColor: context.surfaceMutedColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }
}
