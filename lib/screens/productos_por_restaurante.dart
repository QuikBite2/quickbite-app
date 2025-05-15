import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'producto_detalle.dart';

class ProductosPorRestaurante extends StatelessWidget {
  final String idRestaurante;
  final String nombreRestaurante;

  const ProductosPorRestaurante({
    super.key,
    required this.idRestaurante,
    required this.nombreRestaurante,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menú de $nombreRestaurante')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('productos')
                .where('id_restaurante', isEqualTo: idRestaurante)
                .where('disponible', isEqualTo: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!.docs;

          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final doc = productos[index];
              final producto = doc.data() as Map<String, dynamic>;
              producto['id'] = doc.id; // ✅ Incluir ID del producto

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading:
                      producto['imagen_url'] != null
                          ? Image.network(
                            producto['imagen_url'],
                            width: 50,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.fastfood),
                          )
                          : const Icon(Icons.fastfood),
                  title: Text(producto['nombre']),
                  subtitle: Text(producto['descripcion']),
                  trailing: Text('\$${producto['precio']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductoDetalle(producto: producto),
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
