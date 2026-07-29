
import 'package:flutter/material.dart';
import 'package:unidos/entity/centro_custo.dart';
import 'package:unidos/service/centro_custo_service.dart';
import 'package:unidos/service/movimentacoes_service.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() =>
      _RelatoriosPageState();
}

class _RelatoriosPageState
    extends State<RelatoriosPage> {

  final movimentacaoService =
      MovimentacaoService();

  final centroCustoService =
      CentroCustoService();

  double totalEntradas = 0;
  double totalSaidas = 0;
  double saldoTotal = 0;

  List<CentroCusto> centros = [];

  @override
  void initState() {
    super.initState();
    carregarRelatorio();
  }

  Future<void> carregarRelatorio() async {
    final movimentacoes =
        await movimentacaoService.listAll();

    final centrosCusto =
        await centroCustoService.listAll();

    double entradas = 0;
    double saidas = 0;

    for (final movimentacao in movimentacoes) {
      if (movimentacao.tipo == 'ENTRADA') {
        entradas += movimentacao.valor;
      } else if (movimentacao.tipo == 'SAIDA') {
        saidas += movimentacao.valor;
      }
    }

    if (!mounted) return;

    setState(() {
      totalEntradas = entradas;
      totalSaidas = saidas;
      saldoTotal = entradas - saidas;
      centros = centrosCusto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF101827),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF101827),

        elevation: 0,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Relatórios',

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Visão geral das finanças',

              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed:
                carregarRelatorio,

            icon:
                const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh:
            carregarRelatorio,

        child: ListView(
          padding:
              const EdgeInsets.all(16),

          children: [
            const SizedBox(height: 10),

            const Text(
              'Resumo financeiro',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child:
                      _CardRelatorio(
                    titulo:
                        'Entradas',

                    valor:
                        totalEntradas,

                    icon:
                        Icons.arrow_downward,

                    cor:
                        Colors.greenAccent,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      _CardRelatorio(
                    titulo:
                        'Saídas',

                    valor:
                        totalSaidas,

                    icon:
                        Icons.arrow_upward,

                    cor:
                        Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Card(
              color:
                  const Color(0xFF293344),

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Colors.blueAccent,

                      child:
                          const Icon(
                        Icons.account_balance,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Saldo Geral',

                            style:
                                TextStyle(
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            'R\$ ${saldoTotal.toStringAsFixed(2)}',

                            style:
                                TextStyle(
                              fontSize: 24,

                              fontWeight:
                                  FontWeight.bold,

                              color:
                                  saldoTotal >= 0
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            const Text(
              'Resumo por centro de custo',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ...centros.map(
              (centro) =>
                  _CardCentroCusto(
                centro: centro,

                movimentacaoService:
                    movimentacaoService,
              ),
            ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardRelatorio
    extends StatelessWidget {

  final String titulo;
  final double valor;
  final IconData icon;
  final Color cor;

  const _CardRelatorio({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.cor,
  });

  @override
  Widget build(
      BuildContext context) {

    return Card(
      color:
          const Color(0xFF293344),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,

              color: cor,

              size: 30,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              titulo,

              style:
                  const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'R\$ ${valor.toStringAsFixed(2)}',

              style:
                  TextStyle(
                fontSize: 20,

                fontWeight:
                    FontWeight.bold,

                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCentroCusto
    extends StatelessWidget {

  final CentroCusto centro;

  final MovimentacaoService
      movimentacaoService;

  const _CardCentroCusto({
    required this.centro,
    required this.movimentacaoService,
  });

  @override
  Widget build(
      BuildContext context) {

    return FutureBuilder<
        Map<String, double>>(
      future:
          movimentacaoService
              .getResumoCentroCusto(
                  centro.id!),

      builder:
          (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return Card(
            color:
                const Color(0xFF293344),

            child:
                const Padding(
              padding:
                  EdgeInsets.all(20),

              child:
                  Center(
                child:
                    CircularProgressIndicator(),
              ),
            ),
          );
        }

        final resumo =
            snapshot.data ??
                {
                  'entradas': 0,
                  'saidas': 0,
                  'saldo': 0,
                };

        final entradas =
            resumo['entradas'] ?? 0;

        final saidas =
            resumo['saidas'] ?? 0;

        final saldo =
            resumo['saldo'] ?? 0;

        return Card(
          color:
              const Color(0xFF293344),

          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Colors.greenAccent,

                      foregroundColor:
                          const Color(
                              0xFF101827),

                      child: Icon(
                        centro.id == 1
                            ? Icons
                                .account_balance_wallet
                            : Icons.church,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        centro.nome,

                        style:
                            const TextStyle(
                          fontSize: 17,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _ItemResumo(
                        titulo:
                            'Entradas',

                        valor:
                            entradas,

                        cor:
                            Colors.greenAccent,
                      ),
                    ),

                    Expanded(
                      child:
                          _ItemResumo(
                        titulo:
                            'Saídas',

                        valor:
                            saidas,

                        cor:
                            Colors.redAccent,
                      ),
                    ),

                    Expanded(
                      child:
                          _ItemResumo(
                        titulo:
                            'Saldo',

                        valor:
                            saldo,

                        cor:
                            saldo >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ItemResumo
    extends StatelessWidget {

  final String titulo;
  final double valor;
  final Color cor;

  const _ItemResumo({
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(
      BuildContext context) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          titulo,

          style:
              const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          'R\$ ${valor.toStringAsFixed(2)}',

          style:
              TextStyle(
            color: cor,

            fontWeight:
                FontWeight.bold,

            fontSize: 14,
          ),
        ),
      ],
    );
  }
}