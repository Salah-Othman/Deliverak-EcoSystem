import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:providers/providers.dart';
import 'package:admin/features/auth/presentation/screens/admin_login_screen.dart';

class MockAdminAuthCubit extends Mock implements AdminAuthCubit {}

void main() {
  late MockAdminAuthCubit mockCubit;

  setUp(() {
    mockCubit = MockAdminAuthCubit();
    when(() => mockCubit.state).thenReturn(AdminAuthInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    mockCubit.close();
  });

  Widget buildLoginScreen() {
    return MaterialApp(
      home: BlocProvider<AdminAuthCubit>.value(
        value: mockCubit,
        child: const AdminLoginScreen(),
      ),
    );
  }

  group('AdminLoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Deliverak Admin title', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.text('Deliverak Admin'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => mockCubit.state).thenReturn(AdminAuthLoading());

      await tester.pumpWidget(buildLoginScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('validates empty email shows error', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Submit form with empty fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('validates short password shows error', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Enter valid email but short password
      await tester.enterText(
        find.byType(TextFormField).first,
        'admin@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        '123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Initially obscured
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('can enter email and password', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'admin@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      expect(find.text('admin@test.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
