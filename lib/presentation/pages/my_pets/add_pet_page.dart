import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../domain/entities/pet.dart';
import '../../../presentation/providers/auth_provider.dart';

/// Representa o estado tristate de uma informação de saúde do pet.
///
/// [yes] = confirmado, [no] = não tem, [unknown] = não sei informar.
enum HealthStatus { yes, no, unknown }

class AddPetPage extends ConsumerStatefulWidget {
  const AddPetPage({super.key});

  @override
  ConsumerState<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends ConsumerState<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  PetGender _gender = PetGender.male;
  PetSize _size = PetSize.medium;
  PetEnergyLevel _energyLevel = PetEnergyLevel.medium;

  // Saúde com tristate: Sim / Não / Não sei
  HealthStatus _vaccinated = HealthStatus.unknown;
  HealthStatus _neutered = HealthStatus.unknown;
  HealthStatus _dewormed = HealthStatus.unknown;

  // Localização
  bool _useMyLocation = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pré-preenche com a cidade do perfil se disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocationFromProfile();
    });
  }

  void _syncLocationFromProfile() {
    if (!_useMyLocation) return;
    final user = ref.read(currentUserProvider);
    final city = user?.location?.city ?? '';
    _cityController.text = city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_nameController.text} cadastrado com sucesso!',
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
    final user = ref.watch(currentUserProvider);
    final profileCity = user?.location?.city ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Cadastrar Pet'),
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
              // Placeholder de foto
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        size: 36,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        'Adicionar foto',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Informações Básicas ──────────────────────────────────
              Text('Informações Básicas', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'Nome do pet',
                hint: 'Ex: Thor',
                controller: _nameController,
                validator: (v) =>
                    v?.isEmpty == true ? 'Informe o nome' : null,
              ),
              const SizedBox(height: AppDimensions.md),

              Text('Espécie', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetSpecies>(
                options: PetSpecies.values,
                selected: _species,
                labelOf: (s) => s.label,
                onSelect: (s) => setState(() => _species = s),
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'Raça',
                hint: 'Ex: Labrador',
                controller: _breedController,
                validator: (v) =>
                    v?.isEmpty == true ? 'Informe a raça' : null,
              ),
              const SizedBox(height: AppDimensions.md),

              AppTextField(
                label: 'Idade',
                hint: 'Ex: 2 anos',
                controller: _ageController,
                validator: (v) =>
                    v?.isEmpty == true ? 'Informe a idade' : null,
              ),
              const SizedBox(height: AppDimensions.md),

              Text('Sexo', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetGender>(
                options: PetGender.values,
                selected: _gender,
                labelOf: (g) => g.label,
                onSelect: (g) => setState(() => _gender = g),
              ),
              const SizedBox(height: AppDimensions.md),

              Text('Porte', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetSize>(
                options: PetSize.values,
                selected: _size,
                labelOf: (s) => s.label,
                onSelect: (s) => setState(() => _size = s),
              ),
              const SizedBox(height: AppDimensions.md),

              Text('Nível de energia', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetEnergyLevel>(
                options: PetEnergyLevel.values,
                selected: _energyLevel,
                labelOf: (e) => e.label,
                onSelect: (e) => setState(() => _energyLevel = e),
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Saúde ────────────────────────────────────────────────
              Text('Saúde', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Selecione o que se aplica ao pet. Escolha "Não sei" se não tiver certeza.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.md),

              _HealthTristateRow(
                label: 'Vacinado',
                icon: Icons.vaccines_outlined,
                value: _vaccinated,
                onChanged: (v) => setState(() => _vaccinated = v),
              ),
              const SizedBox(height: AppDimensions.sm),
              _HealthTristateRow(
                label: 'Castrado',
                icon: Icons.cut_outlined,
                value: _neutered,
                onChanged: (v) => setState(() => _neutered = v),
              ),
              const SizedBox(height: AppDimensions.sm),
              _HealthTristateRow(
                label: 'Vermifugado',
                icon: Icons.medical_services_outlined,
                value: _dewormed,
                onChanged: (v) => setState(() => _dewormed = v),
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Localização ──────────────────────────────────────────
              Text('Localização', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.sm),

              // Checkbox "Usar minha localização"
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  title: Text(
                    'Usar minha localização',
                    style: AppTextStyles.bodyLarge,
                  ),
                  subtitle: profileCity.isNotEmpty
                      ? Text(
                          profileCity,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : Text(
                          'Configure sua cidade no perfil',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                  secondary: Icon(
                    Icons.my_location,
                    color: _useMyLocation
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  value: _useMyLocation,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() {
                      _useMyLocation = v ?? true;
                      if (_useMyLocation) {
                        _cityController.text = profileCity;
                      } else {
                        _cityController.clear();
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              // Input de cidade — desabilitado se usar localização do perfil
              AppTextField(
                label: 'Cidade',
                hint: 'Ex: São Paulo',
                controller: _cityController,
                enabled: !_useMyLocation,
                validator: (v) =>
                    v?.isEmpty == true ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Sobre o pet ──────────────────────────────────────────
              Text('Sobre o pet', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: 'Descrição',
                hint:
                    'Conte um pouco sobre a personalidade, hábitos e história do pet...',
                controller: _descriptionController,
                maxLines: 5,
                validator: (v) =>
                    v?.isEmpty == true ? 'Adicione uma descrição' : null,
              ),
              const SizedBox(height: AppDimensions.xxl),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Cadastrar Pet'),
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

/// Seletor segmentado genérico (Espécie, Sexo, Porte, Energia).
class _SegmentedSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;

  const _SegmentedSelector({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = selected == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: option != options.last ? AppDimensions.xs : 0,
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimensions.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                labelOf(option),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Linha de saúde com três opções: Sim / Não / Não sei.
class _HealthTristateRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final HealthStatus value;
  final void Function(HealthStatus) onChanged;

  const _HealthTristateRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: AppDimensions.iconMd, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyLarge),
        ),
        const SizedBox(width: AppDimensions.sm),
        _HealthOption(
          label: 'Sim',
          isSelected: value == HealthStatus.yes,
          selectedColor: AppColors.success,
          onTap: () => onChanged(HealthStatus.yes),
        ),
        const SizedBox(width: AppDimensions.xs),
        _HealthOption(
          label: 'Não',
          isSelected: value == HealthStatus.no,
          selectedColor: AppColors.error,
          onTap: () => onChanged(HealthStatus.no),
        ),
        const SizedBox(width: AppDimensions.xs),
        _HealthOption(
          label: 'Não sei',
          isSelected: value == HealthStatus.unknown,
          selectedColor: AppColors.textSecondary,
          onTap: () => onChanged(HealthStatus.unknown),
        ),
      ],
    );
  }
}

/// Botão de opção individual para o tristate de saúde.
class _HealthOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _HealthOption({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? selectedColor : AppColors.textSecondary,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
