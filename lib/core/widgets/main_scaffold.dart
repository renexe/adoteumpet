import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../config/app_router.dart';
import '../../presentation/providers/auth_provider.dart';

/// Scaffold principal com bottom navigation bar.
///
/// Exibe abas diferentes dependendo do tipo de usuário:
/// - Adotantes: Início, Favoritos, Mensagens, Perfil
/// - Doadores: Início, Meus Pets, Mensagens, Perfil
class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDonor = user?.isDonor ?? false;
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = isDonor ? _donorTabs : _adopterTabs;
    final currentIndex = _getCurrentIndex(location, isDonor);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onTabTapped(context, index, isDonor),
          items: tabs,
        ),
      ),
    );
  }

  int _getCurrentIndex(String location, bool isDonor) {
    if (location.startsWith(AppRoutes.home)) return 0;
    if (isDonor && location.startsWith(AppRoutes.myPets)) return 1;
    if (location.startsWith(AppRoutes.chatList)) return isDonor ? 2 : 1;
    if (location.startsWith(AppRoutes.profile)) return isDonor ? 3 : 2;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index, bool isDonor) {
    if (isDonor) {
      switch (index) {
        case 0:
          context.go(AppRoutes.home);
        case 1:
          context.go(AppRoutes.myPets);
        case 2:
          context.go(AppRoutes.chatList);
        case 3:
          context.go(AppRoutes.profile);
      }
    } else {
      switch (index) {
        case 0:
          context.go(AppRoutes.home);
        case 1:
          context.go(AppRoutes.chatList);
        case 2:
          context.go(AppRoutes.profile);
      }
    }
  }

  static const List<BottomNavigationBarItem> _adopterTabs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.pets_outlined),
      activeIcon: Icon(Icons.pets),
      label: 'Início',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      activeIcon: Icon(Icons.chat_bubble),
      label: 'Mensagens',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  static const List<BottomNavigationBarItem> _donorTabs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Início',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline),
      activeIcon: Icon(Icons.favorite),
      label: 'Meus Pets',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      activeIcon: Icon(Icons.chat_bubble),
      label: 'Mensagens',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];
}
