import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/ChecklistItem.dart';

class ChecklistEquipmentScreen extends StatefulWidget {
  final String equipmentId;
  final Map<String, dynamic> equipmentData;
  const ChecklistEquipmentScreen({
    super.key,
    required this.equipmentId,
    required this.equipmentData
    });

  @override
  State<ChecklistEquipmentScreen> createState() => _ChecklistEquipmentScreen();
}

class _ChecklistEquipmentScreen extends State<ChecklistEquipmentScreen> {
  late List<Map<String, dynamic>> checklist;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    checklist = List<Map<String, dynamic>>.from(widget.equipmentData['CHECKLIST'] ?? []);
    print(checklist);
  }

  void _toggleChecklistItem(int index, bool? value) {
    setState(() {
      checklist[index]['isCompleted'] = value ?? false;
      _saveEquipment();
    });
  }

  void _completeAllItems() {
    setState(() {
      for (var item in checklist) {
        item['isCompleted'] = true;
      }
      _saveEquipment();
    });
  }

  Future<void> _saveEquipment() async {
    try {
      await _firestore.collection('equipment').doc(widget.equipmentId).update({
        'CHECKLIST': checklist,
        'IDUSUARIOALT': FirebaseAuth.instance.currentUser?.uid,
        'DAALT': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocorreu um erro ao tentar salvar as informações, tente novamente e se o erro persistir, contate um administrador do sistema erro: $e")),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nmEquipment = widget.equipmentData['NMEQUPMENT'];
    final equipmentLocal = widget.equipmentData['DSLOCALEQUIPMENT'];
    final equipmentDataMaintenance = widget.equipmentData['DATEEQUIPMENT'];

    final totalItems = checklist.length * 1.0; 
    final completedItems = checklist.where((item) => item['isCompleted'] == true).length * 1.0;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;


    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nmEquipment ?? "Checklist"),
            Text(
              '$equipmentLocal • $equipmentDataMaintenance',
              style: const TextStyle(
                color: Color.fromARGB(255, 134, 134, 134),
                fontSize: 14,
              ),
            ),
          ]
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progresso",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 26, 26, 26)
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$completedItems de $totalItems itens concluídos",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: checklist.isEmpty 
            ? const Center(child: Text("Nenhum item no checklist")) 
            : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: checklist.length,
              itemBuilder: (context, index) {
                final item = checklist[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: (item['isCompleted'] ?? false)
                  ? Color.fromARGB(255, 241, 241, 241)
                  : Color.fromARGB(255, 255, 255, 255),
                  child: ListTile(
                    leading: Checkbox(
                      value: item['isCompleted'] ?? false,
                      onChanged: (value) => _toggleChecklistItem(index, value),
                    ),
                    title: Text(
                      item['title'] ?? 'Item sem título',
                      style: TextStyle(
                        decoration: (item['isCompleted'] ?? false) ? TextDecoration.lineThrough : TextDecoration.none
                      ),
                    ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['description'] ?? ''),
                      (item['isRequired'] ?? false) 
                      ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Obrigatório",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black
                          ),
                        ),
                      )
                      : Container(),
                    ]
                  ),
                  ),
                );
              },
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
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _completeAllItems,
                    child: const Text("Concluir Checklist"),
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