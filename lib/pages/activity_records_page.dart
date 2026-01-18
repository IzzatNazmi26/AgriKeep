import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/record_item.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/services/firebase_service.dart';
import 'package:agrikeep/models/activity.dart';

class ActivityRecordsPage extends StatefulWidget {
  final VoidCallback onBack;
  final String cultivationId;
  final String? cropName;
  final void Function(String, {Map<String, dynamic>? params})? onNavigate;

  const ActivityRecordsPage({
    super.key,
    required this.onBack,
    required this.cultivationId,
    this.cropName,
    this.onNavigate,
  });

  @override
  State<ActivityRecordsPage> createState() => _ActivityRecordsPageState();
}

class _ActivityRecordsPageState extends State<ActivityRecordsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Activity> _activities = [];
  bool _isLoading = true;
  String? _cultivationName;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadCultivationInfo();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _firebaseService.getActivitiesByCultivationId(widget.cultivationId);
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading activities: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load activities: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadCultivationInfo() async {
    try {
      final cultivation = await _firebaseService.getCultivationById(widget.cultivationId);
      if (cultivation != null) {
        setState(() {
          _cultivationName = cultivation.cropName;
        });
      }
    } catch (e) {
      print('❌ Error loading cultivation info: $e');
    }
  }

  Future<void> _deleteActivity(String activityId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.deleteActivity(activityId);

        // Remove from local list
        setState(() {
          _activities.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('❌ Error deleting activity: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editActivity(Activity activity) {
    if (widget.onNavigate != null) {
      widget.onNavigate!('activity-edit', params: {
        'activity': activity,
        'cultivationId': widget.cultivationId,
        'cropName': _cultivationName ?? widget.cropName,
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Activity Records',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Cultivation info banner
                    if (_cultivationName != null || widget.cropName != null)
                      CustomCard(
                        backgroundColor: AgriKeepTheme.primaryColor.withOpacity(0.05),
                        border: Border.all(color: AgriKeepTheme.primaryColor.withOpacity(0.2)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.eco,
                              color: AgriKeepTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cultivation: ${_cultivationName ?? widget.cropName ?? "Unknown"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AgriKeepTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Summary card
                    if (_activities.isNotEmpty)
                      CustomCard(
                        child: Column(
                          children: [
                            Text(
                              'Total Activities',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _activities.length.toString(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AgriKeepTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Activities list
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_activities.isEmpty)
                      Padding(
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
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Activities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._activities.asMap().entries.map((entry) {
                            final index = entry.key;
                            final activity = entry.value;

                            String subtitle = activity.note ?? 'No additional notes';
                            if (activity.activityType == 'Fertilizer Application' && activity.fertilizerType != null) {
                              subtitle += '\nFertilizer: ${activity.fertilizerType}';
                            }
                            if (activity.activityType == 'Watering' && activity.wateringFrequency != null) {
                              subtitle += '\nFrequency: ${activity.wateringFrequency}';
                            }

                            // Replace the Dismissible widget in activity_records_page.dart (around line 180-220)
// Find the Dismissible widget and replace it with:

                            return Dismissible(
                              key: Key(activity.id),
                              direction: DismissDirection.horizontal, // ← Allow both directions
                              background: Container(
                                color: AgriKeepTheme.primaryColor, // ← GREEN for edit (left to right)
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.edit, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red, // ← RED for delete (right to left)
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  // DELETE ACTION (swipe right to left)
                                  await _deleteActivity(activity.id, index);
                                  return false; // We handle deletion in the method
                                } else if (direction == DismissDirection.startToEnd) {
                                  // EDIT ACTION (swipe left to right)
                                  _editActivity(activity);
                                  return false; // We handle navigation in the method
                                }
                                return false;
                              },
                              child: RecordItem(
                                title: activity.activityType,
                                subtitle: subtitle,
                                value: DateFormat('HH:mm').format(activity.activityDate),
                                date: DateFormat('MM/dd/yyyy').format(activity.activityDate),
                                badge: 'Activity',
                              ),
                            );
                          }).toList(),
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
}