import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import 'package:customer/features/auth/presentation/screens/otp_screen.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('OtpScreen', () {
    testWidgets('renders Verify OTP title', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify OTP'), findsOneWidget);
    });

    testWidgets('displays the phone number', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('Enter the code sent to'), findsOneWidget);
    });

    testWidgets('renders 6 OTP input fields', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('renders Verify button', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('shows resend countdown initially', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Resend code in'), findsOneWidget);
    });

    testWidgets('has AppBar', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Verify OTP'), findsOneWidget);
    });
  });
}
