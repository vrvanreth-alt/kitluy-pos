import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../state/cart_provider.dart';
import '../state/exchange_rate_provider.dart';
import '../state/product_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/cart_sidebar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/desktop_kpi_bar.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/pos_header.dart';
import '../widgets/pos_navigation_drawer.dart';
import '../widgets/product_grid.dart';
import '../widgets/vehicle_selector_dialog.dart';

class PosMainScreen extends ConsumerStatefulWidget {
  const PosMainScreen({super.key});

  @override
  ConsumerState<PosMainScreen> createState() => _PosMainScreenState();
}

class _PosMainScreenState extends ConsumerState<PosMainScreen> {
  int _selectedSidebarIndex = 0;
  int _mobileNavIndex = 0;

  void _openMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: const CartSidebar(isMobileBottomSheet: true),
        ),
      ),
    );
  }

  void _showExchangeRateDialog(BuildContext context, WidgetRef ref, double currentRate) {
    final controller = TextEditingController(text: currentRate.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.currency_exchange, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'កំណត់អត្រាប្តូរប្រាក់ (Exchange Rate)',
              style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'អត្រាប្តូរប្រាក់ស្តង់ដារធនាគារជាតិនៃកម្ពុជា (1 USD = ? KHR):',
              style: GoogleFonts.kantumruyPro(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '1 USD = ',
                suffixText: '៛ (KHR)',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [4050, 4100, 4120, 4150].map((rate) {
                return ActionChip(
                  label: Text('$rate ៛'),
                  onPressed: () {
                    controller.text = rate.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បោះបង់', style: GoogleFonts.kantumruyPro(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(controller.text);
              if (newRate != null && newRate > 0) {
                ref.read(exchangeRateProvider.notifier).updateRate(newRate);
                Navigator.pop(ctx);
              }
            },
            child: Text('រក្សាទុក', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDailyReportDialog(BuildContext context, WidgetRef ref) {
    final rate = ref.read(exchangeRateProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.assessment, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'របាយការណ៍បិទបញ្ជី (Daily Z-Report)',
              style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportItem('សរុបការលក់សរុប (Total Sales):', '\$680.00 (2,788,000 ៛)'),
              _buildReportItem('ទូទាត់តាម Bakong KHQR:', '\$420.00'),
              _buildReportItem('សាច់ប្រាក់ដុល្លារ (Cash USD):', '\$160.00'),
              _buildReportItem('សាច់ប្រាក់រៀល (Cash KHR):', '410,000 ៛ (\$100.00)'),
              const Divider(height: 20),
              _buildReportItem('កាត់កងអាគុយចាស់ (Rebates):', '-\$30.00', color: const Color(0xFF16A34A)),
              _buildReportItem('ចំនួនវិក្កយបត្រសរុប:', '12 វិក្កយបត្រ'),
              _buildReportItem('អត្រាប្តូរប្រាក់ថ្ងៃនេះ:', '1\$ = ${CurrencyFormatter.formatNumber(rate)} ៛'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('បិទ', style: GoogleFonts.kantumruyPro()),
          ),
        ],
      ),
    );
  }

  static Widget _buildReportItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.kantumruyPro(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.kantumruyPro(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLowStockDialog(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final lowStockItems = products.where((p) => p.isLowStock).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'ទំនិញជិតអស់ពីស្តុក (Low Stock)',
              style: GoogleFonts.kantumruyPro(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 300,
          child: lowStockItems.isEmpty
              ? Center(
                  child: Text(
                    'មិនមានទំនិញជិតអស់ពីស្តុកទេ!',
                    style: GoogleFonts.kantumruyPro(color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.separated(
                  itemCount: lowStockItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFFED7AA)),
                      ),
                      tileColor: const Color(0xFFFFF7ED),
                      leading: Icon(item.category.icon, color: item.category.tagColor),
                      title: Text(item.nameKh, style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(item.attributeSummary, style: GoogleFonts.kantumruyPro(fontSize: 11)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'សល់: ${item.stockQuantity}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('យល់ព្រម', style: GoogleFonts.kantumruyPro()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final isMobile = screenWidth < 768;
    final cart = ref.watch(cartProvider);
    final rate = ref.watch(exchangeRateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : const PosNavigationDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) {
            return Row(
              children: [
                // 1. Permanent Desktop Sidebar (Like the Reference Laptop Mockup)
                if (isDesktop)
                  DesktopSidebar(
                    selectedIndex: _selectedSidebarIndex,
                    onSelectIndex: (idx) {
                      setState(() => _selectedSidebarIndex = idx);
                    },
                    onOpenGarage: () => showDialog(
                      context: context,
                      builder: (ctx) => const VehicleSelectorDialog(),
                    ),
                    onOpenInventory: () => _showLowStockDialog(context, ref),
                    onOpenReport: () => _showDailyReportDialog(context, ref),
                  ),

                // 2. Main Workspace Body
                Expanded(
                  child: Column(
                    children: [
                      // Top Navigation Header (Adaptive for Mobile & Desktop)
                      PosHeader(
                        isMobile: isMobile,
                        onOpenDrawer: isDesktop ? null : () => Scaffold.of(scaffoldContext).openDrawer(),
                        onOpenCart: isMobile ? () => _openMobileCart(context) : null,
                        onAddProduct: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const AddProductDialog(),
                          );
                        },
                      ),

                      // Metric Summary KPI Bar (Matching Reference Top Row)
                      if (!isMobile)
                        DesktopKpiBar(
                          onOpenVehicle: () => showDialog(
                            context: context,
                            builder: (ctx) => const VehicleSelectorDialog(),
                          ),
                          onOpenLowStock: () => _showLowStockDialog(context, ref),
                          onEditExchangeRate: () => _showExchangeRateDialog(context, ref, rate),
                        ),

                      // Catalog & Cart Split (Desktop) or Full Catalog (Mobile)
                      Expanded(
                        child: isMobile
                            ? const Column(
                                children: [
                                  CategoryFilterBar(),
                                  Expanded(child: ProductGrid()),
                                ],
                              )
                            : const Row(
                                children: [
                                  // Left Side: Catalog & Search
                                  Expanded(
                                    child: Column(
                                      children: [
                                        CategoryFilterBar(),
                                        Expanded(child: ProductGrid()),
                                      ],
                                    ),
                                  ),

                                  // Right Side: Cart Sidebar (Fixed on Desktop/iPad)
                                  CartSidebar(),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Floating Bottom Cart Bar & Navigation for Mobile screens
      bottomNavigationBar: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!cart.isEmpty)
                  _buildMobileCartBottomBar(context, cart, rate),
                _buildMobileNavBar(context, ref),
              ],
            )
          : null,
    );
  }

  Widget _buildMobileCartBottomBar(BuildContext context, CartState cart, double exchangeRate) {
    final totalKHR = cart.netTotalKHR(exchangeRate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cart badge & Total summary
            Expanded(
              child: InkWell(
                onTap: () => _openMobileCart(context),
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 22),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cart.totalItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(cart.netTotalUSD),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cartTotal,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatKHR(totalKHR),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Big Checkout / View Cart Button
            ElevatedButton.icon(
              onPressed: () => _openMobileCart(context),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'មើលកន្ត្រក (${cart.totalItemCount})',
                style: GoogleFonts.kantumruyPro(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final lowStockCount = products.where((p) => p.isLowStock).length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _mobileNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.kantumruyPro(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.kantumruyPro(fontSize: 10),
          elevation: 0,
          onTap: (index) {
            setState(() => _mobileNavIndex = index);
            if (index == 1) {
              // Garage / Vehicle selector
              showDialog(
                context: context,
                builder: (ctx) => const VehicleSelectorDialog(),
              );
            } else if (index == 2) {
              // Low stock inventory
              _showLowStockDialog(context, ref);
            } else if (index == 3) {
              // Z-Report
              _showDailyReportDialog(context, ref);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'កាតាឡុក',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'យានដ្ឋាន',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: lowStockCount > 0,
                label: Text('$lowStockCount'),
                backgroundColor: AppColors.warning,
                child: const Icon(Icons.inventory_2_outlined),
              ),
              activeIcon: const Icon(Icons.inventory_2),
              label: 'ស្តុក',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'បិទបញ្ជី',
            ),
          ],
        ),
      ),
    );
  }
}
