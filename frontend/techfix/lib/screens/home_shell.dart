/// Root navigation shell after login.
///
/// Renders a [NavigationBar] with role-based tab visibility and an
/// [IndexedStack] to preserve screen state across tab switches.
///
/// Tab visibility is determined by the employee's role:
/// - **Owner/Manager**: sees Manager, Technician, and Customer tabs
/// - **Employee**: sees Technician and Customer tabs
/// - **Customer**: sees only the Customer tab
import 'package:flutter/material.dart';
import 'package:techfix/screens/customer_status_screen.dart';
import 'package:techfix/screens/manager_screen.dart';
import 'package:techfix/screens/technician_screen.dart';
import 'package:techfix/state/app_session_scope.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // All available tabs with their role access lists.
  static const List<_NavItem> _allNavItems = [
    _NavItem(
      screen: CustomerStatusScreen(),
      icon: Icons.receipt_long,
      label: 'Customer',
      roles: ['Customer', 'Manager'],
    ),
    _NavItem(
      screen: TechnicianScreen(),
      icon: Icons.build_circle_outlined,
      label: 'Technician',
      roles: ['Employee', 'Manager'],
    ),
    _NavItem(
      screen: ManagerScreen(),
      icon: Icons.dashboard_outlined,
      label: 'Manager',
      roles: ['Owner', 'Manager'],
    ),
  ];

  /// Filters [_allNavItems] to only those whose [roles] include
  /// the current employee's role.
  List<_NavItem> _getVisibleTabs() {
    final session = AppSessionScope.of(context);
    final employee = session.employee;

    if (employee == null) return [];

    final role = (employee['role'] as String?)?.trim() ?? 'Employee';
    return _allNavItems.where((item) => item.roles.contains(role)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTabs = _getVisibleTabs();
    final currentIndex = _index.clamp(
      0,
      visibleTabs.isEmpty ? 0 : visibleTabs.length - 1,
    );

    return Scaffold(
      // IndexedStack keeps all screens alive; switching tabs does not
      // rebuild previous screens.
      body: visibleTabs.isEmpty
          ? const Center(child: Text('No screens available for your role.'))
          : IndexedStack(
              index: currentIndex,
              children: visibleTabs.map((item) => item.screen).toList(),
            ),
      bottomNavigationBar: visibleTabs.length >= 2
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (value) {
                setState(() {
                  _index = value;
                });
              },
              destinations: visibleTabs
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            )
          : null,
    );
  }
}

/// Describes a single navigation tab with its screen, icon, label,
/// and the list of roles authorized to see it.
class _NavItem {
  final Widget screen;
  final IconData icon;
  final String label;
  final List<String> roles;

  const _NavItem({
    required this.screen,
    required this.icon,
    required this.label,
    required this.roles,
  });
}
