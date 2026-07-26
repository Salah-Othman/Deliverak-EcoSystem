import 'package:core/src/models/driver_model.dart';

abstract class IDriverRepository {
  Future<DriverModel> createDriver({
    required String userId,
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
  });

  Future<DriverModel?> getDriver(String driverId);

  Future<DriverModel?> getDriverByUserId(String userId);

  Stream<DriverModel?> watchDriver(String driverId);

  Future<void> updateLocation(String driverId, double lat, double lng);

  Future<void> updateOnlineStatus(String driverId, bool isOnline);

  Future<void> updateDriverProfile({
    required String driverId,
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
  });

  Future<List<DriverModel>> getAvailableDrivers();
}
