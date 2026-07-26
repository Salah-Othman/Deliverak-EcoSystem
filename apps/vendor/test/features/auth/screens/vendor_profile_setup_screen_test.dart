import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:core/core.dart';
import 'package:providers/providers.dart';
import 'package:vendor/features/auth/presentation/screens/vendor_profile_setup_screen.dart';

import '../../../helpers/mock_cubits.dart';

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(ProfileSetup(
      user: UserModel(
        uid: 'vendor-1',
        name: '',
        email: 'vendor@test.com',
        phone: '+1234567890',
        role: UserRole.vendor,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ));
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildProfileSetupScreen() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const VendorProfileSetupScreen(),
      ),
    );
  }

  group('VendorProfileSetupScreen', () {
    testWidgets('renders Full Name field', (tester) async {
      await tester.pumpWidget(buildProfileSetupScreen());
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('renders Set up your profile title', (tester) async {
      await tester.pumpWidget(buildProfileSetupScreen());
      expect(find.text('Set up your profile'), findsOneWidget);
    });

    testWidgets('renders Get Started button', (tester) async {
      await tester.pumpWidget(buildProfileSetupScreen());
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('renders Vendor role chip', (tester) async {
      await tester.pumpWidget(buildProfileSetupScreen());
      expect(find.text('Vendor'), findsOneWidget);
    });

    testWidgets('validates empty name shows error', (tester) async {
      await tester.pumpWidget(buildProfileSetupScreen());
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('validates short name shows error', (tester) async {
      await tester.pumpWidget(buildProfileSetupScreen());
      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('shows loading when AuthLoading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthLoading());
      await tester.pumpWidget(buildProfileSetupScreen());
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
