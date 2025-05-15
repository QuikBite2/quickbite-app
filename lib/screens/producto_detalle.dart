import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductoDetalle extends StatefulWidget {
  final Map<String, dynamic> producto;

  const ProductoDetalle({super.key, required this.producto});

  @override
  State<ProductoDetalle> createState() => _ProductoDetalleState();
}

class _ProductoDetalleState extends State<ProductoDetalle> {
  int cantidad = 1;

  Future<void> _anadirAlPedido() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pedidosRef = FirebaseFirestore.instance.collection('pedidos');

    await pedidosRef.add({
      'id_cliente': uid,
      'nombre_producto': widget.producto['nombre'],
      'precio': widget.producto['precio'] * cantidad,
      'cantidad': cantidad,
      'estado': 'pendiente',
      'id_producto': widget.producto['id'] ?? '',
      'id_restaurante': widget.producto['id_restaurante'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido de ${widget.producto['nombre']} realizado'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    return Scaffold(
      appBar: AppBar(title: Text(producto['nombre'] ?? 'Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (producto['imagen_url'] != null)
              Image.network(
                producto['imagen_url'],
                height: 200,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.fastfood, size: 100),
              ),
            const SizedBox(height: 12),
            CalificacionProducto(idProducto: producto['id'] ?? ''),
            const SizedBox(height: 12),
            Text(
              producto['descripcion'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              '\$${producto['precio']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (cantidad > 1) {
                      setState(() {
                        cantidad--;
                      });
                    }
                  },
                ),
                Text('$cantidad', style: const TextStyle(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      cantidad++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _anadirAlPedido,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Añadir al pedido'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalificacionProducto extends StatelessWidget {
  final String idProducto;
  const CalificacionProducto({super.key, required this.idProducto});

  @override
  Widget build(BuildContext context) {
    if (idProducto.isEmpty) {
      return const Text(
        '⭐ Sin calificación aún',
        style: TextStyle(fontSize: 14),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('calificaciones')
              .where('id_producto', isEqualTo: idProducto)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            '⭐ Sin calificación aún',
            style: TextStyle(fontSize: 14),
          );
        }

        final calificaciones = snapshot.data!.docs;
        final promedio =
            calificaciones
                .map((doc) => doc['calificacion_producto'] as int)
                .reduce((a, b) => a + b) /
            calificaciones.length;

        return Text(
          '⭐ ${promedio.toStringAsFixed(1)} / 5',
          style: const TextStyle(fontSize: 14),
        );
      },
    );
  }
}
