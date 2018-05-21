import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moviedb_seach/data/Movie.dart';
import 'package:moviedb_seach/data/movie_repo.dart';

class DetailPage extends StatefulWidget {
  final Movie movie;

  const DetailPage({Key key, this.movie}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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
    return Scaffold(
      body: Container(
        color: Color(0xFF736AB7),
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            _getBackground(),
            _getGradient(),
            _getContent(),
            _getToolbar(context)
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _isLoading ? null : _onPressed,
        child: _isLoading
            ? Container()
            : Icon(
                _movie.isFavorite ? Icons.star : Icons.star_border,
                color: Colors.white,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  _getBackground() {
    return Container(
      child: Image.network(
        "https://image.tmdb.org/t/p/w500${_movie.posterPath}",
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: new BoxConstraints.expand(height: 300.0),
    );
  }

  _getGradient() {
    return Container(
      margin: EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0x00736AB7),
            Color(0xFF736AB7),
          ],
          stops: [0.0, 0.9],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomStart,
        ),
      ),
    );
  }

  _getContent() {
    final headerStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: 18.0,
    );
    final regularStyle = headerStyle.copyWith(
      fontSize: 14.0,
      color: Color(0xffb6b2df),
      fontWeight: FontWeight.w400,
    );

    final titleText = Text(
      _movie.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: headerStyle,
    );

    final thumbnail = Container(
      margin: new EdgeInsets.only(bottom: 92.0),
      alignment: AlignmentDirectional.center,
      child: Hero(
        child: _movie.posterPath == null
            ? SizedBox(
                child: new Center(
                  child: Container(
                    width: 92.0,
                    height: 92.0 / 2 * 3,
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
      margin: EdgeInsets.only(top: 144.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 4.0),
          titleText,
          SizedBox(height: 8.0),
          Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 2.0,
              width: 128.0,
              color: Color(0xff00c6ff)),
          SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                child: new Row(
                  children: <Widget>[
                    Icon(
                      Icons.thumb_up,
                      color: Theme.of(context).accentColor,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      _movie.voteCount.toString(),
                      style: regularStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
              SizedBox(width: 4.0),
              new Expanded(
                child: new Row(
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    final card = Container(
      margin: EdgeInsets.only(bottom: 0.0),
      decoration: BoxDecoration(
        color: Color(0x8c333366),
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
    var item = Container(
      height: 300.0,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0),
      child: Stack(
        children: <Widget>[card, thumbnail],
      ),
    );

    return new RefreshIndicator(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          item,
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                Text('OVERVIEW', style: headerStyle),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    height: 2.0,
                    width: 32.0,
                    color: Color(0xff00c6ff)),
                Text(_movie.overview, style: regularStyle),
              ],
            ),
          ),
        ],
        padding: EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
      ),
      onRefresh: _onRefresh,
    );
  }

  _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: BackButton(color: Colors.white),
    );
  }

  _onPressed() async {
    final isFavorite = !_movie.isFavorite;

    var res = isFavorite
        ? await _dataSource.insertFavorite(movie: _movie)
        : await _dataSource.removeFavorite(id: _movie.id);

    setState(() {
      _movie.isFavorite = isFavorite;
    });
  }

  Future<Null> _onRefresh() async {
    var movie = await _dataSource.getMovieById(id: _movie.id);
    movie.isFavorite = _movie.isFavorite;
    debugPrint("[DETAIL] Update...$movie");
    if (movie.isFavorite) {
      var res = await _dataSource.insertFavorite(movie: movie);
      debugPrint("[DETAIL] Update...$res");
    }
    setState(() {
      _movie = movie;
      debugPrint("[DETAIL] State...");
    });
  }
}
