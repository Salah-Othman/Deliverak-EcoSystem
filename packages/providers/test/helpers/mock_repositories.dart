import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockVendorRepository extends Mock implements IVendorRepository {}

class MockProductRepository extends Mock implements IProductRepository {}

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

class MockDriverRepository extends Mock implements IDriverRepository {}
