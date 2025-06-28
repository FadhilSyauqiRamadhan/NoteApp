import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'notes.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          category TEXT,
          date TEXT
        )
      ''');
    });
  }

  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }
}
