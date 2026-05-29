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

  // Define all available tabs
  static const List<_NavItem> _allNavItems = [
    _NavItem(
      screen: CustomerStatusScreen(),
      icon: Icons.receipt_long,
      label: 'Customer',
      roles: [
        'Customer',
        'Owner',
        'Manager',
      ], // Accessible by Customer, Owner, Manager
    ),
    _NavItem(
      screen: TechnicianScreen(),
      icon: Icons.build_circle_outlined,
      label: 'Technician',
      roles: [
        'Employee',
        'Owner',
        'Manager',
      ], // Accessible by Employee, Owner, Manager
    ),
    _NavItem(
      screen: ManagerScreen(),
      icon: Icons.dashboard_outlined,
      label: 'Manager',
      roles: ['Owner', 'Manager'], // Accessible only by Owner, Manager
    ),
  ];

  /// Get visible tabs based on user role
  List<_NavItem> _getVisibleTabs() {
    final session = AppSessionScope.of(context);
    final employee = session.employee;

    if (employee == null) return [];

    // Extract role from employee data; default to 'Employee' if not found
    final role = (employee['role'] as String?)?.trim() ?? 'Employee';

    // Filter tabs that include this role
    return _allNavItems.where((item) => item.roles.contains(role)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get tabs visible for this user
    final visibleTabs = _getVisibleTabs();

    // Clamp index to available tabs
    final currentIndex = _index.clamp(
      0,
      visibleTabs.isEmpty ? 0 : visibleTabs.length - 1,
    );

    return Scaffold(
      body: visibleTabs.isEmpty
          ? const Center(child: Text('No screens available for your role.'))
          : IndexedStack(
              index: currentIndex,
              children: visibleTabs.map((item) => item.screen).toList(),
            ),
      // Only show NavigationBar if there are 2+ tabs (Material Design requirement)
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

class _NavItem {
  final Widget screen;
  final IconData icon;
  final String label;
  final List<String> roles; // Roles that can access this tab

  const _NavItem({
    required this.screen,
    required this.icon,
    required this.label,
    required this.roles,
  });
}
