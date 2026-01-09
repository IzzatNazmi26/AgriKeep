/*
import 'package:flutter/material.dart';
import 'package:agrikeep/widgets/header.dart';
import 'package:agrikeep/widgets/card.dart';
import 'package:agrikeep/widgets/custom_button.dart';
import 'package:agrikeep/utils/theme.dart';

class AnalyticsPage extends StatefulWidget {
  final VoidCallback onBack;

  const AnalyticsPage({
    super.key,
    required this.onBack,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _timeRange = 'month';

  final List<_StatItem> _stats = [
    _StatItem(
      label: 'Total Revenue',
      value: 'RM3,145',
      change: '+12.5%',
      trend: 'up',
      icon: Icons.attach_money,
      color: AgriKeepTheme.primaryColor,
    ),
    _StatItem(
      label: 'Total Yield',
      value: '7.7 tons',
      change: '+8.3%',
      trend: 'up',
      icon: Icons.eco,
      color: AgriKeepTheme.secondaryColor,
    ),
    _StatItem(
      label: 'Avg Price/Ton',
      value: 'RM408',
      change: '-3.2%',
      trend: 'down',
      icon: Icons.trending_up,
      color: AgriKeepTheme.infoColor,
    ),
  ];

  final List<_CropPerformance> _cropPerformance = [
    _CropPerformance(
      crop: 'Rice',
      yieldAmount: 4.5,
      revenue: 2025,
      efficiency: 92,
    ),
    _CropPerformance(
      crop: 'Wheat',
      yieldAmount: 3.2,
      revenue: 1120,
      efficiency: 88,
    ),
    _CropPerformance(
      crop: 'Cotton',
      yieldAmount: 0,
      revenue: 0,
      efficiency: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriKeepTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Record & Analysis',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time range selector
                    Row(
                      children: ['week', 'month', 'year'].map((range) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: CustomButton(
                              text: range[0].toUpperCase() + range.substring(1),
                              onPressed: () => setState(() => _timeRange = range),
                              variant: _timeRange == range
                                  ? ButtonVariant.primary
                                  : ButtonVariant.outline,
                              size: ButtonSize.small,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Key metrics
                    Text(
                      'Key Metrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._stats.map((stat) {
                      return CustomCard(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: stat.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                stat.icon,
                                size: 20,
                                color: stat.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stat.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AgriKeepTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    stat.value,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AgriKeepTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Icon(
                                  stat.trend == 'up'
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 20,
                                  color: stat.trend == 'up'
                                      ? AgriKeepTheme.successColor
                                      : AgriKeepTheme.errorColor,
                                ),
                                Text(
                                  stat.change,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: stat.trend == 'up'
                                        ? AgriKeepTheme.successColor
                                        : AgriKeepTheme.errorColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),

                    // Crop performance
                    Text(
                      'Crop Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._cropPerformance.map((crop) {
                      return CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  crop.crop,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AgriKeepTheme.textPrimary,
                                  ),
                                ),
                                if (crop.efficiency > 0)
                                  Text(
                                    '${crop.efficiency}% efficiency',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AgriKeepTheme.successColor,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (crop.efficiency > 0)
                              LinearProgressIndicator(
                                value: crop.efficiency / 100,
                                backgroundColor: AgriKeepTheme.borderColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AgriKeepTheme.primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              )
                            else
                              Text(
                                'No data yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AgriKeepTheme.textTertiary,
                                ),
                              ),
                            if (crop.efficiency > 0) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Yield',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AgriKeepTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${crop.yieldAmount} tons',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                                          'Revenue',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AgriKeepTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'RM${crop.revenue}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AgriKeepTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),

                    // Insights
                    Text(
                      'Insights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      backgroundColor: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AgriKeepTheme.infoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              size: 18,
                              color: AgriKeepTheme.infoColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Strong Performance',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your rice crop is performing 12% above average. Consider increasing allocation next season.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                              ],
                            ),
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

class _StatItem {
  final String label;
  final String value;
  final String change;
  final String trend; // 'up' or 'down'
  final IconData icon;
  final Color color;

  _StatItem({
    required this.label,
    required this.value,
    required this.change,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

class _CropPerformance {
  final String crop;
  final double yieldAmount;
  final double revenue;
  final int efficiency;

  _CropPerformance({
    required this.crop,
    required this.yieldAmount,
    required this.revenue,
    required this.efficiency,
  });
}*/
