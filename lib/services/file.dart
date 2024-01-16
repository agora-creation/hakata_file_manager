import 'dart:io';
import 'dart:typed_data';

import 'package:hakata_file_manager/services/connection_sqlite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
      sql += ' order by id ASC';
      return await db.rawQuery(sql);
    } catch (e) {
      throw Exception();
    }
  }

  Future<String?> insert({
    required String clientNumber,
    required String clientName,
    required File uploadFile,
  }) async {
    String? error;
    if (clientNumber == '') return '取引先番号を入力してください';
    if (clientName == '') return '取引先名を入力してください';
    try {
      final dir = await getApplicationDocumentsDirectory();
      String savedPath = '${dir.path}/.hakata_file/$clientNumber';
      String savedFileName = p.basename(uploadFile.path);
      if (!await Directory(savedPath).exists()) {
        await Directory(savedPath).create(recursive: true);
      }
      Uint8List orgData = await uploadFile.readAsBytes();
      File savedFile = File('$savedPath/$savedFileName');
      await savedFile.writeAsBytes(orgData);
      Database db = await _getDatabase();
      String filePath = '$savedPath/$savedFileName';
      await db.rawInsert('''
        insert into file (
          clientNumber,
          clientName,
          filePath
        ) values (
          '$clientNumber',
          '$clientName',
          '$filePath'
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
