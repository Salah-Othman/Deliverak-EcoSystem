import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/vendors/presentation/screens/vendors_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _NavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavDestination(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Users',
    ),
    _NavDestination(
      icon: Icons.store_outlined,
      selectedIcon: Icons.store,
      label: 'Vendors',
    ),
    _NavDestination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Orders',
    ),
  ];

  Widget get _currentScreen {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const UsersScreen();
      case 2:
        return const VendorsScreen();
      case 3:
        return const OrdersScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliverak Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AdminAuthCubit>().signOut();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                ),
              ),
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
          if (isWide) const VerticalDivider(width: 1),
          Expanded(child: _currentScreen),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: _destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ))
                  .toList(),
            ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
