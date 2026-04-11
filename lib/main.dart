import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'firebase_options.dart';

/// Ponto de entrada do aplicativo Adote Um Pet.
///
/// Inicializa o Firebase antes de montar a árvore de widgets.
/// O arquivo [firebase_options.dart] é gerado pelo FlutterFire CLI
/// e está no .gitignore — nunca deve ser commitado.
///
/// Para configurar o Firebase, siga as instruções em FIREBASE_SETUP.md.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: AdoteUmPetApp(),
    ),
  );
}

/// Widget raiz do aplicativo.
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
