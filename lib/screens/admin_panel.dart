import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'crear_producto.dart';
import 'crear_restaurante.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  void _cambiarEstadoPedido(String id, String nuevoEstado) {
    FirebaseFirestore.instance.collection('pedidos').doc(id).update({
      'estado': nuevoEstado,
    });
  }

  void _cambiarDisponibilidadProducto(String id, bool disponible) {
    FirebaseFirestore.instance.collection('productos').doc(id).update({
      'disponible': disponible,
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel del Administrador'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Pedidos'), Tab(text: 'Productos')],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // 🧾 Pestaña de Pedidos
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('pedidos')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pedidos = snapshot.data!.docs;

                if (pedidos.isEmpty) {
                  return const Center(
                    child: Text('No hay pedidos registrados.'),
                  );
                }

                return ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    final estado = pedido['estado'];
                    return ListTile(
                      title: Text(pedido['nombre_producto']),
                      subtitle: Text('Estado: $estado'),
                      trailing: DropdownButton<String>(
                        value: estado,
                        items: const [
                          DropdownMenuItem(
                            value: 'pendiente',
                            child: Text('Pendiente'),
                          ),
                          DropdownMenuItem(
                            value: 'en_preparacion',
                            child: Text('En preparación'),
                          ),
                          DropdownMenuItem(
                            value: 'listo',
                            child: Text('Listo'),
                          ),
                          DropdownMenuItem(
                            value: 'entregado',
                            child: Text('Entregado'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _cambiarEstadoPedido(pedido.id, value);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),

            // 🍔 Pestaña de Productos y Restaurantes
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir producto'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CrearProducto(),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.store),
                        label: const Text('Crear restaurante'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CrearRestaurante(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const Text(
                  'Productos registrados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('productos')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final productos = snapshot.data!.docs;

                      if (productos.isEmpty) {
                        return const Center(
                          child: Text('No hay productos registrados.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          return SwitchListTile(
                            title: Text(producto['nombre']),
                            subtitle: Text(
                              'Disponible: ${producto['disponible']}',
                            ),
                            value: producto['disponible'],
                            onChanged: (value) {
                              _cambiarDisponibilidadProducto(
                                producto.id,
                                value,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
