// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      name: fields[0] as String,
      bodyPart: fields[1] as String,
      sets: (fields[2] as List?)?.cast<ExerciseSet>(),
      eccentricSeconds: fields[3] as int,
      concentricSeconds: fields[4] as int,
      isTempoEnabled: fields[5] as bool,
      targetSets: fields[6] as int,
      targetReps: fields[7] as String,
      memo: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.bodyPart)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.eccentricSeconds)
      ..writeByte(4)
      ..write(obj.concentricSeconds)
      ..writeByte(5)
      ..write(obj.isTempoEnabled)
      ..writeByte(6)
      ..write(obj.targetSets)
      ..writeByte(7)
      ..write(obj.targetReps)
      ..writeByte(8)
      ..write(obj.memo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
