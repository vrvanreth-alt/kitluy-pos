import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dummy_data.dart';
import '../../data/models/vehicle.dart';

class ActiveVehicleNotifier extends Notifier<Vehicle?> {
  @override
  Vehicle? build() => DummyData.sampleVehicles.first;

  void setVehicle(Vehicle? vehicle) {
    state = vehicle;
  }

  void updateMileage(int mileage) {
    if (state != null) {
      state = state!.copyWith(currentMileage: mileage);
    }
  }

  void clearVehicle() {
    state = null;
  }
}

final activeVehicleProvider = NotifierProvider<ActiveVehicleNotifier, Vehicle?>(
  ActiveVehicleNotifier.new,
);

class VehicleListNotifier extends Notifier<List<Vehicle>> {
  @override
  List<Vehicle> build() => DummyData.sampleVehicles;

  void addVehicle(Vehicle vehicle) {
    state = [vehicle, ...state];
  }
}

final vehicleListProvider = NotifierProvider<VehicleListNotifier, List<Vehicle>>(
  VehicleListNotifier.new,
);
