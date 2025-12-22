import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/crop_card.dart';
import 'package:agrikeep/utils/mock_data.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/models/crop.dart';

class CropInformationPage extends StatefulWidget {
  final VoidCallback onBack;

  const CropInformationPage({
    super.key,
    required this.onBack,
  });

  @override
  State<CropInformationPage> createState() => _CropInformationPageState();
}

class _CropInformationPageState extends State<CropInformationPage> {
  final TextEditingController _searchController = TextEditingController();
  Crop? _selectedCrop;
  List<Crop> _filteredCrops = MockData.mockCrops;

  @override
  void initState() {
    super.initState();
    _filteredCrops = MockData.mockCrops;
    _searchController.addListener(_filterCrops);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCrops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCrops = MockData.mockCrops;
      } else {
        _filteredCrops = MockData.mockCrops.where((crop) {
          return crop.name.toLowerCase().contains(query) ||
              crop.category.toLowerCase().contains(query) ||
              crop.description?.toLowerCase().contains(query) == true;
        }).toList();
      }
    });
  }

  void _selectCrop(Crop crop) {
    setState(() => _selectedCrop = crop);
  }

  void _clearSelection() {
    setState(() => _selectedCrop = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCrop != null) {
      return _buildCropDetailScreen();
    }

    return _buildCropListScreen();
  }

  Widget _buildCropListScreen() {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Crop Information',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AgriKeepTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: AgriKeepTheme.textTertiary,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search Malaysian crops...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'Search Results'
                          : 'Malaysian Cash Crops',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Crop grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _filteredCrops.length,
                      itemBuilder: (context, index) {
                        final crop = _filteredCrops[index];
                        return GestureDetector(
                          onTap: () => _selectCrop(crop),
                          child: CustomCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.eco,
                                    size: 24,
                                    color: AgriKeepTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  crop.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  crop.category,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AgriKeepTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildCropDetailScreen() {
    final crop = _selectedCrop!;

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: crop.name,
              onBack: _clearSelection,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Crop overview
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AgriKeepTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.eco,
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
                                      crop.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AgriKeepTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      crop.category,
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
                          const SizedBox(height: 16),
                          Text(
                            crop.description ?? 'No description available',
                            style: TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Growing details
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Growing Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            icon: Icons.calendar_today,
                            label: 'Season',
                            value: crop.season,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailItem(
                            icon: Icons.calendar_today,
                            label: 'Duration',
                            value: crop.duration,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailItem(
                            icon: Icons.water_drop,
                            label: 'Water Requirement',
                            value: crop.waterRequirement,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailItem(
                            icon: Icons.terrain,
                            label: 'Soil Type',
                            value: crop.soilType.join(', '),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailItem(
                            icon: Icons.wb_sunny,
                            label: 'Climate',
                            value: crop.climate ?? 'Not specified',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expected returns
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expected Returns',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expected Yield',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AgriKeepTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      crop.expectedYield,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AgriKeepTheme.primaryColor,
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
                                      'Market Price',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AgriKeepTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      crop.marketPrice,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AgriKeepTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Growing tips
                    if (crop.tips != null && crop.tips!.isNotEmpty)
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Growing Tips',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AgriKeepTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...crop.tips!.map((tip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AgriKeepTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AgriKeepTheme.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AgriKeepTheme.textTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AgriKeepTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AgriKeepTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}