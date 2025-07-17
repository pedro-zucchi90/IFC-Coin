import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../providers/auth_provider.dart';
import 'como_ganhar.dart';
import 'faq.dart';
import 'tela_login.dart';
import 'metas_screen.dart';
import 'admin_metas_screen.dart';
import 'admin_conquistas_screen.dart';
import 'admin_solicitacoes_professores_screen.dart';
import 'perfil_screen.dart';
import '../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text(
          'Início',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.black, size: 40),
            onPressed: () {},
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return UserAvatar(
                radius: 20,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PerfilScreen(),
                    ),
                  );
                },
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 30),
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaLogin()),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF42A5DA),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Seu saldo atual:',
                    style: TextStyle(fontSize: 20, color: Color.fromARGB(221, 243, 243, 243)),
                  ),
                  const SizedBox(height: 6),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        '${authProvider.user?.saldo ?? 0} IFC Coin',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Color.fromARGB(255, 253, 254, 255),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            
            Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 40),
              child: Image.asset(
                'assets/ifc_coin_logo.png',
                fit: BoxFit.fill,
              ),
            ),

            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isAdmin = authProvider.isAdmin;
                final isProfessor = authProvider.isProfessor;
                
                List<Widget> cards = [
                  _HomeCard(
                    icon: Icons.receipt_long,
                    iconColor: Color(0xFFE53935),
                    title: 'Histórico de Transações',
                    textColor: Color(0xFFE53935),
                    onTap: () {},
                  ),
                  _HomeCard(
                    icon: Icons.attach_money,
                    iconColor: Color(0xFF388E3C),
                    title: 'Como Ganhar Coins',
                    textColor: Color(0xFF388E3C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ComoGanharScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeCard(
                    icon: Icons.check_circle_outline,
                    iconColor: Color(0xFF1976D2),
                    title: isAdmin ? 'Gerenciar Metas' : 'Metas',
                    textColor: Color(0xFF1976D2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => isAdmin 
                              ? const AdminMetasScreen()
                              : const MetasScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeCard(
                    icon: Icons.help_outline,
                    iconColor: Color(0xFF9C27B0),
                    title: 'FAQ',
                    textColor: Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                  ),
                ];

                // Adicionar botões específicos para admin
                if (isAdmin) {
                  cards.addAll([
                    _HomeCard(
                      icon: Icons.person_add,
                      iconColor: Color(0xFFFF9800),
                      title: 'Solicitações de\nProfessores',
                      textColor: Color(0xFFFF9800),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminSolicitacoesProfessoresScreen(),
                          ),
                        );
                      },
                    ),
                    _HomeCard(
                      icon: Icons.emoji_events,
                      iconColor: Color(0xFF9C27B0),
                      title: 'Gerenciar\nConquistas',
                      textColor: Color(0xFF9C27B0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminConquistasScreen(),
                          ),
                        );
                      },
                    ),
                  ]);
                }
                
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.2,
                  children: cards,
                );
              },
            ),
            const SizedBox(height: 55),
            const Text(
              'IFC Coin: Sua moeda digital\npor horas de dedicação na instituição.',
              style: TextStyle(fontSize: 20, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color textColor;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.textColor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
