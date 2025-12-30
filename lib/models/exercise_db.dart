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

  // targetPart: 운동 부위 (다국어 지원)
  String getTargetPart(String locale) => getBodyPartLocalized(bodyPart, locale);
  
  // equipmentType: 장비 타입 (다국어 지원)
  String getEquipmentType(String locale) => getEquipmentLocalized(equipment, locale);
  
  // 운동 이름 (다국어 지원)
  String getLocalizedName(String locale) => getExerciseNameLocalized(name, locale);
  
  // 타겟 근육 (다국어 지원)
  String getLocalizedTarget(String locale) => getMuscleNameLocalized(target, locale);
  
  // 보조 근육들 (다국어 지원)
  List<String> getLocalizedSecondaryMuscles(String locale) {
    return secondaryMuscles.map((muscle) => getMuscleNameLocalized(muscle, locale)).toList();
  }
  
  // 운동 설명 (다국어 지원)
  List<String> getLocalizedInstructions(String locale) {
    return getExerciseInstructionsLocalized(name, locale);
  }

  // 하위 호환성을 위한 기존 getter들 (한국어 기본)
  String get targetPart => getTargetPart('ko');
  String get equipmentType => getEquipmentType('ko');
  
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

  // 부위 매핑 (다국어 지원)
  static String getBodyPartLocalized(String bodyPart, String locale) {
    if (locale == 'ja') {
      const map = {
        'back': '背中',
        'cardio': '有酸素',
        'chest': '胸',
        'lower arms': '腕',
        'lower legs': '下半身',
        'neck': 'ストレッチ',
        'shoulders': '肩',
        'upper arms': '腕',
        'upper legs': '下半身',
        'waist': '腹筋',
      };
      return map[bodyPart] ?? bodyPart;
    } else if (locale == 'en') {
      const map = {
        'back': 'Back',
        'cardio': 'Cardio',
        'chest': 'Chest',
        'lower arms': 'Arms',
        'lower legs': 'Legs',
        'neck': 'Stretching',
        'shoulders': 'Shoulders',
        'upper arms': 'Arms',
        'upper legs': 'Legs',
        'waist': 'Abs',
      };
      return map[bodyPart] ?? bodyPart;
    } else {
      // 한국어 (기본)
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
  }

  // 장비 매핑 (다국어 지원)
  static String getEquipmentLocalized(String equipment, String locale) {
    if (locale == 'ja') {
      const map = {
        'body weight': '自重',
        'machine': 'マシン',
        'barbell': 'バーベル',
        'dumbbell': 'ダンベル',
        'cable': 'ケーブル',
        'resistance band': 'バンド',
        'kettlebell': 'ケトルベル',
        'assisted': 'アシスト',
        'leverage machine': 'レバレッジマシン',
        'stability ball': 'バランスボール',
        'ez barbell': 'EZバー',
        'trap bar': 'トラップバー',
        'roller': 'ローラー',
        'rope': 'ロープ',
        'skierg machine': 'スキーエルグ',
        'sled machine': 'スレッド',
        'smith machine': 'スミスマシン',
        'stationary bike': 'エアロバイク',
        'tire': 'タイヤ',
        'weighted': 'ウェイト',
        'wheel roller': 'ホイールローラー',
        'band': 'バンド',
        'medicine ball': 'メディシンボール',
        'olympic barbell': 'オリンピックバーベル',
      };
      return map[equipment] ?? equipment;
    } else if (locale == 'en') {
      const map = {
        'body weight': 'Bodyweight',
        'machine': 'Machine',
        'barbell': 'Barbell',
        'dumbbell': 'Dumbbell',
        'cable': 'Cable',
        'resistance band': 'Band',
        'kettlebell': 'Kettlebell',
        'assisted': 'Assisted',
        'leverage machine': 'Leverage Machine',
        'stability ball': 'Stability Ball',
        'ez barbell': 'EZ Barbell',
        'trap bar': 'Trap Bar',
        'roller': 'Roller',
        'rope': 'Rope',
        'skierg machine': 'SkiErg Machine',
        'sled machine': 'Sled Machine',
        'smith machine': 'Smith Machine',
        'stationary bike': 'Stationary Bike',
        'tire': 'Tire',
        'weighted': 'Weighted',
        'wheel roller': 'Wheel Roller',
        'band': 'Band',
        'medicine ball': 'Medicine Ball',
        'olympic barbell': 'Olympic Barbell',
      };
      return map[equipment] ?? equipment;
    } else {
      // 한국어 (기본)
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
  }

  // 근육명 매핑 (다국어 지원)
  static String getMuscleNameLocalized(String muscle, String locale) {
    if (locale == 'ja') {
      const map = {
        'abductors': '外転筋',
        'abs': '腹筋',
        'adductors': '内転筋',
        'biceps': '上腕二頭筋',
        'calves': 'ふくらはぎ',
        'cardiovascular system': '心血管系',
        'delts': '三角筋',
        'forearms': '前腕',
        'glutes': '臀筋',
        'hamstrings': 'ハムストリング',
        'lats': '広背筋',
        'levator scapulae': '肩甲挙筋',
        'pectorals': '胸筋',
        'quads': '大腿四頭筋',
        'serratus anterior': '前鋸筋',
        'spine': '脊柱',
        'traps': '僧帽筋',
        'triceps': '上腕三頭筋',
        'upper back': '上背部',
      };
      return map[muscle] ?? muscle;
    } else if (locale == 'en') {
      const map = {
        'abductors': 'Abductors',
        'abs': 'Abs',
        'adductors': 'Adductors',
        'biceps': 'Biceps',
        'calves': 'Calves',
        'cardiovascular system': 'Cardiovascular System',
        'delts': 'Delts',
        'forearms': 'Forearms',
        'glutes': 'Glutes',
        'hamstrings': 'Hamstrings',
        'lats': 'Lats',
        'levator scapulae': 'Levator Scapulae',
        'pectorals': 'Pectorals',
        'quads': 'Quads',
        'serratus anterior': 'Serratus Anterior',
        'spine': 'Spine',
        'traps': 'Traps',
        'triceps': 'Triceps',
        'upper back': 'Upper Back',
      };
      return map[muscle] ?? muscle;
    } else {
      // 한국어 (기본)
      const map = {
        'abductors': '외전근',
        'abs': '복근',
        'adductors': '내전근',
        'biceps': '이두근',
        'calves': '종아리',
        'cardiovascular system': '심혈관계',
        'delts': '삼각근',
        'forearms': '전완근',
        'glutes': '둔근',
        'hamstrings': '햄스트링',
        'lats': '광배근',
        'levator scapulae': '견갑거근',
        'pectorals': '가슴근',
        'quads': '대퇴사두근',
        'serratus anterior': '전거근',
        'spine': '척추',
        'traps': '승모근',
        'triceps': '삼두근',
        'upper back': '상부 등',
      };
      return map[muscle] ?? muscle;
    }
  }

  // 운동 이름 매핑 (다국어 지원) - 자동 번역 포함
  static String getExerciseNameLocalized(String exerciseName, String locale) {
    if (locale == 'ja') {
      // 직접 매핑된 운동들
      const directMap = {
        'Alternating Kettlebell Row': 'オルタネイティング ケトルベル ロウ',
        'Alternating Deltoid Raise': 'オルタネイティング デルトイド レイズ',
        'Alternating Kettlebell Press': 'オルタネイティング ケトルベル プレス',
        'Alternating Renegade Row': 'オルタネイティング レネゲード ロウ',
        'Anti-Gravity Press': 'アンチグラビティ プレス',
        'Arm Circles': 'アーム サークル',
        'Atlas Stone Trainer': 'アトラス ストーン トレーナー',
        'Push-up': 'プッシュアップ',
        'Pull-up': 'プルアップ',
        'Squat': 'スクワット',
        'Deadlift': 'デッドリフト',
        'Bench Press': 'ベンチプレス',
        'Overhead Press': 'オーバーヘッドプレス',
        'Barbell Row': 'バーベルロウ',
        'Dumbbell Curl': 'ダンベルカール',
        'Tricep Dip': 'トライセップディップ',
        'Plank': 'プランク',
        'Burpee': 'バーピー',
        'Mountain Climber': 'マウンテンクライマー',
        'Jumping Jack': 'ジャンピングジャック',
        'Lunge': 'ランジ',
        'Lateral Raise': 'ラテラル レイズ',
        'Front Raise': 'フロント レイズ',
        'Shoulder Press': 'ショルダー プレス',
        'Bicep Curl': 'バイセップ カール',
        'Tricep Extension': 'トライセップ エクステンション',
        'Chest Fly': 'チェスト フライ',
        'Leg Press': 'レッグ プレス',
        'Calf Raise': 'カーフ レイズ',
        'Hip Thrust': 'ヒップ スラスト',
        'Russian Twist': 'ロシアン ツイスト',
        'Sit-up': 'シットアップ',
        'Crunch': 'クランチ',
        '3/4 Sit-Up': '3/4 シットアップ',
        '90/90 Hamstring': '90/90 ハムストリング',
        'Ab Crunch Machine': 'アブ クランチ マシン',
      };
      
      // 직접 매핑이 있으면 사용
      if (directMap.containsKey(exerciseName)) {
        return directMap[exerciseName]!;
      }
      
      // 자동 번역 (단어별 치환)
      return _autoTranslateToJapanese(exerciseName);
    } else if (locale == 'en') {
      // 영어는 원본 그대로 반환
      return exerciseName;
    } else {
      // 한국어 (기본)
      const directMap = {
        'Alternating Kettlebell Row': '교대 케틀벨 로우',
        'Alternating Deltoid Raise': '교대 삼각근 레이즈',
        'Alternating Kettlebell Press': '교대 케틀벨 프레스',
        'Alternating Renegade Row': '교대 레네게이드 로우',
        'Anti-Gravity Press': '안티 그래비티 프레스',
        'Arm Circles': '팔 돌리기',
        'Atlas Stone Trainer': '아틀라스 스톤 트레이너',
        'Push-up': '푸시업',
        'Pull-up': '풀업',
        'Squat': '스쿼트',
        'Deadlift': '데드리프트',
        'Bench Press': '벤치프레스',
        'Overhead Press': '오버헤드 프레스',
        'Barbell Row': '바벨 로우',
        'Dumbbell Curl': '덤벨 컬',
        'Tricep Dip': '트라이셉 딥',
        'Plank': '플랭크',
        'Burpee': '버피',
        'Mountain Climber': '마운틴 클라이머',
        'Jumping Jack': '점핑잭',
        'Lunge': '런지',
        'Lateral Raise': '래터럴 레이즈',
        'Front Raise': '프론트 레이즈',
        'Shoulder Press': '숄더 프레스',
        'Bicep Curl': '바이셉 컬',
        'Tricep Extension': '트라이셉 익스텐션',
        'Chest Fly': '체스트 플라이',
        'Leg Press': '레그 프레스',
        'Calf Raise': '카프 레이즈',
        'Hip Thrust': '힙 스러스트',
        'Russian Twist': '러시안 트위스트',
        'Sit-up': '싯업',
        'Crunch': '크런치',
        '3/4 Sit-Up': '3/4 싯업',
        '90/90 Hamstring': '90/90 햄스트링',
        'Ab Crunch Machine': '복근 크런치 머신',
      };
      
      // 직접 매핑이 있으면 사용
      if (directMap.containsKey(exerciseName)) {
        return directMap[exerciseName]!;
      }
      
      // 자동 번역 (단어별 치환)
      return _autoTranslateToKorean(exerciseName);
    }
  }

  // 일본어 자동 번역 헬퍼 (영어 → 카타카나 발음)
  static String _autoTranslateToJapanese(String exerciseName) {
    const wordMap = {
      // A
      'ab': 'アブ', 'abductor': 'アブダクター', 'above': 'アバブ', 'acceleration': 'アクセラレーション',
      'achilles': 'アキレス', 'across': 'アクロス', 'adduction': 'アダクション', 'adductions': 'アダクションズ',
      'adductor': 'アダクター', 'advanced': 'アドバンスド', 'against': 'アゲインスト', 'air': 'エアー',
      'all': 'オール', 'alternate': 'オルタネイト', 'alternating': 'オルタネイティング', 'an': 'アン',
      'and': 'アンド', 'ankle': 'アンクル', 'anterior': 'アンテリア', 'anti': 'アンチ', 'apart': 'アパート',
      'arm': 'アーム', 'arnold': 'アーノルド', 'around': 'アラウンド', 'assisted': 'アシステッド',
      'at': 'アット', 'atlas': 'アトラス', 'attachment': 'アタッチメント', 'axle': 'アクスル',
      // B
      'back': 'バック', 'backward': 'バックワード', 'bag': 'バッグ', 'balance': 'バランス', 'ball': 'ボール',
      'band': 'バンド', 'bands': 'バンズ', 'bar': 'バー', 'barbell': 'バーベル', 'bars': 'バーズ',
      'battling': 'バトリング', 'bear': 'ベアー', 'behind': 'ビハインド', 'bell': 'ベル', 'below': 'ビロウ',
      'bench': 'ベンチ', 'bend': 'ベンド', 'bends': 'ベンズ', 'bent': 'ベント', 'between': 'ビトウィーン',
      'bicep': 'バイセップ', 'biceps': 'バイセップス', 'bicycling': 'バイシクリング', 'bike': 'バイク',
      'blocks': 'ブロックス', 'board': 'ボード', 'body': 'ボディ', 'bodyweight': 'ボディウェイト',
      'bosu': 'ボス', 'bottoms': 'ボトムズ', 'bound': 'バウンド', 'box': 'ボックス', 'brachialis': 'ブラキアリス',
      'bradford': 'ブラッドフォード', 'bridge': 'ブリッジ', 'bridges': 'ブリッジズ', 'bug': 'バグ',
      'butt': 'バット', 'butterfly': 'バタフライ',
      // C
      'cable': 'ケーブル', 'calf': 'カーフ', 'calves': 'カーブス', 'cambered': 'キャンバード', 'car': 'カー',
      'carioca': 'カリオカ', 'carry': 'キャリー', 'caster': 'キャスター', 'cat': 'キャット', 'catch': 'キャッチ',
      'ceiling': 'シーリング', 'chain': 'チェーン', 'chains': 'チェーンズ', 'chair': 'チェアー',
      'chest': 'チェスト', "child's": 'チャイルズ', 'chin': 'チン', 'chins': 'チンズ', 'chop': 'チョップ',
      'circles': 'サークルズ', 'circus': 'サーカス', 'claw': 'クロー', 'clean': 'クリーン', 'climb': 'クライム',
      'climbers': 'クライマーズ', 'clock': 'クロック', 'close': 'クローズ', 'cocoons': 'コクーンズ',
      "conan's": 'コナンズ', 'concentration': 'コンセントレーション', 'cone': 'コーン', 'crawl': 'クロール',
      'cross': 'クロス', 'crosses': 'クロッシーズ', 'crossover': 'クロスオーバー', 'crucifix': 'クルシフィックス',
      'crunch': 'クランチ', 'crunches': 'クランチーズ', 'crusher': 'クラッシャー', 'cuban': 'キューバン',
      'curl': 'カール', 'curls': 'カールズ',
      // D
      'db': 'DB', "dancer's": 'ダンサーズ', 'dead': 'デッド', 'deadlift': 'デッドリフト', 'deadlifts': 'デッドリフツ',
      'decline': 'デクライン', 'deficit': 'デフィシット', 'delivery': 'デリバリー', 'delt': 'デルト',
      'deltoid': 'デルトイド', 'depth': 'デプス', 'diagonal': 'ダイアゴナル', 'dip': 'ディップ', 'dips': 'ディップス',
      'donkey': 'ドンキー', 'dorsi': 'ドーシ', 'double': 'ダブル', 'down': 'ダウン', 'downward': 'ダウンワード',
      'drag': 'ドラッグ', 'drags': 'ドラッグス', 'drill': 'ドリル', 'drivers': 'ドライバーズ', 'drop': 'ドロップ',
      'dumbbell': 'ダンベル', 'dumbbells': 'ダンベルズ', 'dynamic': 'ダイナミック',
      // E
      'ez': 'EZ', 'elbow': 'エルボー', 'elbows': 'エルボーズ', 'elevated': 'エレベーテッド',
      'elliptical': 'エリプティカル', 'exercise': 'エクササイズ', 'extended': 'エクステンデッド',
      'extension': 'エクステンション', 'extensions': 'エクステンションズ', 'external': 'エクスターナル',
      // F
      'face': 'フェイス', 'facing': 'フェイシング', 'fallout': 'フォールアウト', "farmer's": 'ファーマーズ',
      'fast': 'ファスト', 'feet': 'フィート', 'figure': 'フィギュア', 'finger': 'フィンガー', 'flat': 'フラット',
      'flexion': 'フレクション', 'flexor': 'フレクサー', 'flexors': 'フレクサーズ', 'flip': 'フリップ',
      'floor': 'フロア', 'flutter': 'フラッター', 'fly': 'フライ', 'flye': 'フライ', 'flyes': 'フライズ',
      'foot': 'フット', 'forearm': 'フォアアーム', 'forward': 'フォワード', 'fours': 'フォーズ',
      'frankenstein': 'フランケンシュタイン', 'freehand': 'フリーハンド', 'frog': 'フロッグ', 'from': 'フロム',
      'front': 'フロント', 'full': 'フル',
      // G
      'gastrocnemius': 'ガストロクネミウス', 'get': 'ゲット', 'gironda': 'ジロンダ', 'glute': 'グルート',
      'goblet': 'ゴブレット', 'good': 'グッド', 'gorilla': 'ゴリラ', 'grab': 'グラブ', 'gravity': 'グラビティ',
      'greatest': 'グレイテスト', 'grip': 'グリップ', 'groin': 'グロイン', 'groiners': 'グロイナーズ',
      'guillotine': 'ギロチン',
      // H
      'hack': 'ハック', 'half': 'ハーフ', 'ham': 'ハム', 'hammer': 'ハンマー', 'hamstring': 'ハムストリング',
      'hand': 'ハンド', 'handed': 'ハンデッド', 'handle': 'ハンドル', 'hands': 'ハンズ', 'handstand': 'ハンドスタンド',
      'hang': 'ハング', 'hanging': 'ハンギング', 'harness': 'ハーネス', 'head': 'ヘッド', 'heaving': 'ヒービング',
      'heavy': 'ヘビー', 'heel': 'ヒール', 'high': 'ハイ', 'hip': 'ヒップ', 'hop': 'ホップ', 'hops': 'ホップス',
      'hug': 'ハグ', 'hurdle': 'ハードル', 'hyperextension': 'ハイパーエクステンション',
      'hyperextensions': 'ハイパーエクステンションズ',
      // I
      'it': 'IT', 'iliotibial': 'イリオティビアル', 'in': 'イン', 'inchworm': 'インチワーム', 'incline': 'インクライン',
      'inner': 'インナー', 'intermediate': 'インターミディエイト', 'internal': 'インターナル', 'into': 'イントゥ',
      'inverted': 'インバーテッド', 'iron': 'アイアン', 'iso': 'アイソ', 'isometric': 'アイソメトリック',
      // J
      'jm': 'JM', 'jackknife': 'ジャックナイフ', 'jammer': 'ジャマー', 'janda': 'ジャンダ', 'jefferson': 'ジェファーソン',
      'jerk': 'ジャーク', 'jogging': 'ジョギング', 'judo': 'ジュードー', 'jump': 'ジャンプ', 'jumping': 'ジャンピング',
      // K
      'keg': 'ケグ', 'kettlebell': 'ケトルベル', 'kettlebells': 'ケトルベルズ', 'kick': 'キック',
      'kickback': 'キックバック', 'kicks': 'キックス', 'kipping': 'キッピング', 'knee': 'ニー',
      'kneeling': 'ニーリング', 'knees': 'ニーズ',
      // L
      'landmine': 'ランドマイン', 'lat': 'ラット', 'lateral': 'ラテラル', 'laterals': 'ラテラルズ',
      'latissimus': 'ラティシマス', 'leap': 'リープ', 'leg': 'レッグ', 'legged': 'レッグド', 'legs': 'レッグス',
      'leverage': 'レバレッジ', 'lift': 'リフト', 'linear': 'リニア', 'load': 'ロード', 'locust': 'ロカスト',
      'log': 'ログ', 'london': 'ロンドン', 'long': 'ロング', 'looking': 'ルッキング', 'low': 'ロー',
      'lower': 'ロワー', 'lunge': 'ランジ', 'lunges': 'ランジーズ', 'lying': 'ライイング',
      // M
      'machine': 'マシン', 'manual': 'マニュアル', 'medicine': 'メディシン', 'medium': 'ミディアム', 'mid': 'ミッド',
      'middle': 'ミドル', 'military': 'ミリタリー', 'mill': 'ミル', 'mixed': 'ミックスド', 'monster': 'モンスター',
      'morning': 'モーニング', 'mornings': 'モーニングス', 'motion': 'モーション', 'mountain': 'マウンテン',
      'movers': 'ムーバーズ', 'moving': 'ムービング', 'multiple': 'マルチプル', 'muscle': 'マッスル',
      // N
      'narrow': 'ナロー', 'natural': 'ナチュラル', 'neck': 'ネック', 'neutral': 'ニュートラル', 'no': 'ノー',
      // O
      'oblique': 'オブリーク', 'of': 'オブ', 'olympic': 'オリンピック', 'on': 'オン', 'one': 'ワン', 'open': 'オープン',
      'otis': 'オーティス', 'over': 'オーバー', 'overhead': 'オーバーヘッド',
      // P
      'pallof': 'パロフ', 'palm': 'パーム', 'palms': 'パームズ', 'para': 'パラ', 'parallel': 'パラレル',
      'part': 'パート', 'partials': 'パーシャルズ', 'pass': 'パス', 'pelvic': 'ペルビック', 'peroneals': 'ペロネアルズ',
      'physioball': 'フィジオボール', 'pike': 'パイク', 'pin': 'ピン', 'pinch': 'ピンチ', 'pins': 'ピンズ',
      'pirate': 'パイレート', 'piriformis': 'ピリフォーミス', 'pistol': 'ピストル', 'plank': 'プランク',
      'plate': 'プレート', 'platform': 'プラットフォーム', 'plie': 'プリエ', 'plyo': 'プライオ', 'pose': 'ポーズ',
      'position': 'ポジション', 'positions': 'ポジションズ', 'posterior': 'ポステリア', 'power': 'パワー',
      'powerlifting': 'パワーリフティング', 'preacher': 'プリーチャー', 'press': 'プレス', 'presses': 'プレッシーズ',
      'progression': 'プログレッション', 'pronated': 'プロネイテッド', 'pronation': 'プロネーション',
      'prone': 'プローン', 'prowler': 'プロウラー', 'pull': 'プル', 'pulldown': 'プルダウン', 'pulldowns': 'プルダウンズ',
      'pulley': 'プーリー', 'pullover': 'プルオーバー', 'pulls': 'プルズ', 'pullup': 'プルアップ', 'pullups': 'プルアップス',
      'push': 'プッシュ', 'pushdown': 'プッシュダウン', 'pushups': 'プッシュアップス', 'pyramid': 'ピラミッド',
      // Q
      'quad': 'クワッド', 'quadriceps': 'クワッドリセップス', 'quick': 'クイック',
      // R
      'rack': 'ラック', 'raise': 'レイズ', 'raises': 'レイズ', 'range': 'レンジ', 'rear': 'リア',
      'recumbent': 'リカンベント', 'release': 'リリース', 'renegade': 'レネゲード', 'resistance': 'レジスタンス',
      'response': 'レスポンス', 'return': 'リターン', 'reverse': 'リバース', 'rhomboids': 'ロンボイズ',
      'rickshaw': 'リキシャ', 'ring': 'リング', 'rocket': 'ロケット', 'rocking': 'ロッキング', 'rocky': 'ロッキー',
      'roller': 'ローラー', 'rollout': 'ロールアウト', 'romanian': 'ルーマニアン', 'rope': 'ロープ', 'ropes': 'ロープス',
      'rotation': 'ローテーション', 'rotations': 'ローテーションズ', 'round': 'ラウンド', 'row': 'ロウ',
      'rowing': 'ローイング', 'rows': 'ロウズ', 'run': 'ラン', "runner's": 'ランナーズ', 'running': 'ランニング',
      'russian': 'ロシアン',
      // S
      'smr': 'SMR', 'sandbag': 'サンドバッグ', 'saw': 'ソー', 'scaption': 'スキャプション', 'scapular': 'スキャプラー',
      'scissor': 'シザー', 'scissors': 'シザーズ', 'scoop': 'スクープ', 'seated': 'シーテッド', 'see': 'シー',
      'seesaw': 'シーソー', 'series': 'シリーズ', 'ships': 'シップス', 'shotgun': 'ショットガン', 'shoulder': 'ショルダー',
      'shrug': 'シュラッグ', 'shrugs': 'シュラッグス', 'shuffle': 'シャッフル', 'side': 'サイド', 'sides': 'サイズ',
      'single': 'シングル', 'sissy': 'シシー', 'sit': 'シット', 'skating': 'スケーティング', 'skip': 'スキップ',
      'skipping': 'スキッピング', 'skull': 'スカル', 'skullcrusher': 'スカルクラッシャー', 'slam': 'スラム',
      'sled': 'スレッド', 'sledgehammer': 'スレッジハンマー', 'slides': 'スライズ', 'smith': 'スミス',
      'snatch': 'スナッチ', 'soleus': 'ソレウス', 'speed': 'スピード', 'spell': 'スペル', 'spider': 'スパイダー',
      'spinal': 'スパイナル', 'split': 'スプリット', 'sprint': 'スプリント', 'sprints': 'スプリンツ',
      'squat': 'スクワット', 'squats': 'スクワッツ', 'squeeze': 'スクイーズ', 'squeezes': 'スクイーズィズ',
      'stability': 'スタビリティ', 'stairmaster': 'ステアマスター', 'stairs': 'ステアーズ', 'stance': 'スタンス',
      'standing': 'スタンディング', 'star': 'スター', 'start': 'スタート', 'stationary': 'ステーショナリー',
      'step': 'ステップ', 'sternum': 'スターナム', 'stiff': 'スティッフ', 'stomach': 'ストマック', 'stone': 'ストーン',
      'stones': 'ストーンズ', 'straddle': 'ストラドル', 'straight': 'ストレート', 'straps': 'ストラップス',
      'stretch': 'ストレッチ', 'stride': 'ストライド', 'sumo': 'スモウ', 'superman': 'スーパーマン',
      'supinated': 'スピネイテッド', 'supination': 'スピネーション', 'supine': 'スパイン', 'suspended': 'サスペンデッド',
      'svend': 'スベンド', 'swing': 'スイング', 'swings': 'スイングス',
      // T
      't': 'T', 'tate': 'テイト', 'technique': 'テクニック', 'the': 'ザ', 'thigh': 'サイ', 'through': 'スルー',
      'throw': 'スロー', 'thrust': 'スラスト', 'thruster': 'スラスター', 'tibialis': 'ティビアリス', 'tilt': 'ティルト',
      'tire': 'タイヤ', 'to': 'トゥ', 'toe': 'トー', 'torso': 'トルソー', 'touchers': 'タッチャーズ',
      'touches': 'タッチーズ', 'towel': 'タオル', 'tract': 'トラクト', 'trail': 'トレイル', 'trainer': 'トレーナー',
      'trap': 'トラップ', 'treadmill': 'トレッドミル', 'tricep': 'トライセップ', 'triceps': 'トライセップス',
      'tuck': 'タック', 'tucks': 'タックス', 'turkish': 'ターキッシュ', 'twist': 'ツイスト', 'twists': 'ツイスツ',
      'two': 'ツー',
      // U
      'underhand': 'アンダーハンド', 'up': 'アップ', 'upper': 'アッパー', 'upright': 'アップライト', 'ups': 'アップス',
      'upward': 'アップワード',
      // V
      'v': 'V', 'vacuum': 'バキューム', 'version': 'バージョン', 'vertical': 'バーティカル',
      // W
      'walk': 'ウォーク', 'walking': 'ウォーキング', 'wall': 'ウォール', 'weighted': 'ウェイテッド', 'wheel': 'ホイール',
      'wide': 'ワイド', 'wind': 'ウィンド', 'windmill': 'ウィンドミル', 'windmills': 'ウィンドミルズ', 'wipers': 'ワイパーズ',
      'with': 'ウィズ', 'wood': 'ウッド', 'world': 'ワールド', "world's": 'ワールズ', 'worlds': 'ワールズ', 'wrist': 'リスト',
      // Y
      'yoke': 'ヨーク', 'your': 'ユア',
      // Z
      'zercher': 'ザーチャー', 'zottman': 'ゾットマン',
    };
    
    // 단어 단위로 분리하여 처리
    final words = exerciseName.split(RegExp(r'(\s+|(?=[-()]))|(?<=[-()])'));
    final translatedWords = <String>[];
    
    for (final word in words) {
      if (word.trim().isEmpty) {
        translatedWords.add(word);
        continue;
      }
      
      final lowerWord = word.toLowerCase();
      if (wordMap.containsKey(lowerWord)) {
        translatedWords.add(wordMap[lowerWord]!);
      } else {
        translatedWords.add(word);
      }
    }
    
    return translatedWords.join('');
  }

  // 한국어 자동 번역 헬퍼 (영어 → 한글 발음)
  static String _autoTranslateToKorean(String exerciseName) {
    const wordMap = {
      // A
      'ab': '앱', 'abductor': '앱덕터', 'above': '어보브', 'acceleration': '액셀러레이션',
      'achilles': '아킬레스', 'across': '어크로스', 'adduction': '어덕션', 'adductions': '어덕션즈',
      'adductor': '어덕터', 'advanced': '어드밴스드', 'against': '어겐스트', 'air': '에어',
      'all': '올', 'alternate': '얼터네이트', 'alternating': '얼터네이팅', 'an': '언',
      'and': '앤드', 'ankle': '앵클', 'anterior': '안테리어', 'anti': '안티', 'apart': '어파트',
      'arm': '암', 'arnold': '아놀드', 'around': '어라운드', 'assisted': '어시스티드',
      'at': '앳', 'atlas': '아틀라스', 'attachment': '어태치먼트', 'axle': '액슬',
      // B
      'back': '백', 'backward': '백워드', 'bag': '백', 'balance': '밸런스', 'ball': '볼',
      'band': '밴드', 'bands': '밴즈', 'bar': '바', 'barbell': '바벨', 'bars': '바즈',
      'battling': '배틀링', 'bear': '베어', 'behind': '비하인드', 'bell': '벨', 'below': '빌로우',
      'bench': '벤치', 'bend': '벤드', 'bends': '벤즈', 'bent': '벤트', 'between': '비트윈',
      'bicep': '바이셉', 'biceps': '바이셉스', 'bicycling': '바이시클링', 'bike': '바이크',
      'blocks': '블록스', 'board': '보드', 'body': '바디', 'bodyweight': '바디웨이트',
      'bosu': '보수', 'bottoms': '바텀즈', 'bound': '바운드', 'box': '박스', 'brachialis': '브라키알리스',
      'bradford': '브래드포드', 'bridge': '브릿지', 'bridges': '브릿지즈', 'bug': '버그',
      'butt': '버트', 'butterfly': '버터플라이',
      // C
      'cable': '케이블', 'calf': '카프', 'calves': '카브스', 'cambered': '캠버드', 'car': '카',
      'carioca': '카리오카', 'carry': '캐리', 'caster': '캐스터', 'cat': '캣', 'catch': '캐치',
      'ceiling': '실링', 'chain': '체인', 'chains': '체인즈', 'chair': '체어',
      'chest': '체스트', "child's": '차일즈', 'chin': '친', 'chins': '친즈', 'chop': '촙',
      'circles': '서클즈', 'circus': '서커스', 'claw': '클로', 'clean': '클린', 'climb': '클라임',
      'climbers': '클라이머즈', 'clock': '클락', 'close': '클로즈', 'cocoons': '코쿤즈',
      "conan's": '코난즈', 'concentration': '컨센트레이션', 'cone': '콘', 'crawl': '크롤',
      'cross': '크로스', 'crosses': '크로시즈', 'crossover': '크로스오버', 'crucifix': '크루시픽스',
      'crunch': '크런치', 'crunches': '크런치즈', 'crusher': '크러셔', 'cuban': '큐반',
      'curl': '컬', 'curls': '컬즈',
      // D
      'db': 'DB', "dancer's": '댄서즈', 'dead': '데드', 'deadlift': '데드리프트', 'deadlifts': '데드리프츠',
      'decline': '디클라인', 'deficit': '데피싯', 'delivery': '딜리버리', 'delt': '델트',
      'deltoid': '델토이드', 'depth': '뎁스', 'diagonal': '다이어고널', 'dip': '딥', 'dips': '딥스',
      'donkey': '동키', 'dorsi': '도시', 'double': '더블', 'down': '다운', 'downward': '다운워드',
      'drag': '드래그', 'drags': '드래그스', 'drill': '드릴', 'drivers': '드라이버즈', 'drop': '드롭',
      'dumbbell': '덤벨', 'dumbbells': '덤벨즈', 'dynamic': '다이나믹',
      // E
      'ez': 'EZ', 'elbow': '엘보', 'elbows': '엘보즈', 'elevated': '엘리베이티드',
      'elliptical': '일립티컬', 'exercise': '엑서사이즈', 'extended': '익스텐디드',
      'extension': '익스텐션', 'extensions': '익스텐션즈', 'external': '익스터널',
      // F
      'face': '페이스', 'facing': '페이싱', 'fallout': '폴아웃', "farmer's": '파머즈',
      'fast': '패스트', 'feet': '피트', 'figure': '피겨', 'finger': '핑거', 'flat': '플랫',
      'flexion': '플렉션', 'flexor': '플렉서', 'flexors': '플렉서즈', 'flip': '플립',
      'floor': '플로어', 'flutter': '플러터', 'fly': '플라이', 'flye': '플라이', 'flyes': '플라이즈',
      'foot': '풋', 'forearm': '포어암', 'forward': '포워드', 'fours': '포즈',
      'frankenstein': '프랑켄슈타인', 'freehand': '프리핸드', 'frog': '프로그', 'from': '프롬',
      'front': '프론트', 'full': '풀',
      // G
      'gastrocnemius': '가스트로크네미우스', 'get': '겟', 'gironda': '지론다', 'glute': '글루트',
      'goblet': '고블렛', 'good': '굿', 'gorilla': '고릴라', 'grab': '그랩', 'gravity': '그래비티',
      'greatest': '그레이티스트', 'grip': '그립', 'groin': '그로인', 'groiners': '그로이너즈',
      'guillotine': '길로틴',
      // H
      'hack': '핵', 'half': '하프', 'ham': '햄', 'hammer': '해머', 'hamstring': '햄스트링',
      'hand': '핸드', 'handed': '핸디드', 'handle': '핸들', 'hands': '핸즈', 'handstand': '핸드스탠드',
      'hang': '행', 'hanging': '행잉', 'harness': '하네스', 'head': '헤드', 'heaving': '히빙',
      'heavy': '헤비', 'heel': '힐', 'high': '하이', 'hip': '힙', 'hop': '홉', 'hops': '홉스',
      'hug': '허그', 'hurdle': '허들', 'hyperextension': '하이퍼익스텐션',
      'hyperextensions': '하이퍼익스텐션즈',
      // I
      'it': 'IT', 'iliotibial': '일리오티비알', 'in': '인', 'inchworm': '인치웜', 'incline': '인클라인',
      'inner': '이너', 'intermediate': '인터미디에이트', 'internal': '인터널', 'into': '인투',
      'inverted': '인버티드', 'iron': '아이언', 'iso': '아이소', 'isometric': '아이소메트릭',
      // J
      'jm': 'JM', 'jackknife': '잭나이프', 'jammer': '재머', 'janda': '잔다', 'jefferson': '제퍼슨',
      'jerk': '저크', 'jogging': '조깅', 'judo': '유도', 'jump': '점프', 'jumping': '점핑',
      // K
      'keg': '케그', 'kettlebell': '케틀벨', 'kettlebells': '케틀벨즈', 'kick': '킥',
      'kickback': '킥백', 'kicks': '킥스', 'kipping': '키핑', 'knee': '니',
      'kneeling': '닐링', 'knees': '니즈',
      // L
      'landmine': '랜드마인', 'lat': '랫', 'lateral': '래터럴', 'laterals': '래터럴즈',
      'latissimus': '라티시무스', 'leap': '립', 'leg': '레그', 'legged': '레그드', 'legs': '레그스',
      'leverage': '레버리지', 'lift': '리프트', 'linear': '리니어', 'load': '로드', 'locust': '로커스트',
      'log': '로그', 'london': '런던', 'long': '롱', 'looking': '루킹', 'low': '로우',
      'lower': '로워', 'lunge': '런지', 'lunges': '런지즈', 'lying': '라잉',
      // M
      'machine': '머신', 'manual': '매뉴얼', 'medicine': '메디신', 'medium': '미디엄', 'mid': '미드',
      'middle': '미들', 'military': '밀리터리', 'mill': '밀', 'mixed': '믹스드', 'monster': '몬스터',
      'morning': '모닝', 'mornings': '모닝스', 'motion': '모션', 'mountain': '마운틴',
      'movers': '무버즈', 'moving': '무빙', 'multiple': '멀티플', 'muscle': '머슬',
      // N
      'narrow': '내로우', 'natural': '내추럴', 'neck': '넥', 'neutral': '뉴트럴', 'no': '노',
      // O
      'oblique': '오블리크', 'of': '오브', 'olympic': '올림픽', 'on': '온', 'one': '원', 'open': '오픈',
      'otis': '오티스', 'over': '오버', 'overhead': '오버헤드',
      // P
      'pallof': '팔로프', 'palm': '팜', 'palms': '팜즈', 'para': '파라', 'parallel': '패러렐',
      'part': '파트', 'partials': '파셜즈', 'pass': '패스', 'pelvic': '펠빅', 'peroneals': '페로니얼즈',
      'physioball': '피지오볼', 'pike': '파이크', 'pin': '핀', 'pinch': '핀치', 'pins': '핀즈',
      'pirate': '파이럿', 'piriformis': '피리포미스', 'pistol': '피스톨', 'plank': '플랭크',
      'plate': '플레이트', 'platform': '플랫폼', 'plie': '플리에', 'plyo': '플라이오', 'pose': '포즈',
      'position': '포지션', 'positions': '포지션즈', 'posterior': '포스테리어', 'power': '파워',
      'powerlifting': '파워리프팅', 'preacher': '프리처', 'press': '프레스', 'presses': '프레시즈',
      'progression': '프로그레션', 'pronated': '프로네이티드', 'pronation': '프로네이션',
      'prone': '프론', 'prowler': '프로울러', 'pull': '풀', 'pulldown': '풀다운', 'pulldowns': '풀다운즈',
      'pulley': '풀리', 'pullover': '풀오버', 'pulls': '풀즈', 'pullup': '풀업', 'pullups': '풀업스',
      'push': '푸시', 'pushdown': '푸시다운', 'pushups': '푸시업스', 'pyramid': '피라미드',
      // Q
      'quad': '쿼드', 'quadriceps': '쿼드리셉스', 'quick': '퀵',
      // R
      'rack': '랙', 'raise': '레이즈', 'raises': '레이즈', 'range': '레인지', 'rear': '리어',
      'recumbent': '리컴번트', 'release': '릴리즈', 'renegade': '레네게이드', 'resistance': '레지스턴스',
      'response': '리스폰스', 'return': '리턴', 'reverse': '리버스', 'rhomboids': '롬보이즈',
      'rickshaw': '릭쇼', 'ring': '링', 'rocket': '로켓', 'rocking': '로킹', 'rocky': '로키',
      'roller': '롤러', 'rollout': '롤아웃', 'romanian': '루마니안', 'rope': '로프', 'ropes': '로프스',
      'rotation': '로테이션', 'rotations': '로테이션즈', 'round': '라운드', 'row': '로우',
      'rowing': '로잉', 'rows': '로우즈', 'run': '런', "runner's": '러너즈', 'running': '러닝',
      'russian': '러시안',
      // S
      'smr': 'SMR', 'sandbag': '샌드백', 'saw': '쏘', 'scaption': '스캡션', 'scapular': '스캐풀러',
      'scissor': '시저', 'scissors': '시저즈', 'scoop': '스쿱', 'seated': '시티드', 'see': '시',
      'seesaw': '시소', 'series': '시리즈', 'ships': '쉽스', 'shotgun': '샷건', 'shoulder': '숄더',
      'shrug': '슈러그', 'shrugs': '슈러그스', 'shuffle': '셔플', 'side': '사이드', 'sides': '사이즈',
      'single': '싱글', 'sissy': '시시', 'sit': '싯', 'skating': '스케이팅', 'skip': '스킵',
      'skipping': '스키핑', 'skull': '스컬', 'skullcrusher': '스컬크러셔', 'slam': '슬램',
      'sled': '슬레드', 'sledgehammer': '슬레지해머', 'slides': '슬라이즈', 'smith': '스미스',
      'snatch': '스내치', 'soleus': '솔레우스', 'speed': '스피드', 'spell': '스펠', 'spider': '스파이더',
      'spinal': '스파이널', 'split': '스플릿', 'sprint': '스프린트', 'sprints': '스프린츠',
      'squat': '스쿼트', 'squats': '스쿼츠', 'squeeze': '스퀴즈', 'squeezes': '스퀴지즈',
      'stability': '스태빌리티', 'stairmaster': '스테어마스터', 'stairs': '스테어즈', 'stance': '스탠스',
      'standing': '스탠딩', 'star': '스타', 'start': '스타트', 'stationary': '스테이셔너리',
      'step': '스텝', 'sternum': '스터넘', 'stiff': '스티프', 'stomach': '스토막', 'stone': '스톤',
      'stones': '스톤즈', 'straddle': '스트래들', 'straight': '스트레이트', 'straps': '스트랩스',
      'stretch': '스트레치', 'stride': '스트라이드', 'sumo': '스모', 'superman': '슈퍼맨',
      'supinated': '수피네이티드', 'supination': '수피네이션', 'supine': '수파인', 'suspended': '서스펜디드',
      'svend': '스벤드', 'swing': '스윙', 'swings': '스윙스',
      // T
      't': 'T', 'tate': '테이트', 'technique': '테크닉', 'the': '더', 'thigh': '싸이', 'through': '스루',
      'throw': '스로우', 'thrust': '스러스트', 'thruster': '스러스터', 'tibialis': '티비알리스', 'tilt': '틸트',
      'tire': '타이어', 'to': '투', 'toe': '토', 'torso': '토르소', 'touchers': '터처즈',
      'touches': '터치즈', 'towel': '타월', 'tract': '트랙트', 'trail': '트레일', 'trainer': '트레이너',
      'trap': '트랩', 'treadmill': '트레드밀', 'tricep': '트라이셉', 'triceps': '트라이셉스',
      'tuck': '턱', 'tucks': '턱스', 'turkish': '터키시', 'twist': '트위스트', 'twists': '트위스츠',
      'two': '투',
      // U
      'underhand': '언더핸드', 'up': '업', 'upper': '어퍼', 'upright': '업라이트', 'ups': '업스',
      'upward': '업워드',
      // V
      'v': 'V', 'vacuum': '배큠', 'version': '버전', 'vertical': '버티컬',
      // W
      'walk': '워크', 'walking': '워킹', 'wall': '월', 'weighted': '웨이티드', 'wheel': '휠',
      'wide': '와이드', 'wind': '윈드', 'windmill': '윈드밀', 'windmills': '윈드밀즈', 'wipers': '와이퍼즈',
      'with': '위드', 'wood': '우드', 'world': '월드', "world's": '월즈', 'worlds': '월즈', 'wrist': '리스트',
      // Y
      'yoke': '요크', 'your': '유어',
      // Z
      'zercher': '저처', 'zottman': '조트만',
    };
    
    // 단어 단위로 분리하여 처리
    final words = exerciseName.split(RegExp(r'(\s+|(?=[-()]))|(?<=[-()])'));
    final translatedWords = <String>[];
    
    for (final word in words) {
      if (word.trim().isEmpty) {
        translatedWords.add(word);
        continue;
      }
      
      final lowerWord = word.toLowerCase();
      if (wordMap.containsKey(lowerWord)) {
        translatedWords.add(wordMap[lowerWord]!);
      } else {
        translatedWords.add(word);
      }
    }
    
    return translatedWords.join('');
  }

  // 운동 설명 매핑 (다국어 지원) - 주요 운동들만 매핑
  static List<String> getExerciseInstructionsLocalized(String exerciseName, String locale) {
    if (locale == 'ja') {
      const map = {
        'Alternating Kettlebell Row': [
          '足の前に2つのケトルベルを置きます。膝を軽く曲げ、お尻をできるだけ突き出します。前かがみになってスタートポジションに入り、両方のケトルベルをハンドルで掴みます。',
          '片方のケトルベルを床から持ち上げながら、もう片方のケトルベルを持ち続けます。肩甲骨を引き寄せ、肘を曲げながら作業側のケトルベルを胃やリブケージに向かって引きます。',
          '作業腕のケトルベルを下げ、反対の腕で繰り返します。'
        ],
        'Alternating Deltoid Raise': [
          '両手にダンベルを持ち、足を肩幅に開いて立ちます。',
          '片腕ずつ交互に、ダンベルを肩の高さまで横に上げます。',
          'ゆっくりと元の位置に戻し、反対の腕で繰り返します。'
        ],
        'Alternating Kettlebell Press': [
          '両手にケトルベルを持ち、肩の位置にセットします。',
          '片腕ずつ交互に、ケトルベルを頭上に押し上げます。',
          'ゆっくりと元の位置に戻し、反対の腕で繰り返します。'
        ],
        'Anti-Gravity Press': [
          '仰向けに寝て、膝を90度に曲げます。',
          '重りを胸の上で押し上げる動作を行います。',
          'ゆっくりと元の位置に戻します。'
        ],
        'Arm Circles': [
          '腕を横に伸ばし、肩の高さに保ちます。',
          '小さな円を描くように腕を回します。',
          '前回し、後ろ回しを交互に行います。'
        ],
        'Push-up': [
          '腕立て伏せの姿勢になります。',
          '胸が床に近づくまで体を下げます。',
          '元の位置まで体を押し上げます。'
        ],
        'Pull-up': [
          '鉄棒にぶら下がります。',
          '顎が鉄棒を越えるまで体を引き上げます。',
          'ゆっくりと元の位置に戻します。'
        ],
      };
      return map[exerciseName] ?? ['運動方法の説明がありません。'];
    } else if (locale == 'en') {
      // 영어는 원본 instructions 사용 (API에서 제공)
      return [];
    } else {
      // 한국어 (기본)
      const map = {
        'Alternating Kettlebell Row': [
          '발 앞에 두 개의 케틀벨을 놓습니다. 무릎을 살짝 구부리고 엉덩이를 최대한 뒤로 빼세요. 몸을 앞으로 숙여 시작 자세를 취하고 양손으로 케틀벨 손잡이를 잡습니다.',
          '한쪽 케틀벨을 바닥에서 들어올리면서 다른 케틀벨을 계속 잡고 있습니다. 견갑골을 모으고 팔꿈치를 구부리면서 작업하는 쪽 케틀벨을 복부나 갈비뼈 쪽으로 당깁니다.',
          '작업하는 팔의 케틀벨을 내리고 반대쪽 팔로 반복합니다.'
        ],
        'Alternating Deltoid Raise': [
          '양손에 덤벨을 들고 어깨너비로 발을 벌리고 섭니다.',
          '한 팔씩 교대로 덤벨을 어깨 높이까지 옆으로 들어올립니다.',
          '천천히 원래 위치로 내리고 반대쪽 팔로 반복합니다.'
        ],
        'Alternating Kettlebell Press': [
          '양손에 케틀벨을 들고 어깨 위치에 세팅합니다.',
          '한 팔씩 교대로 케틀벨을 머리 위로 밀어올립니다.',
          '천천히 원래 위치로 내리고 반대쪽 팔로 반복합니다.'
        ],
        'Anti-Gravity Press': [
          '등을 대고 누워 무릎을 90도로 구부립니다.',
          '가슴 위에서 중량을 밀어올리는 동작을 수행합니다.',
          '천천히 원래 위치로 돌아갑니다.'
        ],
        'Arm Circles': [
          '팔을 옆으로 뻗어 어깨 높이로 유지합니다.',
          '작은 원을 그리듯 팔을 돌립니다.',
          '앞으로, 뒤로 번갈아 가며 실시합니다.'
        ],
        'Push-up': [
          '팔굽혀펴기 자세를 취합니다.',
          '가슴이 바닥에 가까워질 때까지 몸을 내립니다.',
          '원래 위치까지 몸을 밀어 올립니다.'
        ],
        'Pull-up': [
          '철봉에 매달립니다.',
          '턱이 철봉을 넘을 때까지 몸을 끌어올립니다.',
          '천천히 원래 위치로 돌아갑니다.'
        ],
      };
      return map[exerciseName] ?? ['운동 방법 설명이 없습니다.'];
    }
  }

  // 부위 매핑 (영어 -> 한국어) - 하위 호환성
  static String getBodyPartKo(String bodyPart) => getBodyPartLocalized(bodyPart, 'ko');

  // 장비 매핑 (영어 -> 한국어) - 하위 호환성
  static String getEquipmentKo(String equipment) => getEquipmentLocalized(equipment, 'ko');
  
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
