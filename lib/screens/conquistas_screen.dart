import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({Key? key}) : super(key: key);

  @override
  State<ConquistasScreen> createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _conquistas = [];
  List<String> _categorias = [];
  bool _isLoading = true;
  String? _error;
  String _selectedTipo = 'todos';
  String _selectedCategoria = 'todas';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Carregar categorias
      final categorias = await _achievementService.listarCategorias();
      
      // Carregar conquistas
      final conquistas = await _achievementService.listarConquistas(
        tipo: _selectedTipo == 'todos' ? null : _selectedTipo,
        categoria: _selectedCategoria == 'todas' ? null : _selectedCategoria,
      );

      setState(() {
        _categorias = categorias;
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

  Future<void> _filtrarConquistas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final conquistas = await _achievementService.listarConquistas(
        tipo: _selectedTipo == 'todos' ? null : _selectedTipo,
        categoria: _selectedCategoria == 'todas' ? null : _selectedCategoria,
      );

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
          'Conquistas',
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
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Filtro por tipo
                DropdownButtonFormField<String>(
                  value: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'medalha', child: Text('Medalha')),
                    DropdownMenuItem(value: 'conquista', child: Text('Conquista')),
                    DropdownMenuItem(value: 'titulo', child: Text('Título')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTipo = value!;
                    });
                    _filtrarConquistas();
                  },
                ),
                const SizedBox(height: 12),
                // Filtro por categoria
                DropdownButtonFormField<String>(
                  value: _selectedCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'todas', child: Text('Todas')),
                    ..._categorias.map((categoria) => DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoria = value!;
                    });
                    _filtrarConquistas();
                  },
                ),
              ],
            ),
          ),
          
          // Lista de conquistas
          Expanded(
            child: _isLoading
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
                              onPressed: _carregarDados,
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
                                          // Ícone da conquista
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