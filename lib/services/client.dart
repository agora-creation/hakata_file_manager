import 'package:hakata_file_manager/services/connection_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ClientService {
  ConnectionSQLiteService connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await connection.db;
  }

  Future<List<Map>> select({
    required Map<String, String> searchMap,
  }) async {
    try {
      Database db = await _getDatabase();
      String sql = 'select * from client where id != 0';
      if (searchMap['number'] != '') {
        sql += " and number like '${searchMap['number']}'";
      }
      if (searchMap['name'] != '') {
        sql += " and name like '%${searchMap['name']}%'";
      }
      if (searchMap['orderBy'] == 'numberASC') {
        sql += ' order by convert(int, number) ASC';
      } else if (searchMap['orderBy'] == 'numberDESC') {
        sql += ' order by convert(int, number) DESC';
      } else if (searchMap['orderBy'] == 'nameASC') {
        sql += ' order by name ASC';
      } else if (searchMap['orderBy'] == 'nameDESC') {
        sql += ' order by name DESC';
      } else {
        sql += ' order by convert(int, number) ASC';
      }
      return await db.rawQuery(sql);
    } catch (e) {
      throw Exception();
    }
  }

  Future<bool> _numberCheck(String number) async {
    try {
      Database db = await _getDatabase();
      String sql = "select * from client where number = '$number'";
      List<Map> listMap = await db.rawQuery(sql);
      if (listMap.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> insert({
    required String number,
    required String name,
  }) async {
    String? error;
    if (number == '') return '取引先番号を入力してください';
    if (name == '') return '取引先名を入力してください';
    if (await _numberCheck(number)) {
      return '取引先番号が重複しています';
    }
    try {
      Database db = await _getDatabase();
      await db.rawInsert('''
        insert into client (
          number,
          name
        ) values (
          '$number',
          '$name'
        );
      ''');
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> update({
    required int id,
    required String name,
  }) async {
    String? error;
    if (name == '') return '取引先名を入力してください';
    try {
      Database db = await _getDatabase();
      await db.rawUpdate('''
        update client
        set name = '$name'
        where id = $id;
      ''');
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> delete({
    required int id,
  }) async {
    String? error;
    try {
      Database db = await _getDatabase();
      await db.rawDelete(
        'delete from client where id = $id;',
      );
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> clear() async {
    String? error;
    try {
      Database db = await _getDatabase();
      await db.delete('client');
    } catch (e) {
      error = e.toString();
    }
    return error;
  }
}
