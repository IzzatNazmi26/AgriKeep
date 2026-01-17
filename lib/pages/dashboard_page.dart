import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/models/cultivation.dart';
import 'package:agrikeep/models/sales_record.dart';
import 'package:agrikeep/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';

class DashboardPage extends StatefulWidget {
  final Function(String) onNavigate;
  final VoidCallback onLogout;

  const DashboardPage({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Cultivation> _cultivations = [];
  List<SalesRecord> _salesRecords = [];
  int _activeCount = 0;
  double _totalRevenue = 0.0;
  String _farmName = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load cultivations
      final cultivations = await _firebaseService.getCultivations();
      final activeCultivations = await _firebaseService.getActiveCultivations();

      // Load sales records
      final salesRecords = await _firebaseService.getSalesRecords();

      // Load farm profile for real farm name
      final farmProfile = await _firebaseService.getFarmProfile();

      // Calculate total revenue
      double totalRevenue = 0.0;
      for (var record in salesRecords) {
        totalRevenue += record.totalAmount;
      }

      setState(() {
        _cultivations = cultivations;
        _salesRecords = salesRecords;
        _activeCount = activeCultivations.length;
        _totalRevenue = totalRevenue;
        _farmName = farmProfile?.farmName ?? 'Your Farm';
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.currentUser?.username ?? 'Farmer';

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with profile button
            AppHeader(
              title: 'Dashboard',
              action: IconButton(
                onPressed: () => widget.onNavigate('profile'),
                icon: const Icon(Icons.person_outline),
                color: AgriKeepTheme.textPrimary,
                splashRadius: 20,
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome section
                      _buildWelcomeSection(username),
                      const SizedBox(height: 24),

                      // Quick stats
                      _buildQuickStats(),
                      const SizedBox(height: 24),

                      // Current crops
                      _buildCurrentCrops(),
                      const SizedBox(height: 24),

                      // Features menu
                      _buildFeaturesMenu(),
                      const SizedBox(height: 24),

                      // Profile quick access (KEEP THIS!)
                      _buildProfileQuickAccess(),
                      const SizedBox(height: 16),

                      // Logout button at bottom
                      _buildLogoutButton(),
                      const SizedBox(height: 16),
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

  Widget _buildWelcomeSection(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $username! 🌱',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AgriKeepTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Text(
        //   _farmName,
        //   style: TextStyle(
        //     fontSize: 16,
        //     color: AgriKeepTheme.textSecondary,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildQuickStats() {
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
          value: _activeCount.toString(),
          color: AgriKeepTheme.primaryColor,
          isLoading: _isLoading,
        ),
        StatCard(
          icon: Icons.list_alt,
          label: 'Activities',
          value: _cultivations.length.toString(),
          color: AgriKeepTheme.secondaryColor,
          isLoading: _isLoading,
        ),
        StatCard(
          icon: Icons.attach_money,
          label: 'Revenue',
          value: _isLoading ? '...' : 'RM${_totalRevenue.toStringAsFixed(0)}',
          color: AgriKeepTheme.infoColor,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildCurrentCrops() {
    if (_isLoading) {
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
              CircularProgressIndicator(
                color: AgriKeepTheme.primaryColor,
                strokeWidth: 2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AgriKeepTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_cultivations.isEmpty) {
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
                onPressed: () => widget.onNavigate('cultivation'),
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
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: 48,
                    color: AgriKeepTheme.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Active Crops',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AgriKeepTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first cultivation to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: AgriKeepTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Add Cultivation',
                    onPressed: () => widget.onNavigate('add-cultivation'),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final activeCrops = _cultivations
        .where((c) => ['Planted', 'Growing', 'Flowering'].contains(c.status))
        .take(3)
        .toList();

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
              onPressed: () => widget.onNavigate('cultivation'),
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
          children: activeCrops.map((cultivation) {
            final daysLeft = cultivation.expectedHarvestDate
                .difference(DateTime.now()).inDays;

            return CustomCard(
              onTap: () {
                widget.onNavigate('cultivation-detail/${cultivation.id}');
              },
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
                            cultivation.cropName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cultivation.status,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: daysLeft < 0
                              ? Colors.red.withOpacity(0.1)
                              : AgriKeepTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          daysLeft < 0 ? 'Overdue' : '$daysLeft days left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: daysLeft < 0
                                ? Colors.red
                                : AgriKeepTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: cultivation.progressPercentage / 100,
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
        title: 'Cultivation Activities',
        description: 'Track farming activities',
        color: AgriKeepTheme.secondaryColor,
      ),
      _MenuItem(
        id: 'salesrecords',
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
        color: const Color(0xFF8B5CF6),
      ),
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
              onTap: () => widget.onNavigate(item.id),
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
      onTap: () => widget.onNavigate('profile'),
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
                  'Manage your profile',
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

  Widget _buildLogoutButton() {
    return CustomCard(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
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
                Icons.logout,
                size: 20,
                color: AgriKeepTheme.errorColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AgriKeepTheme.errorColor,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: AgriKeepTheme.errorColor,
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

// StatCard and CustomButton classes remain the same as before

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AgriKeepTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgriKeepTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          isLoading
              ? CircularProgressIndicator(
            color: color,
            strokeWidth: 2,
          )
              : Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AgriKeepTheme.textPrimary,
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

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == ButtonVariant.primary
            ? AgriKeepTheme.primaryColor
            : Colors.transparent,
        foregroundColor: variant == ButtonVariant.primary
            ? Colors.white
            : AgriKeepTheme.primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: size == ButtonSize.large ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: variant == ButtonVariant.outline
              ? BorderSide(color: AgriKeepTheme.primaryColor)
              : BorderSide.none,
        ),
      ),
      child: isLoading
          ? CircularProgressIndicator(
        color: variant == ButtonVariant.primary
            ? Colors.white
            : AgriKeepTheme.primaryColor,
        strokeWidth: 2,
      )
          : Text(text),
    );
  }
}

enum ButtonVariant { primary, outline }
enum ButtonSize { small, medium, large }