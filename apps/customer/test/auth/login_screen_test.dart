import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import 'package:customer/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockAuthRepo = TestHelpers.createMockAuthRepository(
        authStateChangesUser: null,
      );
    });

    testWidgets('renders Deliverak title and phone input', (tester) async {
      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deliverak'), findsOneWidget);
      expect(find.text('Fast delivery at your fingertips'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows phone validation error on empty submit', (tester) async {
      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Phone'));
      await tester.pumpAndSettle();

      expect(find.text('Phone number is required'), findsOneWidget);
    });

    testWidgets('shows phone validation error on invalid format', (tester) async {
      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '12345');
      await tester.tap(find.text('Continue with Phone'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid phone number with country code'), findsOneWidget);
    });

    testWidgets('calls verifyPhoneNumber on valid phone', (tester) async {
      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '+1234567890');
      await tester.tap(find.text('Continue with Phone'));
      await tester.pump();

      verify(() => mockAuthRepo.verifyPhoneNumber(
            phoneNumber: '+1234567890',
            onCompleted: any(named: 'onCompleted'),
            onFailed: any(named: 'onFailed'),
            onCodeSent: any(named: 'onCodeSent'),
            onCodeTimeout: any(named: 'onCodeTimeout'),
          )).called(1);
    });

    testWidgets('disables button when auth is loading', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo);
      cubit.emit(AuthLoading());

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          child: const LoginScreen(),
        ),
      );
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders terms of service text', (tester) async {
      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Terms of Service'), findsOneWidget);
    });

    testWidgets('renders phone and delivery icons', (tester) async {
      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.delivery_dining), findsOneWidget);
    });
  });
}
