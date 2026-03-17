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
  // Aquí guardamos qué pestaña está activa (0 = Inicio, 1 = Publicar, 2 = Perfil)
  int _currentIndex = 0;

  // Lista de las pantallas que vamos a mostrar
  final List<Widget> _screens = [
    const HomeScreen(),
    const MyExchangesScreen(),
    const AddBookScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Muestra la pantalla según el índice
      // Envolvemos el NavigationBar en un Theme para poder manipular las letras
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            // Estilo cuando la pestaña ESTÁ seleccionada
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 14, // Letra más grande
                fontWeight: FontWeight.bold, // Negrita fuerte
                color: Color(0xFF002855), // Azul Unimet
              );
            }
            // Estilo cuando la pestaña NO está seleccionada
            return const TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w600, // Semi-negrita para no perder visibilidad
              color: Colors.grey,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: Colors.orange.shade300,
          selectedIndex: _currentIndex,
          height: 75, // Le damos un poquito más de altura para que respiren los íconos grandes
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index; // Cambia la pestaña al tocar
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 28), // Ícono base más grande
              selectedIcon: Icon(Icons.home, size: 32),  // Ícono con efecto zoom al seleccionar
              label: 'Catálogo',
            ),
            NavigationDestination(
              icon: Icon(Icons.handshake_outlined, size: 28),
              selectedIcon: Icon(Icons.handshake, size: 32),
              label: 'Intercambios',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded, size: 28),
              selectedIcon: Icon(Icons.add_circle_rounded, size: 32),
              label: 'Publicar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 28),
              selectedIcon: Icon(Icons.person, size: 32),
              label: 'Mi Perfil',
            ),
          ],
        ),
      ),
    );
  }
}