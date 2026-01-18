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
  final String cropId;
  final String cropName;
  final String? cultivationId;
  final Harvest? harvest; // ADD THIS for edit mode

  const HarvestEntryPage({
    super.key,
    required this.onBack,
    required this.onSave,
    required this.cropId,
    required this.cropName,
    this.cultivationId,
    this.harvest, // ADD THIS
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
  bool _isEditMode = false; // ADD THIS
  String? _harvestId; // ADD THIS

  @override
  void initState() {
    super.initState();

    // Check if we're in edit mode
    if (widget.harvest != null) {
      _isEditMode = true;
      _harvestId = widget.harvest!.id;
      _formData['harvestDate'] = DateFormat('yyyy-MM-dd').format(widget.harvest!.harvestDate);
      _formData['quantityKg'] = widget.harvest!.quantityKg.toString();
      _formData['note'] = widget.harvest!.note ?? '';
    } else {
      // Set default date to today for new harvests
      final today = DateTime.now();
      _formData['harvestDate'] = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        print('💾 ${_isEditMode ? 'Updating' : 'Saving'} harvest for crop:');
        print('   cropId: ${widget.cropId}');
        print('   cropName: ${widget.cropName}');
        print('   cultivationId: ${widget.cultivationId}');

        final harvest = Harvest(
          id: _isEditMode ? _harvestId! : DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '', // Will be set by FirebaseService
          cropId: widget.cropId,
          cropName: widget.cropName,
          harvestDate: DateTime.parse(_formData['harvestDate']),
          quantityKg: double.parse(_formData['quantityKg']),
          note: _formData['note'].isNotEmpty ? _formData['note'] : null,
          createdAt: _isEditMode ? widget.harvest!.createdAt : DateTime.now(),
          cultivationId: widget.cultivationId,
        );

        if (_isEditMode) {
          // Update existing harvest
          await _firebaseService.updateHarvest(harvest);
        } else {
          // Save new harvest
          await _firebaseService.addHarvest(harvest);

          // If linked to cultivation, update its status
          if (widget.cultivationId != null) {
            await _firebaseService.updateCultivationStatus(widget.cultivationId!, 'Harvested');
          }
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Harvest updated successfully!'
                : 'Harvest saved successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after delay
        await Future.delayed(const Duration(milliseconds: 1500));
        widget.onSave();

      } catch (e) {
        print('❌ Error ${_isEditMode ? 'updating' : 'saving'} harvest: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isEditMode ? 'update' : 'save'} harvest. Please try again.'),
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
      initialDate: _formData['harvestDate'].isNotEmpty
          ? DateTime.parse(_formData['harvestDate'])
          : DateTime.now(),
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
              title: _isEditMode ? 'Edit Harvest' : 'Record Harvest', // UPDATED
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
                                  _isEditMode ? 'Edit harvested quantity' : 'Enter harvested quantity in kilograms',
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
                            initialValue: _formData['quantityKg'], // ADD THIS for edit mode
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
                            initialValue: _formData['note'], // ADD THIS for edit mode
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
                            text: _isSaving
                                ? (_isEditMode ? 'Updating...' : 'Saving...')
                                : (_isEditMode ? 'Update Harvest Record' : 'Save Harvest Record'),
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