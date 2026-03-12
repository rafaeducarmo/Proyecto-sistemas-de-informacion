import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:metroswap/ui/main_screen.dart';
import 'ui/admin_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0, // Apaga el cambio de color al hacer scroll
          backgroundColor: Colors.transparent, // Opcional: si quieres un color fijo, cámbialo aquí
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
