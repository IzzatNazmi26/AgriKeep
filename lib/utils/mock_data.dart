import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/models/farm_profile.dart';
import 'package:agrikeep/models/sales_record.dart';
import 'package:agrikeep/models/yield_record.dart';

class MockData {
  // Malaysian Cash Crops
  static final List<Crop> mockCrops = [
    Crop(
      id: '1',
      name: 'Oil Palm',
      season: 'Year-round',
      duration: '3-4 years to first harvest',
      waterRequirement: 'High',
      soilType: ['Deep alluvial', 'Clay loam'],
      expectedYield: '18-25 tons FFB/hectare/year',
      marketPrice: 'RM 600-800/ton',
      category: 'Cash Crop',
      description: "Oil palm is Malaysia's most important agricultural crop. It thrives in tropical climates with consistent rainfall and produces high-value palm oil.",
      climate: 'Tropical, 2000-3000mm rainfall',
      tips: [
        'Requires consistent rainfall throughout the year',
        'Plant in well-drained deep soils',
        'Regular fertilization essential for high yields',
        'Harvest fresh fruit bunches at optimal ripeness',
      ],
    ),
    Crop(
      id: '2',
      name: 'Rubber',
      season: 'Year-round tapping',
      duration: '5-7 years to maturity',
      waterRequirement: 'Medium-High',
      soilType: ['Well-drained loamy', 'Clay loam'],
      expectedYield: '1,500-2,000 kg latex/hectare/year',
      marketPrice: 'RM 5-7/kg',
      category: 'Cash Crop',
      description: 'Natural rubber is a major export crop in Malaysia. Rubber trees are tapped for latex, providing steady income for smallholders.',
      climate: 'Tropical, 2000-2500mm rainfall',
      tips: [
        'Tap trees early morning for best latex flow',
        'Maintain proper tapping panel management',
        'Apply fertilizer twice yearly',
        'Control leaf diseases promptly',
      ],
    ),
    Crop(
      id: '3',
      name: 'Padi (Rice)',
      season: 'Main season & Off-season',
      duration: '105-120 days',
      waterRequirement: 'High',
      soilType: ['Clay', 'Clay loam'],
      expectedYield: '4-6 tons/hectare',
      marketPrice: 'RM 1,200-1,500/ton',
      category: 'Food Crop',
      description: "Rice is Malaysia's staple food crop, grown mainly in granary areas. Both irrigated and rain-fed cultivation systems are used.",
      climate: 'Tropical lowlands, high humidity',
      tips: [
        'Maintain 2-5cm water level during growth',
        'Use certified seeds for better yields',
        'Apply fertilizer in split doses',
        'Control golden snail and rats',
      ],
    ),
    Crop(
      id: '4',
      name: 'Durian',
      season: 'June-August (main), Dec-Feb (minor)',
      duration: '4-5 years to first fruit',
      waterRequirement: 'Medium',
      soilType: ['Deep loamy', 'Well-drained clay loam'],
      expectedYield: '50-100 fruits/tree/year',
      marketPrice: 'RM 25-60/kg (variety dependent)',
      category: 'Fruit',
      description: 'The "King of Fruits" is highly prized in Malaysia. Premium varieties like Musang King command excellent prices in local and export markets.',
      climate: 'Tropical, 1500-2000mm rainfall',
      tips: [
        'Plant grafted trees for consistent quality',
        'Ensure good drainage to prevent root rot',
        'Prune regularly for better fruit production',
        'Harvest only when fruits fall naturally',
      ],
    ),
    Crop(
      id: '5',
      name: 'Banana (Pisang)',
      season: 'Year-round',
      duration: '9-12 months',
      waterRequirement: 'High',
      soilType: ['Rich loamy', 'Well-drained'],
      expectedYield: '30-40 kg/plant',
      marketPrice: 'RM 2-4/kg',
      category: 'Fruit',
      description: 'Bananas are widely grown across Malaysia for both domestic consumption and export. Popular varieties include Berangan and Cavendish.',
      climate: 'Tropical lowlands, high humidity',
      tips: [
        'Plant suckers from healthy mother plants',
        'Mulch heavily to retain moisture',
        'Remove dead leaves regularly',
        'Harvest when fingers are full and rounded',
      ],
    ),
    Crop(
      id: '6',
      name: 'Chili (Cili)',
      season: 'Year-round (with irrigation)',
      duration: '90-120 days',
      waterRequirement: 'Medium',
      soilType: ['Well-drained loamy', 'Sandy loam'],
      expectedYield: '10-15 tons/hectare',
      marketPrice: 'RM 8-15/kg',
      category: 'Vegetable',
      description: "Chili is an essential ingredient in Malaysian cuisine. Both bird's eye chili and larger varieties are commercially grown.",
      climate: 'Tropical, well-distributed rainfall',
      tips: [
        'Use raised beds for better drainage',
        'Install drip irrigation for water efficiency',
        'Control thrips and fruit flies promptly',
        'Harvest regularly to encourage more fruiting',
      ],
    ),
    Crop(
      id: '7',
      name: 'Coconut (Kelapa)',
      season: 'Year-round',
      duration: '5-6 years to bearing',
      waterRequirement: 'Medium',
      soilType: ['Sandy loam', 'Coastal alluvial'],
      expectedYield: '80-120 nuts/palm/year',
      marketPrice: 'RM 1.50-2.50/nut',
      category: 'Cash Crop',
      description: 'Coconut palms are versatile crops providing coconuts, copra, and coir. They grow well in coastal and inland areas of Malaysia.',
      climate: 'Tropical coastal, 1500-2000mm rainfall',
      tips: [
        'Plant hybrid varieties for higher yields',
        'Mulch around base to retain moisture',
        'Control rhinoceros beetle infestation',
        'Harvest mature nuts at 11-12 months',
      ],
    ),
    Crop(
      id: '8',
      name: 'Pineapple (Nanas)',
      season: 'Year-round (staggered planting)',
      duration: '18-24 months',
      waterRequirement: 'Low-Medium',
      soilType: ['Sandy loam', 'Well-drained acidic'],
      expectedYield: '50-70 tons/hectare',
      marketPrice: 'RM 3-6/kg',
      category: 'Fruit',
      description: 'Pineapple cultivation is important in Johor and Sarawak. The MD2 variety is popular for export due to its sweetness and shelf life.',
      climate: 'Tropical, 1000-1500mm rainfall',
      tips: [
        'Use certified planting material',
        'Apply plastic mulch to control weeds',
        'Induce flowering with ethylene treatment',
        'Harvest when base color turns yellow',
      ],
    ),
  ];

  // Farm Profile
  static final FarmProfile mockFarmProfile = FarmProfile(
    id: '1',
    userId: 'user123',
    farmName: 'Green Valley Farm',
    location: 'Punjab, India',
    totalArea: 5.5,
    soilType: 'Loamy',
    irrigationType: 'Canal + Tube well',
    preferredCrops: ['Rice', 'Wheat', 'Cotton'],
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  );

  // Yield Records
  static final List<YieldRecord> mockYields = [
    YieldRecord(
      id: '1',
      userId: 'user123',
      cropId: '1',
      cropName: 'Rice',
      quantity: 4.5,
      unit: 'tons',
      date: DateTime(2024, 1, 15),
      quality: 'Good',
      expectedYield: 4.5,
      performancePercentage: 100.0,
      createdAt: DateTime(2024, 1, 15),
    ),
    YieldRecord(
      id: '2',
      userId: 'user123',
      cropId: '2',
      cropName: 'Wheat',
      quantity: 3.2,
      unit: 'tons',
      date: DateTime(2024, 1, 10),
      quality: 'Excellent',
      expectedYield: 3.2,
      performancePercentage: 100.0,
      createdAt: DateTime(2024, 1, 10),
    ),
  ];

  // Sales Records
  static final List<SalesRecord> mockSales = [
    SalesRecord(
      id: '1',
      userId: 'user123',
      cropId: '1',
      cropName: 'Rice',
      quantity: 4.5,
      unit: 'tons',
      pricePerUnit: 450,
      totalAmount: 2025,
      buyer: 'Local Market Co-op',
      date: DateTime(2024, 1, 16),
      createdAt: DateTime(2024, 1, 16),
    ),
    SalesRecord(
      id: '2',
      userId: 'user123',
      cropId: '2',
      cropName: 'Wheat',
      quantity: 3.2,
      unit: 'tons',
      pricePerUnit: 350,
      totalAmount: 1120,
      buyer: 'Regional Distributor',
      date: DateTime(2024, 1, 12),
      createdAt: DateTime(2024, 1, 12),
    ),
  ];

  // Get crop by ID
  static Crop getCropById(String id) {
    return mockCrops.firstWhere((crop) => crop.id == id);
  }

  // Filter crops by season
  static List<Crop> getCropsBySeason(String season) {
    return mockCrops.where((crop) => crop.season.contains(season)).toList();
  }

  // Filter crops by category
  static List<Crop> getCropsByCategory(String category) {
    return mockCrops.where((crop) => crop.category == category).toList();
  }

  // Search crops by name or category
  static List<Crop> searchCrops(String query) {
    if (query.isEmpty) return mockCrops;

    final lowerQuery = query.toLowerCase();
    return mockCrops.where((crop) {
      return crop.name.toLowerCase().contains(lowerQuery) ||
          crop.category.toLowerCase().contains(lowerQuery) ||
          crop.description?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }
}