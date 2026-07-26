import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/role_selection_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError && state.previousState is PhoneSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: AppLoader(),
          );
        }

        if (state is PhoneSubmitted) {
          return const OtpScreen();
        }

        if (state is ProfileSetup) {
          return const RoleSelectionScreen();
        }

        if (state is Authenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
