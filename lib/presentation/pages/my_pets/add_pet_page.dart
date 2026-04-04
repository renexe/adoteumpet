import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../domain/entities/pet.dart';

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
  bool _vaccinated = false;
  bool _neutered = false;
  bool _dewormed = false;
  bool _isSubmitting = false;

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

    // Simula envio
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
                    border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid),
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
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Informações básicas
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

              // Espécie
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

              // Sexo
              Text('Sexo', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetGender>(
                options: PetGender.values,
                selected: _gender,
                labelOf: (g) => g.label,
                onSelect: (g) => setState(() => _gender = g),
              ),
              const SizedBox(height: AppDimensions.md),

              // Porte
              Text('Porte', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetSize>(
                options: PetSize.values,
                selected: _size,
                labelOf: (s) => s.label,
                onSelect: (s) => setState(() => _size = s),
              ),
              const SizedBox(height: AppDimensions.md),

              // Nível de energia
              Text('Nível de energia', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppDimensions.sm),
              _SegmentedSelector<PetEnergyLevel>(
                options: PetEnergyLevel.values,
                selected: _energyLevel,
                labelOf: (e) => e.label,
                onSelect: (e) => setState(() => _energyLevel = e),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Saúde
              Text('Saúde', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.sm),
              _HealthCheckbox(
                label: 'Vacinado',
                value: _vaccinated,
                onChanged: (v) => setState(() => _vaccinated = v!),
              ),
              _HealthCheckbox(
                label: 'Castrado',
                value: _neutered,
                onChanged: (v) => setState(() => _neutered = v!),
              ),
              _HealthCheckbox(
                label: 'Vermifugado',
                value: _dewormed,
                onChanged: (v) => setState(() => _dewormed = v!),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Localização
              Text('Localização', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                label: 'Cidade',
                hint: 'Ex: São Paulo',
                controller: _cityController,
                validator: (v) =>
                    v?.isEmpty == true ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Descrição
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
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                labelOf(option),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HealthCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool?) onChanged;

  const _HealthCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.bodyLarge),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
