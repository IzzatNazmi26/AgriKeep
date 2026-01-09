import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/models/cultivation.dart';
import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/services/firebase_service.dart';


class AddCultivationPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String)? onNavigate;

  const AddCultivationPage({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<AddCultivationPage> createState() => _AddCultivationPageState();
}

class _AddCultivationPageState extends State<AddCultivationPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'cropId': null,
    'cropName': null,
    'plantingDate': DateTime.now(),
    'growthDurationDays': null,
    'expectedHarvestDate': null,
    'note': null,
  };

  bool _isLoading = false;
  bool _isCalculatingHarvest = false;

  // Get all crops from mock data
  List<Crop> get crops => MockData.mockCrops;

  // Get crop names for dropdown
  List<String> get cropNames => crops.map((crop) => crop.name).toList();

  @override
  void initState() {
    super.initState();
    // Initialize with today's date
    _calculateHarvestDate();
  }

  void _calculateHarvestDate() {
    if (_formData['plantingDate'] != null && _formData['growthDurationDays'] != null) {
      setState(() {
        _isCalculatingHarvest = true;
        final plantingDate = _formData['plantingDate'] as DateTime;
        final duration = _formData['growthDurationDays'] as int;
        _formData['expectedHarvestDate'] = plantingDate.add(Duration(days: duration));
        _isCalculatingHarvest = false;
      });
    } else {
      _formData['expectedHarvestDate'] = null;
    }
  }

  void _onCropSelected(String? cropName) {
    if (cropName == null) return;

    final selectedCrop = crops.firstWhere((crop) => crop.name == cropName);

    setState(() {
      _formData['cropId'] = selectedCrop.id;
      _formData['cropName'] = cropName;

      // Get max duration from crop (e.g., "75-90 days" -> 90)
      _formData['growthDurationDays'] = selectedCrop.maxDurationDays;

      // Recalculate harvest date
      _calculateHarvestDate();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData['plantingDate'] as DateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AgriKeepTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AgriKeepTheme.surfaceColor,
              onSurface: AgriKeepTheme.textPrimary,
            ),
            dialogBackgroundColor: AgriKeepTheme.surfaceColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _formData['plantingDate']) {
      setState(() {
        _formData['plantingDate'] = picked;
        _calculateHarvestDate();
      });
    }
  }

  void _onDurationChanged(String value) {
    final duration = int.tryParse(value);
    if (duration != null && duration > 0) {
      setState(() {
        _formData['growthDurationDays'] = duration;
        _calculateHarvestDate();
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseService = FirebaseService();

      // Create cultivation object
      final plantingDate = _formData['plantingDate'] as DateTime;
      final growthDuration = _formData['growthDurationDays'] as int;
      final expectedHarvest = _formData['expectedHarvestDate'] as DateTime;

      // Calculate current day and progress
      final currentDay = DateTime.now().difference(plantingDate).inDays.clamp(0, growthDuration);
      final progressPercentage = ((currentDay / growthDuration) * 100).clamp(0, 100).toInt();

      // Determine initial status based on progress
      String initialStatus = 'Planted';
      if (progressPercentage > 30) initialStatus = 'Growing';
      if (progressPercentage > 60) initialStatus = 'Flowering';

      // Generate a unique ID
      final cultivationId = 'cult_${DateTime.now().millisecondsSinceEpoch}_${_formData['cropId']}';

      final cultivation = Cultivation(
        id: cultivationId,
        userId: '', // Will be set by FirebaseService
        cropId: _formData['cropId'] as String,
        cropName: _formData['cropName'] as String,
        plantingDate: plantingDate,
        growthDurationDays: growthDuration,
        expectedHarvestDate: expectedHarvest,
        status: initialStatus,
        currentDay: currentDay,
        progressPercentage: progressPercentage,
        note: _formData['note'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await firebaseService.addCultivation(cultivation);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cultivation "${cultivation.cropName}" added successfully!'),
          backgroundColor: AgriKeepTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 1500));

      widget.onBack();

    } catch (e) {
      // Handle error
      print('❌ Error saving cultivation: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save cultivation: ${e.toString()}'),
          backgroundColor: AgriKeepTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
              title: 'Add New Cultivation',
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
                      // Info Card
                      CustomCard(
                        backgroundColor: AgriKeepTheme.primaryColor.withOpacity(0.05),
                        border: Border.all(
                          color: AgriKeepTheme.primaryColor.withOpacity(0.2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: AgriKeepTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Register a new crop cultivation cycle to track growth and activities.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AgriKeepTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 1. Crop Selection (Required)
                      InputField(
                        label: 'Crop Name',
                        selectedOption: _formData['cropName'],
                        options: cropNames,
                        onOptionSelected: _onCropSelected,
                        required: true,
                      ),

                      const SizedBox(height: 20),

                      // 2. Planting Date (Required)
                      Text(
                        'Planting Date *',
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
                            color: AgriKeepTheme.surfaceColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd').format(_formData['plantingDate'] as DateTime),
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

                      // 3. Growth Duration (Auto-filled, editable)
                      InputField(
                        label: 'Growth Duration (Days)',
                        value: _formData['growthDurationDays']?.toString() ?? '',
                        onChanged: _onDurationChanged,
                        keyboardType: TextInputType.number,
                        hintText: 'Enter duration in days',
                        required: true,
                        unit: 'days',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter growth duration';
                          }
                          final days = int.tryParse(value);
                          if (days == null || days <= 0) {
                            return 'Please enter a valid number of days';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // 4. Expected Harvest Date (Auto-calculated, read-only)
                      Text(
                        'Expected Harvest Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AgriKeepTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AgriKeepTheme.borderColor),
                          color: AgriKeepTheme.backgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _isCalculatingHarvest
                                ? Text(
                              'Calculating...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            )
                                : _formData['expectedHarvestDate'] != null
                                ? Text(
                              DateFormat('yyyy-MM-dd').format(_formData['expectedHarvestDate'] as DateTime),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AgriKeepTheme.primaryColor,
                              ),
                            )
                                : Text(
                              'Select crop and date',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            ),
                            Icon(
                              Icons.event_available,
                              size: 20,
                              color: AgriKeepTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 5. Optional Note
                      InputField(
                        label: 'Note (Optional)',
                        value: _formData['note'],
                        onChanged: (value) => _formData['note'] = value,
                        maxLines: 2,
                        hintText: 'e.g., Greenhouse section A, special treatment, etc.',
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      CustomButton(
                        text: 'Save Cultivation',
                        onPressed: _handleSubmit,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        fullWidth: true,
                        loading: _isLoading,
                        disabled: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Cancel Button
                      CustomButton(
                        text: 'Cancel',
                        onPressed: widget.onBack,
                        variant: ButtonVariant.outline,
                        size: ButtonSize.large,
                        fullWidth: true,
                        disabled: _isLoading,
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