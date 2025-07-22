import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class QrCodeReceberScreen extends StatelessWidget {
  const QrCodeReceberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final qrData = user == null
        ? ''
        : '{"matricula":"${user.matricula}","nome":"${user.nome}","id":"${user.id}"}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code para Receber'),
      ),
      body: Center(
        child: user == null
            ? const Text('Usuário não encontrado')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Mostre seus dados para receber IFC Coin', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  // Removido QrImage
                  const SizedBox(height: 24),
                  Text('Matrícula:  ${user.matricula}', style: TextStyle(fontSize: 16)),
                  Text('Nome: ${user.nome}', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }
} 