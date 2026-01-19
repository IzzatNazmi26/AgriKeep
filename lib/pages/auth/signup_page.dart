import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';

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
  final _phoneController = TextEditingController(); // ADDED
  final _stateController = TextEditingController(); // CHANGED from country

  bool _isLoading = false;
  bool _passwordsVisible = false;

  // CHANGED: Malaysian states instead of countries
  final List<String> _stateOptions = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Kuala Lumpur',
    'Labuan',
    'Putrajaya',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose(); // ADDED
    _stateController.dispose(); // CHANGED
    super.dispose();
  }

  // Malaysian phone number validation
  bool _isValidMalaysianPhone(String phone) {
    // Remove any spaces, dashes, or plus signs
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-+]'), '');

    // Check if it starts with 01 and has 10-11 digits total
    if (!cleanedPhone.startsWith('01')) return false;

    // Check length: 01 followed by 8-9 digits = 10-11 total
    if (cleanedPhone.length < 10 || cleanedPhone.length > 11) return false;

    // Check if all characters are digits
    return RegExp(r'^[0-9]+$').hasMatch(cleanedPhone);
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

    await authProvider.signUpWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _usernameController.text.trim(),
      _stateController.text.trim(),
      _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    // Check for provider error
    if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AgriKeepTheme.errorColor,
        ),
      );
      return;
    }

    // If signup successful, proceed to next step
    widget.onSignUp();
    print('✅ User created with ID: ${authProvider.firebaseUser?.uid}');
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
                    // Username field
                    // In signup_page.dart, update the Username field in the Form:
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
                        // Check for special characters
                        final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
                        if (!validCharacters.hasMatch(value)) {
                          return 'Only letters, numbers, and underscores allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
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
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ADDED: Phone number field
                    InputField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      hintText: '01XXXXXXXX (10-11 digits)',
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }

                        // Clean the phone number for validation
                        final cleanedPhone = value.replaceAll(RegExp(r'[\s\-+]'), '');

                        // Check if it starts with 01
                        if (!cleanedPhone.startsWith('01')) {
                          return 'Malaysian phone must start with 01';
                        }

                        // Check length
                        if (cleanedPhone.length < 10 || cleanedPhone.length > 11) {
                          return 'Phone must be 10-11 digits (including 01)';
                        }

                        // Check if all digits
                        if (!RegExp(r'^[0-9]+$').hasMatch(cleanedPhone)) {
                          return 'Phone must contain only numbers';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
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

                    // Confirm Password field
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

                    // CHANGED: State field instead of country
                    InputField(
                      label: 'State',
                      controller: _stateController,
                      hintText: 'Select your state',
                      options: _stateOptions,
                      selectedOption: _stateController.text.isNotEmpty ? _stateController.text : null,
                      onOptionSelected: (value) => setState(() => _stateController.text = value ?? ''),
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your state';
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