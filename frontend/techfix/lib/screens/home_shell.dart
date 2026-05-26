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

  final List<Widget> _screens = const [
    CustomerStatusScreen(),
    TechnicianScreen(),
    ManagerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Customer',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_circle_outlined),
            label: 'Technician',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Manager',
          ),
        ],
      ),
    );
  }
}
