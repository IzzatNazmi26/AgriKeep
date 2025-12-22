import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/crop_card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/models/recommendation_input.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/utils/theme.dart';

class RecommendationsPage extends StatefulWidget {
  final VoidCallback onBack;

  const RecommendationsPage({
    super.key,
    required this.onBack,
  });

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  bool _showResults = false;
  final _formKey = GlobalKey<FormState>();

  // Form data - Updated to match new requirements
  final RecommendationInput _formData = RecommendationInput(
    season: '',
    soilType: '',
    waterAvailability: '',
    farmSize: 0.0,
  );

  // Enhanced form data
  String _environmentType = '';
  String _currentSeason = '';
  String _sunlightExposure = '';

  // Updated options based on requirements
  final List<String> _environmentOptions = [
    'Greenhouse',
    'Open Field',
    'Raised Bed / Polybag Farming',
    'Fertigation System'
  ];

  final List<String> _soilTypeOptions = [
    'Loamy',
    'Sandy',
    'Clay',
    'Peat Soil'
  ];

  final List<String> _sunlightOptions = [
    'Full Sun',
    'Partial Shade',
    'Shaded'
  ];

  final List<String> _waterOptions = [
    'High',
    'Moderate',
    'Low'
  ];

  final List<String> _currentSeasonOptions = [
    'Dry Season',
    'Rainy/Monsoon'
  ];

  final List<String> _previousCropOptions = [
    'Rice', 'Wheat', 'Cotton', 'Sugarcane', 'None/First Crop'
  ];

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _showResults = true);
    }
  }

  void _handleReset() {
    setState(() {
      _showResults = false;
      // Reset all form fields
      _formData.season = '';
      _formData.soilType = '';
      _formData.waterAvailability = '';
      _formData.farmSize = 0.0;
      _formData.previousCrop = null;
      _environmentType = '';
      _currentSeason = '';
      _sunlightExposure = '';
    });
  }

  void _handleSaveRecommendation(String cropName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cropName saved to your dashboard!'),
        backgroundColor: AgriKeepTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultsScreen();
    }

    return _buildFormScreen();
  }

  Widget _buildFormScreen() {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Crop Recommendations',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get personalized recommendations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us about your farm conditions and planting schedule',
                      style: TextStyle(
                        fontSize: 14,
                        color: AgriKeepTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Environmental Conditions Card
                          CustomCard(
                            backgroundColor: const Color(0xFFF0FDF4),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Environmental Conditions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // // Environment Type
                                // InputField(
                                //   label: 'Environment Type',
                                //   value: _environmentType,
                                //   onChanged: (value) => setState(() => _environmentType = value),
                                //   options: _environmentOptions,
                                //   selectedOption: _environmentType.isNotEmpty ? _environmentType : null,
                                //   onOptionSelected: (value) => setState(() => _environmentType = value ?? ''),
                                //   required: true,
                                // ),
                                // const SizedBox(height: 16),

                                // Soil Conditions
                                InputField(
                                  label: 'Soil Conditions',
                                  value: _formData.soilType,
                                  onChanged: (value) => setState(() => _formData.soilType = value),
                                  options: _soilTypeOptions,
                                  selectedOption: _formData.soilType.isNotEmpty ? _formData.soilType : null,
                                  onOptionSelected: (value) => setState(() => _formData.soilType = value ?? ''),
                                  required: true,
                                ),
                                const SizedBox(height: 16),

                                // Sunlight Exposure
                                InputField(
                                  label: 'Sunlight Exposure',
                                  value: _sunlightExposure,
                                  onChanged: (value) => setState(() => _sunlightExposure = value),
                                  options: _sunlightOptions,
                                  selectedOption: _sunlightExposure.isNotEmpty ? _sunlightExposure : null,
                                  onOptionSelected: (value) => setState(() => _sunlightExposure = value ?? ''),
                                  required: true,
                                ),
                                const SizedBox(height: 16),

                                // Water Availability
                                InputField(
                                  label: 'Water Availability',
                                  value: _formData.waterAvailability,
                                  onChanged: (value) => setState(() => _formData.waterAvailability = value),
                                  options: _waterOptions,
                                  selectedOption: _formData.waterAvailability.isNotEmpty ? _formData.waterAvailability : null,
                                  onOptionSelected: (value) => setState(() => _formData.waterAvailability = value ?? ''),
                                  required: true,
                                ),
                                const SizedBox(height: 16),

                                // Current Season
                                InputField(
                                  label: 'Current Season',
                                  value: _currentSeason,
                                  onChanged: (value) => setState(() => _currentSeason = value),
                                  options: _currentSeasonOptions,
                                  selectedOption: _currentSeason.isNotEmpty ? _currentSeason : null,
                                  onOptionSelected: (value) => setState(() => _currentSeason = value ?? ''),
                                  required: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // // Farm Size and Previous Crop
                          // InputField(
                          //   label: 'Farm Size',
                          //   value: _formData.farmSize > 0 ? _formData.farmSize.toString() : '',
                          //   onChanged: (value) => setState(() => _formData.farmSize = double.tryParse(value) ?? 0.0),
                          //   keyboardType: TextInputType.number,
                          //   hintText: 'Enter area',
                          //   unit: 'hectares',
                          //   required: true,
                          // ),
                          // const SizedBox(height: 16),
                          // InputField(
                          //   label: 'Previous Crop (Optional)',
                          //   value: _formData.previousCrop ?? '',
                          //   onChanged: (value) => setState(() => _formData.previousCrop = value),
                          //   options: _previousCropOptions,
                          //   selectedOption: _formData.previousCrop,
                          //   onOptionSelected: (value) => setState(() => _formData.previousCrop = value),
                          // ),
                          // const SizedBox(height: 32),

                          // Submit Button
                          CustomButton(
                            text: 'Get Recommendations',
                            onPressed: _handleSubmit,
                            variant: ButtonVariant.primary,
                            size: ButtonSize.large,
                            fullWidth: true,
                          ),
                        ],
                      ),
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

  Widget _buildResultsScreen() {
    final filteredCrops = MockData.mockCrops
        .where((crop) => crop.season.contains(_currentSeason))
        .toList();

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Recommendations',
              onBack: _handleReset,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Results summary card
                    CustomCard(
                      backgroundColor: const Color(0xFFF0FDF4),
                      border: Border.all(
                        color: const Color(0xFFBBF7D0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommendations Ready!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on  ${_formData.soilType} soil, $_sunlightExposure sunlight, and ${_formData.waterAvailability.toLowerCase()} water',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Season: $_currentSeason',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Results title
                    Text(
                      'Top Recommendations for You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crops suitable for your conditions',
                      style: TextStyle(
                        fontSize: 14,
                        color: AgriKeepTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Crop recommendations
                    if (filteredCrops.isNotEmpty)
                      Column(
                        children: filteredCrops.map((crop) {
                          return Column(
                            children: [
                              CropCard(
                                crop: crop,
                                showRecommendedBadge: true,
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: 'Plan to Plant',
                                onPressed: () => _handleSaveRecommendation(crop.name),
                                variant: ButtonVariant.secondary,
                                icon: Icon(
                                  Icons.bookmark_outline,
                                  size: 20,
                                  color: AgriKeepTheme.surfaceColor,
                                ),
                                fullWidth: true,
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }).toList(),
                      )
                    else
                      CustomCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No crops found matching your current season ($_currentSeason). Try different conditions.',
                            style: TextStyle(
                              color: AgriKeepTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // New recommendations button
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Get New Recommendations',
                      onPressed: _handleReset,
                      variant: ButtonVariant.outline,
                      fullWidth: true,
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