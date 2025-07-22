import 'package:flutter/material.dart';
import 'transferencia_screen.dart';

class QrCodeLerScreen extends StatefulWidget {
  const QrCodeLerScreen({super.key});

  @override
  State<QrCodeLerScreen> createState() => _QrCodeLerScreenState();
}

class _QrCodeLerScreenState extends State<QrCodeLerScreen> {
  final _matriculaController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  // Removido o campo de hash

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados do Destinatário')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _matriculaController,
              decoration: const InputDecoration(
                labelText: 'Matrícula do destinatário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor (IFC Coin)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferenciaScreen(
                      matriculaInicial: _matriculaController.text.isNotEmpty ? _matriculaController.text : '',
                      valorInicial: int.tryParse(_valorController.text) ?? 0,
                      descricaoInicial: _descricaoController.text.isNotEmpty ? _descricaoController.text : '',
                    ),
                  ),
                );
              },
              child: const Text('Avançar para Transferência'),
            ),
          ],
        ),
      ),
    );
  }
} 