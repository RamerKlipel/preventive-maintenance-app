import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricScreen extends StatefulWidget {
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistoricScreenState();
}

class _HistoricScreenState extends State<HistoricScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(String date) {
    final parts = date.split('/');
    return "${parts[0]}/${parts[1]}/${parts[2]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Manutenções'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('equipment')
            .where('DAALT', isNull: false)
            // .orderBy('DATEEQUIPMENT', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum registro encontrado'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final checklist = List<Map<String, dynamic>>.from(data['CHECKLIST'] ?? []);
              final completedItems = checklist.where((item) => item['isCompleted'] == true).length;
              final totalItems = checklist.length;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: Icon(
                    completedItems == totalItems 
                        ? Icons.check_circle 
                        : Icons.pending,
                    color: completedItems == totalItems 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  title: Text(
                    data['NMEQUPMENT'] ?? 'Sem nome',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: ${_formatDate(data['DATEEQUIPMENT'])}'),
                      Text('Progresso: $completedItems de $totalItems itens'),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Itens do Checklist:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...checklist.map((item) => ListTile(
                            leading: Icon(
                              item['isCompleted'] == true
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: item['isCompleted'] == true
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            title: Text(item['title'] ?? ''),
                            subtitle: Text(item['description'] ?? ''),
                          )).toList(),
                          const Divider(),
                          Text(
                            'Local: ${data['DSLOCALEQUIPMENT'] ?? 'Não especificado'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Tipo: ${data['DSTPEQUIPMENT'] ?? 'Não especificado'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}