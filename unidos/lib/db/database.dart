import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDB() async {
WidgetsFlutterBinding.ensureInitialized();

return openDatabase(
    join(
    await getDatabasesPath(),
'unidos_database.db',
    ),
    onCreate: (db, version) async {
    await db.execute('''
        CREATE TABLE centros_custo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
        )
    ''');

    await db.execute('''
        CREATE TABLE movimentacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL,
        valor REAL NOT NULL,
        tipo TEXT NOT NULL,
        centro_custo_id INTEGER NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (centro_custo_id)
        REFERENCES centros_custo (id)
        )
''');
    },
    version: 1,
);


}

Future<void> adicionarCentroCusto(String nome) async {
  final db = await initDB();

  await db.insert(
    'centros_custo',
    {
      'nome': nome,
    },
  );
}

Future<void> adicionarMovimentacao({
  required String descricao,
  required double valor,
  required String tipo,
  required int centroCustoId,
  required String data,
}) async {
  final db = await initDB();

  await db.insert(
    'movimentacoes',
    {
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo,
      'centro_custo_id': centroCustoId,
      'data': data,
    },
  );
}