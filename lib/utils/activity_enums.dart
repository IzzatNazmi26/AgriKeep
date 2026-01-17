
import 'package:flutter/material.dart'; // Add this import

// Utility class for activity-related enums and conversions
class ActivityUtils {
  // Activity type options
  static const List<String> activityTypeOptions = [
    'Planting',
    'Watering',
    'Fertilizer Application',
    'Pest / Disease Control',
    'General Maintenance',
  ];

  // Fertilizer type options (only shown for Fertilizer Application)
  static const List<String> fertilizerTypeOptions = [
    'NPK (Chemical Fertilizer)',
    'Organic Compost',
    'Liquid Fertilizer',
    'Manure / Chicken Dung',
    'Other',
  ];

  // Watering frequency options (only shown for Watering)
  static const List<String> wateringFrequencyOptions = [
    'Once',
    'Twice',
    'Regular',
  ];

  // Helper to check if activity type requires fertilizer field
  static bool requiresFertilizerType(String activityType) {
    return activityType == 'Fertilizer Application';
  }

  // Helper to check if activity type requires watering field
  static bool requiresWateringFrequency(String activityType) {
    return activityType == 'Watering';
  }

  // Convert string to dropdown items
  static List<DropdownMenuItem<String>> getActivityTypeDropdownItems() {
    return activityTypeOptions.map((type) {
      return DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      );
    }).toList();
  }

  static List<DropdownMenuItem<String>> getFertilizerTypeDropdownItems() {
    return fertilizerTypeOptions.map((type) {
      return DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      );
    }).toList();
  }

  static List<DropdownMenuItem<String>> getWateringFrequencyDropdownItems() {
    return wateringFrequencyOptions.map((frequency) {
      return DropdownMenuItem<String>(
        value: frequency,
        child: Text(frequency),
      );
    }).toList();
  }
}