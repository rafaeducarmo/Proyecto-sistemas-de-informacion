import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:metroswap/ui/main_screen.dart';
import 'ui/admin_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// Rutas a tus pantallas y providers
import 'ui/login_screen.dart';
import 'ui/home_screen.dart';
import 'providers/book_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BookProvider())],
      child: const MetroSwapApp(),
    ),
  );
}

class MetroSwapApp extends StatelessWidget {
  const MetroSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroSwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Colores principales Unimet
        primaryColor: const Color(0xFF002855), // Azul Fuerte Unimet
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Gris ultra claro
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF37021), // Naranja Fuerte Unimet
          primary: const Color(0xFFF37021),
          secondary: const Color(0xFF002855),
        ),
        // Tipografía general usando Montserrat
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        // Estilo global para los botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFFF37021,
            ), // Botones naranjas fuertes
            foregroundColor: Colors.white, // Texto blanco
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        // Estilo global para las barras superiores (AppBars)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Barra blanca institucional
          foregroundColor: Color(0xFF002855), // Letras y botones en azul fuerte
          elevation: 2,
          shadowColor: Colors.black26,
          centerTitle: false,
        ),
      ),
      // StreamBuilder escucha la autenticación en tiempo real
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // Evaluamos si el correo es el del administrador
            final user = snapshot.data!;
            if (user.email == 'admin@unimet.edu.ve') {
              return const AdminScreen(); // Lo mandamos al panel de control
            }

            // Si es un estudiante normal, va al menú principal
            return const MainScreen();
          }
          // Si el usuario no ha iniciado sesión
          return const LoginScreen();
        },
      ),
    );
  }
}
