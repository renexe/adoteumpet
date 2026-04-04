import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/pet.dart';
import '../../../presentation/providers/pets_provider.dart';
import '../../../presentation/providers/favorites_provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/chat_provider.dart';
import '../../../presentation/widgets/health_chip.dart';
import '../../../config/app_router.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petByIdProvider(widget.petId));
    final isFavorite = ref.watch(favoritesProvider).contains(widget.petId);
    final user = ref.watch(currentUserProvider);

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Pet não encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Galeria de fotos com SliverAppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(AppDimensions.xs),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.xs),
                child: CircleAvatar(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : AppColors.textPrimary,
                    ),
                    onPressed: () => ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(pet.id),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Foto principal
                  PageView.builder(
                    itemCount: pet.photos.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPhotoIndex = index),
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: pet.photos[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.pets,
                            size: 64, color: AppColors.textHint),
                      ),
                    ),
                  ),

                  // Indicadores de foto
                  if (pet.photos.length > 1)
                    Positioned(
                      bottom: AppDimensions.md,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pet.photos.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _currentPhotoIndex == index ? 20 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == index
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e gênero
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(pet.name, style: AppTextStyles.displayMedium),
                      ),
                      Icon(
                        pet.gender == PetGender.male ? Icons.male : Icons.female,
                        color: pet.gender == PetGender.male
                            ? AppColors.info
                            : AppColors.primary,
                        size: AppDimensions.iconXl,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),

                  // Raça, idade e localização
                  Text(
                    '${pet.species.label} • ${pet.breed} • ${pet.age}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AppDimensions.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${pet.city}, ${pet.state}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Chips de saúde
                  Text('Saúde & Informações', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: [
                      HealthChip(
                        icon: Icons.vaccines_outlined,
                        label: 'Vacinado',
                        isActive: pet.healthInfo.vaccinated,
                      ),
                      HealthChip(
                        icon: Icons.cut_outlined,
                        label: 'Castrado',
                        isActive: pet.healthInfo.neutered,
                      ),
                      HealthChip(
                        icon: Icons.medical_services_outlined,
                        label: 'Vermifugado',
                        isActive: pet.healthInfo.dewormed,
                      ),
                      HealthChip(
                        icon: _energyIcon(pet.energyLevel),
                        label: pet.energyLevel.label,
                        isActive: true,
                      ),
                      HealthChip(
                        icon: _sizeIcon(pet.size),
                        label: 'Porte ${pet.size.label}',
                        isActive: true,
                      ),
                    ],
                  ),

                  // Necessidades especiais
                  if (pet.healthInfo.specialNeeds.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.sm),
                    ...pet.healthInfo.specialNeeds.map(
                      (need) => HealthChip(
                        icon: Icons.info_outline,
                        label: need,
                        isActive: true,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimensions.lg),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppDimensions.lg),

                  // Sobre o pet
                  Text('Sobre ${pet.name}', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    pet.description,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppDimensions.xxl + AppDimensions.buttonHeight),
                ],
              ),
            ),
          ),
        ],
      ),

      // Botão fixo de adoção
      bottomNavigationBar: pet.status == PetStatus.available &&
              (user?.isAdopter ?? false)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: ElevatedButton.icon(
                  onPressed: () => _showAdoptionDialog(context, ref, pet, user!),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Quero Adotar'),
                ),
              ),
            )
          : null,
    );
  }

  IconData _energyIcon(PetEnergyLevel level) {
    switch (level) {
      case PetEnergyLevel.low:
        return Icons.battery_1_bar;
      case PetEnergyLevel.medium:
        return Icons.battery_3_bar;
      case PetEnergyLevel.high:
        return Icons.battery_full;
    }
  }

  IconData _sizeIcon(PetSize size) {
    switch (size) {
      case PetSize.small:
        return Icons.straighten;
      case PetSize.medium:
        return Icons.straighten;
      case PetSize.large:
        return Icons.straighten;
    }
  }

  void _showAdoptionDialog(
    BuildContext context,
    WidgetRef ref,
    Pet pet,
    appUser,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: Text(
          'Demonstrar interesse em ${pet.name}?',
          style: AppTextStyles.headlineSmall,
        ),
        content: Text(
          'Ao confirmar, você iniciará uma conversa com o doador. Lembre-se: adotar é um compromisso para a vida toda!',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(chatProvider.notifier).createChat(
                    adopterId: appUser.uid,
                    adopterName: appUser.displayName,
                    donorId: pet.donorId,
                    donorName: 'Doador',
                    petId: pet.id,
                    petName: pet.name,
                    petPhoto: pet.photos.isNotEmpty ? pet.photos.first : '',
                  );
              Navigator.pop(context);
              context.go(AppRoutes.chatList);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
