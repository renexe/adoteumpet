import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AdoteUmPetApp(),
    ),
  );
}

/// Ponto de entrada do aplicativo Adote Um Pet.
///
/// Utiliza [ProviderScope] do Riverpod para gerenciamento de estado
/// e [GoRouter] para navegação declarativa.
class AdoteUmPetApp extends ConsumerWidget {
  const AdoteUmPetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Adote Um Pet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
