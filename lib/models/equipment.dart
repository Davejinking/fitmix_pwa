import 'package:hive/hive.dart';

part 'equipment.g.dart';

/// 장비 카테고리 (RPG 슬롯 시스템)
enum EquipmentCategory {
  helmet,    // 투구 (모자/헤드밴드)
  armor,     // 갑옷 (짐웨어 상의)
  gloves,    // 장갑 (스트랩/그립)
  belt,      // 허리띠 (리프팅 벨트)
  boots,     // 신발 (역도화/운동화)
  weapon,    // 무기 (보호대/니슬리브)
  accessory, // 악세서리 (기타)
}

/// 장비 등급 (희귀도)
enum EquipmentRarity {
  common,    // 회색 - 다이소급
  uncommon,  // 초록색 - 데카트론급
  rare,      // 파란색 - 나이키/아디다스급
  epic,      // 보라색 - 로그/리복급
  legendary, // 주황색 - SBD/카딜로급
}

@HiveType(typeId: 11)
class Equipment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // 장비명 (예: "SBD Belt 13mm")

  @HiveField(2)
  String? brand; // 브랜드 (예: "SBD", "Nike")

  @HiveField(3)
  String? imagePath; // 로컬 이미지 경로

  @HiveField(4)
  int categoryIndex; // EquipmentCategory.index

  @HiveField(5)
  int rarityIndex; // EquipmentRarity.index

  @HiveField(6)
  DateTime? purchaseDate; // 구매일

  @HiveField(7)
  DateTime createdAt; // 등록일

  @HiveField(8)
  double totalVolumeLifted; // 이 장비로 들어올린 총 볼륨

  @HiveField(9)
  int totalSetsCompleted; // 이 장비로 완료한 총 세트 수

  @HiveField(10)
  List<String> linkedExercises; // 자동 장착될 운동 목록

  Equipment({
    required this.id,
    required this.name,
    this.brand,
    this.imagePath,
    this.categoryIndex = 6, // default: accessory
    this.rarityIndex = 0,   // default: common
    this.purchaseDate,
    DateTime? createdAt,
    this.totalVolumeLifted = 0,
    this.totalSetsCompleted = 0,
    List<String>? linkedExercises,
  }) : createdAt = createdAt ?? DateTime.now(),
       linkedExercises = linkedExercises ?? [];

  // Getters for enums
  EquipmentCategory get category => EquipmentCategory.values[categoryIndex];
  EquipmentRarity get rarity => EquipmentRarity.values[rarityIndex];

  // Setters for enums
  set category(EquipmentCategory value) => categoryIndex = value.index;
  set rarity(EquipmentRarity value) => rarityIndex = value.index;

  Equipment copyWith({
    String? id,
    String? name,
    String? brand,
    String? imagePath,
    int? categoryIndex,
    int? rarityIndex,
    DateTime? purchaseDate,
    DateTime? createdAt,
    double? totalVolumeLifted,
    int? totalSetsCompleted,
    List<String>? linkedExercises,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imagePath: imagePath ?? this.imagePath,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      rarityIndex: rarityIndex ?? this.rarityIndex,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      totalVolumeLifted: totalVolumeLifted ?? this.totalVolumeLifted,
      totalSetsCompleted: totalSetsCompleted ?? this.totalSetsCompleted,
      linkedExercises: linkedExercises ?? List.from(this.linkedExercises),
    );
  }

  @override
  String toString() => 'Equipment($name, $brand, ${category.name}, ${rarity.name})';
}

/// 장비 등급별 색상
extension EquipmentRarityColor on EquipmentRarity {
  int get colorValue {
    switch (this) {
      case EquipmentRarity.common:
        return 0xFF9E9E9E; // Grey
      case EquipmentRarity.uncommon:
        return 0xFF4CAF50; // Green
      case EquipmentRarity.rare:
        return 0xFF2196F3; // Blue
      case EquipmentRarity.epic:
        return 0xFF9C27B0; // Purple
      case EquipmentRarity.legendary:
        return 0xFFFF9800; // Orange
    }
  }

  String get displayName {
    switch (this) {
      case EquipmentRarity.common:
        return 'Common';
      case EquipmentRarity.uncommon:
        return 'Uncommon';
      case EquipmentRarity.rare:
        return 'Rare';
      case EquipmentRarity.epic:
        return 'Epic';
      case EquipmentRarity.legendary:
        return 'Legendary';
    }
  }
}

/// 장비 카테고리별 아이콘 및 이름
extension EquipmentCategoryInfo on EquipmentCategory {
  String get displayName {
    switch (this) {
      case EquipmentCategory.helmet:
        return '투구';
      case EquipmentCategory.armor:
        return '갑옷';
      case EquipmentCategory.gloves:
        return '장갑';
      case EquipmentCategory.belt:
        return '벨트';
      case EquipmentCategory.boots:
        return '신발';
      case EquipmentCategory.weapon:
        return '무기';
      case EquipmentCategory.accessory:
        return '악세서리';
    }
  }

  int get iconCodePoint {
    switch (this) {
      case EquipmentCategory.helmet:
        return 0xe3ae; // Icons.sports_martial_arts
      case EquipmentCategory.armor:
        return 0xf06c4; // Icons.checkroom
      case EquipmentCategory.gloves:
        return 0xe1a0; // Icons.back_hand
      case EquipmentCategory.belt:
        return 0xf06c5; // Icons.straighten
      case EquipmentCategory.boots:
        return 0xf06c6; // Icons.ice_skating (closest to shoes)
      case EquipmentCategory.weapon:
        return 0xe8e8; // Icons.shield
      case EquipmentCategory.accessory:
        return 0xe87d; // Icons.star
    }
  }
}
