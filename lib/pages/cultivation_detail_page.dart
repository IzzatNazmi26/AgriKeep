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
// Add these imports at the top (after existing imports):
import 'package:agrikeep/services/firebase_service.dart';
import 'package:agrikeep/models/harvest.dart';



class CultivationDetailPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onAddActivity;
  final VoidCallback onHarvest;
  final String cropId; // ADD THIS
  final String cropName; // ADD THIS
  final String cultivationId; // Add this
  final void Function(String)? onNavigate; // ADD THIS (optional)


  const CultivationDetailPage({
    super.key,
    required this.onBack,
    required this.onAddActivity,
    required this.onHarvest,
    required this.cropId, // ADD THIS
    required this.cropName, // ADD THIS
    this.onNavigate, // ADD THIS
    required this.cultivationId, // Add this
  });

  @override
  State<CultivationDetailPage> createState() => _CultivationDetailPageState();
}

class _CultivationDetailPageState extends State<CultivationDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseService _firebaseService = FirebaseService(); // ADD THIS



  List<TimelineItem> _activities = [];
  List<Harvest> _harvests = []; // ADD THIS LINE
  bool _isLoading = true;
  bool _isLoadingHarvests = false; // ADD THIS LINE

  // Use a getter instead of direct initialization
  _CropDetail get cropData {
    final plantingDate = DateTime(2024, 1, 15);
    final today = DateTime.now();
    final daysElapsed = today.difference(plantingDate).inDays;
    final totalDays = 90;
    final expectedHarvest = plantingDate.add(Duration(days: totalDays));

    String status;
    if (daysElapsed < totalDays * 0.3) {
      status = 'Early Growth';
    } else if (daysElapsed < totalDays * 0.7) {
      status = 'Growing';
    } else if (daysElapsed < totalDays) {
      status = 'Flowering/Fruiting';
    } else {
      status = 'Ready for Harvest';
    }

    return _CropDetail(
      id: widget.cropId,
      name: widget.cropName,
      plantingDate: plantingDate,
      expectedHarvest: expectedHarvest,
      daysElapsed: daysElapsed,
      totalDays: totalDays,
      status: status,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadHarvests(); // ADD THIS LINE
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Refresh when returning to this page
  //   _loadActivities();
  //   _loadHarvests(); // ADD THIS LINE
  // }

  Future<void> _loadHarvests() async {
    if (_user == null) return;

    setState(() => _isLoadingHarvests = true);

    try {
      final harvests = await _firebaseService.getHarvestsByCropId(widget.cropId);
      setState(() {
        _harvests = harvests;
        _isLoadingHarvests = false;
      });
    } catch (e) {
      print('❌ Error loading harvests: $e');
      setState(() => _isLoadingHarvests = false);
    }
  }

  Future<void> _loadActivities() async {
    print('🔍 Loading activities...');
    print('   User ID: ${_user?.uid}');
    print('   Cultivation ID: ${widget.cultivationId}');

    if (_user == null) return;

    setState(() => _isLoading = true);

    try {
      final cultivationId = widget.cultivationId;

      final querySnapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: _user!.uid)
          .where('cultivationId', isEqualTo: cultivationId)
          .orderBy('activityDate', descending: true)

          .get();

      print('   Found ${querySnapshot.docs.length} activities');

      final activities = querySnapshot.docs.map((doc) {
        return Activity.fromFirestore(doc.id, doc.data());
      }).toList();

      // Convert to TimelineItems - UPDATED FOR NEW MODEL
      final timelineItems = activities.map((activity) {
        // Use note instead of generalNotes
        String description = activity.note ?? 'No additional notes';

        // Add fertilizer info if available
        if (activity.activityType == 'Fertilizer Application' && activity.fertilizerType != null) {
          description += '\nFertilizer: ${activity.fertilizerType}';
          // Note: fertilizerAmount removed per spec
        }

        // Add watering info if available
        if (activity.activityType == 'Watering' && activity.wateringFrequency != null) {
          description += '\nFrequency: ${activity.wateringFrequency}';
        }

        return TimelineItem(
          // Use activityDate instead of date
          date: '${activity.activityDate.year}-${activity.activityDate.month.toString().padLeft(2, '0')}-${activity.activityDate.day.toString().padLeft(2, '0')}',
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

      // Fallback to hardcoded activities if Firebase fails //dah tukar takde fallback
      _activities = [];

    }
  }


  @override
  Widget build(BuildContext context) {
    final progress = (cropData.daysElapsed / cropData.totalDays * 100).clamp(0, 100);

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
                    // Crop header card - NOW USING cropData getter
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
                                    cropData.name, // ← Works now!
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
                                  cropData.status, // ← Works now!
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

                    // Add this code AFTER the Timeline Card and BEFORE the Action Buttons:

                    const SizedBox(height: 24),

// Harvest History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Harvest History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                        if (_harvests.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // Navigate to harvest records for this crop
                              if (widget.onNavigate != null) {
                                widget.onNavigate!('crop-harvests');
                              }
                            },
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
                    const SizedBox(height: 16),

// Harvest List Card
                    CustomCard(
                      child: _isLoadingHarvests
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : _harvests.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 48,
                              color: AgriKeepTheme.textTertiary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No harvests recorded yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Record your first harvest above',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                          : Column(
                        children: [
                          // Total harvested summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Harvested',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AgriKeepTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${_harvests.fold(0.0, (sum, h) => sum + h.quantityKg).toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AgriKeepTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Recent harvests (show last 3)
                          ..._harvests.take(3).map((harvest) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${harvest.quantityKg} kg',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AgriKeepTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(harvest.harvestDate),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AgriKeepTheme.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (harvest.note != null && harvest.note!.isNotEmpty)
                                    Flexible(
                                      child: Text(
                                        harvest.note!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AgriKeepTheme.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          // View all button if there are more than 3
                          if (_harvests.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextButton(
                                onPressed: () {
                                  if (widget.onNavigate != null) {
                                    widget.onNavigate!('crop-harvests');
                                  }
                                },
                                child: Text(
                                  'View ${_harvests.length - 3} more harvests',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24), // Add some spacing before action buttons


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
                        // In the action buttons section, update the Record Harvest button:
                        CustomButton(
                          text: 'Record Harvest',
                          onPressed: () {
                            // Navigate to harvest entry with crop data
                            if (widget.onNavigate != null) {
                              // You need to pass the crop data through navigation
                              // This depends on your navigation system
                              widget.onNavigate!('harvest-entry');
                            }
                          },
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

// Update _CropDetail class definition:
class _CropDetail {
  final String id; // ADD THIS
  final String name;
  final DateTime plantingDate;
  final DateTime expectedHarvest;
  final int daysElapsed;
  final int totalDays;
  final String status;

  _CropDetail({
    required this.id, // ADD THIS
    required this.name,
    required this.plantingDate,
    required this.expectedHarvest,
    required this.daysElapsed,
    required this.totalDays,
    required this.status,
  });
}