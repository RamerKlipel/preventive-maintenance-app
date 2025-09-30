import 'package:flutter/material.dart';
import '../screens/create_equipment_screen.dart';

class BottomSheetOptionModal extends StatelessWidget {
  const BottomSheetOptionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'O que você deseja adicionar?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Escolha uma das opções abaixo para continuar',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: Text("Adicionar novo equipamento"), // todo colocar um subtexto como ta no figma
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEquipmentScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 2),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Criar evento'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
