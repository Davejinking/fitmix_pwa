import 'package:hive/hive.dart';
import 'exercise.dart';

part 'session.g.dart';

@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0)
  String ymd; // yyyy-MM-dd

  @HiveField(1)
  List<Exercise> exercises;

  @HiveField(2)
  bool isRest;

  Session({
    required this.ymd,
    List<Exercise>? exercises,
    this.isRest = false,
  }) : exercises = exercises ?? [];
}
