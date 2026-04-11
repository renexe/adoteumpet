import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../domain/entities/app_user.dart';
import '../../../presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Informações pessoais
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  // Localização
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;

  // Contatos
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _instagramController;

  // Privacidade
  late bool _showLocation;
  late bool _showContact;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);

    _nameController =
        TextEditingController(text: user?.displayName ?? '');
    _bioController =
        TextEditingController(text: user?.bio ?? '');
    _cityController =
        TextEditingController(text: user?.location?.city ?? '');
    _stateController =
        TextEditingController(text: user?.location?.state ?? '');
    _phoneController =
        TextEditingController(text: user?.contact?.phone ?? '');
    _whatsappController =
        TextEditingController(text: user?.contact?.whatsapp ?? '');
    _instagramController =
        TextEditingController(text: user?.contact?.instagram ?? '');

    _showLocation = user?.privacy.showLocation ?? false;
    _showContact = user?.privacy.showContact ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final location = (_cityController.text.trim().isNotEmpty ||
            _stateController.text.trim().isNotEmpty)
        ? UserLocation(
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
          )
        : null;

    final contact = (_phoneController.text.trim().isNotEmpty ||
            _whatsappController.text.trim().isNotEmpty ||
            _instagramController.text.trim().isNotEmpty)
        ? UserContact(
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            whatsapp: _whatsappController.text.trim().isEmpty
                ? null
                : _whatsappController.text.trim(),
            instagram: _instagramController.text.trim().isEmpty
                ? null
                : _instagramController.text.trim(),
          )
        : null;

    await ref.read(authProvider.notifier).updateProfile(
          displayName: _nameController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          location: location,
          contact: contact,
          privacy: UserPrivacy(
            showLocation: _showLocation,
            showContact: _showContact,
          ),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil atualizado com sucesso!',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Editar Perfil'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleSave,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    'Salvar',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto de perfil ───────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Center(
                child: Text(
                  'Alterar foto',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Informações Pessoais ─────────────────────────────────
              _SectionHeader(
                icon: Icons.person_outline,
                title: 'Informações Pessoais',
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'Nome completo',
                hint: 'Seu nome ou nome da organização',
                controller: _nameController,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'Bio',
                hint:
                    'Conte um pouco sobre você ou sua organização...',
                controller: _bioController,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Endereço ─────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.location_on_outlined,
                title: 'Endereço',
              ),
              const SizedBox(height: AppDimensions.md),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      label: 'Cidade',
                      hint: 'Ex: São Paulo',
                      controller: _cityController,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    flex: 1,
                    child: AppTextField(
                      label: 'Estado',
                      hint: 'SP',
                      controller: _stateController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),

              // Toggle: tornar endereço público
              _PrivacyToggle(
                icon: Icons.location_on_outlined,
                title: 'Mostrar minha cidade publicamente',
                subtitle: 'Sua cidade será exibida no seu perfil e nos pets cadastrados.',
                value: _showLocation,
                onChanged: (v) => setState(() => _showLocation = v),
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Contatos ─────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.contact_phone_outlined,
                title: 'Contatos',
              ),
              const SizedBox(height: AppDimensions.sm),

              // Warning de privacidade — exibido quando contatos são privados
              if (!_showContact) ...[
                _PrivacyWarningBanner(
                  message:
                      'Seus contatos estão privados. Marque a opção abaixo para que interessados em seus pets possam entrar em contato diretamente.',
                  onCheckboxTap: () =>
                      setState(() => _showContact = true),
                ),
                const SizedBox(height: AppDimensions.md),
              ],

              AppTextField(
                label: 'Telefone',
                hint: '(11) 99999-9999',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'WhatsApp',
                hint: '(11) 99999-9999',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.chat_outlined,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'Instagram',
                hint: '@usuario',
                controller: _instagramController,
                prefixIcon: const Icon(Icons.alternate_email,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),

              // Toggle: tornar contatos públicos
              _PrivacyToggle(
                icon: Icons.visibility_outlined,
                title: 'Mostrar contatos publicamente',
                subtitle:
                    'Telefone, WhatsApp e Instagram serão visíveis para outros usuários.',
                value: _showContact,
                onChanged: (v) => setState(() => _showContact = v),
              ),
              const SizedBox(height: AppDimensions.xxl),

              // Botão salvar
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSave,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Salvar Alterações'),
              ),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

/// Cabeçalho de seção com ícone e título.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconMd, color: AppColors.primary),
        const SizedBox(width: AppDimensions.sm),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }
}

/// Banner de aviso de privacidade com ação de ativar visibilidade.
class _PrivacyWarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback onCheckboxTap;

  const _PrivacyWarningBanner({
    required this.message,
    required this.onCheckboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.warning,
            size: AppDimensions.iconMd,
          ),
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
                const SizedBox(height: AppDimensions.xs),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                GestureDetector(
                  onTap: onCheckboxTap,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.warning, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.check,
                            size: 14, color: AppColors.warning),
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        'Tornar contatos públicos',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.warning,
                          decoration: TextDecoration.underline,
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
    );
  }
}

/// Toggle de privacidade com título, subtítulo e switch.
class _PrivacyToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _PrivacyToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
        onChanged: onChanged,
      ),
    );
  }
}
