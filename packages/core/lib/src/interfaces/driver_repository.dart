import 'package:core/src/models/driver_model.dart';

abstract class IDriverRepository {
  Future<DriverModel?> getDriver(String driverId);

  Future<DriverModel?> getDriverByUserId(String userId);

  Stream<DriverModel?> watchDriver(String driverId);

  Future<void> updateLocation(String driverId, double lat, double lng);

  Future<void> updateOnlineStatus(String driverId, bool isOnline);

  Future<List<DriverModel>> getAvailableDrivers();
}
