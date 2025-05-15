import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/cliente_home.dart';
import 'screens/cocinero_home.dart';
import 'screens/repartidor_home.dart';
import 'screens/admin_panel.dart'; // <-- Importante

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getHomeScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    print("UID del usuario logueado: ${user?.uid}");

    if (user == null) return const LoginScreen();

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

    final rol = doc.data()?['rol'];
    final nombre = doc.data()?['nombre'] ?? '';

    switch (rol) {
      case 'cliente':
        return ClienteHome(nombre: nombre);
      case 'cocinero':
        return CocineroHome(nombre: nombre);
      case 'repartidor':
        return RepartidorHome(nombre: nombre);
      case 'super_admin':
        return const AdminPanel(); // Aquí va el panel de administrador
      default:
        return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBite',
      debugShowCheckedModeBanner: false,
      routes: {
        '/register': (_) => const RegisterScreen(),
        '/cliente': (_) => const ClienteHome(nombre: ''),
        '/cocinero': (_) => const CocineroHome(nombre: ''),
        '/repartidor': (_) => const RepartidorHome(nombre: ''),
      },
      home: FutureBuilder<Widget>(
        future: _getHomeScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
