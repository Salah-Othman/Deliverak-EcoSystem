import 'package:flutter_test/flutter_test.dart';

import 'package:providers/providers.dart';

void main() {
  test('providers barrel exports', () {
    expect(AuthCubit, isNotNull);
    expect(VendorCubit, isNotNull);
    expect(ProductCubit, isNotNull);
    expect(CartCubit, isNotNull);
    expect(OrderCubit, isNotNull);
    expect(SearchCubit, isNotNull);
    expect(NotificationCubit, isNotNull);
    expect(AdminAuthCubit, isNotNull);
    expect(AdminCubit, isNotNull);
    expect(AdminUserCubit, isNotNull);
    expect(VendorOrderCubit, isNotNull);
    expect(VendorProductCubit, isNotNull);
    expect(VendorProfileCubit, isNotNull);
    expect(DriverCubit, isNotNull);
    expect(DriverOrderCubit, isNotNull);
  });
}
