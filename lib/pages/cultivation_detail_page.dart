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
import 'package:agrikeep/models/cultivation.dart';



class CultivationDetailPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onAddActivity;
  final VoidCallback onHarvest;
  final String cropId; // ADD THIS
  final String cropName; // ADD THIS
  final String cultivationId; // Add this
  final void Function(String, {Map<String, dynamic>? params})? onNavigate; // ADD THIS (optional)


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
  Cultivation? _cultivation; // ADD THIS
  bool _isLoadingCultivation = true; // ADD THIS
  bool _hasError = false; // Error state

  // Update the cropData getter to use real cultivation data
  _CropDetail get cropData {
    // Use the fetched cultivation data if available
    if (_cultivation != null) {
      final plantingDate = _cultivation!.plantingDate;
      final today = DateTime.now();
      final daysElapsed = today.difference(plantingDate).inDays;
      final totalDays = _cultivation!.growthDurationDays;
      final expectedHarvest = _cultivation!.expectedHarvestDate;

      String status = _cultivation!.status; // Use the actual status from cultivation

      return _CropDetail(
        id: widget.cultivationId,
        name: _cultivation!.cropName,
        plantingDate: plantingDate,
        expectedHarvest: expectedHarvest,
        daysElapsed: daysElapsed,
        totalDays: totalDays,
        status: status,
        cropId: _cultivation!.cropId, // Add cropId
      );
    } else {
      // Fallback to widget data while loading
      final plantingDate = DateTime.now().subtract(Duration(days: 30)); // Default
      final today = DateTime.now();
      final daysElapsed = today.difference(plantingDate).inDays;
      final totalDays = 90;
      final expectedHarvest = plantingDate.add(Duration(days: totalDays));

      return _CropDetail(
        id: widget.cultivationId,
        name: widget.cropName, // Use widget.cropName as fallback
        plantingDate: plantingDate,
        expectedHarvest: expectedHarvest,
        daysElapsed: daysElapsed,
        totalDays: totalDays,
        status: 'Loading...',
        cropId: widget.cropId, // Use widget.cropId as fallback
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCultivationData(); // ADD THIS
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



  // ADD THIS METHOD to load cultivation data
  Future<void> _loadCultivationData() async {
    setState(() => _isLoadingCultivation = true);

    try {
      final cultivation = await _firebaseService.getCultivationById(widget.cultivationId);
      setState(() {
        _cultivation = cultivation;
        _isLoadingCultivation = false;
      });
    } catch (e) {
      print('❌ Error loading cultivation data: $e');
      setState(() => _isLoadingCultivation = false);
    }
  }

  Future<void> _loadHarvests() async {
    if (_user == null) return;

    setState(() => _isLoadingHarvests = true);

    try {
      // Use cropId from cropData instead of widget.cropId
      final cropId = cropData.cropId;
      final harvests = await _firebaseService.getHarvestsByCropId(cropId);
      setState(() {
        _harvests = harvests;
        _isLoadingHarvests = false;
      });
    } catch (e) {
      print('❌ Error loading harvests: $e');
      setState(() => _isLoadingHarvests = false);
    }
  }

  @override
  void didUpdateWidget(CultivationDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the cultivation ID changed, reload all data
    if (oldWidget.cultivationId != widget.cultivationId) {
      _loadCultivationData();
      _loadActivities();
      _loadHarvests();
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
    final progress = _cultivation != null
        ? (cropData.daysElapsed / cropData.totalDays * 100).clamp(0, 100)
        : 0;
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Cultivation Details',
              onBack: widget.onBack,
            ),
            // Add loading overlay for cultivation data
            if (_isLoadingCultivation)
              LinearProgressIndicator(
                backgroundColor: AgriKeepTheme.backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(AgriKeepTheme.primaryColor),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadCultivationData();
                  await _loadActivities();
                  await _loadHarvests();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Crop header card - NOW USING REAL DATA
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
                                  _cultivation != null
                                      ? 'Day ${cropData.daysElapsed} of ${cropData.totalDays}'
                                      : 'Loading...',
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
                            onPressed: () {
                              if (widget.onNavigate != null) {
                                widget.onNavigate!('weekly-activity', params: {
                                  'cultivationId': widget.cultivationId,
                                  'cropName': cropData.name, // ← This should be cropData.name
                                });
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
                                if (widget.onNavigate != null) {
                                  widget.onNavigate!('harvest-records', params: {
                                    'cropId': cropData.cropId,
                                    'cropName': cropData.name,
                                  });
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
                                      widget.onNavigate!('harvest-records', params: {
                                        'cropId': cropData.cropId,
                                        'cropName': cropData.name,
                                      });
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
                            // For the "Log Weekly Activity" button:
                            onPressed: () {
                              if (widget.onNavigate != null) {
                                widget.onNavigate!('weekly-activity', params: {
                                  'cultivationId': widget.cultivationId,
                                  'cropName': cropData.name, // ← This should be cropData.name
                                });
                              }
                            },
                            variant: ButtonVariant.secondary,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 12),
                          // In the action buttons section, update the Record Harvest button:
                          CustomButton(
                            text: 'Record Harvest',
                            onPressed: () {
                              if (widget.onNavigate != null) {
                                // pass the correct cultivation data
                                widget.onNavigate!('harvest-entry', params: {
                                  'cultivationId': widget.cultivationId,
                                  'cropId': cropData.cropId, // ← Pass the real crop ID
                                  'cropName': cropData.name, // ← Pass the real crop name
                                });
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
  final String cropId; // Add cropId for harvest filtering

  _CropDetail({
    required this.id, // ADD THIS
    required this.name,
    required this.plantingDate,
    required this.expectedHarvest,
    required this.daysElapsed,
    required this.totalDays,
    required this.status,
    required this.cropId, // Add this
  });
}