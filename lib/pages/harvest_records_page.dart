import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/record_item.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/services/firebase_service.dart';
import 'package:agrikeep/models/harvest.dart';

class HarvestRecordsPage extends StatefulWidget {
  final VoidCallback onBack;
  final String? cropId; // Optional: filter by specific crop

  const HarvestRecordsPage({
    super.key,
    required this.onBack,
    this.cropId,
  });

  @override
  State<HarvestRecordsPage> createState() => _HarvestRecordsPageState();
}

class _HarvestRecordsPageState extends State<HarvestRecordsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Harvest> _harvests = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'week', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _loadHarvests();
  }

  Future<void> _loadHarvests() async {
    setState(() => _isLoading = true);

    try {
      final List<Harvest> harvests;
      if (widget.cropId != null) {
        harvests = await _firebaseService.getHarvestsByCropId(widget.cropId!);
      } else {
        harvests = await _firebaseService.getHarvests();
      }

      // Apply time filter
      final filteredHarvests = _applyTimeFilter(harvests);

      setState(() {
        _harvests = filteredHarvests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading harvests: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Harvest> _applyTimeFilter(List<Harvest> harvests) {
    if (_filter == 'all') return harvests;

    final now = DateTime.now();
    DateTime startDate;

    switch (_filter) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        return harvests;
    }

    return harvests.where((harvest) => harvest.harvestDate.isAfter(startDate)).toList();
  }

  double get _totalQuantity {
    return _harvests.fold(0.0, (sum, harvest) => sum + harvest.quantityKg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: widget.cropId != null ? 'Crop Harvests' : 'All Harvests',
              onBack: widget.onBack,
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
                          Text(
                            'Total Harvested',
                            style: TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_totalQuantity.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AgriKeepTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_harvests.length} harvest${_harvests.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AgriKeepTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('This Week', 'week'),
                          const SizedBox(width: 8),
                          _buildFilterChip('This Month', 'month'),
                          const SizedBox(width: 8),
                          _buildFilterChip('This Year', 'year'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Harvest records list
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_harvests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 48,
                              color: AgriKeepTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No harvest records yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Record your first harvest to see it here',
                              style: TextStyle(
                                fontSize: 14,
                                color: AgriKeepTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Harvests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AgriKeepTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._harvests.map((harvest) {
                            return RecordItem(
                              title: harvest.cropName,
                              subtitle: harvest.note ?? 'No additional notes',
                              value: '${harvest.quantityKg.toStringAsFixed(1)} kg',
                              date: DateFormat('MM/dd/yyyy').format(harvest.harvestDate),
                              badge: DateFormat('HH:mm').format(harvest.harvestDate),
                            );
                          }).toList(),
                        ],
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = value;
            _loadHarvests(); // Reload with new filter
          });
        }
      },
      selectedColor: AgriKeepTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AgriKeepTheme.textPrimary,
      ),
    );
  }
}