import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ClipboardEntry {
  final int? id;
  final String content;
  final DateTime timestamp;

  ClipboardEntry({this.id, required this.content, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ClipboardEntry.fromMap(Map<String, dynamic> map) {
    return ClipboardEntry(
      id: map['id'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class ClipboardDatabase {
  static final ClipboardDatabase instance = ClipboardDatabase._init();
  static Database? _database;

  ClipboardDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clipboard.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clipboard_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertEntry(ClipboardEntry entry) async {
    final db = await instance.database;
    return await db.insert('clipboard_entries', entry.toMap());
  }

  Future<List<ClipboardEntry>> getAllEntries() async {
    final db = await instance.database;
    final result = await db.query(
      'clipboard_entries',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ClipboardEntry.fromMap(map)).toList();
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete(
      'clipboard_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ClipboardEntry>> searchEntries(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'clipboard_entries',
      where: 'content LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ClipboardEntry.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
} 