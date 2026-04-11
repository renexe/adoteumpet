import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/favorites_provider.dart';
import '../../../presentation/widgets/pet_card.dart';
import '../../../config/app_router.dart';

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
          // Botão de editar perfil
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editProfile),
            tooltip: 'Editar perfil',
          ),
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
            // ── Header do perfil ─────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: AppDimensions.avatarXl / 2,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
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

                  // Localização pública
                  if (user?.privacy.showLocation == true &&
                      user?.location != null) ...[
                    const SizedBox(height: AppDimensions.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          user!.location!.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      user.bio!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.md),

                  // Botão de editar perfil
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar Perfil'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.lg,
                        vertical: AppDimensions.xs,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.sm),

            // ── Contatos públicos ────────────────────────────────────
            if (user?.privacy.showContact == true &&
                user?.contact != null) ...[
              _ContactSection(user: user!),
              const SizedBox(height: AppDimensions.sm),
            ],

            // ── Aviso de contatos privados ───────────────────────────
            if (user?.privacy.showContact == false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          color: AppColors.warning,
                          size: AppDimensions.iconMd),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contatos privados',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Seus contatos não são visíveis para outros usuários. Ative em Editar Perfil.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(AppRoutes.editProfile),
                        child: Text(
                          'Ativar',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
            ],

            // ── Favoritos ────────────────────────────────────────────
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

/// Seção de contatos públicos do perfil.
class _ContactSection extends StatelessWidget {
  final dynamic user;

  const _ContactSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final contact = user.contact;
    if (contact == null) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone_outlined,
                  color: AppColors.primary),
              const SizedBox(width: AppDimensions.sm),
              Text('Contatos', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          if (contact.phone != null)
            _ContactRow(
              icon: Icons.phone_outlined,
              label: contact.phone!,
            ),
          if (contact.whatsapp != null)
            _ContactRow(
              icon: Icons.chat_outlined,
              label: contact.whatsapp!,
            ),
          if (contact.instagram != null)
            _ContactRow(
              icon: Icons.alternate_email,
              label: contact.instagram!,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          Icon(icon,
              size: AppDimensions.iconMd,
              color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.sm),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
