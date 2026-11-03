import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_helper.dart';
import '../../data/models/staff.dart';
import '../state/staff_provider.dart';

class PinLoginDialog extends ConsumerStatefulWidget {
  final Staff? targetStaff;
  final String title;

  const PinLoginDialog({
    super.key,
    this.targetStaff,
    this.title = 'បញ្ចូលលេខសម្ងាត់ PIN បុគ្គលិក',
  });

  @override
  ConsumerState<PinLoginDialog> createState() => _PinLoginDialogState();
}

class _PinLoginDialogState extends ConsumerState<PinLoginDialog> {
  late Staff _selectedStaff;
  String _enteredPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedStaff = widget.targetStaff ?? ref.read(currentStaffProvider);
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _errorMessage = null;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _errorMessage = null;
      _enteredPin = '';
    });
  }

  void _verifyPin() {
    final success = ref.read(currentStaffProvider.notifier).verifyAndSwitch(
      _selectedStaff.id,
      _enteredPin,
    );

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'បានចូលប្រើជោគជ័យជា៖ ${_selectedStaff.nameKh} (${_selectedStaff.role.titleKh})',
            style: GoogleFonts.kantumruyPro(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'លេខកូដ PIN មិនត្រឹមត្រូវទេ! សូមព្យាយាមម្តងទៀត';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final staffList = ref.watch(staffListProvider);

    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedStaff.role.roleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_selectedStaff.role.icon, color: _selectedStaff.role.roleColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'Staff Security PIN Verification',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 12,
                            color: context.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: Icon(Icons.close, color: context.textMutedColor),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Staff Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: staffList.map((staff) {
                  final isSelected = staff.id == _selectedStaff.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedStaff = staff;
                            _enteredPin = '';
                            _errorMessage = null;
                          });
                        }
                      },
                      avatar: CircleAvatar(
                        backgroundColor: staff.avatarColor,
                        radius: 12,
                        child: Text(
                          staff.nameKh.substring(0, 1),
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      label: Text(
                        '${staff.nameKh} (${staff.role.titleKh.split(' ')[0]})',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : context.textPrimaryColor,
                        ),
                      ),
                      selectedColor: _selectedStaff.role.roleColor,
                      backgroundColor: context.surfaceMutedColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Active Staff Profile Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.surfaceMutedColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _selectedStaff.avatarColor,
                    child: Text(
                      _selectedStaff.nameKh.substring(0, 1),
                      style: GoogleFonts.kantumruyPro(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStaff.nameKh,
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          '${_selectedStaff.role.titleKh} • ${_selectedStaff.phone}',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedStaff.role.roleColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedStaff.role.titleKh.split(' ')[0],
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _selectedStaff.role.roleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PIN Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? _selectedStaff.role.roleColor
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    border: Border.all(
                      color: isFilled ? _selectedStaff.role.roleColor : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: _selectedStaff.role.roleColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                );
              }),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.kantumruyPro(
                  color: AppColors.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Numpad Grid (1-9, C, 0, ⌫)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNumButton('1'),
                      _buildNumButton('2'),
                      _buildNumButton('3'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNumButton('4'),
                      _buildNumButton('5'),
                      _buildNumButton('6'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNumButton('7'),
                      _buildNumButton('8'),
                      _buildNumButton('9'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(
                        icon: Icons.refresh_rounded,
                        label: 'C',
                        onTap: _onClearPressed,
                      ),
                      _buildNumButton('0'),
                      _buildActionButton(
                        icon: Icons.backspace_outlined,
                        onTap: _onDeletePressed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ព័ត៌មានជំនួយ៖ PIN សាកល្បង: Owner (9999), Manager (8888), Cashier (1234), Mechanic (0000)',
              textAlign: TextAlign.center,
              style: GoogleFonts.kantumruyPro(
                fontSize: 11,
                color: context.textMutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumButton(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: context.surfaceMutedColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: GoogleFonts.kantumruyPro(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: context.surfaceMutedColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(
                label,
                style: GoogleFonts.kantumruyPro(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              )
            : Icon(icon, color: context.textSecondaryColor, size: 22),
      ),
    );
  }
}
