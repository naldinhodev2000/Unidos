
class Movimentacao {
  final int? id;
  final String descricao;
  final double valor;
  final String tipo;
  final int centroCustoId;
  final String data;

  Movimentacao({
    this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.centroCustoId,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo,
      'centro_custo_id': centroCustoId,
      'data': data,
    };
  }

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      id: map['id'],
      descricao: map['descricao'],
      valor: (map['valor'] as num).toDouble(),
      tipo: map['tipo'],
      centroCustoId: map['centro_custo_id'],
      data: map['data'],
    );
  }
}