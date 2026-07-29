
import 'package:flutter/material.dart';
import 'package:unidos/entity/centro_custo.dart';
import 'package:unidos/service/centro_custo_service.dart';

class CadastroCentroCustoPage extends StatefulWidget {
  const CadastroCentroCustoPage({super.key});

  @override
  State<CadastroCentroCustoPage> createState() =>
      _CadastroCentroCustoPageState();
}

class _CadastroCentroCustoPageState
    extends State<CadastroCentroCustoPage> {
  final CentroCustoService centroCustoService =
      CentroCustoService();

  final TextEditingController nomeController =
      TextEditingController();

  bool salvando = false;

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do centro de custo'),
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final centroCusto = CentroCusto(
        nome: nome,
      );

      await centroCustoService.add(centroCusto);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centro de custo cadastrado!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),
        elevation: 0,
        title: const Text(
          'Novo Centro de Custo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),

          const Icon(
            Icons.account_balance,
            color: Colors.greenAccent,
            size: 64,
          ),

          const SizedBox(height: 20),

          const Text(
            'Cadastrar Centro de Custo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Adicione uma nova comunidade ou caixa '
            'para controlar suas movimentações.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 32),

          Card(
            color: const Color(0xFF293344),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nome',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nomeController,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ex: Comunidade São José',
                      prefixIcon: const Icon(
                        Icons.groups,
                        color: Colors.greenAccent,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF101827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: salvando ? null : salvar,
                      icon: salvando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        salvando
                            ? 'Salvando...'
                            : 'Cadastrar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.greenAccent,
                        foregroundColor:
                            const Color(0xFF101827),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
