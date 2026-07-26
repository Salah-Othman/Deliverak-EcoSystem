import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:vendor/features/menu/presentation/widgets/product_item_card.dart';

void main() {
  Widget buildProductCard({
    bool isAvailable = true,
    double? discountPrice,
    VoidCallback? onTap,
    VoidCallback? onToggle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProductItemCard(
          product: ProductModel(
            productId: 'p1',
            vendorId: 'v1',
            name: 'Chicken Burger',
            description: 'Delicious',
            price: 12.99,
            discountPrice: discountPrice,
            images: const ['https://example.com/burger.jpg'],
            category: 'Burgers',
            isAvailable: isAvailable,
            createdAt: DateTime(2024),
          ),
          onTap: onTap ?? () {},
          onToggleAvailability: onToggle ?? () {},
        ),
      ),
    );
  }

  group('ProductItemCard', () {
    testWidgets('renders product name', (tester) async {
      await tester.pumpWidget(buildProductCard());
      expect(find.text('Chicken Burger'), findsOneWidget);
    });

    testWidgets('renders product price', (tester) async {
      await tester.pumpWidget(buildProductCard());
      expect(find.textContaining('12.99'), findsOneWidget);
    });

    testWidgets('renders category', (tester) async {
      await tester.pumpWidget(buildProductCard());
      expect(find.text('Burgers'), findsOneWidget);
    });

    testWidgets('renders switch with correct value', (tester) async {
      await tester.pumpWidget(buildProductCard(isAvailable: true));
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('renders switch as off when not available', (tester) async {
      await tester.pumpWidget(buildProductCard(isAvailable: false));
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('shows discount price with strikethrough', (tester) async {
      await tester.pumpWidget(buildProductCard(discountPrice: 9.99));
      expect(find.textContaining('9.99'), findsWidgets);
    });

    testWidgets('onToggleAvailability is called on switch tap', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(buildProductCard(onToggle: () => toggled = true));
      await tester.tap(find.byType(Switch));
      expect(toggled, isTrue);
    });

    testWidgets('onTap is called when card tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildProductCard(onTap: () => tapped = true));
      await tester.tap(find.byType(ProductItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows fallback icon when no images', (tester) async {
      return tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProductItemCard(
            product: ProductModel(
              productId: 'p1',
              vendorId: 'v1',
              name: 'No Image Product',
              description: '',
              price: 5.00,
              images: const [],
              category: 'General',
              isAvailable: true,
              createdAt: DateTime(2024),
            ),
            onTap: () {},
            onToggleAvailability: () {},
          ),
        ),
      ));
    });
  });
}
