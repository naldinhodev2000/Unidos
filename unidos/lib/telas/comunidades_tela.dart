
import 'package:flutter/material.dart';
import 'package:unidos/entity/centro_custo.dart';
import 'package:unidos/service/centro_custo_service.dart';
import 'package:unidos/service/movimentacoes_service.dart';
import 'package:unidos/telas/cadastro_centro_tela.dart';
import 'package:unidos/telas/movimentacoes_centro_de_curso.dart';

class ComunidadesPage extends StatefulWidget {
  const ComunidadesPage({super.key});

  @override
  State<ComunidadesPage> createState() =>
      _ComunidadesPageState();
}

class _ComunidadesPageState
    extends State<ComunidadesPage> {

  final centroCustoService =
      CentroCustoService();

  final movimentacaoService =
      MovimentacaoService();

  List<CentroCusto> centros = [];

  @override
  void initState() {
    super.initState();
    carregarCentros();
  }

  // Carrega todos os centros de custo
  Future<void> carregarCentros() async {

    final resultado =
        await centroCustoService.listAll();

    if (!mounted) return;

    setState(() {
      centros = resultado;
    });
  }

  // Abre a tela de cadastro
  Future<void> abrirCadastro() async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CadastroCentroCustoPage(),
      ),
    );

    await carregarCentros();
  }

  // Abre as movimentações do centro de custo
  Future<void> abrirMovimentacoes(
    CentroCusto centro,
  ) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MovimentacoesCentroCustoPage(
          centro: centro,
        ),
      ),
    );

    // Atualiza os saldos ao voltar
    await carregarCentros();
  }

  // Exclui um centro de custo
  Future<void> excluirCentroCusto(
    CentroCusto centro,
  ) async {

    // Não permite excluir o Meu Caixa
    if (centro.id == 1) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'O Meu Caixa não pode ser excluído.',
          ),
        ),
      );

      return;
    }

    final confirmar =
        await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Excluir centro de custo?',
          ),

          content: Text(
            'Deseja excluir "${centro.nome}"?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Excluir',
                style: TextStyle(
                  color:
                      Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true &&
        centro.id != null) {

      try {

        await centroCustoService.delete(
          centro.id!,
        );

        await carregarCentros();

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Centro de custo excluído.',
            ),
          ),
        );

      } catch (e) {

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível excluir este centro.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

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
              'Comunidades',

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              'Gerencie seus caixas',

              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(

        onRefresh:
            carregarCentros,

        child: ListView(

          padding:
              const EdgeInsets.all(16),

          children: [

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Meus centros de custo',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            ...centros.map(
              (centro) =>
                  FutureBuilder<double>(

                future:
                    movimentacaoService
                        .getSaldoCentroCusto(
                  centro.id!,
                ),

                builder:
                    (context, snapshot) {

                  final saldo =
                      snapshot.data ??
                          0;

                  final meuCaixa =
                      centro.id == 1;

                  return GestureDetector(

                    // Clique normal
                    // Abre as movimentações
                    onTap: () {
                      abrirMovimentacoes(
                        centro,
                      );
                    },

                    // Segurar
                    // Exclui o centro
                    onLongPress: () {
                      excluirCentroCusto(
                        centro,
                      );
                    },

                    child: Card(

                      color:
                          const Color(
                              0xFF293344),

                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),

                      child: ListTile(

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        leading:
                            CircleAvatar(

                          backgroundColor:
                              meuCaixa
                                  ? Colors
                                      .greenAccent
                                  : Colors
                                      .blueAccent,

                          foregroundColor:
                              const Color(
                                  0xFF101827),

                          child: Icon(

                            meuCaixa
                                ? Icons
                                    .account_balance_wallet
                                : Icons
                                    .church,
                          ),
                        ),

                        title: Text(

                          centro.nome,

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        subtitle: Text(

                          meuCaixa
                              ? 'Caixa pessoal'
                              : 'Centro de custo',
                        ),

                        trailing: Text(

                          'R\$ ${saldo.toStringAsFixed(2)}',

                          style:
                              TextStyle(

                            color:
                                saldo >= 0
                                    ? Colors
                                        .greenAccent
                                    : Colors
                                        .redAccent,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize:
                                16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            Colors.greenAccent,

        foregroundColor:
            const Color(
                0xFF101827),

        onPressed:
            abrirCadastro,

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}