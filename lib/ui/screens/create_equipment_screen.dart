import 'package:flutter/material.dart';

class CreateEquipmentScreen extends StatefulWidget {
  const CreateEquipmentScreen({super.key});

  @override
  State<CreateEquipmentScreen> createState() => _CreateEquipmentScreen();
}

class _CreateEquipmentScreen extends State<CreateEquipmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _machinaryType = TextEditingController();
  final TextEditingController _machinaryLocal = TextEditingController();
  final TextEditingController _nextMaintenace = TextEditingController();

  void _saveEquipment() {
    final name = _nameController.text;
    final serialNumber = _machinaryType.text;

    if (name.isNotEmpty) {
      print('salvando: $name - $serialNumber');
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _nextMaintenace.text = _formatDate(picked);
      });
    }
  }

  void dispose() {
    _nameController.dispose();
    _machinaryType.dispose();
    _machinaryLocal.dispose();
    _nextMaintenace.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Equipamento"), centerTitle: true),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.fromLTRB(16, 50, 16, 16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 252, 252, 252),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: "Nome do Equipamento *",
                                  hintText: "Ex: Compressor de ar 001",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _machinaryType,
                                decoration: const InputDecoration(
                                  labelText: "Tipo *",
                                  hintText: "Ex: Compressor, Moto, Bomba",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _machinaryLocal,
                                decoration: const InputDecoration(
                                  labelText: "Localização *",
                                  hintText: "Ex: Área Industrial A, Sala 101",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nextMaintenace,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Próxima Manutenção",
                                  hintText: "Ex: " +_formatDate(DateTime.now()),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                onTap:() => _selectDate(context),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            color: const Color.fromARGB(255, 252, 252, 252),
                            child: const Text(
                              "Detalhes do Equipamento",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 14, 14, 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(children: [Text("Checklists")]),
                        ),
                        Positioned(
                          left: 20,
                          top: 2,
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Cheklist para Manutenção",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                    ),
                    onPressed: _saveEquipment,
                    child: const Text("Salvar"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
