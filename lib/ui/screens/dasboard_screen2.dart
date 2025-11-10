import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricScreen extends StatefulWidget {
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistoricScreenState();
}

class _HistoricScreenState extends State<HistoricScreen> {
  DateTime? _start;
  DateTime? _end;
  String _statusFilter = 'all';

  final CollectionReference logsRef =
      FirebaseFirestore.instance.collection('equipment');

  Future<Map<String, int>> _getEquipmentStatistics() async {
    final query = await logsRef.get();
    int total = 0, completed = 0, pending = 0, overdue = 0;
    final now = DateTime.now();

    for (var doc in query.docs) {
      total++;
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? 'pending') as String;
      if (status == 'completed') completed++;
      if (status == 'pending') pending++;
      final ts = data['date'];
      DateTime date;
      if (ts is Timestamp) date = ts.toDate();
      else if (ts is DateTime) date = ts;
      else continue;
      if (date.isBefore(now) && status != 'completed') overdue++;
    }

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  Query _buildQuery() {
    Query q = logsRef.orderBy('date', descending: true);
    if (_statusFilter != 'all') q = q.where('status', isEqualTo: _statusFilter);
    if (_start != null) {
      q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_start!));
    }
    if (_end != null) {
      final endDay = DateTime(_end!.year, _end!.month, _end!.day, 23, 59, 59);
      q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDay));
    }
    return q;
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
        title: const Text('Histórico de Manutenções'),
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
                final docs = snap.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final data = d.data() as Map<String, dynamic>;
                    final equipmentName = data['equipmentName'] ?? '—';
                    final status = data['status'] ?? 'pending';
                    final date = data['date'];
                    final notes = data['notes'] ?? '';
                    return Card(
                      child: ListTile(
                        leading: _statusIcon(status),
                        title: Text(equipmentName),
                        subtitle: Text('${_formatDate(date)}\n$notes', maxLines: 2, overflow: TextOverflow.ellipsis),
                        isThreeLine: true,
                        trailing: Text(status.toString().toUpperCase()),
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
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'overdue':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_bottom, color: Colors.orange);
    }
  }
}