import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'admin_aprovar_solicitacoes_metas_screen.dart';

class AdminMetasScreen extends StatefulWidget {
  const AdminMetasScreen({super.key});

  @override
  State<AdminMetasScreen> createState() => _AdminMetasScreenState();
}

class _AdminMetasScreenState extends State<AdminMetasScreen> {
  final GoalService _goalService = GoalService();
  List<Goal> _metas = [];
  bool _isLoading = true;
  String? _error;
  final bool _requerAprovacao = false;

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
      final metas = await _goalService.listarMetas();
      setState(() {
        _metas = metas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _mostrarDialogCriarMeta() {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final requisitoController = TextEditingController();
    final recompensaController = TextEditingController();
    String tipoSelecionado = 'evento';
    bool requerAprovacao = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Criar Nova Meta'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Título é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Descrição é obrigatória';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'evento', child: Text('Evento')),
                      DropdownMenuItem(value: 'indicacao', child: Text('Indicação')),
                      DropdownMenuItem(value: 'desempenho', child: Text('Desempenho')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoSelecionado = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: requisitoController,
                    decoration: const InputDecoration(
                      labelText: 'Requisito',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requisito é obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Deve ser um número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: recompensaController,
                    decoration: const InputDecoration(
                      labelText: 'Recompensa (coins)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Recompensa é obrigatória';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Deve ser um número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: requerAprovacao,
                        onChanged: (val) {
                          setState(() { requerAprovacao = val!; });
                        },
                      ),
                      const Text('Requer aprovação?'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _goalService.criarMeta(
                      titulo: tituloController.text,
                      descricao: descricaoController.text,
                      tipo: tipoSelecionado,
                      requisito: int.parse(requisitoController.text),
                      recompensa: int.parse(recompensaController.text),
                      requerAprovacao: requerAprovacao,
                    );
                    
                    Navigator.of(context).pop();
                    _carregarMetas();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meta criada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao criar meta: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogEditarMeta(Goal meta) {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: meta.titulo);
    final descricaoController = TextEditingController(text: meta.descricao);
    final requisitoController = TextEditingController(text: meta.requisito.toString());
    final recompensaController = TextEditingController(text: meta.recompensa.toString());
    String tipoSelecionado = meta.tipo;
    bool requerAprovacaoEdit = meta.requerAprovacao;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Meta'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Título é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Descrição é obrigatória';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'evento', child: Text('Evento')),
                      DropdownMenuItem(value: 'indicacao', child: Text('Indicação')),
                      DropdownMenuItem(value: 'desempenho', child: Text('Desempenho')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoSelecionado = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: requisitoController,
                    decoration: const InputDecoration(
                      labelText: 'Requisito',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requisito é obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Deve ser um número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: recompensaController,
                    decoration: const InputDecoration(
                      labelText: 'Recompensa (coins)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Recompensa é obrigatória';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Deve ser um número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: requerAprovacaoEdit,
                        onChanged: (val) {
                          setState(() { requerAprovacaoEdit = val!; });
                        },
                      ),
                      const Text('Requer aprovação?'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _goalService.editarMeta(
                      metaId: meta.id!,
                      titulo: tituloController.text,
                      descricao: descricaoController.text,
                      tipo: tipoSelecionado,
                      requisito: int.parse(requisitoController.text),
                      recompensa: int.parse(recompensaController.text),
                      requerAprovacao: requerAprovacaoEdit,
                    );
                    
                    Navigator.of(context).pop();
                    _carregarMetas();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meta editada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao editar meta: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarMeta(Goal meta) async {
    await context.read<AuthProvider>().initialize();
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja deletar a meta "${meta.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        await _goalService.deletarMeta(meta.id!);
        _carregarMetas();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta deletada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar meta: $e'),
              backgroundColor: Colors.red,
            ),
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
          'Gerenciar Metas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _mostrarDialogCriarMeta,
          ),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in, color: Colors.blue),
            tooltip: 'Aprovar Solicitações de Metas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAprovarSolicitacoesMetasScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _mostrarDialogEditarMeta(meta),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Editar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _editarMeta(meta),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Deletar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
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