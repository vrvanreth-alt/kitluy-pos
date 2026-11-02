import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product.dart';
import '../../data/models/product_attributes.dart';
import '../state/product_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  ProductCategory _selectedCategory = ProductCategory.tires;
  final _nameKhController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _codeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController(text: '10');
  final _unitController = TextEditingController(text: 'សំបក');

  // Specific Controllers
  // Tire
  final _tireSizeController = TextEditingController(text: '205/55R16');
  final _tireBrandController = TextEditingController(text: 'Michelin');
  final _tireDotController = TextEditingController(text: '2424');

  // Battery
  final _batteryAhController = TextEditingController(text: '70');
  final _batteryTerminalController = TextEditingController(text: 'JIS 80D26L');
  final _batteryRebateController = TextEditingController(text: '10');

  // Oil
  final _oilViscosityController = TextEditingController(text: '5W-30');
  final _oilVolumeController = TextEditingController(text: '4.0');

  // Spare Part
  final _partOemController = TextEditingController(text: '04152-YZZA1');
  final _partCompatController = TextEditingController(text: 'Toyota Camry / Prius');

  @override
  void dispose() {
    _nameKhController.dispose();
    _nameEnController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _tireSizeController.dispose();
    _tireBrandController.dispose();
    _tireDotController.dispose();
    _batteryAhController.dispose();
    _batteryTerminalController.dispose();
    _batteryRebateController.dispose();
    _oilViscosityController.dispose();
    _oilVolumeController.dispose();
    _partOemController.dispose();
    _partCompatController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(ProductCategory cat) {
    setState(() {
      _selectedCategory = cat;
      switch (cat) {
        case ProductCategory.tires:
          _unitController.text = 'សំបក';
          break;
        case ProductCategory.batteries:
          _unitController.text = 'គ្រាប់';
          break;
        case ProductCategory.engineOil:
          _unitController.text = 'កំប៉ុង';
          break;
        case ProductCategory.spareParts:
          _unitController.text = 'គ្រាប់';
          break;
        case ProductCategory.services:
          _unitController.text = 'ដង';
          _stockController.text = '999';
          break;
        default:
          break;
      }
    });
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final cost = double.tryParse(_costController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final id = 'PROD-${DateTime.now().millisecondsSinceEpoch % 100000}';

    TireAttributes? tire;
    BatteryAttributes? battery;
    EngineOilAttributes? oil;
    SparePartAttributes? part;

    if (_selectedCategory == ProductCategory.tires) {
      tire = TireAttributes(
        size: _tireSizeController.text.trim(),
        brand: _tireBrandController.text.trim(),
        dotWeekYear: _tireDotController.text.trim(),
      );
    } else if (_selectedCategory == ProductCategory.batteries) {
      battery = BatteryAttributes(
        brand: _nameEnController.text.split(' ').first,
        capacityAh: int.tryParse(_batteryAhController.text) ?? 70,
        terminalType: _batteryTerminalController.text.trim(),
        defaultRebateUSD: double.tryParse(_batteryRebateController.text) ?? 10.0,
      );
    } else if (_selectedCategory == ProductCategory.engineOil) {
      oil = EngineOilAttributes(
        brand: _nameEnController.text.split(' ').first,
        viscosity: _oilViscosityController.text.trim(),
        oilType: 'Synthetic',
        volumeLiters: double.tryParse(_oilVolumeController.text) ?? 4.0,
      );
    } else if (_selectedCategory == ProductCategory.spareParts) {
      part = SparePartAttributes(
        oemPartNumber: _partOemController.text.trim(),
        compatibility: _partCompatController.text.trim(),
      );
    }

    final newProduct = Product(
      id: id,
      code: _codeController.text.trim().isEmpty ? id : _codeController.text.trim(),
      nameKh: _nameKhController.text.trim(),
      nameEn: _nameEnController.text.trim().isEmpty ? _nameKhController.text.trim() : _nameEnController.text.trim(),
      category: _selectedCategory,
      unitPriceUSD: price,
      costPriceUSD: cost,
      stockQuantity: stock,
      unit: _unitController.text.trim(),
      tire: tire,
      battery: battery,
      engineOil: oil,
      sparePart: part,
    );

    ref.read(productsProvider.notifier).addProduct(newProduct);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('បានបន្ថែមទំនិញថ្មី: ${newProduct.nameKh}'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_business, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'បន្ថែមទំនិញ ឬសេវាកម្មថ្មី (Add Product)',
                          style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category selector chips
                Text('ប្រភេទមុខទំនិញ (Category):', style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ProductCategory.values
                      .where((c) => c != ProductCategory.all)
                      .map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.tagColor),
                          const SizedBox(width: 6),
                          Text(cat.titleKh),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: cat.tagColor,
                      labelStyle: GoogleFonts.kantumruyPro(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) _onCategoryChanged(cat);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // General fields
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameKhController,
                        decoration: const InputDecoration(
                          labelText: 'ឈ្មោះជាភាសាខ្មែរ (Name Khmer)*',
                          hintText: 'ឧ. សំបកកង់ Michelin Primacy 4',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'សូមបញ្ចូលឈ្មោះទំនិញ' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'បាកូដ / SKU (Code)',
                          hintText: 'MIC-2155517',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'ឈ្មោះជាភាសាអង់គ្លេស (English Name)',
                    hintText: 'Michelin Primacy 4 215/55R17',
                  ),
                ),

                const SizedBox(height: 16),

                // Specific Category Attributes Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'លក្ខណៈបច្ចេកទេស ${_selectedCategory.titleKh}:',
                        style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),

                      if (_selectedCategory == ProductCategory.tires) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _tireSizeController,
                                decoration: const InputDecoration(labelText: 'ទំហំកង់ (Size ឧ. 215/55R17)'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _tireBrandController,
                                decoration: const InputDecoration(labelText: 'ម៉ាក (Brand: Michelin)'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _tireDotController,
                                decoration: const InputDecoration(labelText: 'DOT (ឧ. 2424)'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (_selectedCategory == ProductCategory.batteries) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _batteryAhController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'អំពែ (Capacity Ah)', suffixText: 'Ah'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _batteryTerminalController,
                                decoration: const InputDecoration(labelText: 'ប្រភេទក្បាល (JIS / DIN)'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _batteryRebateController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'កាត់អាគុយចាស់ (\$ Rebate)', prefixText: '\$'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (_selectedCategory == ProductCategory.engineOil) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _oilViscosityController,
                                decoration: const InputDecoration(labelText: 'កម្រិតប្រេង (Viscosity ឧ. 5W-30)'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _oilVolumeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'ចំណុះ (Volume Liters)', suffixText: 'L'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (_selectedCategory == ProductCategory.spareParts) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _partOemController,
                                decoration: const InputDecoration(labelText: 'លេខកូដ OEM Part #'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _partCompatController,
                                decoration: const InputDecoration(labelText: 'ត្រូវជាមួយឡាន (Compatibility)'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Pricing & Stock
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'តម្លៃលក់ចេញ (Selling USD)*',
                          prefixText: '\$ ',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'បញ្ចូលតម្លៃលក់' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'ថ្លៃដើម (Cost USD)',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ចំនួនស្តុក (Stock)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'ឯកតា (Unit)',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('បោះបង់', style: GoogleFonts.kantumruyPro()),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveProduct,
                      icon: const Icon(Icons.check),
                      label: Text('រក្សាទុកទំនិញ', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

