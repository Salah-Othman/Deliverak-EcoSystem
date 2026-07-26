import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin/features/dashboard/presentation/widgets/stats_card.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('StatsCard', () {
    testWidgets('renders title, value, and icon', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const StatsCard(
            title: 'Total Users',
            value: '42',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
      );

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('renders with different values', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const StatsCard(
            title: 'Total Revenue',
            value: '\$1,234',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
      );

      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('\$1,234'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });
  });
}
