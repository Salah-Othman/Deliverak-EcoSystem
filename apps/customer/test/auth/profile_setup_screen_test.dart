import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/auth/presentation/screens/profile_setup_screen.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUpAll(() {
    registerFallbackValue(UserRole.customer);
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepo.completeProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          role: any(named: 'role'),
          email: any(named: 'email'),
          profileImage: any(named: 'profileImage'),
        )).thenAnswer((_) async {});
  });

  group('ProfileSetupScreen', () {
    Widget buildScreen({UserRole? selectedRole}) {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(
          user: TestData.emptyNameUser,
          selectedRole: selectedRole,
        ));

      return TestApp(
        authCubit: cubit,
        authRepository: mockAuthRepo,
        child: const ProfileSetupScreen(),
      );
    }

    testWidgets('renders Set up your profile title', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      expect(find.text('Set up your profile'), findsOneWidget);
    });

    testWidgets('displays Full Name and Email input fields', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email (optional)'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows selected role chip', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      expect(find.text('Customer'), findsWidgets);
    });

    testWidgets('renders Get Started button', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('shows validation error on empty name', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('shows validation error on short name', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'J');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('shows validation error on invalid email', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).last, 'invalid-email');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when no role is selected', (tester) async {
      final cubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(ProfileSetup(user: TestData.emptyNameUser, selectedRole: null));

      await tester.pumpWidget(
        TestApp(
          authCubit: cubit,
          authRepository: mockAuthRepo,
          child: const ProfileSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Please go back and select a role'), findsOneWidget);
    });

    testWidgets('renders avatar with camera icon', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsWidgets);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('shows profile setup hint text', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      expect(find.textContaining('update your profile later'), findsOneWidget);
    });

    testWidgets('calls completeProfile on valid form submission', (tester) async {
      await tester.pumpWidget(buildScreen(selectedRole: UserRole.customer));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.enterText(find.byType(TextFormField).last, 'john@example.com');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.completeProfile(
            uid: TestData.emptyNameUser.uid,
            name: 'John Doe',
            role: UserRole.customer,
            email: 'john@example.com',
            profileImage: null,
          )).called(1);
    });
  });
}
