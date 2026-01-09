import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/models/cultivation.dart';
import 'package:agrikeep/services/firebase_service.dart';

class CultivationActivitiesPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String)? onNavigate;

  const CultivationActivitiesPage({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<CultivationActivitiesPage> createState() => _CultivationActivitiesPageState();
}

class _CultivationActivitiesPageState extends State<CultivationActivitiesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Cultivation> _cultivations = [];
  bool _isLoading = true;
  int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCultivations();
  }

  Future<void> _loadCultivations() async {
    setState(() => _isLoading = true);
    try {
      final cultivations = await _firebaseService.getCultivations();
      final activeCultivations = await _firebaseService.getActiveCultivations();

      setState(() {
        _cultivations = cultivations;
        _activeCount = activeCultivations.length;
      });
    } catch (e) {
      print('Error loading cultivations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cultivations: $e'),
          backgroundColor: AgriKeepTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadCultivations();
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'Planted':
        return 'Planted';
      case 'Growing':
        return 'Growing';
      case 'Flowering':
        return 'Flowering';
      case 'Harvested':
        return 'Harvested';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Planted':
        return Colors.blue;
      case 'Growing':
        return Colors.green;
      case 'Flowering':
        return Colors.purple;
      case 'Harvested':
        return Colors.orange;
      default:
        return AgriKeepTheme.textSecondary;
    }
  }

  String _getLastActivityText(Cultivation cultivation) {
    final daysSinceUpdate = DateTime.now().difference(cultivation.updatedAt).inDays;

    if (daysSinceUpdate == 0) {
      return 'Updated today';
    } else if (daysSinceUpdate == 1) {
      return 'Updated yesterday';
    } else {
      return 'Updated $daysSinceUpdate days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Cultivation Log',
              onBack: widget.onBack,
              action: IconButton(
                onPressed: () {
                  if (widget.onNavigate != null) {
                    widget.onNavigate!('add-cultivation');
                  }
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AgriKeepTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Active cultivations count
                      CustomCard(
                        child: Column(
                          children: [
                            Text(
                              'Active Cultivations',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isLoading
                                ? CircularProgressIndicator(
                              color: AgriKeepTheme.primaryColor,
                            )
                                : Text(
                              _activeCount.toString(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AgriKeepTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Current crops header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Cultivations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: _refreshData,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: AgriKeepTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Refresh',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Loading indicator
                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: AgriKeepTheme.primaryColor,
                            ),
                          ),
                        ),

                      // Empty state
                      if (!_isLoading && _cultivations.isEmpty)
                        CustomCard(
                          child: Column(
                            children: [
                              Icon(
                                Icons.eco,
                                size: 48,
                                color: AgriKeepTheme.textTertiary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Cultivations Yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AgriKeepTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start by adding your first crop cultivation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AgriKeepTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Add First Cultivation',
                                onPressed: () {
                                  if (widget.onNavigate != null) {
                                    widget.onNavigate!('add-cultivation');
                                  }
                                },
                                variant: ButtonVariant.primary,
                                size: ButtonSize.medium,
                              ),
                            ],
                          ),
                        ),

                      // Current crops list
                      if (!_isLoading && _cultivations.isNotEmpty)
                        Column(
                          children: _cultivations.map((cultivation) {
                            final daysUntilHarvest = cultivation.expectedHarvestDate
                                .difference(DateTime.now()).inDays;
                            final isOverdue = daysUntilHarvest < 0;

                            return CustomCard(
                              onTap: () {
                                if (widget.onNavigate != null) {
                                  // Add the cultivation ID to the route
                                  widget.onNavigate!('cultivation-detail/${cultivation.id}');
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(cultivation.status)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.eco,
                                          size: 24,
                                          color: _getStatusColor(cultivation.status),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
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
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: AgriKeepTheme.textPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _getStatusDisplay(cultivation.status),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: _getStatusColor(cultivation.status),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isOverdue
                                                        ? Colors.red.withOpacity(0.1)
                                                        : AgriKeepTheme.primaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'Day ${cultivation.currentDay}/${cultivation.growthDurationDays}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: isOverdue
                                                          ? Colors.red
                                                          : AgriKeepTheme.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: AgriKeepTheme.textTertiary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Planted ${DateFormat('MM/dd/yyyy').format(cultivation.plantingDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AgriKeepTheme.textTertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.event,
                                                  size: 14,
                                                  color: AgriKeepTheme.textTertiary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Harvest: ${DateFormat('MM/dd/yyyy').format(cultivation.expectedHarvestDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isOverdue
                                                        ? Colors.red
                                                        : AgriKeepTheme.textTertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            LinearProgressIndicator(
                                              value: cultivation.progressPercentage / 100,
                                              backgroundColor: AgriKeepTheme.borderColor,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                _getStatusColor(cultivation.status),
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            const SizedBox(height: 8),
                                            if (cultivation.note != null && cultivation.note!.isNotEmpty)
                                              Text(
                                                'Note: ${cultivation.note}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AgriKeepTheme.textSecondary,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getLastActivityText(cultivation),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AgriKeepTheme.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),

                      // Add new cultivation button
                      CustomButton(
                        text: 'Add New Cultivation',
                        onPressed: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!('add-cultivation');
                          }
                        },
                        variant: ButtonVariant.outline,
                        fullWidth: true,
                      ),
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
}