import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrearRestaurante extends StatefulWidget {
  const CrearRestaurante({super.key});

  @override
  State<CrearRestaurante> createState() => _CrearRestauranteState();
}

class _CrearRestauranteState extends State<CrearRestaurante> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final Map<String, bool> productosSeleccionados = {};

  Future<void> _cargarProductos() async {
    final productosSnap =
        await FirebaseFirestore.instance.collection('productos').get();
    setState(() {
      for (var doc in productosSnap.docs) {
        productosSeleccionados[doc.id] = false;
      }
    });
  }

  Future<void> _crearRestaurante() async {
    if (_formKey.currentState!.validate()) {
      final idsSeleccionados =
          productosSeleccionados.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList();

      await FirebaseFirestore.instance.collection('restaurantes').add({
        'nombre': nombreController.text.trim(),
        'descripcion': descripcionController.text.trim(),
        'productos': idsSeleccionados,
        'calificacion_promedio': 0,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurante creado exitosamente')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Restaurante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del restaurante',
                ),
                validator:
                    (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleccionar productos asociados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...productosSeleccionados.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.key),
                  value: entry.value,
                  onChanged: (val) {
                    setState(() {
                      productosSeleccionados[entry.key] = val!;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearRestaurante,
                child: const Text('Crear Restaurante'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
