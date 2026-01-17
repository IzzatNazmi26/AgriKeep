import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback onBack;

  const EditProfilePage({
    super.key,
    required this.onBack,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _stateController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email ?? '';
      _stateController.text = user.state ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    setState(() => _isLoading = true);

    try {
      await authProvider.updateUserProfile(
        username: _usernameController.text.trim(),
        state: _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : null,
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back after successful update
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onBack();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AgriKeepTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Edit Profile',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AgriKeepTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update your profile information',
                        style: TextStyle(
                          fontSize: 14,
                          color: AgriKeepTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email field (display only, not editable)
                      InputField(
                        label: 'Email',
                        controller: _emailController,
                        hintText: 'Enter your email',
                        enabled: false, // Make it non-editable
                        validator: (value) {
                          // Email is required but not editable
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Username field
                      InputField(
                        label: 'Username',
                        controller: _usernameController,
                        hintText: 'Enter your username',
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
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

                      // State field (optional)
                      InputField(
                        label: 'State/Region',
                        controller: _stateController,
                        hintText: 'Enter your state or region',
                        validator: (value) {
                          // State is optional
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone field (optional)
                      InputField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          // Phone is optional
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      CustomButton(
                        text: 'Save Changes',
                        onPressed: _saveProfile,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        fullWidth: true,
                        loading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}