/// Shared constants and utility functions used across screens.
import 'package:flutter/material.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/state/app_session_scope.dart';

/// Regex for basic email format validation.
const emailRegex = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';

/// Minimum password length enforced on sign-up.
const minPasswordLength = 6;

/// Clears the session and navigates back to [LoginScreen],
/// removing all previous routes from the stack.
void signOut(BuildContext context) {
  final session = AppSessionScope.of(context);
  session.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

/// Formats a double as a USD currency string (e.g., `$123.45`).
String fmtMoney(double n) => '\$${n.toStringAsFixed(2)}';
