import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../models/session.dart';
import '../models/user_profile.dart';
import 'service_locator.dart';

class ProfileSessionData {
  final UserProfile? profile;
  final List<Session> sessions;

  const ProfileSessionData({
    required this.profile,
    required this.sessions,
  });
}

Future<ProfileSessionData> loadProfileSessionData({
  UserRepo? userRepo,
  SessionRepo? sessionRepo,
}) async {
  final resolvedUserRepo = userRepo ?? getIt<UserRepo>();
  final resolvedSessionRepo = sessionRepo ?? getIt<SessionRepo>();

  final profile = await resolvedUserRepo.getUserProfile();
  final sessions = await resolvedSessionRepo.getWorkoutSessions();

  return ProfileSessionData(
    profile: profile,
    sessions: sessions,
  );
}
