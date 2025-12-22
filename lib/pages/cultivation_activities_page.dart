import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/utils/theme.dart';

class CultivationActivitiesPage extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(String)? onNavigate;

  const CultivationActivitiesPage({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final currentCrops = [
      _CropData(
        id: '1',
        name: 'Rice',
        plantingDate: DateTime(2024, 1, 15),
        status: 'Growing',
        progress: 38,
        daysElapsed: 45,
        totalDays: 120,
        lastActivity: 'Fertilizer applied 3 days ago',
      ),
      _CropData(
        id: '2',
        name: 'Wheat',
        plantingDate: DateTime(2024, 1, 10),
        status: 'Growing',
        progress: 62,
        daysElapsed: 75,
        totalDays: 120,
        lastActivity: 'Watering completed 1 day ago',
      ),
      _CropData(
        id: '3',
        name: 'Cotton',
        plantingDate: DateTime(2024, 2, 1),
        status: 'Planted',
        progress: 15,
        daysElapsed: 25,
        totalDays: 165,
        lastActivity: 'Planted 25 days ago',
      ),
    ];

    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
          AppHeader(
          title: 'Cultivation Log',
          onBack: onBack,
          action: IconButton(
            onPressed: () {
              if (onNavigate != null) {
                onNavigate!('add-cultivation');
              }
            },
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
          // Active cultivations count
          CustomCard(
          child: Column(
          children: [
            Text(
            'Active Cultivations',
            style: TextStyle(
              fontSize: 14,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentCrops.length.toString(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // Current crops header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Current Crops',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Calendar View',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AgriKeepTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Current crops list
      Column(
        children: currentCrops.map((crop) {
          return CustomCard(
            onTap: () {
              if (onNavigate != null) {
                onNavigate!('cultivation-detail');
              }
            },

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
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
          crop.name,
          style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AgriKeepTheme.textPrimary,
          ),
          ),
          const SizedBox(height: 2),
          Text(
          crop.status,
          style: const TextStyle(
          fontSize: 14,
          color: AgriKeepTheme.textSecondary,
          ),
          ),
          ],
          ),
          Container(
          padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
          ),
          decoration: BoxDecoration(
          color: AgriKeepTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
          'Day ${crop.daysElapsed}/${crop.totalDays}',
          style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AgriKeepTheme.primaryColor,
          ),
          ),
          ),
          ],
          ),
          const SizedBox(height: 8),
          Row(
          children: [
          Icon(
          Icons.calendar_today,
          size: 14,
          color: AgriKeepTheme.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
          'Planted ${DateFormat('MM/dd/yyyy').format(crop.plantingDate)}',
          style: TextStyle(
          fontSize: 12,
          color: AgriKeepTheme.textTertiary,
          ),
          ),
          ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
          value: crop.progress / 100,
          backgroundColor: AgriKeepTheme.borderColor,
          valueColor: const AlwaysStoppedAnimation<Color>(
          AgriKeepTheme.primaryColor,
          ),
          borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
          crop.lastActivity,
          style: TextStyle(
          fontSize: 12,
          color: AgriKeepTheme.textSecondary,
          ),
          ),
          ],
          ),
          ),
          ],
          ),
          ],
          ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),

      // Add new cultivation button
      CustomButton(
        text: 'Add New Cultivation',
        onPressed: () {
          if (onNavigate != null) {
            onNavigate!('add-cultivation');
          }
        },
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

class _CropData {
  final String id;
  final String name;
  final DateTime plantingDate;
  final String status;
  final int progress;
  final int daysElapsed;
  final int totalDays;
  final String lastActivity;

  _CropData({
    required this.id,
    required this.name,
    required this.plantingDate,
    required this.status,
    required this.progress,
    required this.daysElapsed,
    required this.totalDays,
    required this.lastActivity,
  });
}