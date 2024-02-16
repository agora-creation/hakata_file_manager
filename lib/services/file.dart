import 'dart:io';

import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/services/connection_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FileService {
  ConnectionSQLiteService connection = ConnectionSQLiteService.instance;

  Future<Database> _getDatabase() async {
    return await connection.db;
  }

  Future<List<Map>> select({
    required Map<String, String> searchMap,
  }) async {
    try {
      Database db = await _getDatabase();
      String sql = 'select * from file where id != 0';
      if (searchMap['clientNumber'] != '') {
        sql += " and clientNumber like '%${searchMap['clientNumber']}%'";
      }
      if (searchMap['createDateStart'] != '' &&
          searchMap['createDateStart'] != '') {
        sql += " and (";
        sql += " createDate BETWEEN '${searchMap['createDateStart']} 00:00:00'";
        sql += " AND";
        sql += " '${searchMap['createDateEnd']} 23:59:59'";
        sql += " )";
      }
      sql += ' order by id ASC';
      return await db.rawQuery(sql);
    } catch (e) {
      throw Exception();
    }
  }

  Future<bool> alreadyCheck(String filePath) async {
    if (filePath == '') return true;
    Database db = await _getDatabase();
    String sql = 'select * from file where id != 0';
    sql += " and filePath like '$filePath'";
    sql += ' order by id ASC';
    List<Map> files = await db.rawQuery(sql);
    if (files.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<String?> insert({
    required String clientNumber,
    required String clientName,
    required File uploadFile,
    required DateTime createDate,
  }) async {
    String? error;
    if (clientNumber == '') return '取引先番号を入力してください';
    if (clientName == '') return '取引先名を入力してください';
    try {
      Database db = await _getDatabase();
      await db.rawInsert('''
        insert into file (
          clientNumber,
          clientName,
          filePath,
          createDate
        ) values (
          '$clientNumber',
          '$clientName',
          '${uploadFile.path}',
          '${dateText('yyyy-MM-dd', createDate)}'
        );
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
        'delete from file where id = $id;',
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
      await db.delete('file');
    } catch (e) {
      error = e.toString();
    }
    return error;
  }
}
