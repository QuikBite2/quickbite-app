import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'restaurantes_cliente.dart';

class ClienteHome extends StatelessWidget {
  final String nombre;
  const ClienteHome({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Hola $nombre 👋\nSelecciona un restaurante para ver su menú',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(child: RestaurantesCliente()),
        ],
      ),
    );
  }
}
