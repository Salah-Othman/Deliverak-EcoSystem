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
  });
}
