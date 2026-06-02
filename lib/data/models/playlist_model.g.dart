// GENERATED CODE - Hand-written Hive adapter for PlaylistData

import 'package:hive/hive.dart';
import 'package:flutter_application_1/data/models/playlist_model.dart';

class PlaylistDataAdapter extends TypeAdapter<PlaylistData> {
  @override
  final int typeId = 1;

  @override
  PlaylistData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return PlaylistData(
      id: fields[0] as String,
      name: fields[1] as String,
      songIds: (fields[2] as List).cast<String>(),
      coverPath: fields[3] as String?,
      createdAt: fields[4] as int,
      updatedAt: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.songIds)
      ..writeByte(3)
      ..write(obj.coverPath)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistDataAdapter && typeId == other.typeId;
}
