import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RepartidorHome extends StatelessWidget {
  final String nombre;
  const RepartidorHome({super.key, required this.nombre});

  void _entregarPedido(String id) {
    FirebaseFirestore.instance.collection('pedidos').doc(id).update({
      'estado': 'entregado',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos - Repartidor'),
        actions: [
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
                .where('estado', isEqualTo: 'listo')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos = snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return const Center(child: Text('No hay pedidos listos.'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return ListTile(
                title: Text(pedido['nombre_producto']),
                subtitle: const Text('Estado: listo'),
                trailing: ElevatedButton(
                  onPressed: () => _entregarPedido(pedido.id),
                  child: const Text('Entregado'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
