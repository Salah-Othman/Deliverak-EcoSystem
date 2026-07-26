import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  UserRole? _selectedRole;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminUserCubit>().loadUsers();
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.name.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query) &&
            !user.phone.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Users',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name, email, or phone...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ChoiceChip(
          label: const Text('All'),
          selected: _selectedRole == null,
          onSelected: (_) {
            setState(() => _selectedRole = null);
            context.read<AdminUserCubit>().loadUsers();
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        ...UserRole.values.map((role) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(role.displayName),
                selected: _selectedRole == role,
                onSelected: (_) {
                  setState(() => _selectedRole = role);
                  context.read<AdminUserCubit>().loadUsers(role: role);
                },
              ),
            )),
      ],
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<AdminUserCubit, AdminUserState>(
      builder: (context, state) {
        if (state is AdminUserLoading) {
          return const AppLoader();
        }

        if (state is AdminUserError) {
          return ErrorState(
            message: state.message,
            isRetryable: true,
            onRetry: () => context.read<AdminUserCubit>().loadUsers(
                  role: _selectedRole,
                ),
          );
        }

        if (state is AdminUsersLoaded) {
          final filtered = _filterUsers(state.users);
          if (filtered.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outlined,
              title: 'No users found',
              subtitle: 'No users match your current filters',
            );
          }

          return Card(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.grey200,
                    backgroundImage: user.profileImage != null &&
                            user.profileImage!.isNotEmpty
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null ||
                            user.profileImage!.isEmpty
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: AppTypography.labelLarge,
                          )
                        : null,
                  ),
                  title: Text(
                    user.name.isNotEmpty ? user.name : 'Unnamed',
                    style: AppTypography.labelLarge,
                  ),
                  subtitle: Text(
                    user.email.isNotEmpty ? user.email : user.phone,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoleChip(role: user.role),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 20),
                        onPressed: () => _showUserDetail(user),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showUserDetail(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name.isNotEmpty ? user.name : 'Unnamed User'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('UID', user.uid),
              _detailRow('Email', user.email.isNotEmpty ? user.email : 'N/A'),
              _detailRow('Phone', user.phone.isNotEmpty ? user.phone : 'N/A'),
              _detailRow('Role', user.role.displayName),
              _detailRow(
                'Created',
                DateFormat.yMMMd().add_jm().format(user.createdAt),
              ),
              _detailRow(
                'Updated',
                DateFormat.yMMMd().add_jm().format(user.updatedAt),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final UserRole role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case UserRole.customer:
        color = AppColors.primary;
      case UserRole.driver:
        color = Colors.blue;
      case UserRole.vendor:
        color = AppColors.success;
      case UserRole.admin:
        color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        role.displayName,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
