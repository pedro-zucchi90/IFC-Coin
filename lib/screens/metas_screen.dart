import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({Key? key}) : super(key: key);

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final GoalService _goalService = GoalService();
  List<Goal> _metas = [];
  bool _isLoading = true;
  String? _error;
  String _selectedTipo = 'todos';

  @override
  void initState() {
    super.initState();
    _carregarMetas();
  }

  Future<void> _carregarMetas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final metas = await _goalService.listarMetas(
        tipo: _selectedTipo == 'todos' ? null : _selectedTipo,
      );
      
      // Reorganizar lista: metas não concluídas primeiro, depois as concluídas
      final metasNaoConcluidas = metas.where((meta) => !(meta.usuarioConcluiu ?? false)).toList();
      final metasConcluidas = metas.where((meta) => meta.usuarioConcluiu ?? false).toList();
      
      setState(() {
        _metas = [...metasNaoConcluidas, ...metasConcluidas];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _concluirMeta(Goal meta) async {
    setState(() { _isLoading = true; });
    try {
      await _goalService.concluirMeta(metaId: meta.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meta concluída! +${meta.recompensa} coins'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await context.read<AuthProvider>().updateUserData();
      await _carregarMetas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao concluir meta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() { _isLoading = false; });
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
          'Metas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.black, size: 40),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black, size: 40),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por tipo
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedTipo,
              decoration: const InputDecoration(
                labelText: 'Filtrar por tipo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todas')),
                DropdownMenuItem(value: 'evento', child: Text('Evento')),
                DropdownMenuItem(value: 'indicacao', child: Text('Indicação')),
                DropdownMenuItem(value: 'desempenho', child: Text('Desempenho')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTipo = value!;
                });
                _carregarMetas();
              },
            ),
          ),
          
          // Lista de metas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Erro ao carregar metas',
                              style: TextStyle(color: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: _carregarMetas,
                              child: Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : _metas.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma meta encontrada',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _metas.length,
                            itemBuilder: (context, index) {
                              final meta = _metas[index];
                              final usuarioConcluiu = meta.usuarioConcluiu ?? false;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              meta.titulo,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getTipoColor(meta.tipo),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              meta.tipo.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        meta.descricao,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Recompensa: ${meta.recompensa} coins',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (usuarioConcluiu)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.green.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Meta concluída!',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                                                              else
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => _concluirMeta(meta),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Concluir Meta'),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'evento':
        return Colors.blue;
      case 'indicacao':
        return Colors.green;
      case 'desempenho':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 