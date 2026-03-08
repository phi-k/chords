class GroupedSong {
  final String title;
  final String artist;
  final List<SongVersion> versions;
  String? coverUrl;

  GroupedSong({
    required this.title,
    required this.artist,
    required this.versions,
    this.coverUrl,
  });
}

class SongVersion {
  final String title;
  final String note;
  final String lien;
  final String type;
  final int versionNumber;
  final String sourceName;
  final String sourceId;
  final int votes;
  final double rating;
  int? rank;

  SongVersion({
    required this.title,
    required this.note,
    required this.lien,
    required this.type,
    required this.versionNumber,
    this.sourceName = '',
    this.sourceId = '',
    this.votes = 0,
    this.rating = 0.0,
    this.rank,
  });
}
