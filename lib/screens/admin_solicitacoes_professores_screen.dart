import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../services/notification_service.dart';

const Color azulPrincipal = Color(0xFF1976D2);

class AdminSolicitacoesProfessoresScreen extends StatefulWidget {
  const AdminSolicitacoesProfessoresScreen({Key? key}) : super(key: key);

  @override
  State<AdminSolicitacoesProfessoresScreen> createState() => _AdminSolicitacoesProfessoresScreenState();
}

class _AdminSolicitacoesProfessoresScreenState extends State<AdminSolicitacoesProfessoresScreen> {
  final AdminService _adminService = AdminService();
  final NotificationService _notificationService = NotificationService();
  List<User> _solicitacoes = [];
  Map<String, int> _estatisticas = {};
  bool _isLoading = true;
  String? _error;
  String _filtroStatus = 'pendente';
  int _paginaAtual = 1;
  int _totalPaginas = 1;
  Map<String, bool> _loadingAprovacao = {};
  Map<String, bool> _loadingRecusa = {};

  @override
  void initState() {
    super.initState();
    _initNotificacoes();
    _carregarDados();
  }

  Future<void> _initNotificacoes() async {
    await _notificationService.initialize();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Carregar estatísticas
      final stats = await _adminService.obterEstatisticasSolicitacoes();
      
      // Carregar solicitações
      final resultado = await _adminService.listarSolicitacoesProfessores(
        page: _paginaAtual,
        status: _filtroStatus == 'todas' ? null : _filtroStatus,
      );

      setState(() {
        _estatisticas = stats;
        _solicitacoes = resultado['solicitacoes'];
        _totalPaginas = resultado['paginacao']['paginas'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _aprovarProfessor(User professor) async {
    setState(() {
      _loadingAprovacao[professor.id!] = true;
    });
    try {
      await _adminService.aprovarProfessor(professor.id!);
      if (!_notificationService.isInitialized) {
        await _notificationService.initialize();
      }
      await _notificationService.notificarProfessorAprovado(professor.nome);
      setState(() {
        final index = _solicitacoes.indexWhere((p) => p.id == professor.id);
        if (index != -1) {
          _solicitacoes[index] = _solicitacoes[index].copyWith(
            statusAprovacao: 'aprovado',
          );
        }
        _estatisticas['pendentes'] = (_estatisticas['pendentes'] ?? 1) - 1;
        _estatisticas['aprovados'] = (_estatisticas['aprovados'] ?? 0) + 1;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professor ${professor.nome} aprovado com sucesso!'),
            backgroundColor: azulPrincipal,
          ),
        );
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: azulPrincipal, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Solicitação Aceita',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: azulPrincipal),
                  ),
                ),
              ],
            ),
            content: Text(
              'A solicitação do professor ${professor.nome} foi aprovada com sucesso!',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: azulPrincipal)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      String mensagemErro = e.toString();
      if (mensagemErro.contains('Solicitação já foi processada')) {
        mensagemErro = 'Esta solicitação já foi processada anteriormente.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aprovar professor: $mensagemErro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loadingAprovacao[professor.id!] = false;
      });
    }
  }

  Future<void> _recusarProfessor(User professor) async {
    final motivoController = TextEditingController();
    
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar Professor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tem certeza que deseja recusar o professor "${professor.nome}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo da recusa (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Recusar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      setState(() {
        _loadingRecusa[professor.id!] = true;
      });
      try {
        await _adminService.recusarProfessor(
          professor.id!,
          motivo: motivoController.text.isNotEmpty ? motivoController.text : null,
        );
        
        // Atualizar o status na lista local
        setState(() {
          final index = _solicitacoes.indexWhere((p) => p.id == professor.id);
          if (index != -1) {
            _solicitacoes[index] = _solicitacoes[index].copyWith(
              statusAprovacao: 'recusado',
            );
          }
          
          // Atualizar estatísticas
          _estatisticas['pendentes'] = (_estatisticas['pendentes'] ?? 1) - 1;
          _estatisticas['recusados'] = (_estatisticas['recusados'] ?? 0) + 1;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Professor ${professor.nome} recusado.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        String mensagemErro = e.toString();
        if (mensagemErro.contains('Solicitação já foi processada')) {
          mensagemErro = 'Esta solicitação já foi processada anteriormente.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao recusar professor: $mensagemErro'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _loadingRecusa[professor.id!] = false;
        });
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
          'Solicitações de Professores',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Estatísticas
          if (_estatisticas.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Pendentes',
                      count: _estatisticas['pendentes'] ?? 0,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'Aprovados',
                      count: _estatisticas['aprovados'] ?? 0,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'Recusados',
                      count: _estatisticas['recusados'] ?? 0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

          // Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _filtroStatus,
              decoration: const InputDecoration(
                labelText: 'Filtrar por status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todas', child: Text('Todas')),
                DropdownMenuItem(value: 'pendente', child: Text('Pendentes')),
                DropdownMenuItem(value: 'aprovado', child: Text('Aprovados')),
                DropdownMenuItem(value: 'recusado', child: Text('Recusados')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroStatus = value!;
                  _paginaAtual = 1;
                });
                _carregarDados();
              },
            ),
          ),

          // Lista de solicitações
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Erro ao carregar solicitações',
                              style: TextStyle(color: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: _carregarDados,
                              child: Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : _solicitacoes.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma solicitação encontrada',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _solicitacoes.length,
                            itemBuilder: (context, index) {
                              final solicitacao = _solicitacoes[index];
                              
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  solicitacao.nome,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  solicitacao.email,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  'SIAPE: ${solicitacao.matricula}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(solicitacao.statusAprovacao ?? 'pendente'),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getStatusText(solicitacao.statusAprovacao ?? 'pendente').toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Data de cadastro: ${_formatDate(solicitacao.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      if (solicitacao.statusAprovacao == 'pendente') ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: _loadingAprovacao[solicitacao.id] == true ? null : () => _aprovarProfessor(solicitacao),
                                                icon: _loadingAprovacao[solicitacao.id] == true
                                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                    : const Icon(Icons.check),
                                                label: const Text('Aprovar'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: _loadingRecusa[solicitacao.id] == true ? null : () => _recusarProfessor(solicitacao),
                                                icon: _loadingRecusa[solicitacao.id] == true
                                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                    : const Icon(Icons.close),
                                                label: const Text('Recusar'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),

          // Paginação
          if (_totalPaginas > 1)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _paginaAtual > 1
                        ? () {
                            setState(() {
                              _paginaAtual--;
                            });
                            _carregarDados();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Página $_paginaAtual de $_totalPaginas'),
                  IconButton(
                    onPressed: _paginaAtual < _totalPaginas
                        ? () {
                            setState(() {
                              _paginaAtual++;
                            });
                            _carregarDados();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'aprovado':
        return Colors.green;
      case 'recusado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pendente':
        return 'pendente';
      case 'aprovado':
        return 'aprovado';
      case 'recusado':
        return 'recusado';
      default:
        return 'desconhecido';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não disponível';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 