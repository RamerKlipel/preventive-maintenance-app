import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CreateEquipmentScreen extends StatefulWidget {
  const CreateEquipmentScreen({super.key});

  @override
  State<CreateEquipmentScreen> createState() => _CreateEquipmentScreen();
}

class ChecklistItem {
  TextEditingController titleController;
  TextEditingController descriptionController;
  bool isRequired;

  ChecklistItem({
    required this.titleController,
    required this.descriptionController,
    this.isRequired = false,
  });
}

class _CreateEquipmentScreen extends State<CreateEquipmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _machinaryType = TextEditingController();
  final TextEditingController _machinaryLocal = TextEditingController();
  final TextEditingController _nextMaintenace = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List <ChecklistItem> _checklistItems = [];

  @override

  void initState() {
    super.initState();
    _addChecklistItem();
  }

  void _addChecklistItem() {
    setState(() {
      _checklistItems.add(
        ChecklistItem(
          titleController: TextEditingController(),
          descriptionController: TextEditingController(),
          isRequired: false,
        ),
      );
    });
  }
  
  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems[index].titleController.dispose();
      _checklistItems[index].descriptionController.dispose();
      _checklistItems.removeAt(index);
    });
  }

  Future<void> _saveEquipment() async {
    final name = _nameController.text;
    final machinaryType = _machinaryType.text;
    final machinaryLocal = _machinaryLocal.text;
    final nextMaintenace = _nextMaintenace.text;

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome do equipamento.'))
      );
      return;
    }

    if (_machinaryType.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o tipo do equipamento.'))
      );
      return;
    }

    if (_machinaryLocal.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o local do equipamento.'))
      );
      return;
    }

    if (_nextMaintenace.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha a data de manutenção do equipamento.')),
      );
      return;
    }

    List<Map<String, dynamic>> checklist = _checklistItems.map((item) {
      return {
        'title': item.titleController.text,
        'description': item.descriptionController.text,
        'isRequired': item.isRequired,
      };
    }).toList();

    try {
      await _firestore.collection('equipment').add({
        'NMEQUPMENT': _nameController.text,
        'DSTPEQUIPMENT': _machinaryType.text,
        'DSLOCALEQUIPMENT': _machinaryLocal.text,
        'DATEEQUIPMENT': _nextMaintenace.text,
        'CHECKLIST': checklist,
        'IDUSUARIOINCLUSAO': FirebaseAuth.instance.currentUser?.uid,
        'DAINCLUSAO': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _machinaryType.clear();
      _machinaryLocal.clear();
      _nextMaintenace.clear();

    Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocorreu um erro ao tentar salvar as informações, tente novamente e se o erro persistir, contate um administrador do sistema erro: $e")),
      );
      return;
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

    for (var item in _checklistItems) {
      item.titleController.dispose();
      item.descriptionController.dispose();
    }

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
                                  labelText: "Próxima Manutenção *",
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
                          padding: EdgeInsets.fromLTRB(16, 50, 16, 16),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 252, 252, 252),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _checklistItems.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.drag_handle, color: Colors.grey),
                                            SizedBox(width: 8),
                                            Text(
                                              "Item ${index + 1}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Spacer(),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: _checklistItems[index].isRequired,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _checklistItems[index].isRequired = value ?? false;
                                                    });
                                                  }
                                                ),
                                                Text('Obrigatorio'),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _removeChecklistItem(index),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        TextField(
                                          controller: _checklistItems[index].titleController,
                                          decoration: InputDecoration(
                                            labelText: 'Título do item (ex: Verificar nível de óleo)',
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        TextField(
                                          controller: _checklistItems[index].descriptionController,
                                          decoration: InputDecoration(
                                            labelText: 'Descrição opcional (Ex: Verificar se está entre min/max)',
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _addChecklistItem,
                                icon: Icon(Icons.add),
                                label: Text("Adicionar Item ao Checklist"),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 45),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            color: const Color.fromARGB(255, 252, 252 ,252),
                            child: const Text(
                              "Checklist para Manutenção",
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
                        borderRadius: BorderRadius.circular(8),
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
