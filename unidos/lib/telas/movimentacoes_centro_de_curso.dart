import 'package:flutter/material.dart';
import 'package:unidos/entity/centro_custo.dart';
import 'package:unidos/entity/movimentacao.dart';
import 'package:unidos/service/movimentacoes_service.dart';

class MovimentacoesCentroCustoPage extends StatefulWidget {
  final CentroCusto centro;

  const MovimentacoesCentroCustoPage({super.key, required this.centro});

  @override
  State<MovimentacoesCentroCustoPage> createState() =>
      _MovimentacoesCentroCustoPageState();
}

class _MovimentacoesCentroCustoPageState
    extends State<MovimentacoesCentroCustoPage> {
  final movimentacaoService = MovimentacaoService();

  List<Movimentacao> movimentacoes = [];

  @override
  void initState() {
    super.initState();
    carregarMovimentacoes();
  }

  Future<void> carregarMovimentacoes() async {
    final resultado = await movimentacaoService.listByCentroCusto(
      widget.centro.id!,
    );

    if (!mounted) return;

    setState(() {
      movimentacoes = resultado.reversed.toList();
    });
  }

  Future<void> excluirMovimentacao(Movimentacao movimentacao) async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir movimentação?'),

          content: Text('Deseja excluir "${movimentacao.descricao}"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true && movimentacao.id != null) {
      await movimentacaoService.delete(movimentacao.id!);

      await carregarMovimentacoes();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Movimentação excluída.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),

        elevation: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              widget.centro.nome,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Text('Movimentações', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: carregarMovimentacoes,

        child: movimentacoes.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),

                  Center(
                    child: Text(
                      'Nenhuma movimentação encontrada.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: movimentacoes.length,

                itemBuilder: (context, index) {
                  final movimentacao = movimentacoes[index];

                  final entrada = movimentacao.tipo == 'ENTRADA';

                  return GestureDetector(
                    // Segurar a movimentação
                    // para excluir
                    onLongPress: () {
                      excluirMovimentacao(movimentacao);
                    },

                    child: Card(
                      color: const Color(0xFF293344),

                      margin: const EdgeInsets.only(bottom: 10),

                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        leading: CircleAvatar(
                          backgroundColor: entrada ? Colors.green : Colors.red,

                          child: Icon(
                            entrada ? Icons.arrow_downward : Icons.arrow_upward,
                          ),
                        ),

                        title: Text(
                          movimentacao.descricao,

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // Mostra o tipo
                        // e a data
                        subtitle: Text(
                          formatarData(movimentacao.data),
                        ),

                        trailing: Text(
                          '${entrada ? '+' : '-'} '
                          'R\$ ${movimentacao.valor.toStringAsFixed(2)}',

                          style: TextStyle(
                            color: entrada
                                ? Colors.greenAccent
                                : Colors.redAccent,

                            fontWeight: FontWeight.bold,

                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String formatarData(String data) {
    final dateTime = DateTime.parse(data);

    final dia = dateTime.day.toString().padLeft(2, '0');
    final mes = dateTime.month.toString().padLeft(2, '0');
    final ano = dateTime.year;


    return '$dia/$mes/$ano';
  }
}
