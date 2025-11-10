import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  DateTime? _start;
  DateTime? _end;
  String _statusFilter = 'all';

  final CollectionReference logsRef = FirebaseFirestore.instance.collection('equipment');

  Future<Map<String, int>> _getEquipmentStatistics() async {
    final query = await logsRef.get();
    int total = 0, completed = 0, pending = 0, overdue = 0;
    final now = DateTime.now();

    for (var doc in query.docs) {
      total++;
      final data = doc.data() as Map<String, dynamic>;
      final checklist = List<Map<String, dynamic>>.from(data['CHECKLIST'] ?? []);
      final isCompleted = checklist.isNotEmpty && 
          checklist.every((item) => item['isCompleted'] == true);
      
      final dateStr = data['DATEEQUIPMENT'] as String?;
      if (dateStr != null && dateStr.isNotEmpty) {
        final parts = dateStr.split('/');
        final maintenanceDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );

        if (isCompleted) {
          completed++;
        } else {
          pending++;
          if (maintenanceDate.isBefore(now)) {
            overdue++;
          }
        }
      }
    }

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  Query _buildQuery() {
    Query query = logsRef.orderBy('DATEEQUIPMENT', descending: true);
    
    if (_start != null) {
      query = query.where('DATEEQUIPMENT', isGreaterThanOrEqualTo: 
        '${_start!.day.toString().padLeft(2, '0')}/${_start!.month.toString().padLeft(2, '0')}/${_start!.year}');
    }
    
    if (_end != null) {
      query = query.where('DATEEQUIPMENT', isLessThanOrEqualTo: 
        '${_end!.day.toString().padLeft(2, '0')}/${_end!.month.toString().padLeft(2, '0')}/${_end!.year}');
    }
    
    return query;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year + 5);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange:
          _start != null && _end != null ? DateTimeRange(start: _start!, end: _end!) : null,
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _start = null;
      _end = null;
      _statusFilter = 'all';
    });
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return '-';
    DateTime Data;
    if (ts is Timestamp) Data = ts.toDate();
    else if (ts is DateTime) Data = ts;
    else return ts.toString();
    return '${Data.day.toString().padLeft(2, '0')}/${Data.month.toString().padLeft(2, '0')}/${Data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Manutenções'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
            tooltip: 'Filtrar por período',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearFilters,
            tooltip: 'Limpar filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, int>>(
            future: _getEquipmentStatistics(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                );
              }
              final stats = snap.data ??
                  {'total': 0, 'completed': 0, 'pending': 0, 'overdue': 0};
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _smallCard('Total', stats['total']!.toString(), Colors.blue),
                    _smallCard('Concluídas', stats['completed']!.toString(), Colors.green),
                    _smallCard('Pendentes', stats['pending']!.toString(), Colors.orange),
                    _smallCard('Atrasadas', stats['overdue']!.toString(), Colors.red),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(_start == null || _end == null
                      ? 'Período: Todos'
                      : 'Período: ${_start!.day}/${_start!.month}/${_start!.year} - ${_end!.day}/${_end!.month}/${_end!.year}'),
                ),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'completed', child: Text('Concluídos')),
                    DropdownMenuItem(value: 'pending', child: Text('Pendentes')),
                    DropdownMenuItem(value: 'overdue', child: Text('Atrasados')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum registro encontrado.'));
                }
                
                final allDocs = snap.data!.docs;
                final docs = _statusFilter == 'all' 
                    ? allDocs 
                    : allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final checklist = List<Map<String, dynamic>>.from(data['CHECKLIST'] ?? []);
                        final isCompleted = checklist.isNotEmpty && 
                            checklist.every((item) => item['isCompleted'] == true);
                
                        switch (_statusFilter) {
                          case 'completed':
                            return isCompleted;
                          case 'pending':
                            return !isCompleted && !_isOverdue(data['DATEEQUIPMENT']);
                          case 'overdue':
                            return !isCompleted && _isOverdue(data['DATEEQUIPMENT']);
                          default:
                            return true;
                        }
                      }).toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final data = d.data() as Map<String, dynamic>;
                    final equipmentName = data['NMEQUPMENT'] ?? '—';
                    final date = data['DATEEQUIPMENT'];
                    final notes = data['DSTPEQUIPMENT'];
                    final checklist = List<Map<String, dynamic>>.from(data['CHECKLIST'] ?? []);
                    final isCompleted = checklist.isNotEmpty && 
                        checklist.every((item) => item['isCompleted'] == true);
        
                    final status = isCompleted ? 'completado' : 
                        (_isOverdue(date) ? 'atrasado' : 'a fazer');

                    return Card(
                      child: ListTile(
                        leading: _statusIcon(status),
                        title: Text(equipmentName),
                        subtitle: Text(_formatDate(date)),
                        trailing: Text(status.toUpperCase()),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(equipmentName),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Data: ${_formatDate(date)}'),
                                  const SizedBox(height: 8),
                                  Text('Status: $status'),
                                  const SizedBox(height: 8),
                                  Text('Observações:'),
                                  Text(notes),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'completado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'atrasado':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_bottom, color: Colors.orange);
    }
  }

  bool _isOverdue(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
  
    final parts = dateStr.split('/');
    final maintenanceDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  
    return maintenanceDate.isBefore(DateTime.now());
  }
}