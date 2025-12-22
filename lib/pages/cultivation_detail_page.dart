import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/timeline.dart';
import 'package:agrikeep/utils/theme.dart';

class CultivationDetailPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAddActivity;
  final VoidCallback onHarvest;

  const CultivationDetailPage({
    super.key,
    required this.onBack,
    required this.onAddActivity,
    required this.onHarvest,
  });

  @override
  Widget build(BuildContext context) {
    final cropData = _CropDetail(
      name: 'Rice',
      plantingDate: DateTime(2024, 1, 15),
      expectedHarvest: DateTime(2024, 5, 15),
      daysElapsed: 45,
      totalDays: 120,
      status: 'Growing',
    );

    final activities = [
      TimelineItem(
        date: '2024-02-28',
        title: 'Fertilizer Applied',
        description: 'NPK fertilizer - 50kg applied to field',
        completed: true,
      ),
      TimelineItem(
        date: '2024-02-20',
        title: 'Pest Control',
        description: 'Sprayed organic pesticide for leaf hoppers',
        completed: true,
      ),
      TimelineItem(
        date: '2024-02-10',
        title: 'Watering',
        description: 'Maintained 2-3 inches water level',
        completed: true,
      ),
      TimelineItem(
        date: '2024-01-15',
        title: 'Planting',
        description: 'Planted rice seedlings in 2 hectares',
        completed: true,
      ),
    ];

    final progress = (cropData.daysElapsed / cropData.totalDays) * 100;

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Cultivation Details',
              onBack: onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Crop header card
                    CustomCard(
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
                                    cropData.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AgriKeepTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Planted on ${DateFormat('MM/dd/yyyy').format(cropData.plantingDate)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AgriKeepTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  cropData.status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Progress bar
                          Text(
                            'Growth Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: AgriKeepTheme.borderColor,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AgriKeepTheme.primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Day ${cropData.daysElapsed} of ${cropData.totalDays}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AgriKeepTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Expected harvest
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AgriKeepTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expected harvest: ${DateFormat('MM/dd/yyyy').format(cropData.expectedHarvest)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AgriKeepTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick stats
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
                        _buildQuickStat(
                          icon: Icons.water_drop,
                          label: 'Water',
                          value: 'Regular',
                          color: AgriKeepTheme.infoColor,
                        ),
                        _buildQuickStat(
                          icon: Icons.agriculture,
                          label: 'Fertilizer',
                          value: '3 times',
                          color: AgriKeepTheme.secondaryColor,
                        ),
                        _buildQuickStat(
                          icon: Icons.warning,
                          label: 'Issues',
                          value: 'None',
                          color: AgriKeepTheme.successColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Activity timeline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activity Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: onAddActivity,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: AgriKeepTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      child: Timeline(items: activities),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Column(
                      children: [
                        CustomButton(
                          text: 'Log Weekly Activity',
                          onPressed: onAddActivity,
                          variant: ButtonVariant.secondary,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Record Harvest',
                          onPressed: onHarvest,
                          variant: ButtonVariant.primary,
                          fullWidth: true,
                        ),
                      ],
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

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropDetail {
  final String name;
  final DateTime plantingDate;
  final DateTime expectedHarvest;
  final int daysElapsed;
  final int totalDays;
  final String status;

  _CropDetail({
    required this.name,
    required this.plantingDate,
    required this.expectedHarvest,
    required this.daysElapsed,
    required this.totalDays,
    required this.status,
  });
}