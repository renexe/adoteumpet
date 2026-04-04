import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/pet.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../presentation/providers/favorites_provider.dart';

/// Card de animal exibido no feed principal.
///
/// Exibe a foto principal, nome, raça, idade, localização
/// e um botão de favoritar.
class PetCard extends ConsumerWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(pet.id);

    return GestureDetector(
      onTap: () => context.push('/pet/${pet.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do pet
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: pet.photos.isNotEmpty ? pet.photos.first : '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.pets,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),

                // Badge de status
                if (pet.status != PetStatus.available)
                  Positioned(
                    top: AppDimensions.sm,
                    left: AppDimensions.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs,
                      ),
                      decoration: BoxDecoration(
                        color: pet.status == PetStatus.adopted
                            ? AppColors.success
                            : AppColors.warning,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        pet.status.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Botão de favoritar
                Positioned(
                  top: AppDimensions.sm,
                  right: AppDimensions.sm,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(pet.id),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : AppColors.textSecondary,
                        size: AppDimensions.iconMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Informações do pet
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e gênero
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: AppTextStyles.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Icon(
                        pet.gender == PetGender.male
                            ? Icons.male
                            : Icons.female,
                        color: pet.gender == PetGender.male
                            ? AppColors.info
                            : AppColors.primary,
                        size: AppDimensions.iconMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),

                  // Raça e idade
                  Text(
                    '${pet.breed} • ${pet.age}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.sm),

                  // Localização e porte
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppDimensions.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${pet.city}, ${pet.state}',
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _SizeChip(size: pet.size),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final PetSize size;

  const _SizeChip({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        size.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
