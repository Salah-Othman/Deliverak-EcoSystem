import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Tap Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, true);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('button is disabled when isLoading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit',
              onPressed: () => tapped = true,
              isLoading: true,
            ),
          ),
        ),
      );

      // When loading, button shows spinner instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Button exists but onPressed is null (disabled)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('outlined variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Outline',
              onPressed: () {},
              isOutlined: true,
            ),
          ),
        ),
      );

      expect(find.text('Outline'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('AppCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, true);
    });
  });

  group('AppFilterChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Food',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilterChip(
              label: 'Food',
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Food'));
      expect(tapped, true);
    });
  });

  group('AppLoader', () {
    testWidgets('renders centered spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoader(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.shopping_cart,
              title: 'No Items',
              subtitle: 'Your cart is empty',
            ),
          ),
        ),
      );

      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('shows action button when onAction provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.shopping_cart,
              title: 'No Items',
              subtitle: 'Empty',
              actionLabel: 'Browse',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Browse'), findsOneWidget);
    });

    testWidgets('hides action button when onAction is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.shopping_cart,
              title: 'No Items',
              subtitle: 'Empty',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('ErrorState', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when isRetryable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Network error',
              isRetryable: true,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when not isRetryable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Permission denied',
              isRetryable: false,
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
