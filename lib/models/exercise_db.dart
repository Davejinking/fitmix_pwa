/// ExerciseDB API 모델 (API 데이터 + 커스텀 운동 통합)
class ExerciseDB {
  final String id;
  final String name;
  final String bodyPart; // API의 bodyPart (부위)
  final String equipment; // API의 equipment (장비)
  final String gifUrl;
  final String target; // 주요 타겟 근육
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final bool isCustom; // 커스텀 운동 여부

  ExerciseDB({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
    this.isCustom = false,
  });

  // targetPart: 운동 부위 (한국어)
  String get targetPart => getBodyPartKo(bodyPart);
  
  // equipmentType: 장비 타입 (한국어)
  String get equipmentType => getEquipmentKo(equipment);
  
  // 커스텀 운동 생성 팩토리
  factory ExerciseDB.custom({
    required String name,
    required String bodyPart,
    String equipment = 'body weight',
  }) {
    return ExerciseDB(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      bodyPart: bodyPart,
      equipment: equipment,
      gifUrl: '', // 커스텀 운동은 이미지 없음
      target: bodyPart,
      secondaryMuscles: [],
      instructions: [],
      isCustom: true,
    );
  }

  factory ExerciseDB.fromJson(Map<String, dynamic> json) {
    return ExerciseDB(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      equipment: json['equipment'] ?? '',
      gifUrl: json['gifUrl'] ?? '',
      target: json['target'] ?? '',
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'equipment': equipment,
      'gifUrl': gifUrl,
      'target': target,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
      'isCustom': isCustom,
    };
  }

  // 부위 매핑 (영어 -> 한국어)
  static String getBodyPartKo(String bodyPart) {
    const map = {
      'back': '등',
      'cardio': '유산소',
      'chest': '가슴',
      'lower arms': '팔',
      'lower legs': '하체',
      'neck': '스트레칭',
      'shoulders': '어깨',
      'upper arms': '팔',
      'upper legs': '하체',
      'waist': '복근',
    };
    return map[bodyPart] ?? bodyPart;
  }

  // 장비 매핑 (영어 -> 한국어)
  static String getEquipmentKo(String equipment) {
    const map = {
      'body weight': '맨몸',
      'machine': '머신',
      'barbell': '바벨',
      'dumbbell': '덤벨',
      'cable': '케이블',
      'resistance band': '밴드',
      'kettlebell': '케틀벨',
      'assisted': '보조',
      'leverage machine': '레버리지 머신',
      'stability ball': '짐볼',
      'ez barbell': 'EZ바',
      'trap bar': '트랩바',
      'roller': '롤러',
      'rope': '로프',
      'skierg machine': '스키에르그',
      'sled machine': '슬레드',
      'smith machine': '스미스 머신',
      'stationary bike': '실내 자전거',
      'tire': '타이어',
      'weighted': '웨이트',
      'wheel roller': '휠 롤러',
      'band': '밴드',
      'medicine ball': '메디신볼',
      'olympic barbell': '올림픽 바벨',
    };
    return map[equipment] ?? equipment;
  }
  
  // 카테고리 매핑 헬퍼
  static String getCategoryFromBodyPart(String bodyPart) {
    const map = {
      'back': '등',
      'cardio': '유산소',
      'chest': '가슴',
      'lower arms': '팔',
      'lower legs': '하체',
      'neck': '스트레칭',
      'shoulders': '어깨',
      'upper arms': '팔',
      'upper legs': '하체',
      'waist': '복근',
    };
    return map[bodyPart] ?? '전신';
  }
}
