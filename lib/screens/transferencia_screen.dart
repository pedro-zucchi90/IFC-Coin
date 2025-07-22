import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import 'package:uuid/uuid.dart';
import 'home.dart';

class TransferenciaScreen extends StatefulWidget {
  final String? matriculaInicial;
  final int? valorInicial;
  final String? descricaoInicial;
  final String? hashInicial;
  const TransferenciaScreen({super.key, this.matriculaInicial, this.valorInicial, this.descricaoInicial, this.hashInicial});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculaController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  Transaction? _transacaoRealizada;
  String? _qrData;
  String? _hash;

  @override
  void initState() {
    super.initState();
    if (widget.matriculaInicial != null) {
      _matriculaController.text = widget.matriculaInicial!;
    }
    if (widget.valorInicial != null) {
      _valorController.text = widget.valorInicial.toString();
    }
    if (widget.descricaoInicial != null) {
      _descricaoController.text = widget.descricaoInicial!;
    }
    _hash = widget.hashInicial ?? const Uuid().v4();
  }

  void _gerarQrCode() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'matricula': _matriculaController.text.trim(),
      'valor': int.parse(_valorController.text.trim()),
      'descricao': _descricaoController.text.trim(),
      'hash': _hash ?? const Uuid().v4(),
    };
    setState(() {
      _qrData = _toJsonString(data);
    });
  }

  String _toJsonString(Map<String, dynamic> data) {
    return '{${data.entries.map((e) => '"${e.key}":"${e.value}"').join(',')}}';
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_senhaController.text.isEmpty) {
      setState(() { _error = 'Digite sua senha para confirmar.'; });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _transacaoRealizada = null;
    });
    try {
      // Aqui você pode autenticar a senha se desejar (ex: AuthService().login...)
      final transacao = await TransactionService().transferir(
        destinoMatricula: _matriculaController.text.trim(),
        quantidade: int.parse(_valorController.text.trim()),
        descricao: _descricaoController.text.trim(),
      );
      setState(() {
        _transacaoRealizada = transacao;
        _isLoading = false;
      });
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.blue, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Transferência Realizada!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A transferência foi realizada com sucesso!', style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                Text('Hash: ${transacao.hash}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 8),
                Text('Status: ${transacao.status ?? 'aprovada'}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }
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
      appBar: AppBar(
        title: const Text('Transferir IFC Coin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _transacaoRealizada == null
            ? Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _matriculaController,
                        decoration: const InputDecoration(
                          labelText: 'Matrícula do destinatário',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Informe a matrícula' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor (IFC Coin)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o valor';
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) return 'Valor inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha da sua conta',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Digite sua senha' : null,
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_error!, style: TextStyle(color: Colors.red)),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox.shrink(), // Removido botão de QR Code
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
                              label: const Text('Enviar'),
                              onPressed: _isLoading ? null : _enviar,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.blue, size: 64),
                  const SizedBox(height: 16),
                  const Text('Transação Realizada!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Text('Hash: ${_transacaoRealizada!.hash}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Status: ${_transacaoRealizada!.status ?? 'aprovada'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar ao início'),
                  ),
                ],
              ),
      ),
    );
  }
} 