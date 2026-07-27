import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is Authenticated ? authState.user : null;

        return ListView(
          padding: AppSpacing.responsivePadding(context),
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: AppSpacing.lg),
            _buildThemeSection(context),
            const SizedBox(height: AppSpacing.lg),
            _buildAccountSection(context),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              (user?.name ?? 'U')[0].toUpperCase(),
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.phone ?? '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return Column(
                children: [
                  _ThemeOption(
                    icon: Icons.light_mode_outlined,
                    label: 'Light',
                    isSelected: state.themeMode == AppThemeMode.light,
                    onTap: () => context
                        .read<ThemeCubit>()
                        .setThemeMode(AppThemeMode.light),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark',
                    isSelected: state.themeMode == AppThemeMode.dark,
                    onTap: () => context
                        .read<ThemeCubit>()
                        .setThemeMode(AppThemeMode.dark),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ThemeOption(
                    icon: Icons.phone_iphone,
                    label: 'System',
                    isSelected: state.themeMode == AppThemeMode.system,
                    onTap: () => context
                        .read<ThemeCubit>()
                        .setThemeMode(AppThemeMode.system),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Saved Addresses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceContainer(context),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant(context),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurface(context),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
