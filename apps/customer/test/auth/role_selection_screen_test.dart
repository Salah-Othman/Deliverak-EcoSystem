import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:customer/features/auth/presentation/screens/profile_setup_screen.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});
  });

  group('RoleSelectionScreen', () {
    testWidgets('renders Choose your role title', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const RoleSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose your role'), findsOneWidget);
      expect(find.text('How will you use Deliverak?'), findsOneWidget);
    });

    testWidgets('displays all three role cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const RoleSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Driver'), findsOneWidget);
      expect(find.text('Vendor'), findsOneWidget);
    });

    testWidgets('shows subtitle descriptions for roles', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const RoleSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order food, groceries & more'), findsOneWidget);
      expect(find.text('Deliver orders & earn'), findsOneWidget);
      expect(find.text('Sell your products'), findsOneWidget);
    });

    testWidgets('selecting Customer role emits ProfileSetup with selectedRole',
        (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const RoleSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      expect(cubit.state, isA<ProfileSetup>());
      final state = cubit.state as ProfileSetup;
      expect(state.selectedRole, UserRole.customer);
    });

    testWidgets('navigates to ProfileSetupScreen on role selection',
        (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const RoleSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSetupScreen), findsOneWidget);
    });

    testWidgets('has no back button', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const RoleSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}
