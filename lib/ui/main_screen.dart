import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_book_screen.dart';
import 'user_profile_screen.dart';
import 'my_exchanges_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyExchangesScreen(),
    const AddBookScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF5D4037);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: brandColor,
          iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: brandColor);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: brandColor, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: brandColor, fontWeight: FontWeight.normal);
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Catálogo',
            ),
            NavigationDestination(
              icon: Icon(Icons.handshake_outlined),
              selectedIcon: Icon(Icons.handshake),
              label: 'Intercambios',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'Publicar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Mi Perfil',
            ),
          ],
        ),
      ),
    );
  }
}