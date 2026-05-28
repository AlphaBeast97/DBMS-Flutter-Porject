import 'package:flutter/material.dart';
import 'package:techfix/config/api_config.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/state/app_session.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';

void main() {
  runApp(const TechFixApp());
}

class TechFixApp extends StatefulWidget {
  const TechFixApp({super.key});

  @override
  State<TechFixApp> createState() => _TechFixAppState();
}

class _TechFixAppState extends State<TechFixApp> {
  late final AppSession _session;

  @override
  void initState() {
    super.initState();
    _session = AppSession(baseUrl: ApiConfig.chromeBaseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AppSessionScope(
      session: _session,
      child: MaterialApp(
        title: 'TechFix',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
