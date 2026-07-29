
import 'package:flutter/material.dart';
import 'package:unidos/entity/centro_custo.dart';
import 'package:unidos/entity/movimentacao.dart';
import 'package:unidos/service/centro_custo_service.dart';
import 'package:unidos/service/movimentacoes_service.dart';

class CadastroMovimentacaoPage extends StatefulWidget {
  const CadastroMovimentacaoPage({super.key});

  @override
  State<CadastroMovimentacaoPage> createState() =>
      _CadastroMovimentacaoPageState();
}

class _CadastroMovimentacaoPageState
    extends State<CadastroMovimentacaoPage> {
  final CentroCustoService centroCustoService =
      CentroCustoService();

  final MovimentacaoService movimentacaoService =
      MovimentacaoService();

  final TextEditingController descricaoController =
      TextEditingController();

  final TextEditingController valorController =
      TextEditingController();

  List<CentroCusto> centros = [];

  CentroCusto? centroSelecionado;

  String tipoSelecionado = 'ENTRADA';

  DateTime dataSelecionada = DateTime.now();

  bool salvando = false;

  @override
  void initState() {
    super.initState();
    carregarCentros();
  }

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  Future<void> carregarCentros() async {
    final resultado =
        await centroCustoService.listAll();

    if (!mounted) return;

    setState(() {
      centros = resultado;
    });
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        dataSelecionada = data;
      });
    }
  }

  Future<void> salvar() async {
    final descricao =
        descricaoController.text.trim();

    final valorTexto =
        valorController.text
            .trim()
            .replaceAll(',', '.');

    if (descricao.isEmpty) {
      mostrarMensagem(
        'Digite uma descrição',
      );
      return;
    }

    if (valorTexto.isEmpty) {
      mostrarMensagem(
        'Digite um valor',
      );
      return;
    }

    final valor =
        double.tryParse(valorTexto);

    if (valor == null || valor <= 0) {
      mostrarMensagem(
        'Digite um valor válido',
      );
      return;
    }

    if (centroSelecionado == null) {
      mostrarMensagem(
        'Selecione um centro de custo',
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final movimentacao = Movimentacao(
        descricao: descricao,
        valor: valor,
        tipo: tipoSelecionado,
        centroCustoId:
            centroSelecionado!.id!,
        data:
            dataSelecionada.toIso8601String(),
      );

      await movimentacaoService
          .add(movimentacao);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Movimentação cadastrada com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      mostrarMensagem(
        'Erro ao cadastrar movimentação: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
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
        title: const Text(
          'Nova Movimentação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),

          const Icon(
            Icons.swap_vert,
            color: Colors.greenAccent,
            size: 64,
          ),

          const SizedBox(height: 16),

          const Text(
            'Cadastrar Movimentação',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Registre uma entrada ou saída '
            'em um dos seus caixas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 32),

          Card(
            color:
                const Color(0xFF293344),
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de movimentação',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<
                      String>(
                    value: tipoSelecionado,
                    decoration:
                        InputDecoration(
                      filled: true,
                      fillColor:
                          const Color(
                              0xFF101827),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ENTRADA',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .arrow_downward,
                              color:
                                  Colors.greenAccent,
                            ),
                            SizedBox(
                                width: 10),
                            Text('Entrada'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'SAIDA',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .arrow_upward,
                              color:
                                  Colors.redAccent,
                            ),
                            SizedBox(
                                width: 10),
                            Text('Saída'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() {
                          tipoSelecionado =
                              valor;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Centro de custo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<
                      CentroCusto>(
                    value:
                        centroSelecionado,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Selecione o centro de custo',
                      prefixIcon:
                          const Icon(
                        Icons.account_balance,
                        color:
                            Colors.greenAccent,
                      ),
                      filled: true,
                      fillColor:
                          const Color(
                              0xFF101827),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                    items: centros
                        .map(
                          (centro) =>
                              DropdownMenuItem<
                                  CentroCusto>(
                            value: centro,
                            child: Text(
                              centro.nome,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (centro) {
                      setState(() {
                        centroSelecionado =
                            centro;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller:
                        descricaoController,
                    textCapitalization:
                        TextCapitalization
                            .sentences,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Ex: Dízimo',
                      prefixIcon:
                          const Icon(
                        Icons.description,
                        color:
                            Colors.greenAccent,
                      ),
                      filled: true,
                      fillColor:
                          const Color(
                              0xFF101827),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Valor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller:
                        valorController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Ex: 100,00',
                      prefixText:
                          'R\$ ',
                      prefixIcon:
                          const Icon(
                        Icons.attach_money,
                        color:
                            Colors.greenAccent,
                      ),
                      filled: true,
                      fillColor:
                          const Color(
                              0xFF101827),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  InkWell(
                    onTap: selecionarData,
                    borderRadius:
                        BorderRadius.circular(
                            12),
                    child: Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFF101827),
                        borderRadius:
                            BorderRadius
                                .circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color:
                                Colors.greenAccent,
                          ),
                          const SizedBox(
                              width: 12),
                          Text(
                            '${dataSelecionada.day.toString().padLeft(2, '0')}/'
                            '${dataSelecionada.month.toString().padLeft(2, '0')}/'
                            '${dataSelecionada.year}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          salvando
                              ? null
                              : salvar,
                      icon: salvando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                            ),
                      label: Text(
                        salvando
                            ? 'Salvando...'
                            : 'Cadastrar',
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.greenAccent,
                        foregroundColor:
                            const Color(
                                0xFF101827),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
