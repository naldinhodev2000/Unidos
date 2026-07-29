import 'package:flutter/material.dart';
import 'package:unidos/entity/movimentacao.dart';
import 'package:unidos/service/movimentacoes_service.dart';

class MovimentacoesPage extends StatefulWidget {
  const MovimentacoesPage({super.key});

  @override
  State<MovimentacoesPage> createState() =>
      _MovimentacoesPageState();
}

class _MovimentacoesPageState
    extends State<MovimentacoesPage> {

  final movimentacaoService =
      MovimentacaoService();

  List<Movimentacao> movimentacoes = [];


  @override
  void initState() {
    super.initState();
    carregarMovimentacoes();
  }


  Future<void> carregarMovimentacoes() async {

    final lista =
        await movimentacaoService.listAll();

    setState(() {

      movimentacoes =
          lista.reversed.toList();

    });
  }


  Future<void> excluirMovimentacao(
      Movimentacao movimentacao) async {


    final confirmar =
        await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Excluir movimentação?',
          ),

          content: Text(
            'Deseja excluir "${movimentacao.descricao}"?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                    context, false);
              },

              child:
                  const Text('Cancelar'),
            ),


            TextButton(
              onPressed: () {

                Navigator.pop(
                    context, true);

              },

              child: const Text(
                'Excluir',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),

          ],
        );
      },
    );


    if(confirmar == true &&
       movimentacao.id != null){


      await movimentacaoService.delete(
        movimentacao.id!,
      );


      carregarMovimentacoes();

    }

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
          'Todas movimentações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),


      body: RefreshIndicator(

        onRefresh:
            carregarMovimentacoes,


        child: ListView.builder(

          padding:
              const EdgeInsets.all(16),


          itemCount:
              movimentacoes.length,


          itemBuilder:
              (context,index){


            final movimentacao =
                movimentacoes[index];



            return GestureDetector(

              onLongPress: () {

                excluirMovimentacao(
                    movimentacao);

              },


              child: Card(

                color:
                    const Color(0xFF293344),


                child: ListTile(


                  leading:
                      CircleAvatar(

                    backgroundColor:

                        movimentacao.tipo ==
                                'ENTRADA'

                        ? Colors.green

                        : Colors.red,


                    child: Icon(

                      movimentacao.tipo ==
                              'ENTRADA'

                          ? Icons.arrow_downward

                          : Icons.arrow_upward,

                    ),

                  ),



                  title:
                      Text(
                        movimentacao.descricao,
                      ),



                  subtitle:
                      Text(
                        movimentacao.tipo,
                      ),



                  trailing:
                      Text(

                    '${movimentacao.tipo == 'ENTRADA' ? '+' : '-'} '
                    'R\$ ${movimentacao.valor.toStringAsFixed(2)}',


                    style:
                        TextStyle(

                      color:

                          movimentacao.tipo ==
                                  'ENTRADA'

                          ? Colors.greenAccent

                          : Colors.redAccent,


                      fontWeight:
                          FontWeight.bold,

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

}