import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Free Exercise DB에서 운동 데이터를 가져와서 JSON 파일로 저장
/// 이미지 포함!
Future<void> main() async {
  const apiUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json';

  print('Free Exercise DB에서 데이터 가져오는 중...');
  print('URL: $apiUrl\n');

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('✅ 성공: ${data.length}개의 운동 데이터를 가져왔습니다.');

      // ExerciseDB 형식으로 변환
      final List<Map<String, dynamic>> convertedData = [];
      
      for (var exercise in data) {
        final images = exercise['images'] as List?;
        final imageUrl = images != null && images.isNotEmpty
            ? 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${images[0]}'
            : '';

        // primaryMuscles를 bodyPart로 매핑
        final primaryMuscles = exercise['primaryMuscles'] as List?;
        String bodyPart = 'cardio';
        if (primaryMuscles != null && primaryMuscles.isNotEmpty) {
          final muscle = primaryMuscles[0].toString().toLowerCase();
          if (muscle.contains('chest') || muscle.contains('pectorals')) {
            bodyPart = 'chest';
          } else if (muscle.contains('back') || muscle.contains('lats')) {
            bodyPart = 'back';
          } else if (muscle.contains('quadriceps') || muscle.contains('hamstrings') || muscle.contains('glutes') || muscle.contains('calves')) {
            bodyPart = 'lower legs';
          } else if (muscle.contains('shoulders') || muscle.contains('deltoids')) {
            bodyPart = 'shoulders';
          } else if (muscle.contains('biceps') || muscle.contains('triceps') || muscle.contains('forearms')) {
            bodyPart = 'lower arms';
          } else if (muscle.contains('abdominals') || muscle.contains('obliques')) {
            bodyPart = 'waist';
          }
        }

        // equipment 매핑
        final equipment = exercise['equipment']?.toString().toLowerCase() ?? 'body weight';
        String mappedEquipment = 'body weight';
        if (equipment.contains('barbell')) {
          mappedEquipment = 'barbell';
        } else if (equipment.contains('dumbbell')) {
          mappedEquipment = 'dumbbell';
        } else if (equipment.contains('cable')) {
          mappedEquipment = 'cable';
        } else if (equipment.contains('machine')) {
          mappedEquipment = 'machine';
        } else if (equipment.contains('band')) {
          mappedEquipment = 'resistance band';
        }

        convertedData.add({
          'id': exercise['id'] ?? exercise['name']?.toString().replaceAll(' ', '_') ?? 'unknown',
          'name': exercise['name'] ?? 'Unknown Exercise',
          'bodyPart': bodyPart,
          'equipment': mappedEquipment,
          'gifUrl': imageUrl,
          'target': primaryMuscles?.isNotEmpty == true ? primaryMuscles![0] : 'general',
          'secondaryMuscles': exercise['secondaryMuscles'] ?? [],
          'instructions': exercise['instructions'] ?? [],
          'isCustom': false,
        });
      }

      print('🔄 ${convertedData.length}개의 운동을 ExerciseDB 형식으로 변환했습니다.');

      // assets/data 폴더 생성
      final directory = Directory('assets/data');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('📁 assets/data 폴더를 생성했습니다.');
      }

      // JSON 파일로 저장
      final file = File('assets/data/exercises.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(convertedData),
      );
      print('💾 파일 저장 완료: ${file.path}');
      print('📊 총 ${convertedData.length}개의 운동 데이터가 저장되었습니다.');
      print('🖼️  모든 운동에 이미지 URL이 포함되어 있습니다!');
    } else {
      print('❌ API 호출 실패: ${response.statusCode}');
      print('응답: ${response.body}');
      exit(1);
    }
  } catch (e) {
    print('❌ 에러 발생: $e');
    exit(1);
  }
}
