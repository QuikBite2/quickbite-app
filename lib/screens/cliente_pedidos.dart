import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientePedidos extends StatelessWidget {
  const ClientePedidos({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('id_cliente', isEqualTo: uid)
                //.orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("🔥 Error exacto: ${snapshot.error}");
            return const Center(
              child: Text('Ocurrió un error al cargar pedidos.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data?.docs ?? [];

          if (pedidos.isEmpty) {
            return const Center(child: Text('Aún no has hecho pedidos.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final estado = pedido['estado'];
              final timestamp = pedido['timestamp'];
              final fecha =
                  timestamp != null
                      ? (timestamp as Timestamp).toDate().toString().substring(
                        0,
                        16,
                      )
                      : 'Sin fecha';

              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(pedido['nombre_producto'] ?? 'Producto'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          const Text('Seguimiento:'),
                          Text(
                            _progresoVisual(estado),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Text(
                        fecha,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (estado == 'entregado')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => CalificacionDialog(
                                        idPedido: pedido.id,
                                        idCliente: pedido['id_cliente'],
                                        idProducto: pedido['id_producto'] ?? '',
                                        idRestaurante:
                                            pedido['id_restaurante'] ?? '',
                                      ),
                                );
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Sí'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tu caso ha sido reportado a soporte técnico.',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.warning),
                              label: const Text('No'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _progresoVisual(String estado) {
    switch (estado) {
      case 'pendiente':
        return '🟢 Pendiente → ⚪ En preparación → ⚪ Listo → ⚪ Entregado';
      case 'en_preparacion':
        return '🟢 Pendiente → 🟡 En preparación → ⚪ Listo → ⚪ Entregado';
      case 'listo':
        return '🟢 Pendiente → 🟡 En preparación → 🔵 Listo → ⚪ Entregado';
      case 'entregado':
        return '🟢 Pendiente → 🟡 En preparación → 🔵 Listo → ✅ Entregado';
      default:
        return 'Estado desconocido';
    }
  }
}

class CalificacionDialog extends StatefulWidget {
  final String idPedido;
  final String idCliente;
  final String idProducto;
  final String idRestaurante;

  const CalificacionDialog({
    super.key,
    required this.idPedido,
    required this.idCliente,
    required this.idProducto,
    required this.idRestaurante,
  });

  @override
  State<CalificacionDialog> createState() => _CalificacionDialogState();
}

class _CalificacionDialogState extends State<CalificacionDialog> {
  int calProd = 5;
  int calRest = 5;

  Future<void> _enviar() async {
    await FirebaseFirestore.instance.collection('calificaciones').add({
      'id_cliente': widget.idCliente,
      'id_producto': widget.idProducto,
      'id_restaurante': widget.idRestaurante,
      'calificacion_producto': calProd,
      'calificacion_restaurante': calRest,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.idPedido)
        .delete();

    if (mounted) {
      Navigator.pop(context); // cerrar diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu calificación!')),
      );
    }
  }

  Widget _buildEstrellas(int cal, Function(int) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final index = i + 1;
        return IconButton(
          onPressed: () => onChange(index),
          icon: Icon(
            Icons.star,
            color: index <= cal ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Califica tu experiencia'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Producto:'),
          _buildEstrellas(calProd, (val) => setState(() => calProd = val)),
          const SizedBox(height: 10),
          const Text('Restaurante:'),
          _buildEstrellas(calRest, (val) => setState(() => calRest = val)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _enviar, child: const Text('Enviar')),
      ],
    );
  }
}
