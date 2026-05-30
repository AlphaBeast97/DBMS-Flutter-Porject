import 'package:flutter/material.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/state/app_session_scope.dart';

const emailRegex = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
const minPasswordLength = 6;

void signOut(BuildContext context) {
  final session = AppSessionScope.of(context);
  session.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

String fmtMoney(double n) => '\$${n.toStringAsFixed(2)}';
