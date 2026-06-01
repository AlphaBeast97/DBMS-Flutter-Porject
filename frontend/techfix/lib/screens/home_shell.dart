/// Root screen after login.
///
/// Shows the appropriate screen based on the employee's role:
/// - Owner/Manager → ManagerScreen
/// - Employee → TechnicianScreen
/// - Customer → CustomerStatusScreen
import 'package:flutter/material.dart';
import 'package:techfix/screens/customer_status_screen.dart';
import 'package:techfix/screens/manager_screen.dart';
import 'package:techfix/screens/technician_screen.dart';
import 'package:techfix/state/app_session_scope.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSessionScope.of(context);
    final employee = session.employee;
    final role = (employee?['role'] as String?)?.trim() ?? '';

    final screen = switch (role) {
      'Owner' || 'Manager' => const ManagerScreen(),
      'Employee' => const TechnicianScreen(),
      'Customer' => const CustomerStatusScreen(),
      _ => const Center(child: Text('No screens available for your role.')),
    };

    return Scaffold(body: screen);
  }
}
