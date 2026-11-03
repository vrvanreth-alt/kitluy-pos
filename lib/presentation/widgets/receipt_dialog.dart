import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order.dart';

class ReceiptDialog extends StatelessWidget {
  final Order order;

  const ReceiptDialog({super.key, required this.order});

  Future<void> _printReceipt() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 4 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  AppConstants.defaultShopNameEn,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Tel: ${AppConstants.defaultShopPhone}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Inv: ${order.invoiceNo}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (order.vehicle != null) ...[
                pw.Text('Vehicle: ${order.vehicle!.plateNumber} (${order.vehicle!.model})', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Odometer: ${order.vehicle!.currentMileage} km', style: const pw.TextStyle(fontSize: 8)),
                if (order.nextServiceMileage != null)
                  pw.Text('Next Service: ${order.nextServiceMileage} km', style: const pw.TextStyle(fontSize: 8)),
              ],
              pw.Divider(),
              ...order.items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text('${item.quantity}x ${item.product.nameEn}', style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Text('\$${item.lineTotalUSD.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL USD:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('\$${order.totalUSD.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL KHR (Rate: ${order.exchangeRate.toInt()}):', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('${order.totalKHR} KHR', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Thank you! Drive safely!', style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Invoice_${order.invoiceNo}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 500;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? screenWidth : 440,
        height: isMobile ? screenHeight * 0.90 : 700,
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          children: [
            // Modal Title & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'វិក្កយបត្រ (80mm Receipt)',
                      style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Scrollable Receipt Visual (Styled like real 80mm thermal receipt)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Shop Header
                      Text(
                        AppConstants.defaultShopNameKh,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AppConstants.defaultShopNameEn,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.defaultShopAddress,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kantumruyPro(fontSize: 9, color: AppColors.textSecondary),
                      ),
                      Text(
                        'ទូរស័ព្ទ: ${AppConstants.defaultShopPhone}',
                        style: GoogleFonts.kantumruyPro(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      Text(
                        'VAT TIN: ${AppConstants.defaultVatTin}',
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                      ),

                      const SizedBox(height: 8),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 6),

                      // Metadata Row
                      _buildReceiptRow('លេខវិក្កយបត្រ:', order.invoiceNo),
                      _buildReceiptRow('កាលបរិច្ឆេទ:', dateFormat.format(order.createdAt)),
                      if (order.mechanicName != null)
                        _buildReceiptRow('ជាងបម្រើសេវា:', order.mechanicName!),

                      // Vehicle & Mileage Section
                      if (order.vehicle != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildReceiptRow('ស្លាកលេខរថយន្ត:', order.vehicle!.plateNumber),
                              _buildReceiptRow('ម៉ាករថយន្ត:', order.vehicle!.model),
                              _buildReceiptRow('គីឡូម៉ែត្រ:', '${CurrencyFormatter.formatNumber(order.vehicle!.currentMileage)} km'),
                              if (order.nextServiceMileage != null)
                                _buildReceiptRow(
                                  'ប្តូរប្រេងលើកក្រោយ:',
                                  '${CurrencyFormatter.formatNumber(order.nextServiceMileage!)} km',
                                  highlight: true,
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 6),

                      // Column Headers
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ទំនិញ/សេវា (Description)',
                              style: GoogleFonts.kantumruyPro(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              'ចំនួន',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.kantumruyPro(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'សរុប (\$)',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.kantumruyPro(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(thickness: 0.5, height: 1),
                      const SizedBox(height: 4),

                      // Items List
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.nameKh,
                                          style: GoogleFonts.kantumruyPro(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          item.product.attributeSummary,
                                          style: GoogleFonts.kantumruyPro(fontSize: 9, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      CurrencyFormatter.formatUSD(item.lineTotalUSD),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.tradeInRebateUSD > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 2),
                                  child: Text(
                                    '- កាត់ថ្លៃអាគុយចាស់: -\$${item.tradeInRebateUSD.toInt()}',
                                    style: GoogleFonts.kantumruyPro(fontSize: 9, color: const Color(0xFF16A34A)),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 6),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 6),

                      // Financial Summary
                      _buildReceiptRow('សរុបរង (Subtotal):', CurrencyFormatter.formatUSD(order.subtotalUSD)),
                      if (order.batteryTradeInTotalUSD > 0)
                        _buildReceiptRow('កាត់អាគុយចាស់ (Trade-in):', '-${CurrencyFormatter.formatUSD(order.batteryTradeInTotalUSD)}', isSuccess: true),
                      if (order.discountUSD > 0)
                        _buildReceiptRow('បញ្ចុះតម្លៃ (Discount):', '-${CurrencyFormatter.formatUSD(order.discountUSD)}', isDanger: true),

                      const SizedBox(height: 4),
                      const Divider(thickness: 1.5, height: 1),
                      const SizedBox(height: 4),

                      // Total in USD & KHR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'សរុបត្រូវបង់ (TOTAL USD):',
                            style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            CurrencyFormatter.formatUSD(order.totalUSD),
                            style: GoogleFonts.kantumruyPro(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'សរុបជាប្រាក់រៀល (KHR):',
                            style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF047857)),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(order.totalKHR),
                            style: GoogleFonts.kantumruyPro(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF047857)),
                          ),
                        ],
                      ),
                      _buildReceiptRow('អត្រាប្តូរប្រាក់ (Rate):', '1\$ = ${CurrencyFormatter.formatNumber(order.exchangeRate)} ៛'),

                      const SizedBox(height: 6),
                      const Divider(thickness: 1, height: 1),
                      const SizedBox(height: 6),

                      // Payment info
                      if (order.payment != null) ...[
                        _buildReceiptRow('វិធីសាស្ត្រទូទាត់:', order.payment!.method.titleKh),
                        if (order.payment!.paidUSD > 0)
                          _buildReceiptRow('ប្រាក់ដុល្លារទទួលបាន:', CurrencyFormatter.formatUSD(order.payment!.paidUSD)),
                        if (order.payment!.paidKHR > 0)
                          _buildReceiptRow('ប្រាក់រៀលទទួលបាន:', CurrencyFormatter.formatKHR(order.payment!.paidKHR)),
                        if (order.payment!.changeUSD > 0)
                          _buildReceiptRow('ប្រាក់អាប់ជាដុល្លារ:', CurrencyFormatter.formatUSD(order.payment!.changeUSD)),
                        if (order.payment!.changeKHR > 0)
                          _buildReceiptRow('ប្រាក់អាប់ជារៀល:', CurrencyFormatter.formatKHR(order.payment!.changeKHR)),
                        if (order.payment!.khqrReference != null)
                          _buildReceiptRow('លេខយោង Bakong:', order.payment!.khqrReference!),
                      ],

                      const SizedBox(height: 12),
                      Text(
                        'ទំនិញដែលបានទិញរួចមិនអាចប្តូរជាសាច់ប្រាក់វិញបានទេ!',
                        style: GoogleFonts.kantumruyPro(fontSize: 9, color: AppColors.textSecondary),
                      ),
                      Text(
                        'សូមអរគុណ! សូមធ្វើដំណើរប្រកបដោយសុវត្ថិភាព!',
                        style: GoogleFonts.kantumruyPro(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Print & Done Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(Icons.print, size: 18),
                    label: Text('បោះពុម្ពវិក្កយបត្រ (Print 80mm)', style: GoogleFonts.kantumruyPro()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: Text('ការលក់ថ្មី (New Sale)', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool highlight = false, bool isSuccess = false, bool isDanger = false}) {
    Color valColor = AppColors.textPrimary;
    if (highlight) valColor = AppColors.primary;
    if (isSuccess) valColor = const Color(0xFF16A34A);
    if (isDanger) valColor = AppColors.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kantumruyPro(fontSize: 10, color: AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.kantumruyPro(
              fontSize: 10,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}
