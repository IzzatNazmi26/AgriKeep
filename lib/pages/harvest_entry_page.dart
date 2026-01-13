import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/services/firebase_service.dart';
import 'package:agrikeep/models/harvest.dart';

class HarvestEntryPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;
  final String cropId; // Add this
  final String cropName; // Add this
  final String? cultivationId; // Optional: link to cultivation

  const HarvestEntryPage({
    super.key,
    required this.onBack,
    required this.onSave,
    required this.cropId,
    required this.cropName,
    this.cultivationId,
  });

  @override
  State<HarvestEntryPage> createState() => _HarvestEntryPageState();
}

class _HarvestEntryPageState extends State<HarvestEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final Map<String, dynamic> _formData = {
    'harvestDate': '',
    'quantityKg': '',
    'note': '',
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    final today = DateTime.now();
    _formData['harvestDate'] = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  // In harvest_entry_page.dart, add debug prints:
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        print('💾 Saving harvest for crop:');
        print('   cropId: ${widget.cropId}');
        print('   cropName: ${widget.cropName}');
        print('   cultivationId: ${widget.cultivationId}');

        // In _handleSubmit method of harvest_entry_page.dart:
        final harvest = Harvest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '', // Will be set by FirebaseService
          cropId: widget.cropId,
          cropName: widget.cropName,
          harvestDate: DateTime.parse(_formData['harvestDate']),
          quantityKg: double.parse(_formData['quantityKg']),
          note: _formData['note'].isNotEmpty ? _formData['note'] : null,
          createdAt: DateTime.now(),
          cultivationId: widget.cultivationId, // ADD THIS - link to specific cultivation
        );

        // ... rest of the code

        // Save to Firebase
        await _firebaseService.addHarvest(harvest);

        // If linked to cultivation, update its status
        if (widget.cultivationId != null) {
          await _firebaseService.updateCultivationStatus(widget.cultivationId!, 'Harvested');
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harvest saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after delay
        await Future.delayed(const Duration(milliseconds: 1500));
        widget.onSave();

      } catch (e) {
        print('❌ Error saving harvest: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save harvest. Please try again.'),
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _formData['harvestDate'] = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
              title: 'Record Harvest',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Crop info banner
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
                              Icons.agriculture,
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
                                  'Crop: ${widget.cropName}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter harvested quantity in kilograms',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AgriKeepTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Simple Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Crop Name (auto-linked, read-only)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AgriKeepTheme.borderColor),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crop',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AgriKeepTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.cropName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Harvest Date
                          Text(
                            'Harvest Date *',
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
                                    _formData['harvestDate'],
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
                          const SizedBox(height: 16),

                          // Quantity in kg (Required)
                          Text(
                            'Quantity Harvested (kg) *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Enter quantity in kilograms',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AgriKeepTheme.borderColor),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixText: 'kg',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Quantity must be greater than 0';
                              }
                              return null;
                            },
                            onChanged: (value) => _formData['quantityKg'] = value,
                          ),
                          const SizedBox(height: 16),

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
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Short note (e.g., "Good yield", "Smaller size than usual")',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AgriKeepTheme.borderColor),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) => _formData['note'] = value,
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          CustomButton(
                            text: _isSaving ? 'Saving...' : 'Save Harvest Record',
                            onPressed: _isSaving ? null : _handleSubmit,
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