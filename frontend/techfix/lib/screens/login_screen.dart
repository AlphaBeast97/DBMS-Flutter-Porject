import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techfix/config/api_config.dart';
import 'package:techfix/screens/home_shell.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/widgets/app_background.dart';

enum AuthMode { owner, employee, customer }
enum OwnerMode { signIn, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ownerSignInFormKey = GlobalKey<FormState>();
  final _ownerSignUpFormKey = GlobalKey<FormState>();
  final _employeeFormKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();

  late final TextEditingController _baseUrlController;
  final _ownerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerSignUpEmailController = TextEditingController();
  final _ownerSignUpPasswordController = TextEditingController();
  final _employeeEmailController = TextEditingController();
  final _employeePasswordController = TextEditingController();
  final _customerEmailController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  AuthMode _authMode = AuthMode.owner;
  OwnerMode _ownerMode = OwnerMode.signIn;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: _defaultBaseUrl());
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    _orgNameController.dispose();
    _ownerNameController.dispose();
    _ownerSignUpEmailController.dispose();
    _ownerSignUpPasswordController.dispose();
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

  void _switchAuthMode(AuthMode mode) {
    setState(() {
      _authMode = mode;
      _errorMessage = null;
    });
  }

  void _switchOwnerMode(OwnerMode mode) {
    setState(() {
      _ownerMode = mode;
      _errorMessage = null;
    });
  }

  Future<void> _authenticateAndGo(String email, String password) async {
    final session = AppSessionScope.of(context);
    final baseUrl = _baseUrlController.text.trim();

    final api = TechFixApi(baseUrl: baseUrl, email: email, password: password);
    final employee = await api.authenticateEmployee();

    session.updateCredentials(baseUrl: baseUrl, email: email, password: password);
    session.setEmployee(employee);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _submitOwnerSignIn() async {
    if (!_ownerSignInFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authenticateAndGo(
        _ownerEmailController.text.trim(),
        _ownerPasswordController.text,
      );
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitOwnerSignUp() async {
    if (!_ownerSignUpFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final baseUrl = _baseUrlController.text.trim();
    final orgName = _orgNameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final email = _ownerSignUpEmailController.text.trim();
    final password = _ownerSignUpPasswordController.text;

    try {
      final api = TechFixApi(baseUrl: baseUrl, email: email, password: password);
      await api.createOwner(
        organizationName: orgName,
        ownerName: ownerName,
        ownerEmail: email,
        password: password,
      );

      await _authenticateAndGo(email, password);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitEmployee() async {
    if (!_employeeFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authenticateAndGo(
        _employeeEmailController.text.trim(),
        _employeePasswordController.text,
      );
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitCustomer() async {
    if (!_customerFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final session = AppSessionScope.of(context);
    final baseUrl = _baseUrlController.text.trim();
    final email = _customerEmailController.text.trim();

    try {
      final api = TechFixApi(baseUrl: baseUrl, email: email, password: '');
      await api.authenticateCustomer(email);
      final customerData = await api.getCustomerMe();

      session.updateCredentials(baseUrl: baseUrl, email: email, password: '');
      final customer = {...customerData, 'role': 'Customer'};
      session.setEmployee(customer);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                      'TechFix',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Repair Workflow Manager',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Auth mode selector — 3 tabs
                    SegmentedButton<AuthMode>(
                      segments: const [
                        ButtonSegment(value: AuthMode.owner, label: Text('Owner')),
                        ButtonSegment(value: AuthMode.employee, label: Text('Employee')),
                        ButtonSegment(value: AuthMode.customer, label: Text('Customer')),
                      ],
                      selected: {_authMode},
                      onSelectionChanged: (s) => _switchAuthMode(s.first),
                    ),
                    const SizedBox(height: 20),

                    // Base URL field (common to all)
                    TextFormField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(labelText: 'API Base URL'),
                    ),
                    const SizedBox(height: 16),

                    // ========== OWNER TAB ==========
                    if (_authMode == AuthMode.owner) ...[
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<OwnerMode>(
                              segments: const [
                                ButtonSegment(value: OwnerMode.signIn, label: Text('Sign In')),
                                ButtonSegment(value: OwnerMode.signUp, label: Text('Sign Up')),
                              ],
                              selected: {_ownerMode},
                              onSelectionChanged: (s) => _switchOwnerMode(s.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_ownerMode == OwnerMode.signIn) ...[
                        Form(
                          key: _ownerSignInFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _ownerEmailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ownerPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: 'Password'),
                                validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitOwnerSignIn,
                            child: _isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Sign in as Owner'),
                          ),
                        ),
                      ],

                      if (_ownerMode == OwnerMode.signUp) ...[
                        Form(
                          key: _ownerSignUpFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _orgNameController,
                                decoration: const InputDecoration(labelText: 'Shop Name'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Shop name is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ownerNameController,
                                decoration: const InputDecoration(labelText: 'Your Name'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ownerSignUpEmailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ownerSignUpPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: 'Password'),
                                validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Creates a new organization and owner account.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitOwnerSignUp,
                            child: _isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Create Shop & Sign In'),
                          ),
                        ),
                      ],
                    ],

                    // ========== EMPLOYEE TAB ==========
                    if (_authMode == AuthMode.employee) ...[
                      Form(
                        key: _employeeFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _employeeEmailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _employeePasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password'),
                              validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitEmployee,
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Sign in as Employee'),
                        ),
                      ),
                    ],

                    // ========== CUSTOMER TAB ==========
                    if (_authMode == AuthMode.customer) ...[
                      Text(
                        'Enter your email to check your repair status.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: _customerFormKey,
                        child: TextFormField(
                          controller: _customerEmailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitCustomer,
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Check Status'),
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
