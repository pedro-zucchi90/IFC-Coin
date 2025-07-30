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
      final todas = await _transactionService.listarTodasTransacoes(limit: 100);
      
      final pendentes = todas.where((t) => t.status == 'pendente').toList();
      
      setState(() {
        _pendentes = pendentes;
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Aprovar Transferências',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erro ao carregar transferências',
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: _carregarPendentes,
                        child: Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _pendentes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma transferência pendente',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Todas as transferências foram processadas',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendentes.length,
                      itemBuilder: (context, index) {
                        final t = _pendentes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'PENDENTE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${t.quantidade} IFC Coin',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'De: ${t.origem?.nome ?? '-'}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Matrícula: ${t.origem?.matricula ?? '-'}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                          Text(
                                            'Tipo: ${t.origem?.role ?? '-'}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward, color: Colors.grey),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Para: ${t.destino?.nome ?? '-'}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.end,
                                          ),
                                          Text(
                                            'Matrícula: ${t.destino?.matricula ?? '-'}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            textAlign: TextAlign.end,
                                          ),
                                          Text(
                                            'Tipo: ${t.destino?.role ?? '-'}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            textAlign: TextAlign.end,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (t.descricao.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.description, color: Colors.blue, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            t.descricao,
                                            style: TextStyle(color: Colors.blue.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Text(
                                  'Data: ${_formatarData(t.createdAt)}',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Aprovar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => _aprovar(t),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const Text('Recusar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
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