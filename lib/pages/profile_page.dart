import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onBack;
  final Function(String)? onNavigate; // Removed onLogout

  const ProfilePage({
    super.key,
    required this.onBack,
    this.onNavigate, // Removed required this.onLogout
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Profile',
              onBack: onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // User profile card
                    CustomCard(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: AgriKeepTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.username ?? 'Loading...', // Changed from fullName to username
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User details card
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.person,
                            label: 'Username',
                            value: user?.username ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Country',
                            value: user?.country ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.location_city,
                            label: 'State',
                            value: user?.state ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: user?.phoneNumber ?? 'Not set',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Column(
                      children: [
                        CustomCard(
                          onTap: () => onNavigate?.call('profile-edit'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 20,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AgriKeepTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // App version
                    Text(
                      'AgriKeep v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AgriKeepTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AgriKeepTheme.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AgriKeepTheme.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AgriKeepTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}