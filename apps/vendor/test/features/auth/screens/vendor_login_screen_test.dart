import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:providers/providers.dart';
import 'package:vendor/features/auth/presentation/screens/vendor_login_screen.dart';

import '../../../helpers/mock_cubits.dart';

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildLoginScreen() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const VendorLoginScreen(),
      ),
    );
  }

  group('VendorLoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('renders Deliverak Vendor title', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Deliverak Vendor'), findsOneWidget);
    });

    testWidgets('renders Sign In button', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders create account link', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.text('Create one'), findsOneWidget);
    });

    testWidgets('validates short password shows error', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.enterText(
        find.byType(TextFormField).first,
        'user@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        '123',
      );
      // Tap Sign In button (it's an AppButton wrapping ElevatedButton)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('can enter email and password', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.enterText(
        find.byType(TextFormField).first,
        'vendor@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      expect(find.text('vendor@test.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('shows loading indicator when AuthLoading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthLoading());
      await tester.pumpWidget(buildLoginScreen());
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
