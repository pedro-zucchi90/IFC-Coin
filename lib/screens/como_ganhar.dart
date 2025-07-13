import 'package:flutter/material.dart';
import '../widgets/user_avatar.dart';
import 'perfil_screen.dart';

class ComoGanharScreen extends StatelessWidget {
  const ComoGanharScreen({Key? key}) : super(key: key);

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
          'Coins',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24, // Aumento do tamanho da fonte
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.black, size: 40),
            onPressed: () {},
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Aumento do padding horizontal
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6FAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20), // Aumento do padding
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Alterado para centralizar o texto
                children: const [
                  Text(
                    'Como Ganhar Coins?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // Aumento do tamanho da fonte
                    ),
                  ),
                  SizedBox(height: 10), // Aumento do tamanho do SizedBox
                  Text(
                    'Descubra diversas formas de acumular IFC Coins e valorizar sua participação na comunidade IFC!',
                    style: TextStyle(fontSize: 17, color: Colors.black87), // Aumento do tamanho da fonte
                    textAlign: TextAlign.center, // Alterado para centralizar o texto
                  ),
                ],
              ),
            ),
            _InfoCard(
              icon: Icons.science,
              iconColor: Color(0xFF2979FF),
              title: 'Participação em Projetos',
              description:
                  'Contribua com projetos de pesquisa e desenvolvimento do IFC. Suas horas dedicadas são convertidas em IFC Coins.',
              // Aumento do tamanho do card
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20), // Aumento do padding
              margin: const EdgeInsets.only(bottom: 28), // Aumento do margin
            ),
            _InfoCard(
              icon: Icons.event_available,
              iconColor: Color(0xFF43A047),
              title: 'Atividade de Extensão',
              description:
                  'Participe ativamente de eventos, palestras e atividades de extensão promovidas pelo IFC. Cada participação gera coins!',
              // Aumento do tamanho do card
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20), // Aumento do padding
              margin: const EdgeInsets.only(bottom: 28), // Aumento do margin
            ),
            _InfoCard(
              icon: Icons.emoji_events,
              iconColor: Color(0xFFFFB300),
              title: 'Desempenho Acadêmico',
              description:
                  'Alcance metas de desempenho acadêmico ou participe de desafios específicos lançados pela instituição para ganhar bônus em IFC Coins.',
              // Aumento do tamanho do card
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20), // Aumento do padding
              margin: const EdgeInsets.only(bottom: 28), // Aumento do margin
            ),
            _InfoCard(
              icon: Icons.person_add_alt_1,
              iconColor: Color(0xFFD32F2F),
              title: 'Atividade de Extensão',
              description:
                  'Convide novos alunos ou professores para o aplicativo IFC Coin e ganhe uma bonificação quando eles se cadastrarem e começarem a usar.',
              // Aumento do tamanho do card
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20), // Aumento do padding
              margin: const EdgeInsets.only(bottom: 28), // Aumento do margin
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.padding,
    required this.margin,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(icon, color: iconColor, size: 32), // Aumento do tamanho do Icon
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Aumento do tamanho da fonte
                  ),
                ),
                const SizedBox(height: 6), // Aumento do tamanho do SizedBox
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87), // Aumento do tamanho da fonte
                  textAlign: TextAlign.center, // Alterado para centralizar o texto
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

