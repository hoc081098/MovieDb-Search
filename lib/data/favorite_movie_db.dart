import 'dart:async';

import 'package:moviedb_seach/data/Movie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteMovieDb {
  static const tableMovies = 'movies';

  Database _db;

  static FavoriteMovieDb _instance;

  FavoriteMovieDb._internal();

  factory FavoriteMovieDb.getInstance() =>
      _instance ??= FavoriteMovieDb._internal();

  Future<Database> get db async => _db ??= await open();

  Future<Database> open() async {
    var directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "movie.db");
    return await openDatabase(path, version: 1,
        onCreate: (db, newVersion) async {
      await db.execute('''CREATE TABLE $tableMovies( 
        id STRING PRIMARY KEY UNIQUE NOT NULL, 
        title TEXT NOT NULL,
        overview TEXT,
        release_date TEXT,
        poster_path TEXT,
        vote_count INTEGER
      )''');
    });
  }

  close() async {
    var dbClient = await db;
    await dbClient.close();
  }

  Future<int> insert(Movie movie) async {
    var dbClient = await db;
    return await dbClient.insert(tableMovies, movie.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Movie movie) async {
    var dbClient = await db;
    return await dbClient.update(
      tableMovies,
      movie.toJson(),
      where: "id = ?",
      whereArgs: [movie.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(String id) async {
    var dbClient = await db;
    return await dbClient.delete(
      tableMovies,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<Movie> getMovie(String id) async {
    var dbClient = await db;
    var maps = await dbClient.query(
      tableMovies,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty
        ? (Movie.fromJson(maps.first)..isFavorite = true)
        : null;
  }

  Future<List<Movie>> getMovies() async {
    var dbClient = await db;
    var maps = await dbClient.query(tableMovies, orderBy: 'title ASC');
    return maps.map((json) => Movie.fromJson(json)..isFavorite = true).toList();
  }
}
