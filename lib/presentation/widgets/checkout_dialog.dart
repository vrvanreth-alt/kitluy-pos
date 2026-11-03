import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/khqr_generator.dart';
import '../../data/models/order.dart';
import '../../data/models/payment.dart';
import '../../data/repositories/firestore_repository.dart';
import '../state/cart_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../state/product_provider.dart';
import '../state/vehicle_provider.dart';
import 'receipt_dialog.dart';

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Cash USD state
  final TextEditingController _cashUsdController = TextEditingController();

  // Cash KHR state
  final TextEditingController _cashKhrController = TextEditingController();

  // Split payment state
  final TextEditingController _splitUsdController = TextEditingController();
  final TextEditingController _splitKhrController = TextEditingController();

  // Preferences
  String _changePreference = 'USD'; // 'USD' or 'KHR'
  String _khqrCurrency = 'USD'; // 'USD' or 'KHR'

  late String _invoiceNo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final now = DateTime.now();
    final randomDigits = (1000 + Random().nextInt(9000)).toString();
    _invoiceNo = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$randomDigits';

    // Auto populate exact amount into USD controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = ref.read(cartProvider);
      _cashUsdController.text = cart.netTotalUSD.toStringAsFixed(2);
      final rate = ref.read(exchangeRateProvider);
      _cashKhrController.text = cart.netTotalKHR(rate).toString();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashUsdController.dispose();
    _cashKhrController.dispose();
    _splitUsdController.dispose();
    _splitKhrController.dispose();
    super.dispose();
  }

  void _completeOrder({
    required PaymentMethod method,
    required double paidUSD,
    required int paidKHR,
    required double changeUSD,
    required int changeKHR,
    String? khqrRef,
  }) {
    final cart = ref.read(cartProvider);
    final rate = ref.read(exchangeRateProvider);
    final vehicle = ref.read(activeVehicleProvider);

    // 1. Deduct stock for all items
    for (final item in cart.items) {
      ref.read(productsProvider.notifier).updateStock(item.product.id, item.quantity);
    }

    // 2. Build payment record
    final payment = PaymentRecord(
      method: method,
      paidUSD: paidUSD,
      paidKHR: paidKHR,
      changeUSD: changeUSD,
      changeKHR: changeKHR,
      changePreference: _changePreference,
      khqrReference: khqrRef,
    );

    // 3. Build order
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNo: _invoiceNo,
      createdAt: DateTime.now(),
      vehicle: vehicle,
      items: List.from(cart.items),
      exchangeRate: rate,
      subtotalUSD: cart.subtotalUSD,
      discountUSD: cart.allDiscountsUSD,
      batteryTradeInTotalUSD: cart.batteryTradeInRebateUSD,
      totalUSD: cart.netTotalUSD,
      totalKHR: cart.netTotalKHR(rate),
      payment: payment,
      mechanicName: cart.mechanicName,
      nextServiceMileage: vehicle != null ? (vehicle.currentMileage + cart.nextServiceIntervalKm) : null,
      nextServiceDate: DateTime.now().add(const Duration(days: 180)),
    );

    // 4. Sync to Firestore in background
    FirestoreRepository().createOrder(order);

    // 5. Clear cart
    ref.read(cartProvider.notifier).clearCart();

    // 6. Close checkout dialog & show receipt dialog
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReceiptDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final rate = ref.watch(exchangeRateProvider);
    final vehicle = ref.watch(activeVehicleProvider);

    final totalUSD = cart.netTotalUSD;
    final totalKHR = cart.netTotalKHR(rate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 780,
        height: 640,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header: Invoice No, Total to pay in Dual Currency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ទូទាត់ប្រាក់ (Payment Checkout)',
                      style: GoogleFonts.kantumruyPro(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'វិក្កយបត្រ: $_invoiceNo • ${vehicle != null ? vehicle.plateNumber : "Walk-in"}',
                      style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),

                // Dual Currency Total Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cartTotalLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(totalUSD),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cartTotal,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(totalKHR),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tab Bar for Payment Methods
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w600, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.qr_code, size: 18), text: 'Bakong KHQR'),
                  Tab(icon: Icon(Icons.attach_money, size: 18), text: 'សាច់ប្រាក់ USD'),
                  Tab(icon: Icon(Icons.payments, size: 18), text: 'សាច់ប្រាក់ ៛ (KHR)'),
                  Tab(icon: Icon(Icons.shuffle, size: 18), text: 'ទូទាត់ចម្រុះ (Split)'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Bakong KHQR Tab
                  _buildKhqrTab(totalUSD, totalKHR, rate),

                  // 2. Cash USD Tab
                  _buildCashUsdTab(totalUSD, totalKHR, rate),

                  // 3. Cash KHR Tab
                  _buildCashKhrTab(totalUSD, totalKHR, rate),

                  // 4. Split Payment Tab
                  _buildSplitPaymentTab(totalUSD, totalKHR, rate),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('បោះបង់ (Cancel)', style: GoogleFonts.kantumruyPro()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 1. BAKONG KHQR TAB
  Widget _buildKhqrTab(double totalUSD, int totalKHR, double rate) {
    final qrAmount = _khqrCurrency == 'USD' ? totalUSD : totalKHR.toDouble();
    final qrPayload = KhqrGenerator.generateDynamicKhqr(
      bakongAccount: AppConstants.bakongMerchantId,
      merchantName: AppConstants.bakongMerchantName,
      merchantCity: AppConstants.bakongMerchantCity,
      amount: qrAmount,
      currency: _khqrCurrency,
      invoiceNo: _invoiceNo,
      terminal: 'COUNTER-01',
      vehiclePlate: ref.read(activeVehicleProvider)?.plateNumber,
    );

    return Row(
      children: [
        // QR Code Box
        Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bakong KHQR Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bakongRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'KHQR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dynamic QR Code Rendering
              QrImageView(
                data: qrPayload,
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 8),
              Text(
                AppConstants.bakongMerchantName,
                style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // KHQR Details & Instant simulation
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Currency Toggle (USD or KHR)
              Text('ជ្រើសរើសរូបិយប័ណ្ណស្កេន (Currency):', style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: Text('USD (\$ ${CurrencyFormatter.formatNumber(totalUSD)})'),
                    selected: _khqrCurrency == 'USD',
                    onSelected: (selected) {
                      if (selected) setState(() => _khqrCurrency = 'USD');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('KHR (${CurrencyFormatter.formatNumber(totalKHR)} ៛)'),
                    selected: _khqrCurrency == 'KHR',
                    onSelected: (selected) {
                      if (selected) setState(() => _khqrCurrency = 'KHR');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'គាំទ្រគ្រប់កម្មវិធីធនាគារនៅកម្ពុជា',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ABA Mobile, ACLEDA mobile, Wing, Canadia, TrueMoney, Sathapana, etc.',
                      style: GoogleFonts.kantumruyPro(fontSize: 12, color: const Color(0xFF15803D)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Button (Simulates KHQR payment webhook)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _completeOrder(
                      method: PaymentMethod.bakongKHQR,
                      paidUSD: _khqrCurrency == 'USD' ? totalUSD : 0.0,
                      paidKHR: _khqrCurrency == 'KHR' ? totalKHR : 0,
                      changeUSD: 0.0,
                      changeKHR: 0,
                      khqrRef: 'KHQR-${Random().nextInt(999999).toString().padLeft(6, '0')}',
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(
                    'បញ្ជាក់ការទូទាត់ជោគជ័យ (Confirm Payment)',
                    style: GoogleFonts.kantumruyPro(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2. CASH USD TAB
  Widget _buildCashUsdTab(double totalUSD, int totalKHR, double rate) {
    final paidUsd = double.tryParse(_cashUsdController.text) ?? 0.0;
    final changeUsd = paidUsd - totalUSD;
    final changeKhr = CurrencyFormatter.usdToKhr(changeUsd > 0 ? changeUsd : 0.0, rate);

    final isEnough = paidUsd >= totalUSD;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ប្រាក់ដុល្លារទទួលបានពីអតិថិជន (USD Received):', style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _cashUsdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.kantumruyPro(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                ),
              ),

              const SizedBox(height: 12),
              // Quick USD Banknotes
              Text('ក្រដាសប្រាក់ញឹកញាប់:', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('ថ្លៃល្មម (Exact)'),
                    onPressed: () => setState(() => _cashUsdController.text = totalUSD.toStringAsFixed(2)),
                  ),
                  ...[10, 20, 50, 100, 200].map((bill) {
                    return ActionChip(
                      label: Text('\$$bill'),
                      onPressed: () => setState(() => _cashUsdController.text = bill.toDouble().toStringAsFixed(2)),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Change Calculation Card
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnough ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isEnough ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ប្រាក់អាប់ត្រូវសង (Change Due):',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isEnough ? const Color(0xFF166534) : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnough ? CurrencyFormatter.formatUSD(changeUsd) : 'មិនទាន់គ្រប់ (-${CurrencyFormatter.formatUSD(changeUsd.abs())})',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isEnough ? const Color(0xFF15803D) : AppColors.danger,
                      ),
                    ),
                    if (isEnough && changeUsd > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ឬជាប្រាក់រៀល: ${CurrencyFormatter.formatKHR(changeKhr)}',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ],
                ),

                // Change Currency Choice
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('អាប់ជា (Change In):', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('ដុល្លារ (\$)'),
                          selected: _changePreference == 'USD',
                          onSelected: (val) => setState(() => _changePreference = 'USD'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('រៀល (៛)'),
                          selected: _changePreference == 'KHR',
                          onSelected: (val) => setState(() => _changePreference = 'KHR'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isEnough
                            ? () {
                                _completeOrder(
                                  method: PaymentMethod.cashUSD,
                                  paidUSD: paidUsd,
                                  paidKHR: 0,
                                  changeUSD: _changePreference == 'USD' ? changeUsd : 0.0,
                                  changeKHR: _changePreference == 'KHR' ? changeKhr : 0,
                                );
                              }
                            : null,
                        child: Text('យល់ព្រមបង់ប្រាក់', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 3. CASH KHR TAB
  Widget _buildCashKhrTab(double totalUSD, int totalKHR, double rate) {
    final paidKhr = int.tryParse(_cashKhrController.text.replaceAll(',', '')) ?? 0;
    final changeKhr = paidKhr - totalKHR;
    final changeUsd = CurrencyFormatter.khrToUsd(changeKhr > 0 ? changeKhr.toDouble() : 0.0, rate);

    final isEnough = paidKhr >= totalKHR;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ប្រាក់រៀលទទួលបានពីអតិថិជន (KHR Received):', style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _cashKhrController,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.kantumruyPro(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  suffixText: '៛ (KHR)',
                  hintText: '0',
                ),
              ),

              const SizedBox(height: 12),
              // Quick KHR Banknotes
              Text('ក្រដាសប្រាក់រៀលញឹកញាប់:', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('ថ្លៃល្មម (Exact)'),
                    onPressed: () => setState(() => _cashKhrController.text = totalKHR.toString()),
                  ),
                  ...[20000, 50000, 100000, 200000, 500000].map((khr) {
                    return ActionChip(
                      label: Text(CurrencyFormatter.formatKHR(khr)),
                      onPressed: () => setState(() => _cashKhrController.text = khr.toString()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Change Calculation Card
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnough ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isEnough ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ប្រាក់អាប់ត្រូវសង (Change Due):',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isEnough ? const Color(0xFF166534) : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnough ? CurrencyFormatter.formatKHR(changeKhr) : 'មិនទាន់គ្រប់ (-${CurrencyFormatter.formatKHR(changeKhr.abs())})',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isEnough ? const Color(0xFF15803D) : AppColors.danger,
                      ),
                    ),
                    if (isEnough && changeKhr > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ឬជាប្រាក់ដុល្លារ: ${CurrencyFormatter.formatUSD(changeUsd)}',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('អាប់ជា (Change In):', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('រៀល (៛)'),
                          selected: _changePreference == 'KHR',
                          onSelected: (val) => setState(() => _changePreference = 'KHR'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('ដុល្លារ (\$)'),
                          selected: _changePreference == 'USD',
                          onSelected: (val) => setState(() => _changePreference = 'USD'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isEnough
                            ? () {
                                _completeOrder(
                                  method: PaymentMethod.cashKHR,
                                  paidUSD: 0.0,
                                  paidKHR: paidKhr,
                                  changeUSD: _changePreference == 'USD' ? changeUsd : 0.0,
                                  changeKHR: _changePreference == 'KHR' ? changeKhr : 0,
                                );
                              }
                            : null,
                        child: Text('យល់ព្រមបង់ប្រាក់', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 4. SPLIT PAYMENT TAB (USD + KHR)
  Widget _buildSplitPaymentTab(double totalUSD, int totalKHR, double rate) {
    final paidUsd = double.tryParse(_splitUsdController.text) ?? 0.0;
    final paidKhr = int.tryParse(_splitKhrController.text.replaceAll(',', '')) ?? 0;

    final totalPaidInUsd = paidUsd + CurrencyFormatter.khrToUsd(paidKhr.toDouble(), rate);
    final diffUSD = totalPaidInUsd - totalUSD;
    final diffKHR = CurrencyFormatter.usdToKhr(diffUSD, rate);

    final isEnough = totalPaidInUsd >= (totalUSD - 0.01);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ទូទាត់ចម្រុះ (ទទួលទាំងដុល្លារ និងរៀលក្នុងពេលតែមួយ):', style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // USD Input
              TextField(
                controller: _splitUsdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'ទទួលជាប្រាក់ដុល្លារ (USD)',
                  prefixText: '\$ ',
                ),
              ),

              const SizedBox(height: 12),

              // KHR Input
              TextField(
                controller: _splitKhrController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'ទទួលជាប្រាក់រៀល (KHR)',
                  suffixText: '៛',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Split Summary & Change
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnough ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isEnough ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('សរុបប្រាក់បានទទួល:', style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatter.formatUSD(totalPaidInUsd),
                      style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnough ? 'ប្រាក់អាប់ត្រូវសង:' : 'នៅខ្វះ:',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isEnough ? const Color(0xFF166534) : AppColors.danger,
                      ),
                    ),
                    Text(
                      isEnough
                          ? '${CurrencyFormatter.formatUSD(diffUSD)}  (${CurrencyFormatter.formatKHR(diffKHR)})'
                          : '-${CurrencyFormatter.formatUSD(diffUSD.abs())}  (-${CurrencyFormatter.formatKHR(diffKHR.abs())})',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isEnough ? const Color(0xFF15803D) : AppColors.danger,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isEnough
                        ? () {
                            _completeOrder(
                              method: PaymentMethod.splitCash,
                              paidUSD: paidUsd,
                              paidKHR: paidKhr,
                              changeUSD: diffUSD > 0 ? diffUSD : 0.0,
                              changeKHR: diffKHR > 0 ? diffKHR : 0,
                            );
                          }
                        : null,
                    child: Text('យល់ព្រមបង់ប្រាក់', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
