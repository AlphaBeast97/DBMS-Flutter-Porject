import 'package:flutter/material.dart';
import 'package:techfix/screens/customer_status_screen.dart';
import 'package:techfix/screens/manager_screen.dart';
import 'package:techfix/screens/technician_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      screen: CustomerStatusScreen(),
      icon: Icons.receipt_long,
      label: 'Customer',
    ),
    _NavItem(
      screen: TechnicianScreen(),
      icon: Icons.build_circle_outlined,
      label: 'Technician',
    ),
    _NavItem(
      screen: ManagerScreen(),
      icon: Icons.dashboard_outlined,
      label: 'Manager',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _index.clamp(0, _navItems.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final Widget screen;
  final IconData icon;
  final String label;

  const _NavItem({
    required this.screen,
    required this.icon,
    required this.label,
  });
}
