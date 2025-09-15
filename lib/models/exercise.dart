import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String bodyPart; // 가슴/등/어깨/팔/하체/복근/유산소

  Exercise({required this.name, required this.bodyPart});
}
