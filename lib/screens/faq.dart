import 'package:flutter/material.dart';
import '../widgets/user_avatar.dart';
import 'perfil_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<_FAQItem> _faqItems = [
    _FAQItem(
      question: 'O que é IFC Coin?',
      answer: 'IFC Coin é uma moeda digital utilizada dentro da instituição para recompensar alunos e professores por participação em atividades e projetos.',
    ),
    _FAQItem(
      question: 'Como vejo meu histórico de transações?',
      answer: 'Na tela inicial do aplicativo, clique no botão "Histórico de Transações" para ver um registro detalhado de todas as suas moedas recebidas e enviadas, incluindo datas e remetentes/destinatários.',
    ),
    _FAQItem(
      question: 'Onde posso usar IFC Coin?',
      answer: 'Você pode usar suas IFC Coins em eventos, projetos e atividades promovidas pela instituição, conforme regras estabelecidas.',
    ),
    _FAQItem(
      question: 'Posso trocar IFC Coin por dinheiro real?',
      answer: 'Não. As IFC Coins são exclusivas para uso dentro da instituição e não possuem valor monetário real.',
    ),
    _FAQItem(
      question: 'Como faço uma transferência de IFC Coin para outra pessoa?',
      answer: 'Clique em no ícone de QR Code no canto superior direito e escaneie o código do destinatário para transferir a quantidade desejada. Confirme a operação para concluir a transferência.',
    ),
    _FAQItem(
      question: 'Como posso receber IFC Coin de outra pessoa?',
      answer: 'Você pode gerar um QR Code na opção "Gerar QR Code" e pedir para a pessoa que vai transferir escanear esse código pelo aplicativo.',
    ),
    _FAQItem(
      question: 'Quem pode participar do sistema IFC Coin?',
      answer: 'Alunos e professores da instituição podem participar, conforme as regras e permissões definidas pela administração.',
    ),
    _FAQItem(
      question: 'O que devo fazer se encontrar um problema ou erro no aplicativo?',
      answer: 'Entre em contato com o suporte da instituição ou procure um responsável para relatar o problema. Sua colaboração é importante para melhorarmos o sistema.',
    ),
  ];

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
        title: Text(
              'FAQ',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Perguntas Frequentes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ..._faqItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isOpen = item.isOpen;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFFE6FAFF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        _faqItems[idx].isOpen = !isOpen;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.question,
                                  style: TextStyle(
                                    color: isOpen ? const Color(0xFF2196F3) : const Color(0xFF2196F3),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Icon(
                                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: isOpen ? const Color(0xFF2196F3) : Colors.black45,
                              ),
                            ],
                          ),
                          if (isOpen) ...[
                            const SizedBox(height: 10),
                            Text(
                              item.answer,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  bool isOpen;
  _FAQItem({required this.question, required this.answer}) : isOpen = false;
}
