import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'productos_por_restaurante.dart';

class RestaurantesCliente extends StatelessWidget {
  const RestaurantesCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurantes disponibles')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurantes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final restaurantes = snapshot.data!.docs;

          if (restaurantes.isEmpty) {
            return const Center(
              child: Text('No hay restaurantes registrados.'),
            );
          }

          return ListView.builder(
            itemCount: restaurantes.length,
            itemBuilder: (context, index) {
              final restaurante = restaurantes[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(restaurante['nombre']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurante['descripcion']),
                      CalificacionRestaurante(idRestaurante: restaurante.id),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProductosPorRestaurante(
                              idRestaurante: restaurante.id,
                              nombreRestaurante: restaurante['nombre'],
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CalificacionRestaurante extends StatelessWidget {
  final String idRestaurante;
  const CalificacionRestaurante({super.key, required this.idRestaurante});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('calificaciones')
              .where('id_restaurante', isEqualTo: idRestaurante)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            '⭐ Sin calificación aún',
            style: TextStyle(fontSize: 12),
          );
        }

        final calificaciones = snapshot.data!.docs;
        final promedio =
            calificaciones
                .map((doc) => doc['calificacion_restaurante'] as int)
                .reduce((a, b) => a + b) /
            calificaciones.length;

        return Text(
          '⭐ ${promedio.toStringAsFixed(1)} / 5',
          style: const TextStyle(fontSize: 12),
        );
      },
    );
  }
}
