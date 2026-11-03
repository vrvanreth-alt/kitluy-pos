import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/staff.dart';

final defaultStaffList = <Staff>[
  const Staff(
    id: 'STF-001',
    nameKh: 'ស៊ុំ វ៉ាន់ណារ៉ែត',
    nameEn: 'Sum Vannareth',
    role: StaffRole.owner,
    pinCode: '9999',
    phone: '012 999 888',
    avatarColor: Color(0xFF6366F1), // Indigo
  ),
  const Staff(
    id: 'STF-002',
    nameKh: 'សុខ ចាន់ថា',
    nameEn: 'Sok Chantha',
    role: StaffRole.manager,
    pinCode: '8888',
    phone: '098 777 666',
    avatarColor: Color(0xFF0EA5E9), // Sky Blue
  ),
  const Staff(
    id: 'STF-003',
    nameKh: 'ជា សុផល',
    nameEn: 'Chea Sophal',
    role: StaffRole.cashier,
    pinCode: '1234',
    phone: '077 555 444',
    avatarColor: Color(0xFF10B981), // Emerald
  ),
  const Staff(
    id: 'STF-004',
    nameKh: 'ម៉េង ហុង',
    nameEn: 'Meng Hong',
    role: StaffRole.mechanic,
    pinCode: '0000',
    phone: '089 333 222',
    avatarColor: Color(0xFFF59E0B), // Amber
  ),
];

class StaffNotifier extends Notifier<List<Staff>> {
  @override
  List<Staff> build() => defaultStaffList;

  void addStaff(Staff staff) {
    state = [...state, staff];
  }
}

final staffListProvider = NotifierProvider<StaffNotifier, List<Staff>>(
  StaffNotifier.new,
);

class CurrentStaffNotifier extends Notifier<Staff> {
  @override
  Staff build() => defaultStaffList[0];

  bool verifyAndSwitch(String staffId, String pin) {
    final staffList = ref.read(staffListProvider);
    final staff = staffList.firstWhere(
      (s) => s.id == staffId,
      orElse: () => state,
    );

    if (staff.pinCode == pin) {
      state = staff;
      return true;
    }
    return false;
  }

  bool quickSwitchByPin(String pin) {
    final staffList = ref.read(staffListProvider);
    try {
      final matching = staffList.firstWhere((s) => s.pinCode == pin && s.isActive);
      state = matching;
      return true;
    } catch (_) {
      return false;
    }
  }

  void setStaff(Staff staff) {
    state = staff;
  }
}

final currentStaffProvider = NotifierProvider<CurrentStaffNotifier, Staff>(
  CurrentStaffNotifier.new,
);
