import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../features/auth/presentation/screens/vendor_login_screen.dart';
import '../features/auth/presentation/screens/vendor_profile_setup_screen.dart';
import '../features/dashboard/presentation/screens/vendor_home_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError && state.previousState == null) {
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

        if (state is ProfileSetup) {
          return const VendorProfileSetupScreen();
        }

        if (state is Authenticated) {
          return const VendorHomeScreen();
        }

        return const VendorLoginScreen();
      },
    );
  }
}
