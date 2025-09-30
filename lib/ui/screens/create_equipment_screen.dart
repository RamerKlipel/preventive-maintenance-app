import 'package:flutter/material.dart';

class CreateEquipmentScreen extends StatefulWidget
{
  const CreateEquipmentScreen({super.key});

  @override
  State<CreateEquipmentScreen> createState() => _CreateEquipmentScreen();
}

class _CreateEquipmentScreen extends State<CreateEquipmentScreen> {
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();

  void _saveEquipment() {
    final name = _nameController.text;
    final serialNumber = _serialController.text;

    if (name.isNotEmpty) {
      print('salvando: $name - $serialNumber');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Equipamento"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nome do Equipamento",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: "Número de Série (Opcional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveEquipment,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}