import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techfix/config/api_config.dart';
import 'package:techfix/screens/home_shell.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMode { employee, customer }

class _LoginScreenState extends State<LoginScreen> {
  final _employeeFormKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();

  late final TextEditingController _baseUrlController;
  final _employeeEmailController = TextEditingController();
  final _employeePasswordController = TextEditingController();
  final _customerEmailController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  AuthMode _authMode = AuthMode.employee;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: _defaultBaseUrl());
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _employeeEmailController.dispose();
    _employeePasswordController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  String _defaultBaseUrl() {
    if (kIsWeb) {
      return ApiConfig.chromeBaseUrl;
    }
    return ApiConfig.androidDeviceBaseUrl;
  }

  /// Submit employee authentication
  Future<void> _submitEmployee() async {
    if (!_employeeFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final session = AppSessionScope.of(context);
    final baseUrl = _baseUrlController.text.trim();
    final email = _employeeEmailController.text.trim();
    final password = _employeePasswordController.text;

    try {
      final api = TechFixApi(
        baseUrl: baseUrl,
        email: email,
        password: password,
      );
      final employee = await api.authenticateEmployee();

      session.updateCredentials(
        baseUrl: baseUrl,
        email: email,
        password: password,
      );
      session.setEmployee(employee);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Submit customer authentication
  Future<void> _submitCustomer() async {
    if (!_customerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final session = AppSessionScope.of(context);
    final baseUrl = _baseUrlController.text.trim();
    final email = _customerEmailController.text.trim();

    try {
      final api = TechFixApi(baseUrl: baseUrl, email: email, password: '');

      // Authenticate customer
      await api.authenticateCustomer(email);

      // Load customer's own data
      final customerData = await api.getCustomerMe();

      session.updateCredentials(baseUrl: baseUrl, email: email, password: '');

      // Store customer data (mark as customer type)
      final customer = {...customerData, 'role': 'Customer'};
      session.setEmployee(customer);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in to TechFix',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Auth mode selector
                    SegmentedButton<AuthMode>(
                      segments: const [
                        ButtonSegment(
                          value: AuthMode.employee,
                          label: Text('Employee'),
                        ),
                        ButtonSegment(
                          value: AuthMode.customer,
                          label: Text('Customer'),
                        ),
                      ],
                      selected: {_authMode},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _authMode = newSelection.first;
                          _errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Base URL field (common to both)
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API Base URL',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Employee login form
                    if (_authMode == AuthMode.employee) ...[
                      Text(
                        'Manager/Owner credentials also work here.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: _employeeFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _employeeEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _employeePasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Customer login form
                    if (_authMode == AuthMode.customer) ...[
                      Text(
                        'Enter your email address to access your repair status.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: _customerFormKey,
                        child: TextFormField(
                          controller: _customerEmailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : (_authMode == AuthMode.employee
                                  ? _submitEmployee
                                  : _submitCustomer),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _authMode == AuthMode.employee
                                    ? 'Sign in as Employee'
                                    : 'Sign in as Customer',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
