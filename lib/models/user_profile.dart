import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'user_profile.g.dart';

@HiveType(typeId: 4)
class UserProfile extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int height;

  @HiveField(2)
  DateTime birthDate;

  @HiveField(3)
  String gender;

  @HiveField(4)
  int monthlyWorkoutGoal;

  @HiveField(5)
  Uint8List? profileImage;

  @HiveField(6)
  double monthlyVolumeGoal;

  UserProfile({
    required this.weight,
    required this.height,
    required this.birthDate,
    required this.gender,
    this.monthlyWorkoutGoal = 20, // 기본 목표 20일
    this.profileImage,
    this.monthlyVolumeGoal = 100000.0, // 기본 볼륨 목표 100,000 kg
  });
}