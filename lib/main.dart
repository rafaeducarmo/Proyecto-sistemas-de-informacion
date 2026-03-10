import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

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
            // Si el usuario ya inició sesión
            return const HomeScreen();
          }
          // Si el usuario no ha iniciado sesión
          return const LoginScreen();
        },
      ),
    );
  }
}
