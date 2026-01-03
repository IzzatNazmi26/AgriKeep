import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrikeep/models/activity.dart';
import 'package:agrikeep/utils/activity_enums.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';

class WeeklyActivityPage extends StatefulWidget {
  final VoidCallback onBack;
  final String cultivationId;
  final String cropName;

  const WeeklyActivityPage({
    super.key,
    required this.onBack,
    required this.cultivationId,
    required this.cropName,
  });

  @override
  State<WeeklyActivityPage> createState() => _WeeklyActivityPageState();
}

class _WeeklyActivityPageState extends State<WeeklyActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  // Form fields
  String _activityType = '';
  String _fertilizerType = '';
  String _wateringFrequency = '';
  String _note = '';
  DateTime _activityDate = DateTime.now();

  bool _isSaving = false;

  Future<void> _saveActivity(BuildContext context) async {
    if (_formKey.currentState!.validate() && _user != null) {
      setState(() => _isSaving = true);

      try {
        // Create simplified activity object
        final activity = Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _user!.uid,
          cultivationId: widget.cultivationId,
          activityType: _activityType,
          activityDate: _activityDate,
          fertilizerType: _activityType == 'Fertilizer Application' ? _fertilizerType : null,
          wateringFrequency: _activityType == 'Watering' ? _wateringFrequency : null,
          note: _note.isNotEmpty ? _note : null,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore
            .collection('activities')
            .doc(activity.id)
            .set(activity.toMap());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after delay
        await Future.delayed(const Duration(milliseconds: 1500));
        widget.onBack();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _activityDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _activityDate) {
      setState(() {
        _activityDate = picked;
      });
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
              title: 'Log Activity',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop info banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AgriKeepTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crop: ${widget.cropName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AgriKeepTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Record your weekly activity',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Activity Type (Required)
                      Text(
                        'Activity Type *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AgriKeepTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _activityType.isNotEmpty ? _activityType : null,
                        decoration: InputDecoration(
                          hintText: 'Select activity type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AgriKeepTheme.borderColor),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ActivityUtils.getActivityTypeDropdownItems(),
                        onChanged: (value) {
                          setState(() {
                            _activityType = value!;
                            // Clear dependent fields when activity type changes
                            if (value != 'Fertilizer Application') _fertilizerType = '';
                            if (value != 'Watering') _wateringFrequency = '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an activity type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Date Selection
                      Text(
                        'Date *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AgriKeepTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AgriKeepTheme.borderColor),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd').format(_activityDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AgriKeepTheme.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Conditional: Fertilizer Type (only for Fertilizer Application)
                      if (_activityType == 'Fertilizer Application') ...[
                        Text(
                          'Fertilizer Type *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _fertilizerType.isNotEmpty ? _fertilizerType : null,
                          decoration: InputDecoration(
                            hintText: 'Select fertilizer type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AgriKeepTheme.borderColor),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ActivityUtils.getFertilizerTypeDropdownItems(),
                          onChanged: (value) {
                            setState(() {
                              _fertilizerType = value!;
                            });
                          },
                          validator: (value) {
                            if (_activityType == 'Fertilizer Application' &&
                                (value == null || value.isEmpty)) {
                              return 'Please select fertilizer type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Conditional: Watering Frequency (only for Watering)
                      if (_activityType == 'Watering') ...[
                        Text(
                          'Watering Frequency *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _wateringFrequency.isNotEmpty ? _wateringFrequency : null,
                          decoration: InputDecoration(
                            hintText: 'Select watering frequency',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AgriKeepTheme.borderColor),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ActivityUtils.getWateringFrequencyDropdownItems(),
                          onChanged: (value) {
                            setState(() {
                              _wateringFrequency = value!;
                            });
                          },
                          validator: (value) {
                            if (_activityType == 'Watering' &&
                                (value == null || value.isEmpty)) {
                              return 'Please select watering frequency';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Optional Note
                      Text(
                        'Note (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AgriKeepTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Short note (if any)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AgriKeepTheme.borderColor),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) => _note = value,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () => _saveActivity(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriKeepTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Save Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
}