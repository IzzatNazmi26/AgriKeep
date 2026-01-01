import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// REMOVE Firebase Storage for now since you don't have the package
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:agrikeep/models/activity.dart';

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
  // REMOVE Firebase Storage for now
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  DateTime _selectedDate = DateTime.now();
  final List<XFile> _selectedImages = [];

  // Form fields
  String _activityType = '';
  String _fertilizerType = '';
  String _fertilizerAmount = '';
  String _wateringFrequency = '';
  String _pestIssues = '';
  String _diseaseNotes = '';
  String _generalNotes = '';

  // Dropdown options
  final List<DropdownMenuItem<String>> activityOptions = [
    const DropdownMenuItem(value: 'Watering', child: Text('Watering')),
    const DropdownMenuItem(value: 'Fertilizing', child: Text('Fertilizing')),
    const DropdownMenuItem(value: 'Pest Control', child: Text('Pest Control')),
    const DropdownMenuItem(value: 'Weeding', child: Text('Weeding')),
    const DropdownMenuItem(value: 'Pruning', child: Text('Pruning')),
    const DropdownMenuItem(
      value: 'General Maintenance',
      child: Text('General Maintenance'),
    ),
  ];

  final List<DropdownMenuItem<String>> fertilizerOptions = [
    const DropdownMenuItem(
      value: 'NPK',
      child: Text('NPK Fertilizer'),
    ),
    const DropdownMenuItem(value: 'Urea', child: Text('Urea')),
    const DropdownMenuItem(
      value: 'Organic Compost',
      child: Text('Organic Compost'),
    ),
    const DropdownMenuItem(value: 'None', child: Text('None Applied')),
  ];

  final List<DropdownMenuItem<String>> wateringOptions = [
    const DropdownMenuItem(value: 'Daily', child: Text('Daily')),
    const DropdownMenuItem(value: 'Every 2 days', child: Text('Every 2 days')),
    const DropdownMenuItem(value: 'Twice a week', child: Text('Twice a week')),
    const DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
    const DropdownMenuItem(value: 'As needed', child: Text('As needed')),
  ];

  bool _isSaving = false;

  Future<void> _saveActivity(BuildContext context) async {
    if (_formKey.currentState!.validate() && _user != null) {
      setState(() => _isSaving = true);

      try {
        // For now, skip image upload since Firebase Storage isn't installed
        List<String>? photoUrls = []; // Empty for now

        // Create activity object
        final activity = Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _user!.uid,
          cultivationId: widget.cultivationId,
          activityType: _activityType,
          date: _selectedDate,
          fertilizerType: _fertilizerType.isNotEmpty ? _fertilizerType : null,
          fertilizerAmount: _fertilizerAmount.isNotEmpty ? _fertilizerAmount : null,
          wateringFrequency: _wateringFrequency.isNotEmpty ? _wateringFrequency : null,
          pestIssues: _pestIssues.isNotEmpty ? _pestIssues : null,
          diseaseNotes: _diseaseNotes.isNotEmpty ? _diseaseNotes : null,
          generalNotes: _generalNotes.isNotEmpty ? _generalNotes : null,
          photoUrls: photoUrls,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore
            .collection('activities')
            .doc(activity.id)
            .set(activity.toMap());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Activity saved successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
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

  // REMOVE the duplicate _saveActivity method that was here
  // REMOVE the _uploadImages method since we don't have Firebase Storage

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _saveActivity(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Show what data we received
    print('📱 WeeklyActivityPage opened with:');
    print('   Cultivation ID: ${widget.cultivationId}');
    print('   Crop Name: ${widget.cropName}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Log Weekly Activity'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Type
              _buildLabel('Activity Type'),
              DropdownButtonFormField<String>(
                value: _activityType.isNotEmpty ? _activityType : null,
                decoration: InputDecoration(
                  hintText: 'Select activity type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: activityOptions,
                onChanged: (value) {
                  setState(() {
                    _activityType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an activity type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date
              _buildLabel('Date'),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fertilizer Section
              Card(
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fertilizer Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Fertilizer Type'),
                      DropdownButtonFormField<String>(
                        value: _fertilizerType.isNotEmpty ? _fertilizerType : null,
                        decoration: InputDecoration(
                          hintText: 'Select fertilizer type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: fertilizerOptions,
                        onChanged: (value) {
                          setState(() {
                            _fertilizerType = value!;
                          });
                        },
                      ),
                      if (_fertilizerType.isNotEmpty && _fertilizerType != 'None')
                        ...[
                          const SizedBox(height: 12),
                          _buildLabel('Amount Applied'),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixText: 'kg',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _fertilizerAmount = value;
                              });
                            },
                          ),
                        ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Watering Section
              Card(
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Watering',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Watering Frequency'),
                      DropdownButtonFormField<String>(
                        value: _wateringFrequency.isNotEmpty ? _wateringFrequency : null,
                        decoration: InputDecoration(
                          hintText: 'Select frequency',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: wateringOptions,
                        onChanged: (value) {
                          setState(() {
                            _wateringFrequency = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pest & Disease Section
              Card(
                color: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pest & Disease Monitoring',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Pest Issues Observed'),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe any pest problems (e.g., aphids, caterpillars)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _pestIssues = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Disease Notes'),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Any signs of disease (e.g., leaf spots, wilting)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _diseaseNotes = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // General Notes
              _buildLabel('General Notes'),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Any other observations or notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _generalNotes = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Photo Upload (Optional - will work but images won't be saved to Firebase)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photos (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickImages,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add photos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Crop condition, pest damage, etc.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedImages.isNotEmpty)
                        ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}