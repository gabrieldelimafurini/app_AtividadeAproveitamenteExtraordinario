import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('weather.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weather (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT,
        temperature TEXT,
        humidity TEXT,
        condition TEXT
      )
    ''');
  }

  Future<int> insertWeather(Map<String, dynamic> weatherData) async {
    final db = await instance.database;
    return await db.insert('weather', weatherData);
  }

  Future<List<Map<String, dynamic>>> fetchWeatherHistory() async {
    final db = await instance.database;
    return await db.query('weather');
  }
}
