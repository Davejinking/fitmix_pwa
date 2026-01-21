import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:iron/models/exercise_db.dart';

void main() {
  test('Benchmark ExerciseDB parsing', () async {
    final file = File('assets/data/exercises.json');
    if (!file.existsSync()) {
      print('File not found: ${file.path}');
      return;
    }
    final jsonString = await file.readAsString();

    final stopwatch = Stopwatch()..start();

    // The code to optimize
    final List<dynamic> jsonData = json.decode(jsonString);
    final exercises = jsonData.map((json) => ExerciseDB.fromJson(json)).toList();

    stopwatch.stop();
    print('Parsing took: ${stopwatch.elapsedMilliseconds}ms for ${exercises.length} items');
  });
}
