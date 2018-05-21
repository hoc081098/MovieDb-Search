class Movie {
  final int voteCount;
  final String id;
  final String title;
  final String overview;
  final String releaseDate;
  final String posterPath;
  bool isFavorite;

  Movie({
    this.voteCount,
    this.id,
    this.title,
    this.overview,
    this.releaseDate,
    this.posterPath,
    this.isFavorite = false,
  });

  Movie.fromJson(Map<String, dynamic> map)
      : voteCount = map['vote_count'],
        id = map['id'].toString(),
        title = map['title'],
        overview = map['overview'],
        releaseDate = map['release_date'],
        posterPath = map['poster_path'],
        isFavorite = false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'vote_count': voteCount,
        'title': title,
        'overview': overview,
        'release_date': releaseDate,
        'poster_path': posterPath,
      };

  //
  //Purpose debug print
  //
  @override
  String toString() => 'Movie{voteCount: $voteCount, id: $id, '
      'title: $title, posterPath: $posterPath, isFavorite: $isFavorite}';
}
