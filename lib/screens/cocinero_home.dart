import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'productos_cocinero.dart';

class CocineroHome extends StatelessWidget {
  final String nombre;
  const CocineroHome({super.key, required this.nombre});

  void _actualizarEstado(String id, String nuevoEstado) {
    FirebaseFirestore.instance.collection('pedidos').doc(id).update({
      'estado': nuevoEstado,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos - Cocinero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Mis productos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductosCocinero()),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('estado', whereIn: ['pendiente', 'en_preparacion'])
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return const Center(child: Text('No hay pedidos aún.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final estado = pedido['estado'];

              return ListTile(
                title: Text(pedido['nombre_producto']),
                subtitle: Text('Estado: $estado'),
                trailing: ElevatedButton(
                  onPressed: () {
                    final nuevo =
                        estado == 'pendiente' ? 'en_preparacion' : 'listo';
                    _actualizarEstado(pedido.id, nuevo);
                  },
                  child: Text(
                    estado == 'pendiente'
                        ? 'Preparar'
                        : estado == 'en_preparacion'
                        ? 'Listo'
                        : 'Finalizado',
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
