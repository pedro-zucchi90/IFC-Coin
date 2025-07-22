import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import '../widgets/user_avatar.dart';
import 'perfil_screen.dart';
import 'transferencia_screen.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HistoricoTransacoesScreen extends StatefulWidget {
  const HistoricoTransacoesScreen({super.key});

  @override
  State<HistoricoTransacoesScreen> createState() => _HistoricoTransacoesScreenState();
}

class _HistoricoTransacoesScreenState extends State<HistoricoTransacoesScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transacoes = [];
  bool _isLoading = true;
  String? _error;
  String _filtro = 'todos';

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  Future<void> _carregarTransacoes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final transacoes = await _transactionService.listarHistorico();
      setState(() {
        _transacoes = transacoes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _transacoesFiltradas {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (_filtro == 'todos') return _transacoes;
    if (_filtro == 'recebido') {
      return _transacoes.where((t) => t.destino?.id == userId).toList();
    }
    if (_filtro == 'enviado') {
      return _transacoes.where((t) => t.origem?.id == userId).toList();
    }
    return _transacoes;
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
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
          'Histórico de Transações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: UserAvatar(
              radius: 20,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerfilScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FiltroChip(
                  label: 'Todos',
                  selected: _filtro == 'todos',
                  onTap: () => setState(() => _filtro = 'todos'),
                ),
                _FiltroChip(
                  label: 'Recebidos',
                  selected: _filtro == 'recebido',
                  onTap: () => setState(() => _filtro = 'recebido'),
                ),
                _FiltroChip(
                  label: 'Enviados',
                  selected: _filtro == 'enviado',
                  onTap: () => setState(() => _filtro = 'enviado'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Erro: $_error'))
                    : _transacoesFiltradas.isEmpty
                        ? const Center(child: Text('Nenhuma transação encontrada'))
                        : ListView.builder(
                            itemCount: _transacoesFiltradas.length,
                            itemBuilder: (context, index) {
                              final t = _transacoesFiltradas[index];
                              final isRecebido = t.destino?.id == userId;
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isRecebido ? Colors.green.shade100 : Colors.red.shade100,
                                    child: Icon(
                                      isRecebido ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isRecebido ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(isRecebido ? 'RECEBIDO' : 'ENVIADO', style: TextStyle(fontWeight: FontWeight.bold, color: isRecebido ? Colors.green : Colors.red)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isRecebido && t.origem != null)
                                        Text('De: ${t.origem!.nome}'),
                                      if (!isRecebido && t.destino != null)
                                        Text('Para: ${t.destino!.nome}'),
                                      Text('Data: ${_formatarData(t.createdAt)}'),
                                      if (t.descricao.isNotEmpty)
                                        Text('Descrição: ${t.descricao}'),
                                      if (t.status != null && t.status != 'aprovada')
                                        Text('Status: ${t.status!.toUpperCase()}', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${isRecebido ? '+' : '-'}${t.quantidade} IFC coin',
                                    style: TextStyle(
                                      color: isRecebido ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.send),
        label: Text('Transferir'),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransferenciaScreen(),
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

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FiltroChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 