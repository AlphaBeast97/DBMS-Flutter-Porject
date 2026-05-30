import 'package:flutter/foundation.dart';

class AppSession extends ChangeNotifier {
  String _baseUrl;
  String _email;
  String _password;
  Map<String, dynamic>? _employee;

  AppSession({required String baseUrl, String email = '', String password = ''})
    : _baseUrl = baseUrl,
      _email = email,
      _password = password;

  String get baseUrl => _baseUrl;
  String get email => _email;
  String get password => _password;
  Map<String, dynamic>? get employee => _employee;

  bool get isAuthenticated => _employee != null;
  bool get isOwner => _employee?['role'] == 'Owner';

  void updateCredentials({
    required String baseUrl,
    required String email,
    required String password,
  }) {
    _baseUrl = baseUrl;
    _email = email;
    _password = password;
    notifyListeners();
  }

  void setEmployee(Map<String, dynamic>? employee) {
    _employee = employee;
    notifyListeners();
  }

  void signOut() {
    _employee = null;
    notifyListeners();
  }
}
