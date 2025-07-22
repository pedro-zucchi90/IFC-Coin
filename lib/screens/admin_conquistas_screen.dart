import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminConquistasScreen extends StatefulWidget {
  const AdminConquistasScreen({super.key});

  @override
  State<AdminConquistasScreen> createState() => _AdminConquistasScreenState();
}

class _AdminConquistasScreenState extends State<AdminConquistasScreen> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _conquistas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarConquistas();
  }

  Future<void> _carregarConquistas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conquistas = await _achievementService.listarConquistas();
      setState(() {
        _conquistas = conquistas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _mostrarDialogCriarConquista() {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final categoriaController = TextEditingController();
    final iconeController = TextEditingController();
    final requisitosController = TextEditingController();
    String tipoSelecionado = 'medalha';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Nova Conquista'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
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
                    DropdownMenuItem(value: 'medalha', child: Text('Medalha')),
                    DropdownMenuItem(value: 'conquista', child: Text('Conquista')),
                    DropdownMenuItem(value: 'titulo', child: Text('Título')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoSelecionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoriaController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: iconeController,
                  decoration: const InputDecoration(
                    labelText: 'Ícone (emoji, opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: requisitosController,
                  decoration: const InputDecoration(
                    labelText: 'Requisitos (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                  await _achievementService.criarConquista(
                    nome: nomeController.text,
                    descricao: descricaoController.text,
                    tipo: tipoSelecionado,
                    categoria: categoriaController.text.isNotEmpty ? categoriaController.text : null,
                    icone: iconeController.text.isNotEmpty ? iconeController.text : null,
                    requisitos: requisitosController.text.isNotEmpty ? requisitosController.text : null,
                  );
                  
                  Navigator.of(context).pop();
                  _carregarConquistas();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conquista criada com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao criar conquista: $e'),
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
    );
  }

  void _mostrarDialogEditarConquista(Achievement conquista) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: conquista.nome);
    final descricaoController = TextEditingController(text: conquista.descricao);
    final categoriaController = TextEditingController(text: conquista.categoria ?? '');
    final iconeController = TextEditingController(text: conquista.icone ?? '');
    final requisitosController = TextEditingController(text: conquista.requisitos ?? '');
    String tipoSelecionado = conquista.tipo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Conquista'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
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
                    DropdownMenuItem(value: 'medalha', child: Text('Medalha')),
                    DropdownMenuItem(value: 'conquista', child: Text('Conquista')),
                    DropdownMenuItem(value: 'titulo', child: Text('Título')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoSelecionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoriaController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: iconeController,
                  decoration: const InputDecoration(
                    labelText: 'Ícone (emoji, opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: requisitosController,
                  decoration: const InputDecoration(
                    labelText: 'Requisitos (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                  await _achievementService.editarConquista(
                    conquistaId: conquista.id!,
                    nome: nomeController.text,
                    descricao: descricaoController.text,
                    tipo: tipoSelecionado,
                    categoria: categoriaController.text.isNotEmpty ? categoriaController.text : null,
                    icone: iconeController.text.isNotEmpty ? iconeController.text : null,
                    requisitos: requisitosController.text.isNotEmpty ? requisitosController.text : null,
                  );
                  
                  Navigator.of(context).pop();
                  _carregarConquistas();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conquista editada com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao editar conquista: $e'),
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
    );
  }

  Future<void> _deletarConquista(Achievement conquista) async {
    await context.read<AuthProvider>().initialize();
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja deletar a conquista "${conquista.nome}"?'),
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
        await _achievementService.deletarConquista(conquista.id!);
        _carregarConquistas();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conquista deletada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar conquista: $e'),
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
          'Gerenciar Conquistas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _mostrarDialogCriarConquista,
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
                        'Erro ao carregar conquistas',
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: _carregarConquistas,
                        child: Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _conquistas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma conquista encontrada',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _conquistas.length,
                      itemBuilder: (context, index) {
                        final conquista = _conquistas[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (conquista.icone != null)
                                      Text(
                                        conquista.icone!,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            conquista.nome,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (conquista.categoria != null)
                                            Text(
                                              conquista.categoria!,
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
                                        color: _getTipoColor(conquista.tipo),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        conquista.tipo.toUpperCase(),
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
                                  conquista.descricao,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (conquista.requisitos != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            conquista.requisitos!,
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _mostrarDialogEditarConquista(conquista),
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
                                        onPressed: () => _deletarConquista(conquista),
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
      case 'medalha':
        return Colors.amber;
      case 'conquista':
        return Colors.blue;
      case 'titulo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 