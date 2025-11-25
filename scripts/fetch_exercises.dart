import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// ExerciseDB API에서 모든 운동 데이터를 가져와서 JSON 파일로 저장
/// 페이지네이션을 사용하여 여러 번 호출
Future<void> main() async {
  const apiUrl = 'https://exercisedb.p.rapidapi.com/exercises';
  const apiKey = 'd5fe345d81mshdbc0255cfa7b727p1a8dc2jsn10d1a5ef8fee';
  const limit = 10; // API가 한 번에 10개만 반환
  const maxExercises = 1500; // 최대 1500개까지 가져오기

  print('ExerciseDB API에서 데이터 가져오는 중...');
  print('페이지네이션을 사용하여 여러 번 호출합니다...\n');

  try {
    final List<dynamic> allExercises = [];
    int offset = 0;
    int pageCount = 0;

    while (allExercises.length < maxExercises) {
      pageCount++;
      print('[$pageCount] offset=$offset 요청 중...');
      
      final response = await http.get(
        Uri.parse('$apiUrl?limit=$limit&offset=$offset'),
        headers: {
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
          'X-RapidAPI-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        
        if (data.isEmpty) {
          print('더 이상 데이터가 없습니다.');
          break;
        }
        
        allExercises.addAll(data);
        print('    ✅ ${data.length}개 추가 (총 ${allExercises.length}개)');
        
        offset += limit;
        
        // API 호출 제한을 피하기 위해 잠시 대기
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        print('응답: ${response.body}');
        break;
      }
    }

    if (allExercises.isEmpty) {
      print('❌ 데이터를 가져오지 못했습니다.');
      exit(1);
    }

    print('\n✅ 총 ${allExercises.length}개의 운동 데이터를 가져왔습니다.');

    // assets/data 폴더 생성
    final directory = Directory('assets/data');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('📁 assets/data 폴더를 생성했습니다.');
    }

    // gifUrl 추가 (빈 문자열 - 이미지 없음, 아이콘만 표시)
    print('\n🖼️  gifUrl 필드 추가 중...');
    for (var exercise in allExercises) {
      exercise['gifUrl'] = ''; // 이미지 없음
    }
    
    // JSON 파일로 저장
    final file = File('assets/data/exercises.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(allExercises),
    );
    print('💾 파일 저장 완료: ${file.path}');
    print('📊 총 ${allExercises.length}개의 운동 데이터가 저장되었습니다.');
  } catch (e) {
    print('❌ 에러 발생: $e');
    exit(1);
  }
}
