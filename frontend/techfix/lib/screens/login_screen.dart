import 'package:flutter/material.dart';
import 'package:techfix/config/api_config.dart';
import 'package:techfix/screens/home_shell.dart';
import 'package:techfix/services/techfix_api.dart';
import 'package:techfix/state/app_session_scope.dart';
import 'package:techfix/theme/app_theme.dart';
import 'package:techfix/widgets/app_background.dart';
import 'package:techfix/widgets/field.dart';
import 'package:techfix/widgets/toast.dart';

enum AuthMode { owner, employee, customer }
enum OwnerMode { signIn, signUp }

class Brandmark extends StatelessWidget {
  final double size;

  const Brandmark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: [AppTheme.coral, Color(0xFFE0553A)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.coral.withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.handyman, size: 28, color: Colors.white),
    );
  }
}

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
  AuthMode _authMode = AuthMode.owner;
  OwnerMode _ownerMode = OwnerMode.signIn;

  @override
  void dispose() {
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

  bool _isValidEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  void _switchAuthMode(AuthMode mode) {
    setState(() => _authMode = mode);
  }

  void _switchOwnerMode(OwnerMode mode) {
    setState(() => _ownerMode = mode);
  }

  Future<void> _authenticateAndGo(String email, String password, {String? requiredRole}) async {
    final session = AppSessionScope.of(context);
    final baseUrl = ApiConfig.baseUrl;

    final api = TechFixApi(baseUrl: baseUrl, email: email, password: password);
    final employee = await api.authenticateEmployee();

    if (requiredRole != null) {
      final role = (employee['role'] as String?)?.trim();
      if (role != requiredRole) {
        throw Exception('Access denied: not a $requiredRole account.');
      }
    }
    session.updateCredentials(baseUrl: baseUrl, email: email, password: password);
    session.setEmployee(employee);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _submitOwnerSignIn() async {
    if (!_ownerSignInFormKey.currentState!.validate()) return;
    final email = _ownerEmailController.text.trim();
    if (!_isValidEmail(email)) {
      showToast(context, 'Enter a valid email address', type: ToastType.error);
      return;
    }
    if (_ownerPasswordController.text.isEmpty) {
      showToast(context, 'Enter your password', type: ToastType.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authenticateAndGo(email, _ownerPasswordController.text, requiredRole: 'Owner');
    } catch (error) {
      showToast(context, '$error', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitOwnerSignUp() async {
    if (!_ownerSignUpFormKey.currentState!.validate()) return;
    final email = _ownerSignUpEmailController.text.trim();
    if (!_isValidEmail(email)) {
      showToast(context, 'Enter a valid email address', type: ToastType.error);
      return;
    }
    if (_ownerSignUpPasswordController.text.length < 6) {
      showToast(context, 'Password must be at least 6 characters', type: ToastType.error);
      return;
    }
    if (_orgNameController.text.trim().isEmpty) {
      showToast(context, 'Enter your organization name', type: ToastType.error);
      return;
    }
    if (_ownerNameController.text.trim().isEmpty) {
      showToast(context, 'Enter your name', type: ToastType.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final orgName = _orgNameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final password = _ownerSignUpPasswordController.text;

    try {
      final api = TechFixApi(baseUrl: ApiConfig.baseUrl, email: email, password: password);
      await api.createOwner(
        organizationName: orgName,
        ownerName: ownerName,
        ownerEmail: email,
        password: password,
      );

      await _authenticateAndGo(email, password);
    } catch (error) {
      showToast(context, '$error', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitEmployee() async {
    if (!_employeeFormKey.currentState!.validate()) return;
    final email = _employeeEmailController.text.trim();
    if (!_isValidEmail(email)) {
      showToast(context, 'Enter a valid email address', type: ToastType.error);
      return;
    }
    if (_employeePasswordController.text.isEmpty) {
      showToast(context, 'Enter your password', type: ToastType.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authenticateAndGo(email, _employeePasswordController.text);
    } catch (error) {
      showToast(context, '$error', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitCustomer() async {
    if (!_customerFormKey.currentState!.validate()) return;
    final email = _customerEmailController.text.trim();
    if (!_isValidEmail(email)) {
      showToast(context, 'Enter a valid email address', type: ToastType.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final session = AppSessionScope.of(context);

    try {
      final api = TechFixApi(baseUrl: ApiConfig.baseUrl, email: email, password: '');
      await api.authenticateCustomer(email);
      final customerData = await api.getCustomerMe();

      session.updateCredentials(baseUrl: ApiConfig.baseUrl, email: email, password: '');
      final customer = {...customerData, 'role': 'Customer'};
      session.setEmployee(customer);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (error) {
      showToast(context, '$error', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _submit() {
    switch (_authMode) {
      case AuthMode.owner:
        if (_ownerMode == OwnerMode.signIn) {
          _submitOwnerSignIn();
        } else {
          _submitOwnerSignUp();
        }
      case AuthMode.employee:
        _submitEmployee();
      case AuthMode.customer:
        _submitCustomer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 46, 22, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand header
                Column(
                  children: [
                    const Brandmark(),
                    const SizedBox(height: 16),
                    const Text(
                      'TechFix',
                      style: TextStyle(
                        
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Repair workflow, handled.',
                      style: TextStyle(
                        
                        fontSize: 14.5,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Role segmented control
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.line2),
                  ),
                  child: Row(
                    children: [
                      _SegOption(
                        icon: Icons.admin_panel_settings,
                        label: 'Owner',
                        selected: _authMode == AuthMode.owner,
                        tint: AppTheme.coral,
                        onTap: () => _switchAuthMode(AuthMode.owner),
                      ),
                      _SegOption(
                        icon: Icons.engineering,
                        label: 'Employee',
                        selected: _authMode == AuthMode.employee,
                        tint: AppTheme.teal,
                        onTap: () => _switchAuthMode(AuthMode.employee),
                      ),
                      _SegOption(
                        icon: Icons.person,
                        label: 'Customer',
                        selected: _authMode == AuthMode.customer,
                        tint: AppTheme.sky,
                        onTap: () => _switchAuthMode(AuthMode.customer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _buildCardBody(),
                  ),
                ),

                const SizedBox(height: 22),
                Text(
                  _authMode == AuthMode.customer
                      ? 'No account needed \u2014 just your email.'
                      : 'Northgate Repair Co. \u00b7 v2.4',
                  style: const TextStyle(
                    
                    fontSize: 12,
                    color: AppTheme.faint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildCardBody() {
    final roleMeta = switch (_authMode) {
      AuthMode.owner => (
        icon: Icons.admin_panel_settings,
        tint: AppTheme.coral,
        blurb: 'Full org access — manage staff, revenue & all jobs.',
      ),
      AuthMode.employee => (
        icon: Icons.engineering,
        tint: AppTheme.teal,
        blurb: 'Technician console — your jobs and parts logging.',
      ),
      AuthMode.customer => (
        icon: Icons.person,
        tint: AppTheme.sky,
        blurb: 'Track your repairs and pick-up status.',
      ),
    };

    final cta = _authMode == AuthMode.owner && _ownerMode == OwnerMode.signUp
        ? 'Create workshop'
        : 'Sign in';
    final busyIcon = _isSubmitting
        ? null
        : (_authMode == AuthMode.owner && _ownerMode == OwnerMode.signUp
            ? Icons.rocket_launch
            : Icons.login);

    return Column(
      key: ValueKey('$_authMode-$_ownerMode'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role blurb
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: roleMeta.tint.withOpacity(0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(roleMeta.icon, size: 23, color: roleMeta.tint),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                roleMeta.blurb,
                style: const TextStyle(

                  fontSize: 13,
                  color: AppTheme.muted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Owner sign in / sign up toggle
        if (_authMode == AuthMode.owner) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _ModeToggle(
                  label: 'Sign in',
                  selected: _ownerMode == OwnerMode.signIn,
                  onTap: () => _switchOwnerMode(OwnerMode.signIn),
                ),
                _ModeToggle(
                  label: 'Sign up',
                  selected: _ownerMode == OwnerMode.signUp,
                  onTap: () => _switchOwnerMode(OwnerMode.signUp),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Owner Sign In
        if (_authMode == AuthMode.owner && _ownerMode == OwnerMode.signIn)
          Form(
            key: _ownerSignInFormKey,
            child: Column(
              children: [
                Field(
                  label: 'Email',
                  value: _ownerEmailController.text,
                  onChanged: (v) => _ownerEmailController.text = v,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.mail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Field(
                  label: 'Password',
                  value: _ownerPasswordController.text,
                  onChanged: (v) => _ownerPasswordController.text = v,
                  obscureText: true,
                  icon: Icons.lock,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),

        // Owner Sign Up
        if (_authMode == AuthMode.owner && _ownerMode == OwnerMode.signUp)
          Form(
            key: _ownerSignUpFormKey,
            child: Column(
              children: [
                Field(
                  label: 'Workshop name',
                  value: _orgNameController.text,
                  onChanged: (v) => _orgNameController.text = v,
                  icon: Icons.storefront,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Field(
                  label: 'Your name',
                  value: _ownerNameController.text,
                  onChanged: (v) => _ownerNameController.text = v,
                  icon: Icons.badge,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Field(
                  label: 'Email',
                  value: _ownerSignUpEmailController.text,
                  onChanged: (v) => _ownerSignUpEmailController.text = v,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.mail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Field(
                  label: 'Password',
                  value: _ownerSignUpPasswordController.text,
                  onChanged: (v) => _ownerSignUpPasswordController.text = v,
                  obscureText: true,
                  icon: Icons.lock,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),

        // Employee Sign In
        if (_authMode == AuthMode.employee)
          Form(
            key: _employeeFormKey,
            child: Column(
              children: [
                Field(
                  label: 'Email',
                  value: _employeeEmailController.text,
                  onChanged: (v) => _employeeEmailController.text = v,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.mail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Field(
                  label: 'Password',
                  value: _employeePasswordController.text,
                  onChanged: (v) => _employeePasswordController.text = v,
                  obscureText: true,
                  icon: Icons.lock,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),

        // Customer Sign In
        if (_authMode == AuthMode.customer) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.sky.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, size: 17, color: AppTheme.sky),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enter the email on your repair ticket to see your devices.',
                    style: TextStyle(

                      fontSize: 12,
                      color: AppTheme.muted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Form(
            key: _customerFormKey,
            child: Field(
              label: 'Email',
              value: _customerEmailController.text,
              onChanged: (v) => _customerEmailController.text = v,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.mail,
              placeholder: 'Email on your ticket',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],

        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(busyIcon),
            label: Text(
              _isSubmitting ? 'Just a moment\u2026' : cta,
              style: const TextStyle(

                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: roleMeta.tint,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),

        // Signup hint for owner
        if (_authMode == AuthMode.owner &&
            _ownerMode == OwnerMode.signUp)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Creating your workshop sets up the org and signs you in automatically.',
              textAlign: TextAlign.center,
              style: const TextStyle(

                fontSize: 11.5,
                color: AppTheme.faint,
                height: 1.5,
              ),
            ),
          ),

        // Error message
      ],
    );
  }
}

class _SegOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color tint;
  final VoidCallback onTap;

  const _SegOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.tint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          decoration: BoxDecoration(
            color: selected ? tint.withOpacity(0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? tint : AppTheme.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? tint : AppTheme.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.ink : AppTheme.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
