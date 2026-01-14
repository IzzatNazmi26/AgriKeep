import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/widgets/record_item.dart';
import 'package:agrikeep/widgets/input_field.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/services/firebase_service.dart';
import 'package:agrikeep/models/sales_record.dart';
import 'package:agrikeep/models/crop.dart';

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
  bool _isEditMode = false;
  String _editingRecordId = '';
  final Map<String, String?> _formData = {
    'cropName': null,
    'quantity': '',
    'unit': 'kg',
    'date': '',
    'pricePerUnit': '',
    'buyer': '',
  };

  final FirebaseService _firebaseService = FirebaseService();
  List<SalesRecord> _salesRecords = [];
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  double _totalQuantity = 0.0;

  List<Crop> get crops => MockData.mockCrops;

  List<String> get cropNames => crops.map((crop) => crop.name).toList();

  String? getCropIdByName(String cropName) {
    try {
      return crops.firstWhere((crop) => crop.name == cropName).id;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set default date to today
    final today = DateTime.now();
    _formData['date'] = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    _loadSalesRecords();
  }

  Future<void> _loadSalesRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await _firebaseService.getSalesRecords();
      double revenue = 0.0;
      double quantity = 0.0;

      for (var record in records) {
        revenue += record.totalAmount;
        quantity += record.quantity;
      }

      setState(() {
        _salesRecords = records;
        _totalRevenue = revenue;
        _totalQuantity = quantity;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sales records: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handleSubmit() async {
    print('=== _handleSubmit() called ===');
    print('Form data: $_formData');
    print('Is edit mode: $_isEditMode');

    if (_formData['cropName'] == null ||
        _formData['cropName']!.isEmpty ||
        _formData['quantity']!.isEmpty ||
        _formData['pricePerUnit']!.isEmpty) {
      print('Validation failed - missing required fields');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print('Validation passed');

    try {
      final quantity = double.tryParse(_formData['quantity']!) ?? 0.0;
      final pricePerUnit = double.tryParse(_formData['pricePerUnit']!) ?? 0.0;
      final totalAmount = quantity * pricePerUnit;
      final cropId = getCropIdByName(_formData['cropName']!) ?? '';
      if (cropId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid crop selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final salesRecord = SalesRecord(
        id: _isEditMode ? _editingRecordId : DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '',
        cropId: cropId,
        cropName: _formData['cropName']!,
        quantity: quantity,
        unit: 'kg',
        pricePerUnit: pricePerUnit,
        totalAmount: totalAmount,
        buyer: _formData['buyer'],
        date: DateTime.parse(_formData['date']!),
        notes: null,
        createdAt: DateTime.now(),
      );

      if (_isEditMode) {
        print('Updating sales record: ${salesRecord.id}');
        await _firebaseService.updateSalesRecord(salesRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sales record updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Adding new sales record: ${salesRecord.id}');
        await _firebaseService.addSalesRecord(salesRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sales record added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reset form
      _resetForm();

      // Reload data
      await _loadSalesRecords();

      // Navigate back to records list
      setState(() {
        _showAddForm = false;
        _isEditMode = false;
        _editingRecordId = '';
      });

      print('=== _handleSubmit() completed ===');

    } catch (e) {
      print('Error in _handleSubmit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    final today = DateTime.now();
    _formData['cropName'] = null;
    _formData['quantity'] = '';
    _formData['unit'] = 'kg';
    _formData['date'] = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _formData['pricePerUnit'] = '';
    _formData['buyer'] = '';
  }

  Future<void> _selectDate(BuildContext context) async {
    // Parse current date or use today if not set
    DateTime initialDate;
    if (_formData['date'] != null && _formData['date']!.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_formData['date']!);
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    if (picked != null) {
      setState(() {
        _formData['date'] = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _editRecord(SalesRecord record) {
    setState(() {
      _showAddForm = true;
      _isEditMode = true;
      _editingRecordId = record.id;
      // Populate form with record data
      _formData['cropName'] = record.cropName;
      _formData['quantity'] = record.quantity.toString();
      _formData['unit'] = record.unit;
      _formData['date'] = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}'; // Already correct
      _formData['pricePerUnit'] = record.pricePerUnit.toString();
      _formData['buyer'] = record.buyer ?? '';
    });
  }

  void _deleteRecord(String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record'),
        content: Text('Are you sure you want to delete this sales record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.deleteSalesRecord(recordId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSalesRecords();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSalesByCrop() {
    if (_salesRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No sales records available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Map<String, Map<String, dynamic>> cropSales = {};

    for (var sale in _salesRecords) {
      if (!cropSales.containsKey(sale.cropName)) {
        cropSales[sale.cropName] = {
          'totalQuantity': 0.0,
          'totalAmount': 0.0,
          'count': 0,
        };
      }
      cropSales[sale.cropName]!['totalQuantity'] += sale.quantity;
      cropSales[sale.cropName]!['totalAmount'] += sale.totalAmount;
      cropSales[sale.cropName]!['count'] += 1;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sales by Crop'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cropSales.length,
            itemBuilder: (context, index) {
              final cropName = cropSales.keys.elementAt(index);
              final data = cropSales[cropName]!;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AgriKeepTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.eco,
                    color: AgriKeepTheme.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  cropName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AgriKeepTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${data['count']} sale${data['count'] > 1 ? 's' : ''} • ${data['totalQuantity'].toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: AgriKeepTheme.textSecondary,
                  ),
                ),
                trailing: Text(
                  'RM${data['totalAmount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AgriKeepTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
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
                        selectedOption: _formData['cropName'],
                        options: cropNames,
                        onOptionSelected: (value) => setState(() => _formData['cropName'] = value),
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Quantity Sold',
                        value: _formData['quantity'],
                        onChanged: (value) => setState(() => _formData['quantity'] = value),
                        keyboardType: TextInputType.number,
                        unit: 'kg',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      // Sale Date Field with Date Picker
                      Text(
                        'Sale Date *',
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
                                _formData['date'] ?? 'Select date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _formData['date'] == null
                                      ? AgriKeepTheme.textTertiary
                                      : AgriKeepTheme.textPrimary,
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

                      GestureDetector(
                        onTap: () {
                          print('Save button tapped!');
                          _handleSubmit();
                        },
                        child: CustomButton(
                          text: 'Save Sale Record',
                          onPressed: _handleSubmit,
                          variant: ButtonVariant.primary,
                          size: ButtonSize.large,
                          fullWidth: true,
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

  Widget _buildRecordsList() {
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
                                      _isLoading
                                          ? 'Loading...'
                                          : 'RM${_totalRevenue.toStringAsFixed(2)}',
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
                                      _isLoading
                                          ? 'Loading...'
                                          : '${_totalQuantity.toStringAsFixed(1)} kg',
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
                            text: 'View Sales by Crop',
                            onPressed: _showSalesByCrop,
                            variant: ButtonVariant.primary,
                            icon: Icon(
                              Icons.pie_chart,
                              size: 20,
                              color: Colors.white,
                            ),
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: AgriKeepTheme.primaryColor,
                          ),
                        ),
                      )
                    else if (_salesRecords.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 48,
                              color: AgriKeepTheme.textTertiary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No sales records yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first sale to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                        Text(
                          'Recent Sales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AgriKeepTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._salesRecords.map((sale) {
                          return Dismissible(
                            key: Key(sale.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                _deleteRecord(sale.id);
                                return false;
                              }
                              return false;
                            },
                            child: GestureDetector(
                              onTap: () => _editRecord(sale),
                              child: RecordItem(
                                title: sale.cropName,
                                subtitle: (sale.buyer?.isNotEmpty ?? false)
                                    ? sale.buyer!
                                    : 'Direct sale',
                                value: 'RM${sale.totalAmount.toStringAsFixed(2)}',
                                date: '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                                badge: '${sale.quantity.toStringAsFixed(1)} kg',
                              ),
                            ),
                          );
                        }).toList(),
                      ],
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