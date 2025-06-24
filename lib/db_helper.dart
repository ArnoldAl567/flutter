import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'diagnosticos.db');

    _database = await openDatabase(
      path,
      version: 2, // Asegúrate de incrementar el número de versión
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE diagnosticos (
            nivel_riesgo TEXT,
            riesgo_1 REAL,
            riesgo_2 REAL,
            riesgo_3 REAL,
            fecha TEXT,
            hora TEXT,
            tratamiento TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Si la versión es menor a 2, actualizamos la tabla
          await db.execute(''' 
            ALTER TABLE diagnosticos ADD COLUMN tratamiento TEXT
          ''');
        }
      },
    );

    return _database!;
  }

  static Future<void> insertarDiagnostico(Map<String, dynamic> datos) async {
    final db = await getDatabase();
    await db.insert('diagnosticos', datos);
  }
}

