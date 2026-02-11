// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 2;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      ymd: fields[0] as String,
      exercises: (fields[1] as List?)?.cast<Exercise>(),
      isRest: fields[2] as bool,
      durationInSeconds: fields[3] as int,
      isCompleted: fields[4] as bool,
      routineName: fields[5] as String?,
      condition: fields[6] as String?,
      conditionTags: (fields[7] as List?)?.cast<String>(),
      decisionReview: fields[8] as String?,
      decisionReason: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.ymd)
      ..writeByte(1)
      ..write(obj.exercises)
      ..writeByte(2)
      ..write(obj.isRest)
      ..writeByte(3)
      ..write(obj.durationInSeconds)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.routineName)
      ..writeByte(6)
      ..write(obj.condition)
      ..writeByte(7)
      ..write(obj.conditionTags)
      ..writeByte(8)
      ..write(obj.decisionReview)
      ..writeByte(9)
      ..write(obj.decisionReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
