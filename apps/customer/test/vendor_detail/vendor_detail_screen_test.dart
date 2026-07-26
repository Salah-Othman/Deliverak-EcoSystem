import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/vendor_detail/presentation/screens/vendor_detail_screen.dart';

void main() {
  late MockProductRepository mockProductRepo;

  setUp(() {
    mockProductRepo = MockProductRepository();
    when(() => mockProductRepo.getProducts(vendorId: any(named: 'vendorId')))
        .thenAnswer((_) async => [
              TestData.product,
              TestData.discountedProduct,
              TestData.unavailableProduct,
            ]);
  });

  group('VendorDetailScreen', () {
    void setUpSurfaceSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
    }

    testWidgets('displays vendor name', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pizza Palace'), findsWidgets);
    });

    testWidgets('displays vendor info section', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Food'), findsWidgets);
      expect(find.text('Best pizza in town with authentic Italian flavors'),
          findsOneWidget);
    });

    testWidgets('displays vendor rating and order count', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsWidgets);
      expect(find.textContaining('orders'), findsWidgets);
    });

    testWidgets('displays vendor address', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('123 Main St, New York, NY 10001'), findsOneWidget);
    });

    testWidgets('displays product list', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Margherita Pizza'), findsOneWidget);
      expect(find.text('Pepperoni Pizza'), findsOneWidget);
      expect(find.text('Hawaiian Pizza'), findsOneWidget);
    });

    testWidgets('shows category filters when products have categories',
        (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsWidgets);
      expect(find.text('Pizza'), findsWidgets);
      expect(find.text('Specialty'), findsWidgets);
    });

    testWidgets('tapping category chip filters products', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Specialty'));
      await tester.pumpAndSettle();

      expect(find.text('Hawaiian Pizza'), findsOneWidget);
      expect(find.text('Margherita Pizza'), findsNothing);
    });

    testWidgets('shows Unavailable badge for unavailable products', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('add to cart button shows snackbar', (tester) async {
      setUpSurfaceSize(tester);
      final cartCubit = CartCubit();

      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          cartCubit: cartCubit,
          child: VendorDetailScreen(vendor: TestData.vendor),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('added to cart'), findsOneWidget);
    });

    testWidgets('shows Closed badge for closed vendors', (tester) async {
      setUpSurfaceSize(tester);
      await tester.pumpWidget(
        TestApp(
          productRepository: mockProductRepo,
          child: VendorDetailScreen(vendor: TestData.closedVendor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Closed'), findsWidgets);
    });
  });
}
