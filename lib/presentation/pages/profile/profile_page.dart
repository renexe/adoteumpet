import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/favorites_provider.dart';
import '../../../presentation/widgets/pet_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final favoritePets = ref.watch(favoritePetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: 'Sair',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header do perfil
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: AppDimensions.avatarXl / 2,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      user?.displayName.isNotEmpty == true
                          ? user!.displayName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    user?.displayName ?? 'Usuário',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      user?.userType.label ?? '',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.sm),

            // Seção de favoritos (apenas adotantes)
            if (user?.isAdopter == true) ...[
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: AppColors.primary),
                    const SizedBox(width: AppDimensions.sm),
                    Text('Favoritos', style: AppTextStyles.titleLarge),
                    const Spacer(),
                    Text(
                      '${favoritePets.length} pets',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (favoritePets.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        'Nenhum favorito ainda',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        'Toque no coração de um pet para salvá-lo aqui.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppDimensions.sm,
                      mainAxisSpacing: AppDimensions.sm,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: favoritePets.length,
                    itemBuilder: (context, index) =>
                        PetCard(pet: favoritePets[index]),
                  ),
                ),
            ],

            // Informações do quiz (adotantes)
            if (user?.isAdopter == true && user?.quizAnswers != null) ...[
              const SizedBox(height: AppDimensions.sm),
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.quiz_outlined,
                            color: AppColors.secondary),
                        const SizedBox(width: AppDimensions.sm),
                        Text('Meu Perfil de Adotante',
                            style: AppTextStyles.titleLarge),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _InfoRow(
                      icon: Icons.home_outlined,
                      label: 'Moradia',
                      value: user!.quizAnswers!.housing.label,
                    ),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Tempo disponível',
                      value: user.quizAnswers!.availableTime.label,
                    ),
                    _InfoRow(
                      icon: Icons.child_care_outlined,
                      label: 'Tem crianças',
                      value: user.quizAnswers!.hasChildren ? 'Sim' : 'Não',
                    ),
                    _InfoRow(
                      icon: Icons.pets_outlined,
                      label: 'Tem outros pets',
                      value: user.quizAnswers!.hasOtherPets ? 'Sim' : 'Não',
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: Text('Sair da conta?', style: AppTextStyles.headlineSmall),
        content: Text(
          'Você precisará fazer login novamente.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.sm),
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
