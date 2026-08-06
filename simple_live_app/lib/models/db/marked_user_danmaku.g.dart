// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marked_user_danmaku.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkedUserDanmakuAdapter extends TypeAdapter<MarkedUserDanmaku> {
  @override
  final int typeId = 5;

  @override
  MarkedUserDanmaku read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkedUserDanmaku(
      id: fields[0] as String,
      siteId: fields[1] as String,
      userId: fields[2] as String,
      userName: fields[3] as String,
      content: fields[4] as String,
      sentAt: fields[5] as DateTime,
      roomId: fields[6] as String,
      roomTitle: fields[7] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, MarkedUserDanmaku obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.siteId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.sentAt)
      ..writeByte(6)
      ..write(obj.roomId)
      ..writeByte(7)
      ..write(obj.roomTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkedUserDanmakuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
