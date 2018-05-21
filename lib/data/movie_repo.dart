import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:moviedb_seach/data/Movie.dart';
import 'package:moviedb_seach/data/favorite_movie_db.dart';

abstract class MovieDataSource {
  Future<List<Movie>> getMovies({@required String query});

  Future<List<Movie>> getFavoriteMovies();

  Future<bool> isFavorite({@required String id});

  Future<int> removeFavorite({@required String id});

  Future<int> insertFavorite({@required Movie movie});

  Future<Movie> getMovieById({@required String id});

  factory MovieDataSource.getInstance() => _MovieRepository();
}

class _MovieRepository implements MovieDataSource {
  static const API_KEY = '435b3cafa645350876e0bdb7cda32577';

  static _MovieRepository _instance;
  final FavoriteMovieDb _db;

  factory _MovieRepository() =>
      _instance ??= _MovieRepository._internal(FavoriteMovieDb.getInstance());

  _MovieRepository._internal(this._db);

  @override
  Future<List<Movie>> getMovies({@required String query}) async {
    var url = Uri.https(
      'api.themoviedb.org',
      '/3/search/movie',
      {'api_key': API_KEY, 'query': query ?? ''},
    );
    var response = await http.get(url);
    var decoded = json.decode(response.body);

    return response.statusCode == HttpStatus.OK
        ? (decoded['results'] as List)
            .map((json) => Movie.fromJson(json))
            .toList()
        : throw HttpException(decoded['status_message']);
  }

  @override
  Future<List<Movie>> getFavoriteMovies() => _db.getMovies();

  @override
  Future<bool> isFavorite({String id}) async {
    var movie = await _db.getMovie(id);
    return movie != null;
  }

  @override
  Future<int> removeFavorite({String id}) => _db.delete(id);

  @override
  Future<int> insertFavorite({Movie movie}) => _db.insert(movie);

  @override
  Future<Movie> getMovieById({String id}) async {
    var url = Uri.https(
      'api.themoviedb.org',
      '/3/movie/$id',
      {'api_key': API_KEY},
    );
    var response = await http.get(url);
    var decoded = json.decode(response.body);

    return response.statusCode == HttpStatus.OK
        ? new Movie.fromJson(decoded)
        : throw HttpException(decoded['status_message']);
  }
}
