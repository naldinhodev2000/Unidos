class CentroCusto {
  final int? id;
  final String nome;

  CentroCusto({
    this.id,
    required this.nome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory CentroCusto.fromMap(Map<String, dynamic> map) {
    return CentroCusto(
      id: map['id'],
      nome: map['nome'],
    );
  }
}