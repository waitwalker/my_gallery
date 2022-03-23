import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_base.dart';

class DBHelper {
  Future<Database>? _db;

  Future<Database>? get db async {
    if (_db == null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentDir = await getApplicationDocumentsDirectory();
    String path = join(documentDir.path, "aixue.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE Employee(id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT, mobilenu TEXT,emailId TEXT )");
  }

  Future<List<DBObject>> getData(String query) async {
    var dbClient = await db!;
    List<Map> listMap = await dbClient.rawQuery(query);
    List<DBObject> listObjet = [];
    for (int i = 0; i < listMap.length; i++) {
      DBObject object = DBObject();
      object.loadObject(listMap[i]);
      listObjet.add(object);
    }
    return listObjet;
  }
}
