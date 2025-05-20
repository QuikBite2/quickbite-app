import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductosCocinero extends StatelessWidget {
  const ProductosCocinero({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Productos')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('productos')
                .where('id_restaurante', isEqualTo: uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!.docs;

          if (productos.isEmpty) {
            return const Center(
              child: Text('No tienes productos registrados.'),
            );
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final nombre = producto['nombre'];
              final precio = producto['precio'];
              final disponible = producto['disponible'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(nombre),
                  subtitle: Text('Precio: \$${precio.toString()}'),
                  trailing: Icon(
                    disponible ? Icons.check_circle : Icons.cancel,
                    color: disponible ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
