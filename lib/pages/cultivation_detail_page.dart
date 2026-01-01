import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/timeline.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:agrikeep/models/activity.dart'; // Add this import



class CultivationDetailPage extends StatefulWidget {
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
  State<CultivationDetailPage> createState() => _CultivationDetailPageState();
}

class _CultivationDetailPageState extends State<CultivationDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  List<TimelineItem> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this page
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    print('🔍 Loading activities...');
    print('   User ID: ${_user?.uid}');
    print('   Cultivation ID: TEMPORARY_ID_001');

    if (_user == null) return;

    setState(() => _isLoading = true);

    try {
      // Use the same ID as WeeklyActivityPage
      final cultivationId = 'TEMPORARY_ID_001';

      final querySnapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: _user!.uid)
          .where('cultivationId', isEqualTo: cultivationId)
          .orderBy('date', descending: true)

          .get();

      print('   Found ${querySnapshot.docs.length} activities');

      final activities = querySnapshot.docs.map((doc) {
        return Activity.fromFirestore(doc.id, doc.data());
      }).toList();

      // Convert to TimelineItems
      final timelineItems = activities.map((activity) {
        String description = activity.generalNotes ?? 'No additional notes';
        if (activity.fertilizerType != null && activity.fertilizerType != 'None') {
          description += '\nFertilizer: ${activity.fertilizerType}';
          if (activity.fertilizerAmount != null) {
            description += ' (${activity.fertilizerAmount}kg)';
          }
        }

        return TimelineItem(
          date: '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}-${activity.date.day.toString().padLeft(2, '0')}',
          title: activity.activityType,
          description: description,
          completed: true,
        );
      }).toList();

      setState(() {
        _activities = timelineItems;
        _isLoading = false;
      });

    } catch (e) {
      print('❌ Error loading activities: $e');
      setState(() => _isLoading = false);

      // Fallback to hardcoded activities if Firebase fails
      _activities = [
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
    }
  }

  // Crop data (hardcoded for now)
  final _CropDetail cropData = _CropDetail(
    name: 'Rice',
    plantingDate: DateTime(2024, 1, 15),
    expectedHarvest: DateTime(2024, 5, 15),
    daysElapsed: 45,
    totalDays: 120,
    status: 'Growing',
  );

  final progress = (45 / 120) * 100; // 45 days elapsed / 120 total days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Cultivation Details',
              onBack: widget.onBack,
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
                          onPressed: widget.onAddActivity,
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
// Timeline Card with Loading/Empty states
                    CustomCard(
                      child: _isLoading
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : _activities.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.list,
                              size: 48,
                              color: AgriKeepTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No activities yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Log your first activity to see it here',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                          : Timeline(items: _activities),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Column(
                      children: [
                        CustomButton(
                          text: 'Log Weekly Activity',
                          onPressed: widget.onAddActivity,
                          variant: ButtonVariant.secondary,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Record Harvest',
                          onPressed: widget.onHarvest,
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