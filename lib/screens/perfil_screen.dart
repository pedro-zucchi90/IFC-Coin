import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../providers/auth_provider.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import '../services/user_service.dart';
import '../config.dart';
import 'conquistas_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AchievementService _achievementService = AchievementService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  final List<Achievement> _conquistas = [];
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;
  bool _isUploadingPhoto = false;
  Map<String, dynamic>? _estatisticas;

  // Controllers para edição
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _inicializarControllers();
  }

  void _inicializarControllers() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nomeController.text = user.nome;
      _emailController.text = user.email;
      _cursoController.text = user.curso ?? '';
    }
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Carregar conquistas do usuário
      final response = await _achievementService.getConquistasUsuario();
      
      if (response['success']) {
        setState(() {
          _conquistas.clear();
          for (var conquista in response['conquistas']) {
            if (conquista['achievement'] != null) {
              try {
                _conquistas.add(Achievement.fromJson(conquista['achievement']));
              } catch (e) {
                // Ignorar conquistas com erro de parsing
              }
            }
          }
          _estatisticas = response['estatisticas'];
        });
      } else {
        setState(() {
          _error = response['error'];
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Widget> _buildConquistasPorCategoria() {
    // Agrupar conquistas por categoria
    Map<String, List<Achievement>> conquistasPorCategoria = {};
    
    for (var conquista in _conquistas) {
      String categoria = conquista.categoria ?? 'Geral';
      if (!conquistasPorCategoria.containsKey(categoria)) {
        conquistasPorCategoria[categoria] = [];
      }
      conquistasPorCategoria[categoria]!.add(conquista);
    }

    List<Widget> widgets = [];
    
    conquistasPorCategoria.forEach((categoria, conquistas) {
      // Título da categoria
      widgets.add(
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
                             Container(
                 width: 4,
                 height: 20,
                 decoration: BoxDecoration(
                   color: _ConquistaCard._getCategoriaColor(categoria),
                   borderRadius: BorderRadius.circular(2),
                 ),
               ),
              const SizedBox(width: 8),
              Text(
                categoria,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
      
      // Conquistas da categoria
      widgets.addAll(
        conquistas.map((conquista) => _ConquistaCard(conquista: conquista))
      );
    });

    return widgets;
  }



  Future<void> _salvarAlteracoes() async {
    try {
      final success = await _userService.atualizarPerfil(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        curso: _cursoController.text.trim(),
      );

      if (success) {
        // Atualizar dados do usuário no provider
        await context.read<AuthProvider>().updateUserData();
        
        setState(() {
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _processarEEnviarFoto(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _tirarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _processarEEnviarFoto(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao tirar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processarEEnviarFoto(File imageFile) async {
    if (_isUploadingPhoto) return;
    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      // Cropar a imagem (opcional)
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cortar Foto',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Cortar Foto',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        // Salvar apenas o path local da foto de perfil
        final success = await _userService.atualizarPerfil(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          curso: _cursoController.text.trim(),
          fotoPerfilFile: File(croppedFile.path),
        );
        if (success) {
          await context.read<AuthProvider>().updateUserData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolher foto de perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _tirarFoto();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
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
          'Meu Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _salvarAlteracoes,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _inicializarControllers(); // Restaurar valores originais
                    setState(() {
                      _isEditing = false;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('Usuário não encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card do perfil
                                 Card(
                   child: Padding(
                     padding: const EdgeInsets.all(16),
                     child: Column(
                      children: [
                        // Foto de perfil
                        Stack(
                          children: [
                            Builder(
                              builder: (context) {
                                String? fotoPerfilUrl = user.fotoPerfil;
                                if (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty) {
                                  String url = fotoPerfilUrl;
                                  if (!url.startsWith('http')) {
                                    String base = baseUrl;
                                    if (base.endsWith('/api')) base = base.substring(0, base.length - 4);
                                    if (!url.startsWith('/')) url = '/$url';
                                    url = '$base$url';
                                  }
                                  // Forçar atualização da imagem (cache bust)
                                  url = '$url?${DateTime.now().millisecondsSinceEpoch}';
                                  return CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: NetworkImage(url),
                                  );
                                }
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                            if (_isUploadingPhoto)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploadingPhoto ? null : _mostrarOpcoesFoto,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Nome
                        if (_isEditing)
                          TextFormField(
                            controller: _nomeController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              border: OutlineInputBorder(),
                            ),
                          )
                        else
                          Text(
                            user.nome,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        
                        const SizedBox(height: 8),
                        
                        // Email
                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          )
                        else
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                                                 // Informações do usuário
                         Wrap(
                           spacing: 16,
                           runSpacing: 8,
                           alignment: WrapAlignment.spaceEvenly,
                           children: [
                             _InfoItem(
                               label: 'Matrícula',
                               value: user.matricula,
                               icon: Icons.badge,
                             ),
                             _InfoItem(
                               label: 'Role',
                               value: user.role.toUpperCase(),
                               icon: Icons.person_outline,
                             ),
                             _InfoItem(
                               label: 'Saldo',
                               value: '${user.saldo} coins',
                               icon: Icons.monetization_on,
                             ),
                           ],
                         ),
                        
                        // Curso (apenas para alunos)
                        if (user.role == 'aluno') ...[
                          const SizedBox(height: 16),
                          if (_isEditing)
                            TextFormField(
                              controller: _cursoController,
                              decoration: const InputDecoration(
                                labelText: 'Curso',
                                border: OutlineInputBorder(),
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  user.curso ?? 'Curso não definido',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                        
                                                 // Estatísticas
                         if (!_isEditing && _estatisticas != null) ...[
                           const SizedBox(height: 32),
                           const Divider(),
                           const SizedBox(height: 16),
                           
                           Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Colors.blue.shade50,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: Colors.blue.shade200),
                             ),
                             child: Column(
                               children: [
                                 const Text(
                                   'Estatísticas',
                                   style: TextStyle(
                                     fontSize: 16,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 const SizedBox(height: 12),
                                 Wrap(
                                   spacing: 16,
                                   runSpacing: 8,
                                   alignment: WrapAlignment.spaceEvenly,
                                   children: [
                                     _StatItem(
                                       label: 'Transferências',
                                       value: '${_estatisticas!['totalTransferencias'] ?? 0}',
                                       icon: Icons.swap_horiz,
                                     ),
                                     _StatItem(
                                       label: 'Metas Concluídas',
                                       value: '${_estatisticas!['totalMetasConcluidas'] ?? 0}',
                                       icon: Icons.check_circle,
                                     ),
                                     _StatItem(
                                       label: 'Dias Consecutivos',
                                       value: '${_estatisticas!['diasConsecutivos'] ?? 0}',
                                       icon: Icons.calendar_today,
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                           
                           const SizedBox(height: 24),
                         ],
                         
                         // Seção de Conquistas
                         if (!_isEditing) ...[
                           // Título da seção
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Row(
                                 children: [
                                   Icon(Icons.emoji_events, color: Colors.amber),
                                   const SizedBox(width: 8),
                                   const Text(
                                     'Conquistas',
                                     style: TextStyle(
                                       fontSize: 20,
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ],
                               ),
                               TextButton.icon(
                                 onPressed: () {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                       builder: (context) => const ConquistasScreen(),
                                     ),
                                   );
                                 },
                                 icon: const Icon(Icons.list, size: 16),
                                 label: const Text('Ver todas'),
                                 style: TextButton.styleFrom(
                                   foregroundColor: Colors.blue,
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 ),
                               ),
                             ],
                           ),
                           
                           const SizedBox(height: 16),
                          
                          // Lista de conquistas organizadas por categoria
                          if (_conquistas.isNotEmpty) ...[
                            const Text(
                              'Conquistas Desbloqueadas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._buildConquistasPorCategoria(),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nenhuma conquista ainda',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Continue usando o app para desbloquear conquistas!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                
                                 const SizedBox(height: 24),
                 
                 // Indicador de carregamento ou erro
                 _isLoading
                     ? const Center(child: CircularProgressIndicator())
                     : _error != null
                         ? Center(
                             child: Column(
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
                         : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

}

// Widget para exibir estatísticas
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget para exibir conquista
class _ConquistaCard extends StatelessWidget {
  final Achievement conquista;

  const _ConquistaCard({required this.conquista});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone da conquista
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: conquista.icone != null
                  ? Text(
                      conquista.icone!,
                      style: const TextStyle(fontSize: 24),
                    )
                  : const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Informações da conquista
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conquista.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conquista.descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (conquista.requisitos != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    conquista.requisitos!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Categoria
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoriaColor(conquista.categoria ?? conquista.tipo),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (conquista.categoria ?? conquista.tipo).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'transferências':
        return Colors.blue;
      case 'recebimentos':
        return Colors.green;
      case 'metas':
        return Colors.orange;
      case 'coins':
        return Colors.amber;
      case 'frequência':
        return Colors.purple;
      case 'perfil':
        return Colors.teal;
      case 'balanço':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}