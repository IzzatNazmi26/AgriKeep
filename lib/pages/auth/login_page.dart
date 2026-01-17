import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onSignUp,
    required this.onForgotPassword,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // Changed from emailController
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    setState(() => _isLoading = true);

    await authProvider.signInWithUsernameOrEmail(
      _identifierController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
      //authProvider.clearError();
    }

    // If login successful, the auth state listener in App.dart will handle navigation.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and title
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AgriKeepTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AgriKeepTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to AgriKeep',
                style: TextStyle(
                  fontSize: 16,
                  color: AgriKeepTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Login form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      label: 'Username or Email', // Updated label
                      controller: _identifierController, // Updated controller name
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Enter your username or email',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username or email';
                        }
                        // Basic validation - at least something entered
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      hintText: 'Enter your password',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AgriKeepTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      fullWidth: true,
                      loading: _isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      color: AgriKeepTheme.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onSignUp,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AgriKeepTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Terms and privacy
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AgriKeepTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}