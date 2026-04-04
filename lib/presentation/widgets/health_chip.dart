import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Chip de informação de saúde exibido na página de detalhes do pet.
///
/// Apresenta informações como "Vacinado", "Castrado" etc.
/// de forma visual e padronizada.
class HealthChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const HealthChip({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.secondary : AppColors.textHint;
    final bgColor = isActive
        ? AppColors.secondary.withValues(alpha: 0.1)
        : AppColors.textHint.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm + 2,
        vertical: AppDimensions.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: color),
          const SizedBox(width: AppDimensions.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
