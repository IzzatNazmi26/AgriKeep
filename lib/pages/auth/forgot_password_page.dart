import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordPage({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: AgriKeepTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _buildSuccessScreen();
    }

    return _buildResetForm();
  }

  Widget _buildResetForm() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                'Reset Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AgriKeepTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send you instructions to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AgriKeepTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Email input
              InputField(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'your.email@example.com',
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              CustomButton(
                text: 'Send Reset Link',
                onPressed: _handleSubmit,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
                loading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Back to login
              TextButton(
                onPressed: widget.onBackToLogin,
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: AgriKeepTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline,
                  size: 40,
                  color: AgriKeepTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AgriKeepTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent password reset instructions to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AgriKeepTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AgriKeepTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Back to Login',
                onPressed: widget.onBackToLogin,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  setState(() => _submitted = false);
                },
                child: Text(
                  'Didn\'t receive email? Try again',
                  style: TextStyle(
                    color: AgriKeepTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}