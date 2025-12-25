import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/crop_card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/models/recommendation_input.dart';
import 'package:agrikeep/models/crop.dart';
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
  bool _hasAtLeastOneField = false;
  final _formKey = GlobalKey<FormState>();

  // Form data
  final RecommendationInput _formData = RecommendationInput(
    soilType: '',
    waterAvailability: '',
    farmSize: 0.0,
  );

  // Additional form fields
  String _sunlightExposure = '';
  String? _selectedDurationRange;

  // Updated options
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

  // 30-day standard ranges starting from 30 days
  final List<String> _durationRanges = [
    '30–60 days',
    '60–90 days',
    '90–120 days',
    '120–150 days',
  ];

  // Parse range string to get min and max days
  (int, int) _parseDurationRange(String range) {
    try {
      final clean = range.replaceAll(' days', '').replaceAll('–', '-');
      final parts = clean.split('-');
      if (parts.length == 2) {
        final min = int.tryParse(parts[0].trim()) ?? 0;
        final max = int.tryParse(parts[1].trim()) ?? 0;
        return (min, max);
      }
    } catch (e) {
      // ignore
    }
    return (0, 0);
  }

  // Check if at least one field is filled
  void _checkFormFilled() {
    setState(() {
      _hasAtLeastOneField = _formData.soilType.isNotEmpty ||
          _sunlightExposure.isNotEmpty ||
          _formData.waterAvailability.isNotEmpty ||
          _selectedDurationRange != null;
    });
  }

  void _handleSubmit() {
    if (_hasAtLeastOneField) {
      setState(() => _showResults = true);
    }
  }

  // Check if crop matches ALL selected criteria
  bool _matchesAllSelectedCriteria(Crop crop) {
    // Track which criteria need to be checked
    bool needsSoilMatch = _formData.soilType.isNotEmpty;
    bool needsSunlightMatch = _sunlightExposure.isNotEmpty;
    bool needsWaterMatch = _formData.waterAvailability.isNotEmpty;
    bool needsDurationMatch = _selectedDurationRange != null;

    // 1. Soil match (PARTIAL MATCH)
    if (needsSoilMatch) {
      final soilMatches = crop.soilType.any((soil) =>
          soil.toLowerCase().contains(_formData.soilType.toLowerCase()));
      if (!soilMatches) return false;
    }

    // 2. Sunlight match
    if (needsSunlightMatch) {
      if (crop.climate == null) return false;
      final cropClimate = crop.climate!.toLowerCase();
      final selectedSunlight = _sunlightExposure.toLowerCase();

      final sunlightMatches = cropClimate.contains(selectedSunlight) ||
          (selectedSunlight == 'full sun' && cropClimate.contains('full')) ||
          (selectedSunlight == 'partial shade' && (cropClimate.contains('partial') || cropClimate.contains('shade'))) ||
          (selectedSunlight == 'shaded' && cropClimate.contains('shade'));
      if (!sunlightMatches) return false;
    }

    // 3. Water requirement (EXACT MATCH)
    if (needsWaterMatch) {
      if (crop.waterRequirement != _formData.waterAvailability) {
        return false;
      }
    }

    // 4. Duration match (30-DAY RANGE MATCHING)
    if (needsDurationMatch) {
      final (selectedMin, selectedMax) = _parseDurationRange(_selectedDurationRange!);
      final cropMin = crop.minDurationDays;
      final cropMax = crop.maxDurationDays;

      // Check: Crop range overlaps with selected range AND crop max ≤ selected max
      final hasOverlap = !(cropMin > selectedMax || cropMax < selectedMin);
      final withinMaxLimit = cropMax <= selectedMax;

      if (!hasOverlap || !withinMaxLimit) {
        return false;
      }
    }

    // Crop passed ALL selected criteria checks
    return true;
  }

  List<String> _getSelectedCriteria() {
    final criteria = <String>[];

    if (_formData.soilType.isNotEmpty) {
      criteria.add('Soil: ${_formData.soilType}');
    }
    if (_sunlightExposure.isNotEmpty) {
      criteria.add('Sunlight: $_sunlightExposure');
    }
    if (_formData.waterAvailability.isNotEmpty) {
      criteria.add('Water: ${_formData.waterAvailability}');
    }
    if (_selectedDurationRange != null) {
      criteria.add('Duration: $_selectedDurationRange');
    }

    return criteria;
  }

  void _handleReset() {
    setState(() {
      _showResults = false;
      // Reset all form fields
      _formData.soilType = '';
      _formData.waterAvailability = '';
      _formData.farmSize = 0.0;
      _formData.previousCrop = null;
      _formData.maxDurationDays = null;

      _sunlightExposure = '';
      _selectedDurationRange = null;
      _hasAtLeastOneField = false;
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
                      'Select at least one criteria. Crops must match ALL selected criteria.',
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
                          // Main form card (without title)
                          CustomCard(
                            backgroundColor: const Color(0xFFF0FDF4),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),

                                // Soil Conditions
                                InputField(
                                  label: 'Soil Conditions',
                                  value: _formData.soilType,
                                  onChanged: (value) {
                                    setState(() => _formData.soilType = value);
                                    _checkFormFilled();
                                  },
                                  options: _soilTypeOptions,
                                  selectedOption: _formData.soilType.isNotEmpty ? _formData.soilType : null,
                                  onOptionSelected: (value) {
                                    setState(() => _formData.soilType = value ?? '');
                                    _checkFormFilled();
                                  },
                                  required: false,
                                ),
                                const SizedBox(height: 16),

                                // Sunlight Exposure
                                InputField(
                                  label: 'Sunlight Exposure',
                                  value: _sunlightExposure,
                                  onChanged: (value) {
                                    setState(() => _sunlightExposure = value);
                                    _checkFormFilled();
                                  },
                                  options: _sunlightOptions,
                                  selectedOption: _sunlightExposure.isNotEmpty ? _sunlightExposure : null,
                                  onOptionSelected: (value) {
                                    setState(() => _sunlightExposure = value ?? '');
                                    _checkFormFilled();
                                  },
                                  required: false,
                                ),
                                const SizedBox(height: 16),

                                // Water Availability
                                InputField(
                                  label: 'Water Availability',
                                  value: _formData.waterAvailability,
                                  onChanged: (value) {
                                    setState(() => _formData.waterAvailability = value);
                                    _checkFormFilled();
                                  },
                                  options: _waterOptions,
                                  selectedOption: _formData.waterAvailability.isNotEmpty ? _formData.waterAvailability : null,
                                  onOptionSelected: (value) {
                                    setState(() => _formData.waterAvailability = value ?? '');
                                    _checkFormFilled();
                                  },
                                  required: false,
                                ),
                                const SizedBox(height: 16),

                                // Duration Range (30-day ranges)
                                InputField(
                                  label: 'Planting Duration Range',
                                  value: _selectedDurationRange ?? '',
                                  onChanged: (value) {
                                    setState(() => _selectedDurationRange = value);
                                    _checkFormFilled();
                                  },
                                  options: _durationRanges,
                                  selectedOption: _selectedDurationRange,
                                  onOptionSelected: (value) {
                                    setState(() => _selectedDurationRange = value);
                                    _checkFormFilled();
                                  },
                                  required: false,
                                  hintText: 'Select 30-day duration range',
                                ),
                                const SizedBox(height: 8),

                                // Instructions
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Duration ranges show crops finishing within that period.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AgriKeepTheme.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        'Example: "30–60 days" shows crops taking 30–60 days to harvest.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AgriKeepTheme.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Submit Button - Enabled only if at least one field filled
                          CustomButton(
                            text: 'Get Recommendations',
                            onPressed: _hasAtLeastOneField ? _handleSubmit : null,
                            variant: ButtonVariant.primary,
                            size: ButtonSize.large,
                            fullWidth: true,
                            disabled: !_hasAtLeastOneField,
                          ),
                          const SizedBox(height: 8),

                          // Warning if no fields filled
                          if (!_hasAtLeastOneField)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Please select at least one criteria',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFFDC2626),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
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
    // Get selected criteria
    final selectedCriteria = _getSelectedCriteria();

    // Filter crops that match ALL selected criteria
    final matchingCrops = MockData.mockCrops
        .where(_matchesAllSelectedCriteria)
        .toList();

    // Sort by duration (shortest first)
    matchingCrops.sort((a, b) => a.maxDurationDays.compareTo(b.maxDurationDays));

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
                      backgroundColor: matchingCrops.isNotEmpty
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF2F2),
                      border: Border.all(
                        color: matchingCrops.isNotEmpty
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFECACA),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            matchingCrops.isNotEmpty
                                ? 'Matching Crops Found!'
                                : 'No Matching Crops',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: matchingCrops.isNotEmpty
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selected Criteria (ALL must match):',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: matchingCrops.isNotEmpty
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selectedCriteria.isNotEmpty)
                            ...selectedCriteria.map((criterion) => Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                              child: Text(
                                '• $criterion',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: matchingCrops.isNotEmpty
                                      ? const Color(0xFF166534)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            )).toList(),
                          const SizedBox(height: 8),
                          Text(
                            matchingCrops.isNotEmpty
                                ? 'Found ${matchingCrops.length} crop(s) matching ALL criteria'
                                : 'No crops match ALL your selected criteria',
                            style: TextStyle(
                              fontSize: 12,
                              color: matchingCrops.isNotEmpty
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFDC2626),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (matchingCrops.isNotEmpty) ...[
                      // Results title
                      Text(
                        'Recommended Crops',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AgriKeepTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sorted by growing duration (shortest first)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AgriKeepTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Crop recommendations
                      Column(
                        children: matchingCrops.map((crop) {
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
                      ),
                    ] else ...[
                      // No results message
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AgriKeepTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Crops Match ALL Your Criteria',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AgriKeepTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  'We couldn\'t find any crops that match ALL your selected requirements.\n\n'
                                      'Try adjusting your criteria:\n'
                                      '• Select fewer criteria\n'
                                      '• Choose different options\n'
                                      '• Select a longer duration range',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AgriKeepTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],

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