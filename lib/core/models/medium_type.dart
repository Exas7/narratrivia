// lib/models/medium_type.dart

enum MediumType {
  videogames,
  books,
  comics,
  manga,
  anime,
  tvSeries,
  movies,
}

extension MediumTypeExtension on MediumType {
  String get displayName {
    switch (this) {
      case MediumType.videogames:
        return 'Videogiochi';
      case MediumType.books:
        return 'Libri';
      case MediumType.comics:
        return 'Fumetti';
      case MediumType.manga:
        return 'Manga';
      case MediumType.anime:
        return 'Anime';
      case MediumType.tvSeries:
        return 'Serie TV';
      case MediumType.movies:
        return 'Film';
    }
  }
}