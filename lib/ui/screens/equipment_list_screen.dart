import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "../screens/edit_equipment_screen.dart";
import "../screens/checklist_equipment_screen.dart";

Color _getCardColor(String? date) {
  if (date == null || date.isEmpty) {
    return Colors.grey[100]!;
  }

  int DaysUntilMaintenance = _getDifferenceDays(date);

  if (DaysUntilMaintenance < 0) {
    return const Color.fromARGB(255, 255, 142, 142);
  } else if (DaysUntilMaintenance == 0) {
    return const Color.fromARGB(255, 170, 255, 121);
  } else if (DaysUntilMaintenance < 3) {
    return const Color.fromARGB(255, 255, 176, 142);
  }
  return Colors.white;
}

Color _getBorder(String? date) {
  if (date == null || date.isEmpty) {
    return Colors.grey[100]!;
  }

  int DaysUntilMaintenance = _getDifferenceDays(date);
  if (DaysUntilMaintenance < 0) {
    return const Color.fromARGB(255, 255, 110, 110);
  } else if (DaysUntilMaintenance == 0) {
    return const Color.fromARGB(255, 150, 231, 102);
  } else if (DaysUntilMaintenance < 3) {
    return const Color.fromARGB(255, 255, 139, 90);
  }
  return Colors.white;
}

String _getTextByDate(String? date) {
  if (date == null || date.isEmpty) {
    return 'awdiawld';
  }
  int DaysUntilMaintenance = _getDifferenceDays(date);
  if (DaysUntilMaintenance < 0) {
    return "Atrasado";
  } else if (DaysUntilMaintenance == 0) {
    return "Hoje";
  } else if (DaysUntilMaintenance < 3) {
    return "Vencendo";
  }
  return '';
}

int _getDifferenceDays(String? date) {
  List<String> parts = date!.split('/');
  DateTime maintenanceDate = DateTime(
    int.parse(parts[2]),
    int.parse(parts[1]),
    int.parse(parts[0]),
  );

  return maintenanceDate.difference(DateTime.now()).inDays;
}

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('equipment').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "ocorreu um erro. contate o administrador ou tente novamente mais tarde!",
            ),
          );
        }

        final equipmentList = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final checklist = List<Map<String, dynamic>>.from(data['CHECKLIST'] ?? []);
          
          if (checklist.isEmpty) return true;
          
          final allCompleted = checklist.every((item) => item['isCompleted'] == true);
          
          return !allCompleted;
        }).toList();

        if (equipmentList.isEmpty) {
          return const Center(
            child: Text("Nenhum equipamento com manutenção pendente"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: equipmentList.length,
          itemBuilder: (context, index) {
            final equipmentDoc = equipmentList[index];
            final equipmentData = equipmentDoc.data() as Map<String, dynamic>;
            final equipmentName = equipmentData['NMEQUPMENT'] ?? 'Nome não informado';
            final equipmentLocal = equipmentData['DSLOCALEQUIPMENT'] ?? 'Local não informado';
            final equipmentTipo = equipmentData['DSTPEQUIPMENT'] ?? 'Tipo não informado';
            final equipmentDataMaintenance = equipmentData['DATEEQUIPMENT'] ?? "Data não informada";
            final textCard = _getTextByDate(equipmentDataMaintenance);
            final colorCard = _getCardColor(equipmentDataMaintenance);
            final colorBordercard = _getBorder(equipmentDataMaintenance);

            return Dismissible(
              key: Key(equipmentDoc.id),
              background: Container(
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              secondaryBackground: Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Editar', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.edit, color: Colors.white),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  final delete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar Exclusão"),
                      content: const Text(
                        "Tem certeza que deseja excluir este esquipamento?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Excluir"),
                        ),
                      ],
                    ),
                  );
                  if (delete == true) {
                    FirebaseFirestore.instance
                        .collection('equipment')
                        .doc(equipmentDoc.id)
                        .delete();
                  }
                  return delete;
                }
                if (direction == DismissDirection.endToStart) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditEquipmentScreen(
                        equipmentId: equipmentDoc.id,
                        equipmentData: equipmentData,
                      ),
                    ),
                  );
                  return false;
                }
                return false;
              },
              child: Card(
                elevation: 2,
                color: colorCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorBordercard, width: 2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChecklistEquipmentScreen(
                          equipmentId: equipmentDoc.id,
                          equipmentData: equipmentData,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              equipmentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(equipmentTipo),
                                Text(
                                  '$equipmentLocal • $equipmentDataMaintenance',
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (textCard.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorBordercard,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              textCard,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
