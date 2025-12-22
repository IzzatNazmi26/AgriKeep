import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/widgets/card.dart' as custom_card;
import 'package:agrikeep/utils/theme.dart';

class ProfileSetupPage extends StatefulWidget {
  final VoidCallback onComplete;

  const ProfileSetupPage({
    super.key,
    required this.onComplete,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Form data
  String _farmName = '';
  double _farmSize = 0.0;
  String _location = '';
  String _soilType = '';
  String _waterSource = '';
  final List<String> _preferredCrops = [];

  // Options
  final List<String> _soilTypeOptions = [
    'Clay',
    'Loamy',
    'Sandy',
    'Black Soil',
    'Red Soil',
    'Peat',
  ];

  final List<String> _waterSourceOptions = [
    'River',
    'Canal',
    'Tube Well',
    'Rain-fed',
    'Drip Irrigation',
  ];

  final List<String> _cropOptions = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Corn',
    'Vegetables',
    'Fruits',
    'Herbs',
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _toggleCrop(String crop) {
    setState(() {
      if (_preferredCrops.contains(crop)) {
        _preferredCrops.remove(crop);
      } else {
        _preferredCrops.add(crop);
      }
    });
  }

  double get _progress => _currentStep / _totalSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Setup Your Farm'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            const SizedBox(height: 32),

            // Current step content
            Expanded(
              child: _buildCurrentStep(),
            ),
            const SizedBox(height: 32),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $_currentStep of $_totalSteps',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AgriKeepTheme.textPrimary,
              ),
            ),
            Text(
              '${(_progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 14,
                color: AgriKeepTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: AgriKeepTheme.borderColor,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AgriKeepTheme.primaryColor,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return Container();
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your farm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us provide better recommendations',
            style: TextStyle(
              fontSize: 16,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          InputField(
            label: 'Farm Name',
            value: _farmName,
            onChanged: (value) => _farmName = value,
            hintText: 'e.g., Green Valley Farm',
            required: true,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Farm Size',
            value: _farmSize > 0 ? _farmSize.toString() : '',
            onChanged: (value) => _farmSize = double.tryParse(value) ?? 0.0,
            keyboardType: TextInputType.number,
            hintText: 'Enter size',
            unit: 'hectares',
            required: true,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Location',
            value: _location,
            onChanged: (value) => _location = value,
            hintText: 'City, State',
            required: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm conditions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your growing environment',
            style: TextStyle(
              fontSize: 16,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          InputField(
            label: 'Soil Type',
            value: _soilType,
            onChanged: (value) => _soilType = value,
            options: _soilTypeOptions,
            selectedOption: _soilType.isNotEmpty ? _soilType : null,
            onOptionSelected: (value) => setState(() => _soilType = value ?? ''),
            required: true,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Water Source',
            value: _waterSource,
            onChanged: (value) => _waterSource = value,
            options: _waterSourceOptions,
            selectedOption: _waterSource.isNotEmpty ? _waterSource : null,
            onOptionSelected: (value) => setState(() => _waterSource = value ?? ''),
            required: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred crops',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select crops you\'re interested in growing',
            style: TextStyle(
              fontSize: 16,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cropOptions.map((crop) {
              final isSelected = _preferredCrops.contains(crop);
              return GestureDetector(
                onTap: () => _toggleCrop(crop),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AgriKeepTheme.primaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AgriKeepTheme.primaryColor
                          : AgriKeepTheme.borderColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        crop,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AgriKeepTheme.primaryColor
                              : AgriKeepTheme.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: AgriKeepTheme.primaryColor,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_preferredCrops.isNotEmpty)
            Text(
              'Selected: ${_preferredCrops.join(', ')}',
              style: TextStyle(
                fontSize: 14,
                color: AgriKeepTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: CustomButton(
              text: 'Back',
              onPressed: _previousStep,
              variant: ButtonVariant.outline,
            ),
          ),
        if (_currentStep > 1) const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _currentStep == _totalSteps ? 'Complete Setup' : 'Next',
            onPressed: _nextStep,
            variant: ButtonVariant.primary,
          ),
        ),
      ],
    );
  }
}