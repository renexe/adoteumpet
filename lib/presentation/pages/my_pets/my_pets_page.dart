import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/pet.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/pets_provider.dart';
import '../../../config/app_router.dart';

class MyPetsPage extends ConsumerWidget {
  const MyPetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allPets = ref.watch(petsProvider).pets;
    final myPets = allPets.where((p) => p.donorId == user?.uid).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Pets'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addPet),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Cadastrar Pet',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      body: myPets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pets,
                      size: 72,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Nenhum pet cadastrado',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Cadastre um pet para colocá-lo\ndisponível para adoção.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    ElevatedButton.icon(
                      onPressed: () => context.push(AppRoutes.addPet),
                      icon: const Icon(Icons.add),
                      label: const Text('Cadastrar meu primeiro pet'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: myPets.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.sm),
              itemBuilder: (context, index) {
                final pet = myPets[index];
                return _DonorPetCard(pet: pet);
              },
            ),
    );
  }
}

class _DonorPetCard extends StatelessWidget {
  final Pet pet;

  const _DonorPetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.md),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: SizedBox(
            width: AppDimensions.avatarLg,
            height: AppDimensions.avatarLg,
            child: pet.photos.isNotEmpty
                ? Image.network(
                    pet.photos.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.pets, color: AppColors.textHint),
                    ),
                  )
                : Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.pets, color: AppColors.textHint),
                  ),
          ),
        ),
        title: Text(pet.name, style: AppTextStyles.titleLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.xs),
            Text(
              '${pet.species.label} • ${pet.breed} • ${pet.age}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            _StatusBadge(status: pet.status),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: () => context.push('/pet/${pet.id}'),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PetStatus status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case PetStatus.available:
        return AppColors.success;
      case PetStatus.inProgress:
        return AppColors.warning;
      case PetStatus.adopted:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(color: _color),
      ),
    );
  }
}
