import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/app/app.dart';
import 'package:customer/features/auth/presentation/screens/login_screen.dart';
import 'package:customer/features/auth/presentation/screens/otp_screen.dart';
import 'package:customer/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:customer/features/home/presentation/screens/home_screen.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('AppRouter', () {
    testWidgets('shows LoginScreen when unauthenticated', (tester) async {
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        TestApp(
          authRepository: mockAuthRepo,
          child: const AppRouter(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows OtpScreen when PhoneSubmitted', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(const PhoneSubmitted(
          verificationId: 'test-vid',
          phoneNumber: '+1234567890',
        ));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const AppRouter(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OtpScreen), findsOneWidget);
    });

    testWidgets('shows RoleSelectionScreen when ProfileSetup', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const AppRouter(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RoleSelectionScreen), findsOneWidget);
    });

    testWidgets('shows HomeScreen when Authenticated', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(Authenticated(TestData.customer));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const AppRouter(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows loading when AuthLoading', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(AuthLoading());

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const AppRouter(),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
