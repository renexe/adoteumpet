import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/app_user.dart';
import '../../../config/app_router.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int _currentStep = 0;

  HousingType? _housing;
  AvailableTime? _availableTime;
  bool? _hasChildren;
  bool? _hasOtherPets;

  final List<_QuizStep> _steps = [
    const _QuizStep(
      emoji: '🏠',
      question: 'Como é o seu espaço atual?',
      subtitle: 'Isso nos ajuda a encontrar o pet ideal para você.',
    ),
    const _QuizStep(
      emoji: '⏰',
      question: 'Quanto tempo você tem disponível por dia para o pet?',
      subtitle: 'Considere passeios, brincadeiras e companhia.',
    ),
    const _QuizStep(
      emoji: '👶',
      question: 'Você tem crianças em casa?',
      subtitle: 'Alguns pets se adaptam melhor a famílias com crianças.',
    ),
    const _QuizStep(
      emoji: '🐾',
      question: 'Você já tem outros animais?',
      subtitle: 'Vamos verificar a compatibilidade com outros pets.',
    ),
  ];

  bool get _canAdvance {
    switch (_currentStep) {
      case 0:
        return _housing != null;
      case 1:
        return _availableTime != null;
      case 2:
        return _hasChildren != null;
      case 3:
        return _hasOtherPets != null;
      default:
        return false;
    }
  }

  void _advance() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    // As respostas serão persistidas no perfil do usuário na integração com Firebase
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de progresso
              Row(
                children: List.generate(
                  _steps.length,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: EdgeInsets.only(
                          right: index < _steps.length - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Passo ${_currentStep + 1} de ${_steps.length}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppDimensions.xxl),

              // Emoji e pergunta
              Text(
                _steps[_currentStep].emoji,
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                _steps[_currentStep].question,
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                _steps[_currentStep].subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Opções
              Expanded(
                child: _buildOptions(),
              ),

              // Botão avançar
              AnimatedOpacity(
                opacity: _canAdvance ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _canAdvance ? _advance : null,
                  child: Text(
                    _currentStep < _steps.length - 1
                        ? 'Próximo'
                        : 'Ver meus matches!',
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    switch (_currentStep) {
      case 0:
        return _OptionList<HousingType>(
          options: HousingType.values,
          selected: _housing,
          labelOf: (h) => h.label,
          onSelect: (h) => setState(() => _housing = h),
        );
      case 1:
        return _OptionList<AvailableTime>(
          options: AvailableTime.values,
          selected: _availableTime,
          labelOf: (t) => t.label,
          onSelect: (t) => setState(() => _availableTime = t),
        );
      case 2:
        return _BoolOptions(
          selected: _hasChildren,
          onSelect: (v) => setState(() => _hasChildren = v),
        );
      case 3:
        return _BoolOptions(
          selected: _hasOtherPets,
          onSelect: (v) => setState(() => _hasOtherPets = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _QuizStep {
  final String emoji;
  final String question;
  final String subtitle;
  const _QuizStep({
    required this.emoji,
    required this.question,
    required this.subtitle,
  });
}

class _OptionList<T> extends StatelessWidget {
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;

  const _OptionList({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.sm),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    labelOf(option),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BoolOptions extends StatelessWidget {
  final bool? selected;
  final void Function(bool) onSelect;

  const _BoolOptions({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BoolOption(
          label: 'Sim',
          icon: Icons.check_circle_outline,
          isSelected: selected == true,
          onTap: () => onSelect(true),
        ),
        const SizedBox(height: AppDimensions.sm),
        _BoolOption(
          label: 'Não',
          icon: Icons.cancel_outlined,
          isSelected: selected == false,
          onTap: () => onSelect(false),
        ),
      ],
    );
  }
}

class _BoolOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BoolOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.md),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
