import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/utils/theme.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsPage({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, bool> _notifications = {
    'harvest': true,
    'activities': true,
    'weather': false,
  };

  String _language = 'English';
  bool _showLanguageModal = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ms', 'name': 'Bahasa Malaysia'},
    {'code': 'zh', 'name': '中文 (Chinese)'},
    {'code': 'ta', 'name': 'தமிழ் (Tamil)'},
  ];

  void _handleLanguageSelect(String language) {
    setState(() {
      _language = language;
      _showLanguageModal = false;
    });
  }

  void _toggleNotification(String key) {
    setState(() {
      _notifications[key] = !_notifications[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLanguageModal) {
      return Scaffold(
        backgroundColor: AgriKeepTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Select Language',
                onBack: () => setState(() => _showLanguageModal = false),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: _languages.map((lang) {
                    return CustomCard(
                      onTap: () => _handleLanguageSelect(lang['name']!),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          if (_language == lang['name'])
                            Icon(
                              Icons.check,
                              size: 20,
                              color: AgriKeepTheme.primaryColor,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Settings',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notifications Section
                    Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      child: Column(
                        children: [
                          _buildNotificationSetting(
                            icon: Icons.notifications,
                            title: 'Harvest Reminders',
                            description: 'Get notified when crops are ready',
                            value: _notifications['harvest']!,
                            onChanged: () => _toggleNotification('harvest'),
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationSetting(
                            icon: Icons.notifications,
                            title: 'Activity Reminders',
                            description: 'Weekly activity logging reminders',
                            value: _notifications['activities']!,
                            onChanged: () => _toggleNotification('activities'),
                          ),
                          const SizedBox(height: 16),
                          _buildNotificationSetting(
                            icon: Icons.notifications,
                            title: 'Weather Alerts',
                            description: 'Important weather updates',
                            value: _notifications['weather']!,
                            onChanged: () => _toggleNotification('weather'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Language Section
                    Text(
                      'LANGUAGE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      onTap: () => setState(() => _showLanguageModal = true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 20,
                                color: AgriKeepTheme.textPrimary,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'App Language',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AgriKeepTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _language,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AgriKeepTheme.textSecondary,
                                    ),
                                  ),
                                ],
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
                    const SizedBox(height: 24),

                    // Support Section
                    Text(
                      'SUPPORT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        CustomCard(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Help & FAQ'),
                                content: const Text('Help & FAQ section is under development.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    size: 20,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Help & FAQ',
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
                        CustomCard(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Privacy Policy'),
                                content: const Text('Privacy Policy is under development.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 20,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Privacy Policy',
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
                      ],
                    ),
                    const SizedBox(height: 40),

                    // App Info
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Seed 2 Harvest v1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© 2024 All rights reserved',
                            style: TextStyle(
                              fontSize: 12,
                              color: AgriKeepTheme.textTertiary,
                            ),
                          ),
                        ],
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

  Widget _buildNotificationSetting({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AgriKeepTheme.textPrimary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AgriKeepTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AgriKeepTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: (newValue) => onChanged(),
          activeColor: AgriKeepTheme.primaryColor,
        ),
      ],
    );
  }
}