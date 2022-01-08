import 'package:local_database_example/constant.dart';
import 'package:local_database_example/model/todo.dart';
import 'package:local_database_example/service/save_user_cache.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoProvider {
  late Database db;

  Future<String> getDatabasePath() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, DB);
    return path;
  }

  Future removeDatabase() async {
    String path = await getDatabasePath();
    await deleteDatabase(path);
  }

  Future<bool> initDatabase() async {
    String path = await getDatabasePath();

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $TABLE (
            $COLUMN_ID integer primary key autoincrement,
            $COLUMN_TITLE text not null,
            $COLUMN_DONE integer not null,
            $COLUMN_DESC text,
            $COLUMN_DATE text not null,
            $COLUMN_TIME text not null,
            $COLUMN_USER text not null
          )
          ''');
      },
    );
    return db.isOpen;
  }

  Future<Todo?> insert(Todo todo) async {
    var id = await db.insert(TABLE, todo.toMap(todo));
    return todo.copyWith(id: id);
  }

  Future<Todo?> getTodo(int id) async {
    List<Map<String, dynamic>> maps = await db.query(TABLE, columns: [
      COLUMN_ID,
      COLUMN_TITLE,
      COLUMN_TITLE,
      COLUMN_DATE,
      COLUMN_DESC,
      COLUMN_TIME,
      COLUMN_USER
    ], whereArgs: [
      id
    ]);
    if (maps.length > 0) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Todo>?> fetchAll() async {
    final user = await SaveUserCache.getUser();
    var list = await db.query(TABLE, where: 'user = ?', whereArgs: [user]);
    return list.map((e) => Todo.fromMap(e)).toList();
  }

  Future<int?> getCount({required String user, required String date}) async {
    int? count = Sqflite.firstIntValue(await db.rawQuery(
        'select count(*) from $TABLE where user=? and date=?', [user, date]));
    return count;
  }

  Future<int> delete(int id) async {
    return await db.delete(TABLE, where: '$COLUMN_ID = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await db.update(TABLE, todo.toMap(todo),
        where: '$COLUMN_ID = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteAll() async {
    int count = await db.rawDelete('DELETE FROM $TABLE');
    return count;
  }

  Future close() async {
    db.close();
  }
}
