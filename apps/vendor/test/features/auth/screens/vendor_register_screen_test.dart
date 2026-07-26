import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:providers/providers.dart';
import 'package:vendor/features/auth/presentation/screens/vendor_register_screen.dart';

import '../../../helpers/mock_cubits.dart';

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildRegisterScreen() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const VendorRegisterScreen(),
      ),
    );
  }

  group('VendorRegisterScreen', () {
    testWidgets('renders all input fields', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('renders Join as a Vendor title', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Join as a Vendor'), findsOneWidget);
    });

    testWidgets('renders Create Account button', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      // AppBar title "Create Account" + button label "Create Account"
      expect(find.text('Create Account'), findsNWidgets(2));
    });

    testWidgets('validates empty name shows error', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('validates short name shows error', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('validates password mismatch shows error', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'different',
      );
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('password visibility toggles work', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
    });

    testWidgets('renders Sign in link', (tester) async {
      await tester.pumpWidget(buildRegisterScreen());
      expect(find.text('Sign in'), findsOneWidget);
    });
  });
}
