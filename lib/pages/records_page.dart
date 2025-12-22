import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/record_item.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/utils/theme.dart';

class RecordsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String)? onNavigate;

  const RecordsPage({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  bool _showAddForm = false;
  final Map<String, String> _formData = {
    'cropName': '',
    'quantity': '',
    'unit': 'tons',
    'date': '',
    'pricePerUnit': '',
    'buyer': '',
  };

  @override
  void initState() {
    super.initState();
    // Set default date to today
    final today = DateTime.now();
    _formData['date'] = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  void _handleSubmit() {
    setState(() {
      _showAddForm = false;
      // Reset form
      _formData.updateAll((key, value) => '');
      _formData['date'] = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      _formData['unit'] = 'tons';
    });
  }

  double get _totalAmount {
    final quantity = double.tryParse(_formData['quantity'] ?? '') ?? 0.0;
    final price = double.tryParse(_formData['pricePerUnit'] ?? '') ?? 0.0;
    return quantity * price;
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      return _buildAddForm();
    }

    return _buildRecordsList();
  }

  Widget _buildAddForm() {
    //final String cropName = _formData['cropName'] as String;

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Record Sale',
              onBack: () => setState(() => _showAddForm = false),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  child: Column(
                    children: [
                      InputField(
                        label: 'Crop Name',
                        value: _formData['cropName']!,
                        onChanged: (value) => setState(() => _formData['cropName'] = value),
                        options: ['Rice', 'Wheat', 'Cotton', 'Sugarcane'],
                        selectedOption: _formData['cropName']!.isNotEmpty ? _formData['cropName'] : null,
                        onOptionSelected: (value) => setState(() => _formData['cropName'] = value ?? ''),
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Quantity Sold',
                        value: _formData['quantity'],
                        onChanged: (value) => setState(() => _formData['quantity'] = value),
                        keyboardType: TextInputType.number,
                        unit: _formData['unit'],
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Sale Date',
                        value: _formData['date'],
                        onChanged: (value) => setState(() => _formData['date'] = value),
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Price per Unit',
                        value: _formData['pricePerUnit'],
                        onChanged: (value) => setState(() => _formData['pricePerUnit'] = value),
                        keyboardType: TextInputType.number,
                        unit: 'RM',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Buyer Name (Optional)',
                        value: _formData['buyer'],
                        onChanged: (value) => setState(() => _formData['buyer'] = value),
                        hintText: 'Enter buyer name or leave blank',
                      ),
                      const SizedBox(height: 16),

                      // Auto-calculated total
                      if (_formData['quantity']!.isNotEmpty && _formData['pricePerUnit']!.isNotEmpty)
                        CustomCard(
                          backgroundColor: const Color(0xFFF0FDF4),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AgriKeepTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'RM${_totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AgriKeepTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Save Sale Record',
                        onPressed: _handleSubmit,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        fullWidth: true,
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

  Widget _buildRecordsList() {
    final totalRevenue = MockData.mockSales.fold(
      0.0,
          (sum, sale) => sum + sale.totalAmount,
    );
    final totalQuantity = MockData.mockSales.fold(
      0.0,
          (sum, sale) => sum + sale.quantity,
    );

    return Scaffold(
        backgroundColor: AgriKeepTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
            AppHeader(
            title: 'Sales Record',
            onBack: widget.onBack,
            action: IconButton(
              onPressed: () => setState(() => _showAddForm = true),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AgriKeepTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary card
                  CustomCard(
                    child: Column(
                      children: [
                    Row(
                    children: [
                    Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Revenue',
                          style: TextStyle(
                            fontSize: 14,
                            color: AgriKeepTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM${totalRevenue.toInt()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Sold',
                          style: TextStyle(
                            fontSize: 14,
                            color: AgriKeepTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalQuantity.toStringAsFixed(1)} tons',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                  text: 'View Detailed Analysis',
                  onPressed: () => widget.onNavigate?.call('sales-detail'),
              variant: ButtonVariant.primary,
              icon: Icon(
                Icons.trending_up,
                size: 20,
                color: Colors.white,
              ),
              fullWidth: true,
            ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recent sales
        Text(
          'Recent Sales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AgriKeepTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...MockData.mockSales.map((sale) {
      return RecordItem(
        title: sale.cropName,
        subtitle: (sale.buyer?.isNotEmpty ?? false)
            ? sale.buyer!
            : 'Direct sale',

        value: 'RM${sale.totalAmount.toInt()}',
        date: '${sale.date.day}/${sale.date.month}/${sale.date.year}',
        badge: '${sale.quantity} ${sale.unit}',
      );
    }).toList(),
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