// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marked_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkedUserAdapter extends TypeAdapter<MarkedUser> {
  @override
  final int typeId = 4;

  @override
  MarkedUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkedUser(
      id: fields[0] as String,
      siteId: fields[1] as String,
      userId: fields[2] as String,
      userName: fields[3] as String,
      highlight: fields[4] as bool,
      record: fields[5] as bool,
      scope: fields[6] as int,
      roomId: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MarkedUser obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.siteId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.highlight)
      ..writeByte(5)
      ..write(obj.record)
      ..writeByte(6)
      ..write(obj.scope)
      ..writeByte(7)
      ..write(obj.roomId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkedUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
