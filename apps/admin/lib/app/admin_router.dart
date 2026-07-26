import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../features/auth/presentation/screens/admin_login_screen.dart';
import 'admin_shell.dart';

class AdminRouter extends StatelessWidget {
  const AdminRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAuthCubit, AdminAuthState>(
      listener: (context, state) {
        if (state is AdminAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminAuthLoading) {
          return const Scaffold(
            body: AppLoader(),
          );
        }

        if (state is AdminAuthenticated) {
          return const AdminShell();
        }

        return const AdminLoginScreen();
      },
    );
  }
}
