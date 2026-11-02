import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/vehicle.dart';
import '../../data/repositories/supabase_repository.dart';
import '../state/vehicle_provider.dart';

class VehicleSelectorDialog extends ConsumerStatefulWidget {
  const VehicleSelectorDialog({super.key});

  @override
  ConsumerState<VehicleSelectorDialog> createState() => _VehicleSelectorDialogState();
}

class _VehicleSelectorDialogState extends ConsumerState<VehicleSelectorDialog> {
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isCreatingNew = false;

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveNewVehicle() {
    if (_plateController.text.trim().isEmpty) return;

    final newVehicle = Vehicle(
      plateNumber: _plateController.text.trim(),
      model: _modelController.text.trim().isEmpty ? 'មិនបញ្ជាក់ម៉ាក' : _modelController.text.trim(),
      currentMileage: int.tryParse(_mileageController.text.trim()) ?? 0,
      customerName: _customerNameController.text.trim().isEmpty ? 'អតិថិជនទូទៅ' : _customerNameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
    );

    ref.read(vehicleListProvider.notifier).addVehicle(newVehicle);
    ref.read(activeVehicleProvider.notifier).setVehicle(newVehicle);
    SupabaseRepository().saveVehicle(newVehicle);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final activeVehicle = ref.watch(activeVehicleProvider);
    final vehicleList = ref.watch(vehicleListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _isCreatingNew ? 'ចុះឈ្មោះយានយន្តថ្មី' : 'ជ្រើសរើសយានយន្តអតិថិជន',
                      style: GoogleFonts.kantumruyPro(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isCreatingNew = !_isCreatingNew;
                    });
                  },
                  icon: Icon(_isCreatingNew ? Icons.list : Icons.add, size: 16),
                  label: Text(
                    _isCreatingNew ? 'មើលបញ្ជីឡាន' : 'ថែមឡានថ្មី',
                    style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (!_isCreatingNew) ...[
              // Walk-in option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: activeVehicle == null ? AppColors.primary : AppColors.cardBorder,
                    width: activeVehicle == null ? 2 : 1,
                  ),
                ),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Icon(Icons.person_outline, color: AppColors.textSecondary),
                ),
                title: Text(
                  'អតិថិជនទូទៅ (Walk-in Customer / No Vehicle)',
                  style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text('មិនកត់ត្រាស្លាកលេខឡាន', style: GoogleFonts.kantumruyPro(fontSize: 11)),
                trailing: activeVehicle == null
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(activeVehicleProvider.notifier).clearVehicle();
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 12),
              Text(
                'យានយន្តដែលធ្លាប់មកទទួលសេវា:',
                style: GoogleFonts.kantumruyPro(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: vehicleList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final v = vehicleList[index];
                    final isSelected = activeVehicle?.plateNumber == v.plateNumber;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      tileColor: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.directions_car, color: isSelected ? Colors.white : AppColors.primary, size: 20),
                      ),
                      title: Row(
                        children: [
                          Text(
                            v.plateNumber,
                            style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${CurrencyFormatter.formatNumber(v.currentMileage)} km',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${v.model} • ${v.customerName} (${v.customerPhone})',
                        style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref.read(activeVehicleProvider.notifier).setVehicle(v);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Form to add new vehicle
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _plateController,
                          decoration: const InputDecoration(
                            labelText: 'ស្លាកលេខ (ឧ. ភ្នំពេញ 2BC-1234)*',
                            prefixIcon: Icon(Icons.pin),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'ម៉ាករថយន្ត (ឧ. Prius 2012 / Camry)',
                            prefixIcon: Icon(Icons.car_rental),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mileageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'គីឡូម៉ែត្របច្ចុប្បន្ន (Odometer km)',
                            prefixIcon: Icon(Icons.speed),
                            suffixText: 'km',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'លេខទូរស័ព្ទអតិថិជន',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'ឈ្មោះអតិថិជន',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _isCreatingNew = false),
                        child: Text('ត្រឡប់ក្រោយ', style: GoogleFonts.kantumruyPro()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveNewVehicle,
                        child: Text('រក្សាទុក & ជ្រើសរើស', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
