import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/search/presentation/screens/search_screen.dart';
import 'package:customer/features/vendor_detail/presentation/screens/vendor_detail_screen.dart';

void main() {
  late MockVendorRepository mockVendorRepo;

  setUp(() {
    mockVendorRepo = TestHelpers.createMockVendorRepository(
      vendors: [TestData.vendor],
    );
  });

  Widget buildSearchScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    return TestApp(
      vendorRepository: mockVendorRepo,
      child: Scaffold(body: const SearchScreen()),
    );
  }

  group('SearchScreen', () {
    testWidgets('renders search bar with hint text', (tester) async {
      await tester.pumpWidget(buildSearchScreen(tester));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Find food, groceries, medicine & more'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('shows default view with search icon', (tester) async {
      await tester.pumpWidget(buildSearchScreen(tester));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('entering text triggers search', (tester) async {
      when(() => mockVendorRepo.searchVendors(any()))
          .thenAnswer((_) async => [TestData.vendor]);

      await tester.pumpWidget(buildSearchScreen(tester));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pump(const Duration(milliseconds: 600));

      verify(() => mockVendorRepo.searchVendors('pizza')).called(1);
    });

    testWidgets('shows search results when vendors found', (tester) async {
      when(() => mockVendorRepo.searchVendors(any()))
          .thenAnswer((_) async => [TestData.vendor]);

      await tester.pumpWidget(buildSearchScreen(tester));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Pizza Palace'), findsOneWidget);
    });

    testWidgets('tapping search result navigates to VendorDetailScreen',
        (tester) async {
      when(() => mockVendorRepo.searchVendors(any()))
          .thenAnswer((_) async => [TestData.vendor]);

      await tester.pumpWidget(buildSearchScreen(tester));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pizza Palace'));
      await tester.pumpAndSettle();

      expect(find.byType(VendorDetailScreen), findsOneWidget);
    });

    testWidgets('shows EmptyState when no results', (tester) async {
      when(() => mockVendorRepo.searchVendors(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildSearchScreen(tester));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });
  });
}
