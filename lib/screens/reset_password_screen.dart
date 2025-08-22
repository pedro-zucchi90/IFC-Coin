import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // Importa o baseUrl correto

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController senhaController = TextEditingController();
  String mensagem = '';
  bool sucesso = false;
  bool carregando = false;

  Future<void> redefinirSenha() async {
    setState(() {
      carregando = true;
      mensagem = '';
      sucesso = false;
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        body: jsonEncode({'token': widget.token, 'novaSenha': senhaController.text}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          mensagem = 'Senha alterada com sucesso!';
          sucesso = true;
        });
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          mensagem = body['message'] ?? 'Erro ao redefinir senha.';
          sucesso = false;
        });
      }
    } catch (e) {
      setState(() {
        mensagem = 'Erro de conexão. Tente novamente.';
        sucesso = false;
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova senha'),
            ),
            const SizedBox(height: 16),
            carregando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: redefinirSenha,
                    child: const Text('Redefinir senha'),
                  ),
            const SizedBox(height: 16),
            if (mensagem.isNotEmpty)
              Text(
                mensagem,
                style: TextStyle(
                  color: sucesso ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}