/// App entry point. Loads environment variables, initializes session state,
/// and renders the root [TechFixApp] widget wrapped in [AppSessionScope].
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:techfix/config/api_config.dart';
import 'package:techfix/screens/login_screen.dart';
import 'package:techfix/state/app_session.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const TechFixApp());
}

/// Root MaterialApp widget. Creates the [AppSession] and provides it
/// down the widget tree via [AppSessionScope].
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
    _session = AppSession(baseUrl: ApiConfig.baseUrl);
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
