import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Chip de informação de saúde exibido na página de detalhes do pet.
///
/// Aceita três estados:
/// - `true`  → confirmado (verde)
/// - `false` → negado (vermelho)
/// - `null`  → desconhecido (cinza)
class HealthChip extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Estado tristate:
  /// - `true`  → confirmado
  /// - `false` → negado
  /// - `null`  → desconhecido
  final bool? isActive;

  const HealthChip({
    super.key,
    required this.icon,
    required this.label,
    this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color bgColor;
    final String suffix;

    if (isActive == null) {
      color = AppColors.textHint;
      bgColor = AppColors.textHint.withValues(alpha: 0.1);
      suffix = ': não informado';
    } else if (isActive!) {
      color = AppColors.secondary;
      bgColor = AppColors.secondary.withValues(alpha: 0.1);
      suffix = '';
    } else {
      color = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: 0.1);
      suffix = ': não';
    }

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
            '$label$suffix',
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
