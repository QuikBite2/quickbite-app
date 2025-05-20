import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/cliente_home.dart';
import 'screens/cocinero_home.dart';
import 'screens/repartidor_home.dart';
import 'screens/cliente_pedidos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getHomeScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const LoginScreen();

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

    if (!doc.exists || !doc.data()!.containsKey('rol')) {
      return const LoginScreen(); // rol desconocido
    }

    final rol = doc['rol'];
    final nombre = doc['nombre'] ?? 'Usuario';

    switch (rol) {
      case 'cliente':
        return ClienteHome(nombre: nombre);
      case 'cocinero':
        return CocineroHome(nombre: nombre);
      case 'repartidor':
        return RepartidorHome(nombre: nombre);
      default:
        return const LoginScreen(); // rol no válido
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange, useMaterial3: true),
      routes: {
        '/':
            (context) => FutureBuilder(
              future: _getHomeScreen(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.data ?? const LoginScreen();
              },
            ),
        '/cliente_pedidos': (context) => const ClientePedidos(),
        // '/productos_cocinero': (context) => const ProductosCocinero(), // Solo si navegas por ruta
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
