import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:moviedb_seach/data/Movie.dart';
import 'package:moviedb_seach/data/movie_repo.dart';
import 'package:moviedb_seach/detail_page.dart';
import 'package:moviedb_seach/favorite_page.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie searcher',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'NunitoSans',
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              'Movie search',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0),
            ),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.movie)),
                Tab(icon: Icon(Icons.favorite)),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              MyHomePage(scaffoldKey: _scaffoldKey),
              FavoritePage(scaffoldKey: _scaffoldKey),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  MovieDataSource _dataSource;
  PublishSubject<String> _subject;
  List<Movie> _movies;
  bool _isLoading;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();

    _isLoading = false;
    _scaffoldKey = widget.scaffoldKey;
    _movies = <Movie>[];

    _subject = PublishSubject()
      ..stream
          .debounce(Duration(milliseconds: 300))
          .distinct()
          .where((query) => query.trim().isNotEmpty)
          .switchMap(searchMovie)
          .listen(onData, onError: onError);

    _dataSource = MovieDataSource.getInstance();
  }

  Stream<List<Movie>> searchMovie(query) {
    return Observable
        .fromFuture(_dataSource.getMovies(query: query))
        .doOnListen(onListen);
  }

  void onData(List<Movie> movies) {
    setState(() {
      _movies = movies;
      debugPrint("Search...");
      _movies.forEach((m) => debugPrint(m.toString()));
      _isLoading = false;
    });
  }

  onError(e) {
    setState(() {
      _isLoading = false;
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    });
  }

  void onListen() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: TextField(
              onChanged: (text) {
                _subject.add(text);
              },
            ),
          ),
          Flexible(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _movies.length,
                    itemBuilder: (context, index) =>
                        MovieWidget(movie: _movies[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MyHomePage({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class MovieWidget extends StatefulWidget {
  final Movie movie;

  const MovieWidget({Key key, @required this.movie}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MovieWidgetState();
}

class MovieWidgetState extends State<MovieWidget> {
  Movie _movie;
  MovieDataSource _dataSource;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _isLoading = true;
    _dataSource = MovieDataSource.getInstance()
      ..isFavorite(id: _movie.id).then((b) => setState(() {
            _isLoading = false;
            _movie.isFavorite = b;
          }));
  }

  @override
  Widget build(BuildContext context) {
    final starIcon = _isLoading
        ? Container()
        : IconButton(
            onPressed: () {
              _onPressed();
            },
            icon: Icon(
              _movie.isFavorite ? Icons.star : Icons.star_border,
              color: Theme.of(context).accentColor,
            ),
          );

    final headerStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: 18.0,
    );
    final regularStyle = headerStyle.copyWith(
      fontSize: 9.0,
      color: Color(0xffb6b2df),
      fontWeight: FontWeight.w400,
    );
    final subHeaderStyle = headerStyle.copyWith(
      fontSize: 12.0,
    );

    final titleText = Text(
      _movie.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: headerStyle,
    );

    final thumbnail = Container(
      margin: EdgeInsets.symmetric(vertical: 12.0),
      alignment: AlignmentDirectional.centerStart,
      child: Hero(
        child: _movie.posterPath == null
            ? SizedBox(
                child: new Center(
                  child: Container(
                    width: 92.0 * 2 / 3,
                    child: new Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.redAccent.shade400,
                      ),
                    ),
                    decoration: BoxDecoration(color: Colors.black54),
                  ),
                ),
                width: 92.0,
              )
            : Image.network(
                "https://image.tmdb.org/t/p/w92${_movie.posterPath}",
                width: 92.0,
              ),
        tag: _movie.id,
      ),
    );
    final cardContent = Container(
      margin: EdgeInsets.only(left: 46.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 4.0),
          titleText,
          SizedBox(height: 8.0),
          Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 32.0,
              color: Color(0xff00c6ff)),
          Row(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.thumb_up,
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    _movie.voteCount.toString(),
                    style: regularStyle,
                  ),
                ],
              ),
              SizedBox(width: 4.0),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.date_range,
                      color: Theme.of(context).accentColor,
                    ),
                    SizedBox(width: 8.0),
                    new Center(
                      child: Text(
                        _movie.releaseDate.toString(),
                        style: regularStyle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.0),
              starIcon
            ],
          ),
        ],
      ),
    );
    final card = Container(
      margin: EdgeInsets.only(left: 46.0),
      decoration: BoxDecoration(
        color: Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: cardContent,
    );
    return GestureDetector(
      child: Container(
        height: 132.0,
        margin: EdgeInsets.only(
          left: 4.0,
          right: 8.0,
          bottom: 12.0,
          top: 12.0,
        ),
        child: Stack(
          children: <Widget>[card, thumbnail],
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          return DetailPage(movie: _movie);
        }));
      },
    );
  }

  _onPressed() async {
    final isFavorite = !_movie.isFavorite;

    var res = isFavorite
        ? await _dataSource.insertFavorite(movie: _movie)
        : await _dataSource.removeFavorite(id: _movie.id);
    debugPrint("${isFavorite ? "insert" : "delete"}, res = $res");

    setState(() {
      _movie.isFavorite = isFavorite;
    });
  }
}
