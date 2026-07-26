import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/home/presentation/screens/home_screen.dart';
import 'package:customer/features/vendor_detail/presentation/screens/vendor_detail_screen.dart';

void main() {
  late MockVendorRepository mockVendorRepo;
  late MockOrderRepository mockOrderRepo;

  setUp(() {
    mockVendorRepo = TestHelpers.createMockVendorRepository(
      vendors: [TestData.vendor, TestData.closedVendor],
    );
    mockOrderRepo = MockOrderRepository();
  });

  Widget buildHome(WidgetTester tester, {MockVendorRepository? vendorRepo}) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final authCubit = AuthCubit(
      authRepository: TestHelpers.createMockAuthRepository(
        currentUser: TestData.customer,
      ),
    )..emit(Authenticated(TestData.customer));

    return TestApp(
      authCubit: authCubit,
      vendorRepository: vendorRepo ?? mockVendorRepo,
      orderRepository: mockOrderRepo,
      child: const HomeScreen(),
    );
  }

  group('HomeScreen', () {
    testWidgets('renders category chips', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Food'), findsWidgets);
    });

    testWidgets('displays vendor cards when loaded', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      expect(find.text('Pizza Palace'), findsOneWidget);
      expect(find.text('Burger Barn'), findsOneWidget);
    });

    testWidgets('displays vendor ratings', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsWidgets);
      expect(find.textContaining('orders'), findsWidgets);
    });

    testWidgets('shows Closed badge for closed vendors', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('tapping vendor card navigates to VendorDetailScreen',
        (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pizza Palace'));
      await tester.pumpAndSettle();

      expect(find.byType(VendorDetailScreen), findsOneWidget);
    });

    testWidgets('shows bottom navigation with 5 tabs', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('shows EmptyState when no vendors', (tester) async {
      final vendorRepo = MockVendorRepository();
      when(() => vendorRepo.getVendors(
            category: any(named: 'category'),
            isOpen: any(named: 'isOpen'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(buildHome(tester, vendorRepo: vendorRepo));
      await tester.pumpAndSettle();

      expect(find.text('No vendors nearby'), findsOneWidget);
    });

    testWidgets('tapping Search tab switches to search screen', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Search for vendors'), findsOneWidget);
    });

    testWidgets('tapping Cart tab switches to cart screen', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('tapping Orders tab switches to orders screen', (tester) async {
      await tester.pumpWidget(buildHome(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsOneWidget);
    });
  });
}
