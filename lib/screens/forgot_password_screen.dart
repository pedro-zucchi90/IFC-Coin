import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // Importa o baseUrl correto

// Tela de recuperação de senha
class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool enviado = false;
  String mensagem = '';
  bool carregando = false;

  Future<void> solicitarRecuperacao() async {
    setState(() {
      carregando = true;
      mensagem = '';
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        body: jsonEncode({'email': emailController.text.trim()}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          enviado = true;
          mensagem = 'E-mail enviado! Verifique sua caixa de entrada (inclusive o spam).';
        });
      } else {
        String msg = 'Erro ao enviar e-mail.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            msg = body['message'];
          }
        } catch (_) {}
        setState(() {
          mensagem = msg;
        });
      }
    } catch (e) {
      setState(() {
        mensagem = 'Erro de conexão. Tente novamente.';
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
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Informe o e-mail cadastrado para receber o link de redefinição de senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Seu e-mail cadastrado',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !enviado && !carregando,
                ),
                const SizedBox(height: 16),
                carregando
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: (enviado || carregando)
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                solicitarRecuperacao();
                              },
                        child: const Text('Enviar recuperação'),
                      ),
                const SizedBox(height: 16),
                if (mensagem.isNotEmpty)
                  Text(
                    mensagem,
                    style: TextStyle(
                      color: enviado ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}