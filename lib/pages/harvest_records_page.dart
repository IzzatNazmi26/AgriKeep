// Remove the filter-related code and simplify

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/record_item.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/services/firebase_service.dart';
import 'package:agrikeep/models/harvest.dart';

// Update the HarvestRecordsPage constructor:
class HarvestRecordsPage extends StatefulWidget {
  final VoidCallback onBack;
  final String? cropId; // Optional: filter by specific crop
  final String? cultivationId; // For navigation back
  final String? cropName; // For displaying title

  const HarvestRecordsPage({
    super.key,
    required this.onBack,
    this.cropId,
    this.cultivationId,
    this.cropName,
  });

  @override
  State<HarvestRecordsPage> createState() => _HarvestRecordsPageState();
}

class _HarvestRecordsPageState extends State<HarvestRecordsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Harvest> _harvests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHarvests();
  }

  // In harvest_records_page.dart, update the _loadHarvests method:
  Future<void> _loadHarvests() async {
    setState(() => _isLoading = true);

    try {
      final List<Harvest> harvests;

      // PRIORITY: Filter by cultivationId first (most specific)
      if (widget.cultivationId != null && widget.cultivationId!.isNotEmpty) {
        print('🌱 Filtering by cultivationId: ${widget.cultivationId}');
        harvests = await _firebaseService.getHarvestsByCultivationId(widget.cultivationId!);
      }
      // Otherwise filter by cropId
      else if (widget.cropId != null && widget.cropId!.isNotEmpty) {
        print('🌱 Filtering by cropId: ${widget.cropId}');
        harvests = await _firebaseService.getHarvestsByCropId(widget.cropId!);
      }
      // Otherwise get all harvests
      else {
        print('🌱 Loading ALL harvests');
        harvests = await _firebaseService.getHarvests();
      }

      // Sort by date (newest first)
      harvests.sort((a, b) => b.harvestDate.compareTo(a.harvestDate));

      setState(() {
        _harvests = harvests;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading harvests: $e');
      setState(() => _isLoading = false);

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load harvests: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get _totalQuantity {
    return _harvests.fold(0.0, (sum, harvest) => sum + harvest.quantityKg);
  }

  // In harvest_records_page.dart, update the build method:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: widget.cropName != null && widget.cropName!.isNotEmpty
                  ? '${widget.cropName} Harvests'
                  : 'All Harvests',
              onBack: widget.onBack,
            ),
            // ... rest of the code
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary card
                    if (_harvests.isNotEmpty)
                      CustomCard(
                        child: Column(
                          children: [
                            Text(
                              widget.cropName != null
                                  ? 'Total Harvested'
                                  : 'Total Harvested',
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
                              widget.cropName != null
                                  ? 'No harvests recorded yet'
                                  : 'No harvest records yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AgriKeepTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.cropName != null
                                  ? 'Record your first harvest for this crop'
                                  : 'Record your first harvest to see it here',
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
                            widget.cropName != null
                                ? 'All Harvests'
                                : 'Recent Harvests',
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
}