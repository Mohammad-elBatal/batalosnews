import 'package:batalosnews/classes/Article.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('articles.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE articles (
        source TEXT,
        author TEXT,
        title TEXT,
        description TEXT,
        url TEXT PRIMARY KEY,
        urlToImage TEXT,
        publishedAt DATETIME,
        content TEXT,
        state TEXT
      )
    ''');
  }
  Future<void> insertArticle(Article article) async {
    final db = await instance.database;
    await db.insert(
      'articles',
      article.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<List<Article>> getSavedArticles() async {
    final db = await instance.database;
    final savedArticlesJson = await db.query('articles');
    return savedArticlesJson.map((articleJson) => Article.fromMap(articleJson)).toList();
  }
  Future<void> deleteArticles() async {
    final db = await instance.database;
    await db.delete(
      'articles',
    );
  }
  Future<void> addArticles(List<Article> articles) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var article in articles) {
      if (!await isArticleSaved(article.url!, article.title!)) {
        batch.insert(
        'articles',
        article.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      }
    }
    await batch.commit(noResult: true);
  }
  Future<void> setStatusAsOld() async {
    final db = await instance.database;
    await db.update(
      'articles',
      {'state': 'old'},
    );
  }
  Future<int> getNewsCount() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT IFNULL(COUNT(*), 0) FROM articles WHERE state = ?', ['New']),
    );
    return count ?? 0;
  }
  Future<bool> isArticleSaved(String url, String title) async {
    final db = await instance.database;
    final result = await db.query(
      'articles',
      where: 'url = ? AND title = ?',
      whereArgs: [url, title],
    );
    return result.isNotEmpty;
  }
}