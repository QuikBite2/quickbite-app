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
                  children: [
                    ListTile(
                      title: Text("Estado del pedido"),
                      subtitle: Text(
                        estado.toUpperCase(),
                        style: TextStyle(
                          color:
                              estado == 'pendiente'
                                  ? Colors.orange
                                  : estado == 'en_preparacion'
                                  ? Colors.blue
                                  : estado == 'listo'
                                  ? Colors.green
                                  : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text("Fecha: $fecha"),
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
}
