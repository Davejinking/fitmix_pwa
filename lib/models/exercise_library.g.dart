// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_library.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseLibraryItemAdapter extends TypeAdapter<ExerciseLibraryItem> {
  @override
  final int typeId = 10;

  @override
  ExerciseLibraryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseLibraryItem(
      id: fields[0] as String,
      targetPart: fields[1] as String,
      equipmentType: fields[2] as String,
      nameKr: fields[3] as String,
      nameEn: fields[4] as String,
      nameJp: fields[5] as String,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseLibraryItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.targetPart)
      ..writeByte(2)
      ..write(obj.equipmentType)
      ..writeByte(3)
      ..write(obj.nameKr)
      ..writeByte(4)
      ..write(obj.nameEn)
      ..writeByte(5)
      ..write(obj.nameJp)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLibraryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
