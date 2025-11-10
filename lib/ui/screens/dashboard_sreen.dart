import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardSreen extends StatelessWidget {
  const DashboardSreen ({super.key});
  
  Future<Map<String, int>> _getEquipmentStatistics() async {
    final equipments = await FirebaseFirestore.instance.collection('equipment').get();
    int total = 0;
    int dueSoon = 0;
    int dueToday = 0;
    int overDue = 0;
    int dueNextSoon = 0;

    for (var doc in equipments.docs) {
      total++;

      final date = doc['DATEEQUIPMENT'] as String?;
      if (date != null && date.isNotEmpty) {
        final partes = date.split('/');
        final maintenaceDate = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );

        final difference = maintenaceDate.difference(DateTime.now()).inDays;

        if (difference < 0) {
          overDue++;
        } else if (difference == 0) {
          dueToday++;
        } else if (difference < 3) {
          dueSoon++;
        } else {
          dueNextSoon++;
        }
      }
    }
    return {
      'total': total,
      'dueSoon': dueSoon,
      'dueToday': dueToday,
      'overDue': overDue,
      'dueNextSoon': dueNextSoon
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getEquipmentStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final stats = snapshot.data ?? {
          'total': 0,
          'dueSoon': 0,
          'dueToday': 0,
          'overDue': 0,
          'dueNextSoon': 0,
        };

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: 
                
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildCard(
                      'Total de Equipamentos',
                      stats['total'].toString(),
                      Colors.blue,
                      Icons.build,
                    ),
                    _buildCard(
                      'Manutenções hoje',
                      stats['dueToday'].toString(),
                      Colors.green,
                      Icons.build,
                    ),
                    _buildCard(
                      'Manutenções Vencendo',
                      stats['dueSoon'].toString(),
                      Colors.orange,
                      Icons.build,
                    ),
                    _buildCard(
                      'Manutenções Atrasadas',
                      stats['overDue'].toString(),
                      Colors.red,
                      Icons.build,
                    ),
                    _buildCard(
                      'Manutenções futuras',
                      stats['dueNextSoon'].toString(),
                      Colors.white70,
                      Icons.build,
                    ),
                  ],
                )
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        )
      ),
    );
  }
}