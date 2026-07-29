import 'package:unidos/db/database.dart';
import 'package:unidos/entity/movimentacao.dart';

class MovimentacaoService {
  Future<void> add(Movimentacao movimentacao) async {
    final db = await initDB();

    await db.insert(
      'movimentacoes',
      movimentacao.toMap(),
    );
  }

  Future<void> delete(int id) async {
    final db = await initDB();

    await db.delete(
      'movimentacoes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> update(Movimentacao movimentacao) async {
    final db = await initDB();

    await db.update(
      'movimentacoes',
      movimentacao.toMap(),
      where: 'id = ?',
      whereArgs: [movimentacao.id],
    );
  }

  Future<List<Movimentacao>> listAll() async {
    final db = await initDB();

    final maps = await db.query('movimentacoes');

    return maps
        .map((map) => Movimentacao.fromMap(map))
        .toList();
  }

  Future<List<Movimentacao>> listByCentroCusto(
    int centroCustoId,
  ) async {
    final db = await initDB();

    final maps = await db.query(
      'movimentacoes',
      where: 'centro_custo_id = ?',
      whereArgs: [centroCustoId],
    );

    return maps
        .map((map) => Movimentacao.fromMap(map))
        .toList();
  }

  // Saldo de um centro de custo
  Future<double> getSaldoCentroCusto(int centroCustoId) async {
    final movimentacoes = await listByCentroCusto(centroCustoId);

    double saldo = 0;

    for (final movimentacao in movimentacoes) {
      if (movimentacao.tipo == 'ENTRADA') {
        saldo += movimentacao.valor;
      } else if (movimentacao.tipo == 'SAIDA') {
        saldo -= movimentacao.valor;
      }
    }

    return saldo;
  }

  // Saldo total juntando todos os centros de custo
  Future<double> getSaldoTotal() async {
    final movimentacoes = await listAll();

    double saldo = 0;

    for (final movimentacao in movimentacoes) {
      if (movimentacao.tipo == 'ENTRADA') {
        saldo += movimentacao.valor;
      } else if (movimentacao.tipo == 'SAIDA') {
        saldo -= movimentacao.valor;
      }
    }

    return saldo;
  }
}