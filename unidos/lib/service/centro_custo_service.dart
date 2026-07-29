import 'package:sqflite/sqflite.dart';
import 'package:unidos/db/database.dart';
import 'package:unidos/entity/centro_custo.dart';

class CentroCustoService {
  Future<Database> get db => initDB();

  Future<void> add(CentroCusto centroCusto) async {
    final database = await db;
    await database.insert(
      'centros_custo',
      centroCusto.toMap(),
    );
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete(
      'centros_custo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> update(CentroCusto centroCusto) async {
    final database = await db;
    await database.update(
      'centros_custo',
      centroCusto.toMap(),
      where: 'id = ?',
      whereArgs: [centroCusto.id],
    );
  }

  Future<List<CentroCusto>> listAll() async {
    final database = await db;

    final maps = await database.query('centros_custo');

    return maps.map((map) {
      return CentroCusto.fromMap(map);
    }).toList();
  }
}