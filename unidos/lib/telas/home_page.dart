import 'package:flutter/material.dart';
import 'package:unidos/entity/movimentacao.dart';
import 'package:unidos/entity/centro_custo.dart';
import 'package:unidos/service/centro_custo_service.dart';
import 'package:unidos/service/movimentacoes_service.dart';
import 'package:unidos/telas/cadastro_movimentacao_tela.dart';
import 'package:unidos/telas/movimentacoes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final centroCustoService = CentroCustoService();
  final movimentacaoService = MovimentacaoService();

  double meuCaixa = 0;
  double totalGeral = 0;

  List<CentroCusto> centros = [];
  List<Movimentacao> movimentacoes = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final centrosCusto = await centroCustoService.listAll();

    final todasMovimentacoes = await movimentacaoService.listAll();

    final saldoMeuCaixa = await movimentacaoService.getSaldoCentroCusto(1);

    final saldoTotal = await movimentacaoService.getSaldoTotal();

    if (!mounted) return;

    setState(() {
      centros = centrosCusto;

      movimentacoes = todasMovimentacoes.reversed.take(3).toList();

      meuCaixa = saldoMeuCaixa;
      totalGeral = saldoTotal;
    });
  }

  Future<void> abrirCadastroMovimentacao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroMovimentacaoPage()),
    );

    await carregarDados();
  }

  Future<void> mostrarOpcoesMovimentacao(Movimentacao movimentacao) async {
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

      await carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalComunidades = totalGeral - meuCaixa;

    return Scaffold(
      backgroundColor: const Color(0xFF101827),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101827),

        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, Secretário!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Gerencie os caixas', style: TextStyle(fontSize: 16)),
          ],
        ),

        actions: [
          IconButton(onPressed: carregarDados, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: carregarDados,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            const SizedBox(height: 10),

            const Text(
              'Resumo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _CardResumo(
                    titulo: 'Meu Caixa',
                    valor: meuCaixa,
                    subtitulo: 'Saldo atual',
                    icon: Icons.account_balance_wallet,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _CardResumo(
                    titulo: 'Total Comunidades',
                    valor: totalComunidades,
                    subtitulo: 'Saldo combinado',
                    icon: Icons.groups,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _CardResumo(
              titulo: 'Total Geral',
              valor: totalGeral,
              subtitulo: 'Todos os caixas',
              icon: Icons.account_balance,
            ),

            const SizedBox(height: 28),

            const Text(
              'Comunidades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...centros
                .where((centro) => centro.id != 1)
                .map(
                  (centro) => FutureBuilder<double>(
                    future: movimentacaoService.getSaldoCentroCusto(centro.id!),

                    builder: (context, snapshot) {
                      final saldo = snapshot.data ?? 0;

                      return Card(
                        color: const Color(0xFF293344),

                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.church),
                          ),

                          title: Text(centro.nome),

                          trailing: Text(
                            'R\$ ${saldo.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Últimas movimentações',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MovimentacoesPage(),
                      ),
                    );

                    carregarDados();
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...movimentacoes.map(
              (movimentacao) => GestureDetector(
                onLongPress: () {
                  mostrarOpcoesMovimentacao(movimentacao);
                },

                child: Card(
                  color: const Color(0xFF293344),

                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: movimentacao.tipo == 'ENTRADA'
                          ? Colors.green
                          : Colors.red,

                      child: Icon(
                        movimentacao.tipo == 'ENTRADA'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                    ),

                    title: Text(movimentacao.descricao),

                    subtitle: Text(movimentacao.tipo),

                    trailing: Text(
                      '${movimentacao.tipo == 'ENTRADA' ? '+' : '-'} '
                      'R\$ ${movimentacao.valor.toStringAsFixed(2)}',

                      style: TextStyle(
                        color: movimentacao.tipo == 'ENTRADA'
                            ? Colors.greenAccent
                            : Colors.redAccent,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,

        foregroundColor: const Color(0xFF101827),

        onPressed: abrirCadastroMovimentacao,

        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardResumo extends StatelessWidget {
  final String titulo;
  final double valor;
  final String subtitulo;
  final IconData icon;

  const _CardResumo({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF293344),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Icon(icon, color: Colors.greenAccent, size: 32),

            const SizedBox(height: 8),

            Text(titulo, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 4),

            Text(
              'R\$ ${valor.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(subtitulo, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
