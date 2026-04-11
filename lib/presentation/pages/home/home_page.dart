import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/pet.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/pets_provider.dart';
import '../../../presentation/widgets/pet_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final filters = ref.watch(petFeedFilterProvider);
    final filteredAsync = ref.watch(filteredPetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar customizada
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.pets, color: AppColors.primary, size: 28),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'Adote Um Pet',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                onPressed: () => _showFilterSheet(context, ref),
                tooltip: 'Filtros',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.divider),
            ),
          ),

          // Saudação
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${user?.displayName.split(' ').first ?? 'visitante'}! 👋',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Veja quem está esperando por você',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filtros ativos
          if (filters.hasActiveFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.sm,
                  AppDimensions.md,
                  0,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: AppDimensions.iconSm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      'Filtros ativos',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          ref.read(petFeedFilterProvider.notifier).clearFilters(),
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              ),
            ),

          // Conteúdo baseado no AsyncValue
          filteredAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Erro ao carregar pets',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      e.toString(),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            data: (pets) => pets.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 64, color: AppColors.textHint),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'Nenhum pet encontrado',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            'Tente ajustar os filtros',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppDimensions.sm,
                        mainAxisSpacing: AppDimensions.sm,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => PetCard(pet: pets[index]),
                        childCount: pets.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (context) => _FilterSheet(ref: ref),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _FilterSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final filters = widgetRef.watch(petFeedFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPaddingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          Text('Filtrar por', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.lg),

          // Espécie
          Text('Espécie', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            children: PetSpecies.values.map((species) {
              final isSelected = filters.species == species;
              return FilterChip(
                label: Text(species.label),
                selected: isSelected,
                onSelected: (selected) {
                  widgetRef
                      .read(petFeedFilterProvider.notifier)
                      .setSpecies(selected ? species : null);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontFamily: 'Nunito',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.md),

          // Porte
          Text('Porte', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            children: PetSize.values.map((size) {
              final isSelected = filters.size == size;
              return FilterChip(
                label: Text(size.label),
                selected: isSelected,
                onSelected: (selected) {
                  widgetRef
                      .read(petFeedFilterProvider.notifier)
                      .setSize(selected ? size : null);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontFamily: 'Nunito',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.md),

          // Sexo
          Text('Sexo', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            children: PetGender.values.map((gender) {
              final isSelected = filters.gender == gender;
              return FilterChip(
                label: Text(gender.label),
                selected: isSelected,
                onSelected: (selected) {
                  widgetRef
                      .read(petFeedFilterProvider.notifier)
                      .setGender(selected ? gender : null);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontFamily: 'Nunito',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.xl),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widgetRef
                        .read(petFeedFilterProvider.notifier)
                        .clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpar filtros'),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
        ],
      ),
    );
  }
}
