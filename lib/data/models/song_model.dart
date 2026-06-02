import 'package:hive/hive.dart';

/// Represents a song with all metadata
class SongData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String album;

  @HiveField(4)
  final String filePath;

  @HiveField(5)
  final int duration; // in milliseconds

  @HiveField(6)
  String? customArtworkPath; // user-uploaded cover art

  @HiveField(7)
  final int? bitrate;

  @HiveField(8)
  final String? format;

  @HiveField(9)
  final int? sampleRate;

  @HiveField(10)
  final int? size; // file size in bytes

  @HiveField(11)
  final int? dateAdded; // timestamp

  @HiveField(12)
  final int? albumId;

  @HiveField(13)
  final int? artistId;

  SongData({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.duration,
    this.customArtworkPath,
    this.bitrate,
    this.format,
    this.sampleRate,
    this.size,
    this.dateAdded,
    this.albumId,
    this.artistId,
  });

  SongData copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    int? duration,
    String? customArtworkPath,
    int? bitrate,
    String? format,
    int? sampleRate,
    int? size,
    int? dateAdded,
    int? albumId,
    int? artistId,
  }) {
    return SongData(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      customArtworkPath: customArtworkPath ?? this.customArtworkPath,
      bitrate: bitrate ?? this.bitrate,
      format: format ?? this.format,
      sampleRate: sampleRate ?? this.sampleRate,
      size: size ?? this.size,
      dateAdded: dateAdded ?? this.dateAdded,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SongData && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
