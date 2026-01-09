import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/utils/theme.dart';

class DashboardPage extends StatelessWidget {
  final Function(String) onNavigate;

  const DashboardPage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with settings button
            AppHeader(
              title: 'Dashboard',
              action: IconButton(
                onPressed: () => onNavigate('settings'),
                icon: const Icon(Icons.settings_outlined),
                color: AgriKeepTheme.textPrimary,
                splashRadius: 20,
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),

                    // Quick stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // Current crops
                    _buildCurrentCrops(),
                    const SizedBox(height: 24),

                    // // Upcoming tasks
                    // _buildUpcomingTasks(),
                    // const SizedBox(height: 24),

                    // Features menu
                    _buildFeaturesMenu(),
                    const SizedBox(height: 24),

                    // Profile quick access
                    _buildProfileQuickAccess(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back! 🌱',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AgriKeepTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          MockData.mockFarmProfile.farmName,
          style: TextStyle(
            fontSize: 16,
            color: AgriKeepTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final totalYield = MockData.mockYields
        .fold(0.0, (sum, record) => sum + record.quantity);
    final totalRevenue = MockData.mockSales
        .fold(0.0, (sum, record) => sum + record.totalAmount);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      children: [
        StatCard(
          icon: Icons.eco,
          label: 'Active Crops',
          value: '3',
          color: AgriKeepTheme.primaryColor,
        ),
        StatCard(
          icon: Icons.list_alt,
          label: 'Activities',
          value: '12',
          color: AgriKeepTheme.secondaryColor,
        ),
        StatCard(
          icon: Icons.attach_money,
          label: 'Revenue',
          value: 'RM${totalRevenue.toInt()}',
          color: AgriKeepTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildCurrentCrops() {
    final List<Map<String, dynamic>> crops = [
      {'name': 'Cherry Tomato', 'status': 'Growing', 'progress': 65, 'daysLeft': 45},
      {'name': 'Cucumber', 'status': 'Growing', 'progress': 80, 'daysLeft': 10},
      {'name': 'Capsicum', 'status': 'Flowering', 'progress': 40, 'daysLeft': 90},
    ];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Crops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AgriKeepTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => onNavigate('cultivation'),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AgriKeepTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: crops.map((crop) {
            return CustomCard(
              onTap: () => onNavigate('cultivation-detail'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            crop['status'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${crop['daysLeft']} days left',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AgriKeepTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (crop['progress'] as int) / 100,
                    backgroundColor: AgriKeepTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AgriKeepTheme.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget _buildUpcomingTasks() {
  //   final tasks = [
  //     TaskCard(
  //       title: 'Fertilize Rice Crop',
  //       description: 'Apply NPK fertilizer to rice field',
  //       dueDate: 'Tomorrow',
  //       priority: TaskPriority.high,
  //       //onTap: () => onNavigate('cultivation-detail'),
  //     ),
  //     TaskCard(
  //       title: 'Update Weekly Activity',
  //       description: 'Log this week\'s farming activities',
  //       dueDate: 'In 2 days',
  //       priority: TaskPriority.medium,
  //       //onTap: () => onNavigate('weekly-activity'),
  //     ),
  //     TaskCard(
  //       title: 'Wheat Harvest Ready',
  //       description: 'Wheat crop ready for harvest soon',
  //       dueDate: 'In 45 days',
  //       priority: TaskPriority.low,
  //       //onTap: () => onNavigate('harvest-entry'),
  //     ),
  //   ];
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Upcoming Tasks',
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //           color: AgriKeepTheme.textPrimary,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       Column(
  //         children: tasks,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildFeaturesMenu() {
    final menuItems = [
      _MenuItem(
        id: 'recommendations',
        icon: Icons.auto_awesome,
        title: 'Crop Recommendations',
        description: 'Get personalized crop suggestions',
        color: AgriKeepTheme.primaryColor,
      ),
      _MenuItem(
        id: 'cultivation',
        icon: Icons.list_alt,
        title: 'Cultivation Log',
        description: 'Track farming activities',
        color: AgriKeepTheme.secondaryColor,
      ),
      _MenuItem(
        id: 'sales',
        icon: Icons.attach_money,
        title: 'Sales Record',
        description: 'Manage crop sales and revenue',
        color: AgriKeepTheme.infoColor,
      ),
      _MenuItem(
        id: 'crop-info',
        icon: Icons.menu_book,
        title: 'Crop Information',
        description: 'Learn about different crops',
        color: const Color(0xFF8B5CF6), // purple
      ),
      // _MenuItem(
      //   id: 'analytics',
      //   icon: Icons.insights,
      //   title: 'Record & Analysis',
      //   description: 'View insights and trends',
      //   color: const Color(0xFF10B981), // emerald
      // ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AgriKeepTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: menuItems.map((item) {
            return CustomCard(
              onTap: () => onNavigate(item.id),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      size: 24,
                      color: item.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AgriKeepTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AgriKeepTheme.textTertiary,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileQuickAccess() {
    return CustomCard(
      onTap: () => onNavigate('profile'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AgriKeepTheme.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AgriKeepTheme.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View Profile',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AgriKeepTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your farm details',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AgriKeepTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _MenuItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}