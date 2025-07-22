import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../models/goal_model.dart';

class AdminAprovarSolicitacoesMetasScreen extends StatefulWidget {
  const AdminAprovarSolicitacoesMetasScreen({Key? key}) : super(key: key);

  @override
  State<AdminAprovarSolicitacoesMetasScreen> createState() => _AdminAprovarSolicitacoesMetasScreenState();
}

class _AdminAprovarSolicitacoesMetasScreenState extends State<AdminAprovarSolicitacoesMetasScreen> {
  final GoalService _goalService = GoalService();
  List<GoalRequest> _solicitacoes = [];
  bool _isLoading = true;
  String? _error;
  String _filtroStatus = 'pendente';

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _goalService.listarSolicitacoesConclusao(status: _filtroStatus);
      setState(() {
        _solicitacoes = data.map<GoalRequest>((json) => GoalRequest.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _aprovarSolicitacao(GoalRequest req) async {
    try {
      await _goalService.aprovarSolicitacaoConclusao(req.id);
      _carregarSolicitacoes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação aprovada e coins creditados!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aprovar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _recusarSolicitacao(GoalRequest req) async {
    final TextEditingController respostaController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar Solicitação'),
        content: TextField(
          controller: respostaController,
          decoration: const InputDecoration(labelText: 'Motivo da recusa (opcional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Recusar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _goalService.recusarSolicitacaoConclusao(req.id, resposta: respostaController.text);
        _carregarSolicitacoes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitação recusada.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
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
        title: const Text('Aprovar Solicitações de Metas'),
        actions: [
          DropdownButton<String>(
            value: _filtroStatus,
            items: const [
              DropdownMenuItem(value: 'pendente', child: Text('Pendentes')),
              DropdownMenuItem(value: 'aprovada', child: Text('Aprovadas')),
              DropdownMenuItem(value: 'recusada', child: Text('Recusadas')),
            ],
            onChanged: (value) {
              setState(() {
                _filtroStatus = value!;
              });
              _carregarSolicitacoes();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : _solicitacoes.isEmpty
                  ? const Center(child: Text('Nenhuma solicitação encontrada'))
                  : ListView.builder(
                      itemCount: _solicitacoes.length,
                      itemBuilder: (context, index) {
                        final req = _solicitacoes[index];
                        return Card(
                          margin: const EdgeInsets.all(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Meta: ${req.goal.titulo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Aluno: ${req.aluno['nome']} (${req.aluno['matricula']})'),
                                if (req.comentario != null && req.comentario!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('Comentário: ${req.comentario}'),
                                  ),
                                if (req.evidenciaTexto != null && req.evidenciaTexto!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('Evidência: ${req.evidenciaTexto}'),
                                  ),
                                if (req.evidenciaArquivo != null && req.evidenciaArquivo!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('Arquivo: ${req.evidenciaArquivo}'),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('Status: ${req.status.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: req.status == 'pendente' ? Colors.orange : req.status == 'aprovada' ? Colors.green : Colors.red)),
                                ),
                                if (req.status == 'pendente')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.check),
                                          label: const Text('Aprovar'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          onPressed: () => _aprovarSolicitacao(req),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.close),
                                          label: const Text('Recusar'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => _recusarSolicitacao(req),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (req.status != 'pendente' && req.resposta != null && req.resposta!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('Resposta: ${req.resposta}'),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 