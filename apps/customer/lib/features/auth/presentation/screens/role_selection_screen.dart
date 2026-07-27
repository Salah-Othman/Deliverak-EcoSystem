import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import 'profile_setup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your role'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'How will you use Deliverak?',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select the role that best describes you',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.0,
                  children: [
                    _RoleCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Customer',
                      subtitle: 'Order food, groceries & more',
                      role: UserRole.customer,
                      onTap: (role) => _onRoleSelected(context, role),
                    ),
                    _RoleCard(
                      icon: Icons.delivery_dining_outlined,
                      title: 'Driver',
                      subtitle: 'Deliver orders & earn',
                      role: UserRole.driver,
                      onTap: (role) => _onRoleSelected(context, role),
                    ),
                    _RoleCard(
                      icon: Icons.store_outlined,
                      title: 'Vendor',
                      subtitle: 'Sell your products',
                      role: UserRole.vendor,
                      onTap: (role) => _onRoleSelected(context, role),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRoleSelected(BuildContext context, UserRole role) {
    context.read<AuthCubit>().selectRole(role);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final UserRole role;
  final ValueChanged<UserRole> onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => onTap(role),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant(context),
              ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
