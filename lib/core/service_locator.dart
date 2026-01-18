import 'package:get_it/get_it.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/user_repo.dart';
import '../data/settings_repo.dart';
import '../data/auth_repo.dart';
import '../data/routine_repo.dart';
import '../data/equipment_repo.dart';
import '../services/pro_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Repository 인스턴스 생성 및 초기화
  final sessionRepo = HiveSessionRepo();
  await sessionRepo.init();

  final exerciseRepo = HiveExerciseLibraryRepo();
  await exerciseRepo.init();

  final userRepo = HiveUserRepo();
  await userRepo.init();

  final settingsRepo = HiveSettingsRepo();
  await settingsRepo.init();

  final authRepo = GoogleAuthRepo();

  final routineRepo = HiveRoutineRepo();
  await routineRepo.init();

  final equipmentRepo = HiveEquipmentRepo();
  await equipmentRepo.init();

  // ProService 초기화
  await proService.init();

  // GetIt에 싱글톤으로 등록
  getIt.registerSingleton<SessionRepo>(sessionRepo);
  getIt.registerSingleton<ExerciseLibraryRepo>(exerciseRepo);
  getIt.registerSingleton<UserRepo>(userRepo);
  getIt.registerSingleton<SettingsRepo>(settingsRepo);
  getIt.registerSingleton<AuthRepo>(authRepo);
  getIt.registerSingleton<RoutineRepo>(routineRepo);
  getIt.registerSingleton<EquipmentRepo>(equipmentRepo);
  getIt.registerSingleton<ProService>(proService);
}