import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/supplier_debt.dart';
import '../state/exchange_rate_provider.dart';
import '../state/staff_provider.dart';
import '../state/supplier_debt_provider.dart';

class SupplierDebtDialog extends ConsumerStatefulWidget {
  const SupplierDebtDialog({super.key});

  @override
  ConsumerState<SupplierDebtDialog> createState() => _SupplierDebtDialogState();
}

class _SupplierDebtDialogState extends ConsumerState<SupplierDebtDialog> {
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  void _showAddSupplierDebtDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final invoiceCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
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
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.domain_add, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'កត់ត្រាវិក្កយបត្រទិញពីក្រុមហ៊ុន',
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
                _buildFieldLabel(context, 'ឈ្មោះក្រុមហ៊ុនផ្គត់ផ្គង់ *'),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: 'ឧ. ក្រុមហ៊ុន GS Battery Cambodia'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(context, 'លេខវិក្កយបត្រ *'),
                          TextField(
                            controller: invoiceCtrl,
                            decoration: const InputDecoration(hintText: 'INV-2024-001'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel(context, 'លេខទូរស័ព្ទ'),
                          TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(hintText: '023 888 777'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFieldLabel(context, 'តម្លៃសរុបនៃវិក្កយបត្រ (\$ USD) *'),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(height: 12),
                _buildFieldLabel(context, 'បរិយាយមុខទំនិញដែលបានទិញចូល'),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'ឧ. អាគុយ 70Ah ចំនួន 20 គ្រាប់...'),
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
                ref.read(supplierDebtProvider.notifier).addSupplierDebt(
                  supplierName: nameCtrl.text.trim(),
                  invoiceNumber: invoiceCtrl.text.trim().isEmpty ? 'INV-${DateTime.now().millisecondsSinceEpoch % 1000}' : invoiceCtrl.text.trim(),
                  contactPhone: phoneCtrl.text.trim().isEmpty ? '023 000 000' : phoneCtrl.text.trim(),
                  totalAmountUSD: amount,
                  notes: noteCtrl.text.trim().isEmpty ? 'ទំនិញចូលស្តុក' : noteCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('បានកត់ត្រាវិក្កយបត្រក្រុមហ៊ុនជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
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

  void _showPaySupplierDialog(BuildContext context, SupplierDebt debt) {
    final amountCtrl = TextEditingController(text: debt.remainingUSD.toStringAsFixed(2));
    final noteCtrl = TextEditingController();
    String paymentMethod = 'ABA Bank Transfer';
    final currentStaff = ref.read(currentStaffProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.outbox, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'កត់ត្រាការទូទាត់ឱ្យក្រុមហ៊ុន',
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
                              debt.supplierName,
                              style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'វិក្កយបត្រ៖ ${debt.invoiceNumber}',
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
                  _buildFieldLabel(context, 'ចំនួនទឹកប្រាក់ដែលត្រូវទូទាត់ (\$ USD) *'),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel(context, 'វិធីសាស្ត្រផ្ទេរប្រាក់'),
                  Wrap(
                    spacing: 8,
                    children: ['ABA Bank Transfer', 'Canadia Bank', 'Cash (លុយសុទ្ធ)'].map((method) {
                      final isSelected = paymentMethod == method;
                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (_) => setModalState(() => paymentMethod = method),
                        label: Text(
                          method,
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : context.textPrimaryColor,
                          ),
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: context.surfaceMutedColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel(context, 'កំណត់សម្គាល់ការបង់ប្រាក់'),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(hintText: 'ឧ. ផ្ទេរប្រាក់តាម App ឬបង់លើកទី ២...'),
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
                    ref.read(supplierDebtProvider.notifier).recordPayment(
                      debtId: debt.id,
                      amountUSD: amount,
                      paidByStaffName: currentStaff.nameKh,
                      paymentMethod: paymentMethod,
                      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('បានកត់ត្រាការទូទាត់ឱ្យក្រុមហ៊ុនជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Text('បញ្ជាក់ការទូទាត់', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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
    final debts = ref.watch(supplierDebtProvider);
    final rate = ref.watch(exchangeRateProvider);
    final totalOutstanding = ref.watch(totalSupplierDebtOutstandingProvider);

    final filteredDebts = debts.where((d) {
      if (_selectedFilterIndex == 1 && d.status != SupplierDebtStatus.unpaid) return false;
      if (_selectedFilterIndex == 2 && d.status != SupplierDebtStatus.partial) return false;
      if (_selectedFilterIndex == 3 && d.status != SupplierDebtStatus.paid) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return d.supplierName.toLowerCase().contains(q) ||
            d.invoiceNumber.toLowerCase().contains(q) ||
            d.contactPhone.contains(q) ||
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_center, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'គ្រប់គ្រងបំណុលក្រុមហ៊ុន / អ្នកផ្គត់ផ្គង់ (Supplier Debts)',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'Accounts Payable • បំណុលត្រូវទូទាត់ឱ្យក្រុមហ៊ុនទំនិញ',
                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.outbox, color: AppColors.warning, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'បំណុលត្រូវបង់សរុប',
                                style: GoogleFonts.kantumruyPro(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${totalOutstanding.toStringAsFixed(2)} (${CurrencyFormatter.formatKHR(totalOutstanding * rate)})',
                                style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.warning),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSupplierDebtDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('+ វិក្កយបត្រថ្មី', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
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

            // Search Bar & Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ស្វែងរកឈ្មោះក្រុមហ៊ុន, លេខវិក្កយបត្រ, ទូរស័ព្ទ...',
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
                    _buildFilterChip(1, 'មិនទាន់ទូទាត់ (${debts.where((d) => d.status == SupplierDebtStatus.unpaid).length})'),
                    _buildFilterChip(2, 'ទូទាត់ខ្លះ (${debts.where((d) => d.status == SupplierDebtStatus.partial).length})'),
                    _buildFilterChip(3, 'ទូទាត់រួច (${debts.where((d) => d.status == SupplierDebtStatus.paid).length})'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Supplier Debts List
            Expanded(
              child: filteredDebts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 56, color: context.textMutedColor),
                          const SizedBox(height: 10),
                          Text(
                            'មិនមានវិក្កយបត្រក្រុមហ៊ុនក្នុងផ្នែកនេះទេ!',
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
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(status.colorHex).withValues(alpha: 0.15),
                                child: Icon(Icons.corporate_fare, color: Color(status.colorHex)),
                              ),
                              const SizedBox(width: 14),

                              // Company Info
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          debt.supplierName,
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
                                            color: AppColors.secondary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            debt.invoiceNumber,
                                            style: GoogleFonts.kantumruyPro(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${debt.contactPhone} • ${debt.notes}',
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
                                          'វិក្កយបត្រសរុប: ',
                                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                                        ),
                                        Text(
                                          '\$${debt.totalAmountUSD.toStringAsFixed(2)}',
                                          style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'បានបង់: ',
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
                                        color: debt.remainingUSD > 0 ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Action Button
                              if (debt.remainingUSD > 0)
                                ElevatedButton.icon(
                                  onPressed: () => _showPaySupplierDialog(context, debt),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.outbox, size: 16),
                                  label: Text('ទូទាត់ប្រាក់', style: GoogleFonts.kantumruyPro(fontSize: 12)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'ទូទាត់រួច ✓',
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
