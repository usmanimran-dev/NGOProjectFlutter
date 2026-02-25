import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_event.dart';
import 'package:demo/presentation/features/auth/bloc/auth_state.dart';
import 'package:demo/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginRole { admin, staff, vendor }

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  LoginRole _selectedRole = LoginRole.admin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Premium Gradient Background ──
          Container(decoration: AppTheme.premiumGradient()),
          
          // ── Decorative Circles ──
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.05),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: AppTheme.accentBlue.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: BlocListener<AuthBloc, AuthState>(
                    listener: _handleAuthState,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Brand Identity ──
                          _buildBrandHeader(theme),
                          const SizedBox(height: 40),

                          // ── Role Selector ──
                          _buildRoleSelector(theme),
                          const SizedBox(height: 24),

                          // ── Glassmorphism Login Card ──
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: AppTheme.glassDecoration(opacity: 0.7),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getRoleIcon(_selectedRole),
                                            color: _getRoleColor(_selectedRole),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${_getRoleName(_selectedRole)} Login',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Please enter your ${_selectedRole.name.toLowerCase()} credentials',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 32),
                                      
                                      // Email Field
                                      _buildTextField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        icon: Icons.alternate_email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                                      ),
                                      const SizedBox(height: 20),

                                      // Password Field
                                      _buildTextField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        icon: Icons.lock_outline_rounded,
                                        isPassword: true,
                                        obscureText: _obscurePassword,
                                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                        validator: (v) => (v == null || v.length < 4) ? 'Enter password' : null,
                                      ),
                                      const SizedBox(height: 32),

                                      // Submit Button
                                      _buildSubmitButton(theme),
                                      
                                      const SizedBox(height: 24),
                                      _buildFooterInfo(theme),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          _buildSystemVersion(theme),
                        ],
                      ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.volunteer_activism_rounded,
            size: 40,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'NGO COMPASSION',
          style: theme.textTheme.headlineMedium?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: AppTheme.deepGreen,
          ),
        ),
        Text(
          'EMPOWERING COMMUNITIES',
          style: theme.textTheme.bodySmall?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
              onPressed: onTogglePassword,
            ) 
          : null,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.deepGreen.withOpacity(0.8)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ACCESS PORTAL'),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFooterInfo(ThemeData theme) {
    return Text(
      'Authorized Personnel Only. All actions are audited for security purposes.',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
    );
  }

  Widget _buildSystemVersion(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield_rounded, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          'ENCRYPTED CONNECTION v2.0',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoleButton(LoginRole.admin, 'ADMIN', Icons.admin_panel_settings_rounded),
        const SizedBox(width: 12),
        _buildRoleButton(LoginRole.staff, 'STAFF', Icons.badge_rounded),
        const SizedBox(width: 12),
        _buildRoleButton(LoginRole.vendor, 'VENDOR', Icons.storefront_rounded),
      ],
    );
  }

  Widget _buildRoleButton(LoginRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    final color = _getRoleColor(role);

    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)] : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppTheme.textSecondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isSelected ? color : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleName(LoginRole role) {
    switch (role) {
      case LoginRole.admin: return 'Admin';
      case LoginRole.staff: return 'Staff';
      case LoginRole.vendor: return 'Vendor';
    }
  }

  IconData _getRoleIcon(LoginRole role) {
    switch (role) {
      case LoginRole.admin: return Icons.admin_panel_settings_rounded;
      case LoginRole.staff: return Icons.badge_rounded;
      case LoginRole.vendor: return Icons.storefront_rounded;
    }
  }

  Color _getRoleColor(LoginRole role) {
    switch (role) {
      case LoginRole.admin: return AppTheme.accentBlue;
      case LoginRole.staff: return AppTheme.primaryGreen;
      case LoginRole.vendor: return Colors.teal;
    }
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthError) {
      _showErrorDialog(context, state.message);
    }
  }

  void _showErrorDialog(BuildContext context, String rawMessage) {
    // Parse the backend message into user-friendly text
    String title;
    String message;
    IconData icon;
    Color color;

    final msg = rawMessage.toLowerCase();
    if (msg.contains('invalid credentials') || msg.contains('invalid email') || msg.contains('wrong password')) {
      title = 'Login Failed';
      message = 'Incorrect email or password. Please double-check your credentials and try again.';
      icon = Icons.lock_rounded;
      color = Colors.redAccent;
    } else if (msg.contains('inactive') || msg.contains('suspended')) {
      title = 'Account Disabled';
      message = 'Your account has been deactivated. Please contact your system administrator for assistance.';
      icon = Icons.person_off_rounded;
      color = Colors.orange;
    } else if (msg.contains('email is required') || msg.contains('invalid email format')) {
      title = 'Invalid Email';
      message = 'Please enter a valid email address.';
      icon = Icons.email_rounded;
      color = Colors.orange;
    } else if (msg.contains('password is required') || msg.contains('password too short')) {
      title = 'Invalid Password';
      message = 'Please enter a valid password (minimum 4 characters).';
      icon = Icons.password_rounded;
      color = Colors.orange;
    } else if (msg.contains('server error') || msg.contains('500')) {
      title = 'Server Error';
      message = 'The server encountered an issue. Please try again in a few moments.';
      icon = Icons.dns_rounded;
      color = Colors.redAccent;
    } else if (msg.contains('connection') || msg.contains('network') || msg.contains('timeout')) {
      title = 'Connection Error';
      message = 'Unable to reach the server. Please check your internet connection and try again.';
      icon = Icons.wifi_off_rounded;
      color = Colors.grey;
    } else {
      title = 'Login Failed';
      message = rawMessage;
      icon = Icons.error_outline_rounded;
      color = Colors.redAccent;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 20),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary, height: 1.5,
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
