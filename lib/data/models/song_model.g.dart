// GENERATED CODE - Hand-written Hive adapter for SongData
// This avoids requiring build_runner / hive_generator

import 'package:hive/hive.dart';
import 'package:flutter_application_1/data/models/song_model.dart';

class SongDataAdapter extends TypeAdapter<SongData> {
  @override
  final int typeId = 0;

  @override
  SongData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SongData(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      filePath: fields[4] as String,
      duration: fields[5] as int,
      customArtworkPath: fields[6] as String?,
      bitrate: fields[7] as int?,
      format: fields[8] as String?,
      sampleRate: fields[9] as int?,
      size: fields[10] as int?,
      dateAdded: fields[11] as int?,
      albumId: fields[12] as int?,
      artistId: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SongData obj) {
    writer
      ..writeByte(14) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.filePath)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.customArtworkPath)
      ..writeByte(7)
      ..write(obj.bitrate)
      ..writeByte(8)
      ..write(obj.format)
      ..writeByte(9)
      ..write(obj.sampleRate)
      ..writeByte(10)
      ..write(obj.size)
      ..writeByte(11)
      ..write(obj.dateAdded)
      ..writeByte(12)
      ..write(obj.albumId)
      ..writeByte(13)
      ..write(obj.artistId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongDataAdapter && typeId == other.typeId;
}
