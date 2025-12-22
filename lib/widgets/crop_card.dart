import 'package:agrikeep/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/utils/theme.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onTap;
  final bool showRecommendedBadge;

  const CropCard({
    super.key,
    required this.crop,
    this.onTap,
    this.showRecommendedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final waterColor = _getWaterColor(crop.waterRequirement);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AgriKeepTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${crop.season} Season',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AgriKeepTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showRecommendedBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AgriKeepTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AgriKeepTheme.successColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Crop details
          Column(
            children: [
              _buildDetailRow(
                icon: Icons.calendar_today,
                text: crop.duration,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.water_drop,
                text: '${crop.waterRequirement} Water',
                iconColor: waterColor,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.trending_up,
                text: crop.expectedYield,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Market price
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AgriKeepTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Market Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AgriKeepTheme.textSecondary,
                  ),
                ),
                Text(
                  crop.marketPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AgriKeepTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? AgriKeepTheme.textTertiary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AgriKeepTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getWaterColor(String requirement) {
    switch (requirement.toLowerCase()) {
      case 'high':
        return const Color(0xFF2563EB); // blue-600
      case 'medium':
        return const Color(0xFF3B82F6); // blue-500
      case 'low':
        return const Color(0xFF60A5FA); // blue-400
      default:
        return AgriKeepTheme.textTertiary;
    }
  }
}