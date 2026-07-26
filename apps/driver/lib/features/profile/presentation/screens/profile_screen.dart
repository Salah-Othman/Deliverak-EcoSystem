import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, driverState) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return const Center(child: AppLoader());
            }

            final user = authState.user;
            final driver =
                driverState is DriverLoaded ? driverState.driver : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: AppSpacing.lg),
                  if (driver != null) ...[
                    _buildDriverStats(driver),
                    const SizedBox(height: AppSpacing.lg),
                    _buildVehicleInfo(driver),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildMenuItems(context),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Sign Out',
                    isOutlined: true,
                    onPressed: () => _showSignOutDialog(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                user.profileImage != null && user.profileImage!.isNotEmpty
                    ? NetworkImage(user.profileImage!)
                    : null,
            child: user.profileImage == null || user.profileImage!.isEmpty
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'D',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.name.isNotEmpty ? user.name : 'Driver',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.phone,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Text(
              'Driver',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStats(DriverModel driver) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_outline,
            label: 'Rating',
            value: Formatters.rating(driver.rating),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.delivery_dining_outlined,
            label: 'Deliveries',
            value: '${driver.totalDeliveries}',
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(DriverModel driver) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Information', style: AppTypography.titleMedium),
          const Divider(),
          _InfoRow(label: 'Type', value: driver.vehicleType),
          _InfoRow(label: 'Number', value: driver.vehicleNumber),
          _InfoRow(label: 'License', value: driver.licenseNumber),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          const Divider(),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          const Divider(),
          _MenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthCubit>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
