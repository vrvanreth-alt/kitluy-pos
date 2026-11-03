import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../data/models/staff.dart';
import '../state/staff_provider.dart';
import 'pin_login_dialog.dart';

class StaffManagementDialog extends ConsumerStatefulWidget {
  const StaffManagementDialog({super.key});

  @override
  ConsumerState<StaffManagementDialog> createState() => _StaffManagementDialogState();
}

class _StaffManagementDialogState extends ConsumerState<StaffManagementDialog> {
  void _showAddStaffDialog(BuildContext context) {
    final nameKhCtrl = TextEditingController();
    final nameEnCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    StaffRole selectedRole = StaffRole.cashier;

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
                  child: const Icon(Icons.person_add, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'បន្ថែមបុគ្គលិកថ្មី',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(context, 'ឈ្មោះបុគ្គលិក (ខ្មែរ) *'),
                    TextField(
                      controller: nameKhCtrl,
                      decoration: const InputDecoration(hintText: 'ឧ. សុខ ពិសិដ្ឋ'),
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel(context, 'ឈ្មោះបុគ្គលិក (English)'),
                    TextField(
                      controller: nameEnCtrl,
                      decoration: const InputDecoration(hintText: 'Sok Piseth'),
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel(context, 'តួនាទី (Role) *'),
                    Wrap(
                      spacing: 8,
                      children: StaffRole.values.map((role) {
                        final isSelected = selectedRole == role;
                        return ChoiceChip(
                          selected: isSelected,
                          onSelected: (_) => setModalState(() => selectedRole = role),
                          avatar: Icon(role.icon, size: 16, color: isSelected ? Colors.white : role.roleColor),
                          label: Text(
                            role.titleKh.split(' ')[0],
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : context.textPrimaryColor,
                            ),
                          ),
                          selectedColor: role.roleColor,
                          backgroundColor: context.surfaceMutedColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel(context, 'លេខទូរស័ព្ទ'),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: '012 333 444'),
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel(context, 'លេខកូដសម្ងាត់ PIN (៤ ខ្ទង់) *'),
                    TextField(
                      controller: pinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        hintText: 'ឧ. 2468',
                        counterText: '',
                      ),
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
                  if (nameKhCtrl.text.trim().isNotEmpty && pinCtrl.text.length == 4) {
                    final newStaff = Staff(
                      id: 'STF-${DateTime.now().millisecondsSinceEpoch % 1000}',
                      nameKh: nameKhCtrl.text.trim(),
                      nameEn: nameEnCtrl.text.trim().isEmpty ? nameKhCtrl.text.trim() : nameEnCtrl.text.trim(),
                      role: selectedRole,
                      pinCode: pinCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty ? '012 000 000' : phoneCtrl.text.trim(),
                      avatarColor: selectedRole.roleColor,
                    );

                    ref.read(staffListProvider.notifier).addStaff(newStaff);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('បានបង្កើតបុគ្គលិកជោគជ័យ!', style: GoogleFonts.kantumruyPro()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Text('រក្សាទុក', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
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
    final staffList = ref.watch(staffListProvider);
    final currentStaff = ref.watch(currentStaffProvider);

    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 820,
        height: 620,
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
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'បុគ្គលិក & សិទ្ធិប្រើប្រាស់ (Staff & Permissions)',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'RBAC • Security PIN Code & Access Controls',
                          style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textMutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (currentStaff.canManageStaff)
                      ElevatedButton.icon(
                        onPressed: () => _showAddStaffDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('+ បុគ្គលិកថ្មី', style: GoogleFonts.kantumruyPro(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 20),

            // Staff List
            Expanded(
              child: ListView.separated(
                itemCount: staffList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final staff = staffList[index];
                  final isCurrent = staff.id == currentStaff.id;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent ? staff.role.roleColor.withValues(alpha: 0.08) : context.surfaceMutedColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? staff.role.roleColor : context.borderColor,
                        width: isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: staff.avatarColor,
                          child: Text(
                            staff.nameKh.substring(0, 1),
                            style: GoogleFonts.kantumruyPro(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name & Role
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    staff.nameKh,
                                    style: GoogleFonts.kantumruyPro(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'កំពុង Login',
                                        style: GoogleFonts.kantumruyPro(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${staff.nameEn} • ${staff.phone}',
                                style: GoogleFonts.kantumruyPro(fontSize: 12, color: context.textSecondaryColor),
                              ),
                            ],
                          ),
                        ),

                        // Role Badge & Permissions Summary
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: staff.role.roleColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  staff.role.titleKh,
                                  style: GoogleFonts.kantumruyPro(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: staff.role.roleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                staff.role.descriptionEn,
                                style: GoogleFonts.kantumruyPro(fontSize: 11, color: context.textMutedColor),
                              ),
                            ],
                          ),
                        ),

                        // Switch Staff via PIN Button
                        if (!isCurrent)
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => PinLoginDialog(targetStaff: staff),
                              );
                            },
                            icon: const Icon(Icons.lock_open, size: 16),
                            label: Text('ប្តូរមកគណនីនេះ', style: GoogleFonts.kantumruyPro(fontSize: 12)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'សកម្ម (Active)',
                                  style: GoogleFonts.kantumruyPro(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
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
}
