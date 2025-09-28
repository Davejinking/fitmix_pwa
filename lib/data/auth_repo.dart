import 'package:google_sign_in/google_sign_in.dart';

/// 인증 관련 로직을 처리하는 저장소 인터페이스
abstract class AuthRepo {
  GoogleSignInAccount? get currentUser;
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
}

class GoogleAuthRepo implements AuthRepo {
  final GoogleSignIn _googleSignIn;

  // 웹용 클라이언트 ID. 실제 프로젝트에서는 환경 변수 등으로 관리하는 것이 좋습니다.
  static const String _webClientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';

  GoogleAuthRepo()
      : _googleSignIn = GoogleSignIn(
          clientId: _webClientId,
          scopes: <String>[
            'email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ],
        );

  @override
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}