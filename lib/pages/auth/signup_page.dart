import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';


class SignUpPage extends StatefulWidget {
  final VoidCallback onSignUp;
  final VoidCallback onBackToLogin;

  const SignUpPage({
    super.key,
    required this.onSignUp,
    required this.onBackToLogin,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  bool _passwordsVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AgriKeepTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    setState(() => _isLoading = true);

    // 1️⃣ Create Firebase Auth account
    await authProvider.signUpWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
      authProvider.clearError();
      return;
    }

    // 2️⃣ Save extra user data to Firestore
    final user = authProvider.user;
    if (user != null) {
      final username = _usernameController.text.trim().toLowerCase();


      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'username': username,
        'farmName': _farmNameController.text.trim(),
        'location': _locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

    }
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
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AgriKeepTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join AgriKeep to start managing your farm',
                style: TextStyle(
                  fontSize: 16,
                  color: AgriKeepTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Sign up form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      label: 'Username',
                      controller: _usernameController,
                      hintText: 'Choose a unique username',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.contains(' ')) {
                          return 'Username cannot contain spaces';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: !_passwordsVisible,
                      hintText: 'Create a strong password',
                      required: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordsVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AgriKeepTheme.textTertiary,
                        ),
                        onPressed: () {
                          setState(() => _passwordsVisible = !_passwordsVisible);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: !_passwordsVisible,
                      hintText: 'Re-enter your password',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Farm Name',
                      controller: _farmNameController,
                      hintText: 'e.g., Green Valley Farm',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your farm name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Location',
                      controller: _locationController,
                      hintText: 'City, State/Province',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _handleSignUp,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      fullWidth: true,
                      loading: _isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AgriKeepTheme.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onBackToLogin,
                    child: Text(
                      'Sign In',
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
                'By signing up, you agree to our Terms of Service and Privacy Policy',
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