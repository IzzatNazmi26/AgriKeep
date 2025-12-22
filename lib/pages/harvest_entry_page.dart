import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';

class HarvestEntryPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;

  const HarvestEntryPage({
    super.key,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<HarvestEntryPage> createState() => _HarvestEntryPageState();
}

class _HarvestEntryPageState extends State<HarvestEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'cropName': 'Rice',
    'harvestDate': '',
    'quantityHarvested': '',
    'unit': 'tons',
    'quality': '',
    'notes': '',
  };

  final double _expectedYield = 4.5; // From planting data

  @override
  void initState() {
    super.initState();
    // Set default date to today
    final today = DateTime.now();
    _formData['harvestDate'] = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave();
    }
  }

  double get _actualYield {
    return double.tryParse(_formData['quantityHarvested']) ?? 0.0;
  }

  double get _performancePercentage {
    return _expectedYield > 0 ? ((_actualYield / _expectedYield) * 100) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Record Harvest',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Welcome card
                    CustomCard(
                      backgroundColor: const Color(0xFFF0FDF4),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              size: 24,
                              color: AgriKeepTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ready to Harvest!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Record your harvest details below',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputField(
                            label: 'Crop Name',
                            value: _formData['cropName'],
                            onChanged: (value) => setState(() => _formData['cropName'] = value),
                            required: true,
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'Harvest Date',
                            value: _formData['harvestDate'],
                            onChanged: (value) => setState(() => _formData['harvestDate'] = value),
                            required: true,
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'Quantity Harvested',
                            value: _formData['quantityHarvested'],
                            onChanged: (value) => setState(() => _formData['quantityHarvested'] = value),
                            keyboardType: TextInputType.number,
                            unit: _formData['unit'],
                            required: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'Quality Grade',
                            value: _formData['quality'],
                            onChanged: (value) => setState(() => _formData['quality'] = value),
                            options: [
                              'Excellent (Grade A)',
                              'Good (Grade B)',
                              'Fair (Grade C)',
                              'Poor (Grade D)',
                            ],
                            selectedOption: _formData['quality'].isNotEmpty ? _formData['quality'] : null,
                            onOptionSelected: (value) => setState(() => _formData['quality'] = value ?? ''),
                            required: true,
                          ),
                          const SizedBox(height: 16),

                          // Performance indicator
                          if (_actualYield > 0)
                            CustomCard(
                              backgroundColor: _performancePercentage >= 90
                                  ? const Color(0xFFF0FDF4)
                                  : _performancePercentage >= 70
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFFEF2F2),
                              border: Border.all(
                                color: _performancePercentage >= 90
                                    ? const Color(0xFFBBF7D0)
                                    : _performancePercentage >= 70
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFFECACA),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Performance vs Expected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AgriKeepTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${_performancePercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _performancePercentage >= 90
                                              ? AgriKeepTheme.successColor
                                              : _performancePercentage >= 70
                                              ? AgriKeepTheme.warningColor
                                              : AgriKeepTheme.errorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Expected: $_expectedYield ${_formData['unit']} | Actual: $_actualYield ${_formData['unit']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AgriKeepTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Harvest notes
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Harvest Notes',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AgriKeepTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AgriKeepTheme.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Any observations about the harvest (weather conditions, challenges, etc.)...',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(12),
                                    hintStyle: TextStyle(
                                      color: AgriKeepTheme.textTertiary,
                                    ),
                                  ),
                                  onChanged: (value) => _formData['notes'] = value,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Save button
                          CustomButton(
                            text: 'Save Harvest Record',
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
}