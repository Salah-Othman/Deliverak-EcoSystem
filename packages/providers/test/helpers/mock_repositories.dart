import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockVendorRepository extends Mock implements IVendorRepository {}

class MockProductRepository extends Mock implements IProductRepository {}

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

class MockDriverRepository extends Mock implements IDriverRepository {}

class MockStorageService extends Mock implements IStorageService {}

class MockSecureStorageService extends Mock implements ISecureStorageService {}

class MockConnectivity extends Mock implements Connectivity {}
