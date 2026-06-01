/// Central application state held as a [ChangeNotifier].
///
/// Stores the current user's credentials (baseUrl, email, password)
/// and the authenticated employee map (id, name, role, etc.).
/// Screens listen to this via [AppSessionScope] and rebuild on changes.
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

  /// Updates stored credentials (used after login or URL change).
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

  /// Stores the authenticated employee/customer data from the API response.
  void setEmployee(Map<String, dynamic>? employee) {
    _employee = employee;
    notifyListeners();
  }

  /// Clears the session on logout.
  void signOut() {
    _employee = null;
    notifyListeners();
  }
}
