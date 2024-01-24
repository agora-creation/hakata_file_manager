import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ConnectionSQLiteService {
  ConnectionSQLiteService._();

  static ConnectionSQLiteService? _instance;

  static ConnectionSQLiteService get instance {
    _instance ??= ConnectionSQLiteService._();
    return _instance!;
  }

  static const DATABASE_NAME = 'hakata_file_manager20240201.db';
  static const DATABASE_VERSION = 1;
  Database? _db;

  Future<Database> get db => _openDatabase();

  Future<Database> _openDatabase() async {
    sqfliteFfiInit();
    final dbDirectory = await getApplicationSupportDirectory();
    final dbFilePath = dbDirectory.path;
    String path = join(dbFilePath, DATABASE_NAME);
    DatabaseFactory databaseFactory = databaseFactoryFfi;
    _db ??= await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        onCreate: _onCreate,
        version: DATABASE_VERSION,
      ),
    );
    return _db!;
  }

  FutureOr<void> _onCreate(Database db, int version) {
    db.transaction((reference) async {
      await reference.execute('''
        CREATE TABLE `client` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `number` TEXT,
          `name` TEXT,
          `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      ''');
      await reference.execute('''
        CREATE TABLE `file` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT,
          `clientNumber` TEXT,
          `clientName` TEXT,
          `filePath` TEXT,
          `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      ''');
    });
  }
}
