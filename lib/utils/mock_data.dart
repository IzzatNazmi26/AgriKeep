import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/models/farm_profile.dart';
import 'package:agrikeep/models/sales_record.dart';
import 'package:agrikeep/models/yield_record.dart';

class MockData {
  // Malaysian Cash Crops
  static final List<Crop> mockCrops = [
    // Your original 6 crops (updated durations for consistency)
    Crop(
      id: '1',
      name: 'Cherry Tomato',
      season: 'Year-round (Greenhouse)',
      duration: '75–90 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Sandy loam', 'Well-drained'],
      expectedYield: '4–6 kg/plant',
      marketPrice: 'RM 6–10/kg',
      category: 'Cash Crop',
      description: 'Cherry tomato is a high-value greenhouse cash crop with stable market demand.',
      climate: 'Full Sun',
      tips: [
        'Grow under greenhouse with trellis support',
        'Maintain consistent irrigation',
        'Ensure good ventilation',
        'Harvest when fruits fully ripen',
      ],
    ),

    Crop(
      id: '2',
      name: 'Cucumber',
      season: 'Year-round (Greenhouse)',
      duration: '45–60 days',
      waterRequirement: 'High',
      soilType: ['Loamy', 'Sandy loam'],
      expectedYield: '3–5 kg/plant',
      marketPrice: 'RM 2–4/kg',
      category: 'Cash Crop',
      description: 'Fast-growing greenhouse cucumber suitable for continuous harvest.',
      climate: 'Full Sun',
      tips: [
        'Use vertical trellis system',
        'Maintain high soil moisture',
        'Harvest early for better quality',
        'Avoid overcrowding',
      ],
    ),

    Crop(
      id: '3',
      name: 'Capsicum (Bell Pepper)',
      season: 'Year-round (Greenhouse)',
      duration: '90–120 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Well-drained'],
      expectedYield: '2–4 kg/plant',
      marketPrice: 'RM 8–15/kg',
      category: 'Cash Crop',
      description: 'Capsicum is a premium greenhouse cash crop with strong market returns.',
      climate: 'Full Sun to Partial Shade',
      tips: [
        'Control temperature inside greenhouse',
        'Use drip irrigation',
        'Avoid excessive nitrogen',
        'Harvest at mature color stage',
      ],
    ),

    Crop(
      id: '4',
      name: 'Lettuce',
      season: 'Year-round (Greenhouse)',
      duration: '30–45 days',
      waterRequirement: 'Moderate',
      soilType: ['Loose loamy', 'Organic-rich'],
      expectedYield: '0.3–0.5 kg/plant',
      marketPrice: 'RM 4–6/kg',
      category: 'Cash Crop',
      description: 'Lettuce is a short-cycle greenhouse cash crop ideal for quick income.',
      climate: 'Partial Shade',
      tips: [
        'Avoid excessive heat',
        'Maintain moist growing medium',
        'Harvest early morning',
        'Ensure good airflow',
      ],
    ),

    Crop(
      id: '5',
      name: 'Chili (Cili)',
      season: 'Year-round (Greenhouse)',
      duration: '90–120 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Sandy loam'],
      expectedYield: '1.5–3 kg/plant',
      marketPrice: 'RM 8–15/kg',
      category: 'Cash Crop',
      description: 'Chili is a high-demand greenhouse cash crop with good price stability.',
      climate: 'Full Sun',
      tips: [
        'Grow on raised beds or grow bags',
        'Install drip irrigation',
        'Control pests proactively',
        'Harvest regularly to increase yield',
      ],
    ),

    Crop(
      id: '6',
      name: 'Spinach',
      season: 'Year-round (Greenhouse)',
      duration: '25–35 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Moist but well-drained'],
      expectedYield: '1.5–2.5 kg/m²',
      marketPrice: 'RM 3–5/kg',
      category: 'Cash Crop',
      description: 'Spinach is a fast-harvest greenhouse leafy cash crop.',
      climate: 'Partial Shade',
      tips: [
        'Harvest young leaves',
        'Maintain consistent moisture',
        'Avoid overcrowding',
        'Apply light nitrogen fertilizer',
      ],
    ),

    // UPDATED & NEW CROPS:

    // 7. Bitter Gourd - Covers 'Low' water, 'Clay' soil
    Crop(
      id: '7',
      name: 'Bitter Gourd (Peria)',
      season: 'Year-round (Greenhouse)',
      duration: '70–85 days',
      waterRequirement: 'Low',
      soilType: ['Clay', 'Clay loam', 'Well-drained'],
      expectedYield: '8–12 kg/plant',
      marketPrice: 'RM 4–7/kg',
      category: 'Cash Crop',
      description: 'Popular Malaysian vegetable with medicinal value. Drought tolerant once established.',
      climate: 'Full Sun',
      tips: [
        'Use trellis for better yield',
        'Harvest when fruits are green and firm',
        'Tolerant to dry conditions',
      ],
    ),

    // 8. Okra - Covers 'Clay' soil, 'Moderate' water
    Crop(
      id: '8',
      name: 'Okra (Bendi)',
      season: 'Year-round (Greenhouse)',
      duration: '50–65 days',
      waterRequirement: 'Moderate',
      soilType: ['Clay', 'Clay loam'],
      expectedYield: '2–3 kg/plant',
      marketPrice: 'RM 3–6/kg',
      category: 'Cash Crop',
      description: 'Fast-growing vegetable, popular in Malaysian cuisine.',
      climate: 'Full Sun',
      tips: [
        'Harvest daily when pods are young',
        'Good for clay soil areas',
        'Continuous harvest possible',
      ],
    ),

    // 9. Watermelon - Covers 'Sandy' soil, 'High' water
    Crop(
      id: '9',
      name: 'Watermelon (Tembikai)',
      season: 'Year-round (Greenhouse)',
      duration: '80–95 days',
      waterRequirement: 'High',
      soilType: ['Sandy', 'Sandy loam'],
      expectedYield: '2–3 fruits/plant',
      marketPrice: 'RM 3–5/kg',
      category: 'Cash Crop',
      description: 'Popular fruit crop for greenhouse cultivation.',
      climate: 'Full Sun',
      tips: [
        'Requires ample space',
        'Needs consistent watering',
        'Harvest when tendril near fruit dries',
      ],
    ),

    // 10. Starfruit - Replaces Pineapple, covers 'Peat Soil'
    Crop(
      id: '10',
      name: 'Starfruit (Belimbing)',
      season: 'Year-round (Greenhouse)',
      duration: '60–90 days',
      waterRequirement: 'Moderate',
      soilType: ['Peat Soil', 'Sandy loam', 'Well-drained'],
      expectedYield: '15–25 kg/tree',
      marketPrice: 'RM 4–8/kg',
      category: 'Cash Crop',
      description: 'Tropical fruit that tolerates peat soil conditions.',
      climate: 'Full Sun',
      tips: [
        'Prune to maintain size in greenhouse',
        'Harvest when fully yellow',
        'Can produce year-round',
      ],
    ),

    // 11. Dragon Fruit - Short-cycle alternative
    Crop(
      id: '11',
      name: 'Dragon Fruit (Buah Naga)',
      season: 'Year-round (Greenhouse)',
      duration: '90–120 days',
      waterRequirement: 'Low',
      soilType: ['Sandy', 'Peat Soil', 'Well-drained'],
      expectedYield: '10–15 kg/plant/year',
      marketPrice: 'RM 8–15/kg',
      category: 'Cash Crop',
      description: 'High-value cactus fruit suitable for greenhouse.',
      climate: 'Full Sun',
      tips: [
        'Use vertical support',
        'Drought tolerant',
        'Harvest when color fully develops',
      ],
    ),

    // 12. Long Bean - Covers 'Low' water, 'Sandy' soil
    Crop(
      id: '12',
      name: 'Long Bean (Kacang Panjang)',
      season: 'Year-round (Greenhouse)',
      duration: '45–60 days',
      waterRequirement: 'Low',
      soilType: ['Sandy', 'Sandy loam'],
      expectedYield: '3–5 kg/plant',
      marketPrice: 'RM 3–5/kg',
      category: 'Cash Crop',
      description: 'Fast-growing legume, popular in Malaysian dishes.',
      climate: 'Full Sun',
      tips: [
        'Use trellis for straight pods',
        'Harvest regularly',
        'Drought tolerant',
      ],
    ),

    // 13. Sweet Corn - Covers 'Sandy' soil, 'High' water
    Crop(
      id: '13',
      name: 'Sweet Corn (Jagung Manis)',
      season: 'Year-round (Greenhouse)',
      duration: '65–80 days',
      waterRequirement: 'High',
      soilType: ['Sandy', 'Sandy loam'],
      expectedYield: '1–2 ears/plant',
      marketPrice: 'RM 2–4/ear',
      category: 'Cash Crop',
      description: 'Popular sweet corn for local market.',
      climate: 'Full Sun',
      tips: [
        'Plant in blocks for pollination',
        'Needs consistent moisture',
        'Harvest when silks turn brown',
      ],
    ),

    // 14. Roselle - Covers various soils, 'Moderate' water
    Crop(
      id: '14',
      name: 'Roselle (Asam Belanda)',
      season: 'Year-round (Greenhouse)',
      duration: '120–150 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Sandy', 'Clay', 'Well-drained'],
      expectedYield: '2–3 kg/plant',
      marketPrice: 'RM 10–20/kg (dried calyx)',
      category: 'Cash Crop',
      description: 'Medicinal plant used for drinks and jam.',
      climate: 'Full Sun',
      tips: [
        'Harvest calyx when fully grown',
        'Drought tolerant once established',
        'Good for various soil types',
      ],
    ),

    // 15. Eggplant - Additional short-cycle crop
    Crop(
      id: '15',
      name: 'Eggplant (Terung)',
      season: 'Year-round (Greenhouse)',
      duration: '70–85 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Well-drained'],
      expectedYield: '3–5 kg/plant',
      marketPrice: 'RM 5–8/kg',
      category: 'Cash Crop',
      description: 'Popular vegetable in Malaysian cuisine.',
      climate: 'Full Sun',
      tips: [
        'Use stake support',
        'Harvest when fruits are shiny',
        'Control fruit fly pests',
      ],
    ),

    // 16. Kai Lan - Very short cycle, covers 'Shaded'
    Crop(
      id: '16',
      name: 'Kai Lan (Chinese Kale)',
      season: 'Year-round (Greenhouse)',
      duration: '40–50 days',
      waterRequirement: 'Moderate',
      soilType: ['Loamy', 'Organic-rich'],
      expectedYield: '1–2 kg/m²',
      marketPrice: 'RM 4–7/kg',
      category: 'Cash Crop',
      description: 'Fast-growing leafy vegetable.',
      climate: 'Partial Shade',
      tips: [
        'Harvest whole plant or leaves',
        'Maintain consistent moisture',
        'Can be harvested multiple times',
      ],
    ),

  ];


  // Farm Profile - Updated for Malaysian greenhouse
  static final FarmProfile mockFarmProfile = FarmProfile(
    id: '1',
    userId: 'user123',
    farmName: 'Greenhouse Farm Malaysia',
    location: 'Selangor, Malaysia',
    totalArea: 0.5, // 0.5 hectare typical for smallholder
    soilType: 'Loamy',
    irrigationType: 'Drip Irrigation',
    preferredCrops: ['Cherry Tomato', 'Cucumber', 'Capsicum'], // Your greenhouse crops
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  );

  // Yield Records - Updated for greenhouse crops
  static final List<YieldRecord> mockYields = [
    YieldRecord(
      id: '1',
      userId: 'user123',
      cropId: '1',
      cropName: 'Cherry Tomato',
      quantity: 25.5,
      unit: 'kg',
      date: DateTime(2024, 2, 15),
      quality: 'Good',
      expectedYield: 20.0,
      performancePercentage: 127.5,
      createdAt: DateTime(2024, 2, 15),
    ),
    YieldRecord(
      id: '2',
      userId: 'user123',
      cropId: '2',
      cropName: 'Cucumber',
      quantity: 18.2,
      unit: 'kg',
      date: DateTime(2024, 2, 10),
      quality: 'Excellent',
      expectedYield: 15.0,
      performancePercentage: 121.3,
      createdAt: DateTime(2024, 2, 10),
    ),
  ];

  // Sales Records - Updated for greenhouse crops
  static final List<SalesRecord> mockSales = [
    SalesRecord(
      id: '1',
      userId: 'user123',
      cropId: '1',
      cropName: 'Cherry Tomato',
      quantity: 25.5,
      unit: 'kg',
      pricePerUnit: 8.0, // RM 8/kg
      totalAmount: 204.0,
      buyer: 'Local Market',
      date: DateTime(2024, 2, 16),
      createdAt: DateTime(2024, 2, 16),
    ),
    SalesRecord(
      id: '2',
      userId: 'user123',
      cropId: '2',
      cropName: 'Cucumber',
      quantity: 18.2,
      unit: 'kg',
      pricePerUnit: 3.0, // RM 3/kg
      totalAmount: 54.6,
      buyer: 'Vegetable Supplier',
      date: DateTime(2024, 2, 11),
      createdAt: DateTime(2024, 2, 11),
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