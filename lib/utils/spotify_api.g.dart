// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_api.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 1;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      fields[0] as String,
      fields[1] as String?,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.previewUrl)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 2;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      id: fields[0] as String,
      name: fields[1] as String,
      creatorName: fields[2] as String,
      imageUrl: fields[3] as String,
      snapshotId: fields[5] as String,
      lastFetch: fields[6] as DateTime,
      enabled: fields[7] as bool,
      included: fields[8] as bool,
    )..songIds = (fields[4] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.creatorName)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.songIds)
      ..writeByte(5)
      ..write(obj.snapshotId)
      ..writeByte(6)
      ..write(obj.lastFetch)
      ..writeByte(7)
      ..write(obj.enabled)
      ..writeByte(8)
      ..write(obj.included);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
