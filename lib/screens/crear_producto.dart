import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrearProducto extends StatefulWidget {
  const CrearProducto({super.key});

  @override
  State<CrearProducto> createState() => _CrearProductoState();
}

class _CrearProductoState extends State<CrearProducto> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final imagenController = TextEditingController();
  bool disponible = true;

  Future<void> _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': nombreController.text.trim(),
        'descripcion': descripcionController.text.trim(),
        'precio': int.parse(precioController.text.trim()),
        'imagen_url': imagenController.text.trim(),
        'disponible': disponible,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado exitosamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
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
              TextFormField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Ingresa el precio' : null,
              ),
              TextFormField(
                controller: imagenController,
                decoration: const InputDecoration(labelText: 'URL de imagen'),
              ),
              SwitchListTile(
                title: const Text('Disponible'),
                value: disponible,
                onChanged: (value) {
                  setState(() {
                    disponible = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarProducto,
                child: const Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
