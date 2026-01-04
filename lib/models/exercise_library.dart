import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'exercise_library.g.dart';

@HiveType(typeId: 10)
class ExerciseLibraryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String targetPart;

  @HiveField(2)
  String equipmentType;

  @HiveField(3)
  String nameKr;

  @HiveField(4)
  String nameEn;

  @HiveField(5)
  String nameJp;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  ExerciseLibraryItem({
    required this.id,
    required this.targetPart,
    required this.equipmentType,
    required this.nameKr,
    required this.nameEn,
    required this.nameJp,
    this.createdAt,
    this.updatedAt,
  }) {
    createdAt ??= DateTime.now();
    updatedAt ??= DateTime.now();
  }

  /// 현재 앱의 Locale에 따라 적절한 이름을 반환
  String getLocalizedName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    
    switch (locale.languageCode) {
      case 'ko':
        return nameKr.isNotEmpty ? nameKr : nameEn;
      case 'ja':
        return nameJp.isNotEmpty ? nameJp : nameEn;
      default:
        return nameEn.isNotEmpty ? nameEn : nameKr;
    }
  }

  /// JSON에서 ExerciseLibraryItem 생성
  factory ExerciseLibraryItem.fromJson(Map<String, dynamic> json) {
    return ExerciseLibraryItem(
      id: json['id'] as String,
      targetPart: json['target_part'] as String,
      equipmentType: json['equipment_type'] as String,
      nameKr: json['name_kr'] as String,
      nameEn: json['name_en'] as String,
      nameJp: json['name_jp'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// ExerciseLibraryItem을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_part': targetPart,
      'equipment_type': equipmentType,
      'name_kr': nameKr,
      'name_en': nameEn,
      'name_jp': nameJp,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 데이터 업데이트 (이름 변경 등)
  ExerciseLibraryItem copyWith({
    String? id,
    String? targetPart,
    String? equipmentType,
    String? nameKr,
    String? nameEn,
    String? nameJp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseLibraryItem(
      id: id ?? this.id,
      targetPart: targetPart ?? this.targetPart,
      equipmentType: equipmentType ?? this.equipmentType,
      nameKr: nameKr ?? this.nameKr,
      nameEn: nameEn ?? this.nameEn,
      nameJp: nameJp ?? this.nameJp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseLibraryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExerciseLibraryItem(id: $id, nameKr: $nameKr, nameEn: $nameEn, nameJp: $nameJp)';
  }
}