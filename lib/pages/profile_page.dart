import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/utils/theme.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final Function(String)? onNavigate;

  const ProfilePage({
    super.key,
    required this.onBack,
    required this.onLogout,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
    _MenuItem(
        icon: Icons.settings,
        label: 'Settings',
        onClick: () => onNavigate?.call('settings'),
    ),
    _MenuItem(
    icon: Icons.help_outline,
    label: 'Help & Support',
    onClick: () {
    // Show coming soon dialog
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    title: const Text('Coming Soon'),
    content: const Text('Help & Support feature is under development.'),
    actions: [
    TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('OK'),
    ),
    ],
    ),
    );
    },
    ),
    _MenuItem(
    icon: Icons.logout,
    label: 'Logout',
    onClick: onLogout,
    isDanger: true,
    ),
    ];

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
    'John Farmer',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AgriKeepTheme.textPrimary,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    'john.farmer@example.com',
    style: TextStyle(
    fontSize: 14,
    color: AgriKeepTheme.textSecondary,
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 16),

    // Farm details card
    CustomCard(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Farm Details',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AgriKeepTheme.textPrimary,
    ),
    ),
    const SizedBox(height: 16),
    _buildFarmDetailRow(
    icon: Icons.agriculture,
    label: 'Farm Name',
    value: MockData.mockFarmProfile.farmName,
    ),
    const SizedBox(height: 12),
    _buildFarmDetailRow(
    icon: Icons.location_on,
    label: 'Location',
    value: MockData.mockFarmProfile.location,
    ),
    const SizedBox(height: 12),
    _buildFarmDetailRow(
    icon: Icons.square_foot,
    label: 'Total Area',
    value: '${MockData.mockFarmProfile.totalArea} hectares',
    ),
    const SizedBox(height: 12),
    _buildFarmDetailRow(
    icon: Icons.terrain,
    label: 'Soil Type',
    value: MockData.mockFarmProfile.soilType,
    ),
    const SizedBox(height: 12),
    _buildFarmDetailRow(
    icon: Icons.water_drop,
    label: 'Irrigation',
    value: MockData.mockFarmProfile.irrigationType,
    ),
    ],
    ),
    ),
    const SizedBox(height: 16),

    // Stats summary
    GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.9,
    ),
    children: [
    _buildStatCard('3', 'Active Crops'),
    _buildStatCard('7.7t', 'Total Yield'),
    _buildStatCard('RM3.1K', 'Revenue'),
    ],
    ),
    const SizedBox(height: 24),

    // Menu items
    ...menuItems.map((item) {
    return CustomCard(
    onTap: item.onClick,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    Icon(
    item.icon,
    size: 20,
    color: item.isDanger
    ? AgriKeepTheme.errorColor
        : AgriKeepTheme.textPrimary,
    ),
    const SizedBox(width: 12),
    Text(
    item.label,
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: item.isDanger
    ? AgriKeepTheme.errorColor
        : AgriKeepTheme.textPrimary,
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
    );
    }).toList(),
    const SizedBox(height: 32),

    // App version
    Text(
    'Seed 2 Harvest v1.0.0',
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

  Widget _buildFarmDetailRow({
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

  Widget _buildStatCard(String value, String label) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AgriKeepTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onClick;
  final bool isDanger;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.onClick,
    this.isDanger = false,
  });
}