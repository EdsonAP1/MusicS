import 'package:hive/hive.dart';

/// Represents a user-created playlist
class PlaylistData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> songIds;

  @HiveField(3)
  String? coverPath;

  @HiveField(4)
  final int createdAt;

  @HiveField(5)
  int updatedAt;

  PlaylistData({
    required this.id,
    required this.name,
    List<String>? songIds,
    this.coverPath,
    int? createdAt,
    int? updatedAt,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  int get songCount => songIds.length;

  void addSong(String songId) {
    if (!songIds.contains(songId)) {
      songIds.add(songId);
      updatedAt = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void removeSong(String songId) {
    songIds.remove(songId);
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }
}
