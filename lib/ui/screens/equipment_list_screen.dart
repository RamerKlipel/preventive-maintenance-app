import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

Color _getCardColor(String? date) {
  if (date == null || date.isEmpty) {
    return Colors.grey[100]!;
  } 
  
  // DateTime today = DateTime.now();
  // int totalDays
  int DaysUntilMaintenance = _getDifferenceDays(date);

  if (DaysUntilMaintenance < 0) {
    return const Color.fromARGB(255, 255, 142, 142);
  } else if (DaysUntilMaintenance < 3) {
    return const Color.fromARGB(255, 255, 176, 142);
  } else if (DaysUntilMaintenance < 7) {
    return const Color.fromARGB(255, 253, 255, 142);
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
  } else if (DaysUntilMaintenance < 3) {
    return const Color.fromARGB(255, 255, 161, 121);
  } else if (DaysUntilMaintenance < 7) {
    return const Color.fromARGB(255, 255, 251, 0);
  }
  return Colors.white;
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
  const EquipmentListScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('equipment').snapshots(),
      builder:(context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

        // }
        if (snapshot.hasError) {
          return const Center(child: Text("ocorreu um erro. contate o administrador ou tente novamente mais tarde!"));
        }

        final equipmentList = snapshot.data!.docs;
        
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
                )
              ),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  FirebaseFirestore.instance.collection('equipment').doc(equipmentDoc.id).delete();
                }
                if (direction == DismissDirection.endToStart) {
                  print('editar'); //todo fazer a função para abrir a tela de edição do equipamento
                }
              },
              child: Card(
                elevation: 2,
                color: _getCardColor(equipmentDataMaintenance),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                  side: BorderSide(
                    color: _getBorder(equipmentDataMaintenance),
                    width: 2,
                  )
                ),
                child: ListTile(
                  title: Text(
                    equipmentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(equipmentTipo),
                      Text(equipmentLocal +' • ' + equipmentDataMaintenance),
                    ]
                  ),
                  onTap: () {
                    // todo Fazer a tela de editar aqui
                    print('clicado');
                  },
                ),
              ),
            );
          },
        );
        // return ListView.builder()
        // return Center(child: Text(snapshot.data?.docs));
      }
    );
  }
}