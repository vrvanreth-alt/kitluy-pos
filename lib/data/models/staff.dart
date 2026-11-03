import 'package:flutter/material.dart';

enum StaffRole {
  owner('ម្ចាស់ហាង (Owner)', 'Full System Access', Icons.admin_panel_settings, Color(0xFF6366F1)),
  manager('ប្រធានផ្នែក (Manager)', 'Inventory, Pricing, Debts & Reports', Icons.manage_accounts, Color(0xFF0EA5E9)),
  cashier('អ្នកគិតលុយ (Cashier)', 'Sales, Cart & Invoicing', Icons.point_of_sale, Color(0xFF10B981)),
  mechanic('ជាងជួសជុល (Mechanic)', 'Services & Inspection', Icons.car_repair, Color(0xFFF59E0B));

  final String titleKh;
  final String descriptionEn;
  final IconData icon;
  final Color roleColor;

  const StaffRole(this.titleKh, this.descriptionEn, this.icon, this.roleColor);
}

class Staff {
  final String id;
  final String nameKh;
  final String nameEn;
  final StaffRole role;
  final String pinCode; // 4-digit PIN e.g. "9999"
  final String phone;
  final Color avatarColor;
  final bool isActive;

  const Staff({
    required this.id,
    required this.nameKh,
    required this.nameEn,
    required this.role,
    required this.pinCode,
    required this.phone,
    required this.avatarColor,
    this.isActive = true,
  });

  // Role Permissions
  bool get canAccessPOS => true;
  bool get canManageInventory => role == StaffRole.owner || role == StaffRole.manager;
  bool get canManageServices => true;
  bool get canManageCustomerDebt => role == StaffRole.owner || role == StaffRole.manager || role == StaffRole.cashier;
  bool get canManageSupplierDebt => role == StaffRole.owner || role == StaffRole.manager;
  bool get canViewReports => role == StaffRole.owner || role == StaffRole.manager;
  bool get canChangeExchangeRate => role == StaffRole.owner || role == StaffRole.manager;
  bool get canManageStaff => role == StaffRole.owner;
  bool get canApplySpecialDiscount => role == StaffRole.owner || role == StaffRole.manager;
}
