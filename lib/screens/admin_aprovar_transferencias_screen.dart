import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class AdminAprovarTransferenciasScreen extends StatefulWidget {
  const AdminAprovarTransferenciasScreen({super.key});

  @override
  State<AdminAprovarTransferenciasScreen> createState() => _AdminAprovarTransferenciasScreenState();
}

class _AdminAprovarTransferenciasScreenState extends State<AdminAprovarTransferenciasScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _pendentes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarPendentes();
  }

  Future<void> _carregarPendentes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Buscar todas as transações e filtrar pendentes
      final todas = await _transactionService.listarHistorico(limit: 100);
      setState(() {
        _pendentes = todas.where((t) => t.status == 'pendente').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _aprovar(Transaction t) async {
    setState(() { _isLoading = true; });
    try {
      await _transactionService.aprovarTransferencia(t.id!);
      await _carregarPendentes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transferência aprovada!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aprovar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _recusar(Transaction t) async {
    final TextEditingController motivoController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar Transferência'),
        content: TextField(
          controller: motivoController,
          decoration: const InputDecoration(labelText: 'Motivo da recusa (opcional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Recusar')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() { _isLoading = true; });
      try {
        await _transactionService.recusarTransferencia(t.id!, motivo: motivoController.text);
        await _carregarPendentes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transferência recusada.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        setState(() { _isLoading = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao recusar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprovar Transferências Pendentes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : _pendentes.isEmpty
                  ? const Center(child: Text('Nenhuma transferência pendente'))
                  : ListView.builder(
                      itemCount: _pendentes.length,
                      itemBuilder: (context, index) {
                        final t = _pendentes[index];
                        return Card(
                          margin: const EdgeInsets.all(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('De: ${t.origem?.nome ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Para: ${t.destino?.nome ?? '-'}'),
                                Text('Valor: ${t.quantidade} IFC Coin'),
                                Text('Descrição: ${t.descricao}'),
                                Text('Hash: ${t.hash}'),
                                Text('Data: ${_formatarData(t.createdAt)}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Aprovar'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () => _aprovar(t),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const Text('Recusar'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => _recusar(t),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
} 