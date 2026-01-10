import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/iron_theme.dart';
import '../data/exercise_library_repo.dart';
import '../data/user_repo.dart';
import '../data/session_repo.dart';
import '../data/auth_repo.dart';
import '../data/settings_repo.dart';
import '../l10n/app_localizations.dart';
import 'profile_page.dart';

class SettingsPage extends StatefulWidget {
  final UserRepo userRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SessionRepo sessionRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;

  const SettingsPage({
    super.key,
    required this.userRepo,
    required this.exerciseRepo,
    required this.sessionRepo,
    required this.settingsRepo,
    required this.authRepo,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 테마 관련 코드 제거 - 다크 모드로 고정

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: IronTheme.background,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: IronTheme.background,
        foregroundColor: IronTheme.textHigh,
      ),
      body: ListView(
        children: [
          // 프로필 설정
          ListTile(
            leading: Icon(Icons.person_outline, color: IronTheme.textHigh),
            title: Text(l10n.profile, style: TextStyle(color: IronTheme.textHigh)),
            trailing: Icon(Icons.chevron_right, color: IronTheme.textMedium),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userRepo: widget.userRepo,
                    authRepo: widget.authRepo,
                  ),
                ),
              );
            },
          ),
          
          // 구분선
          Divider(color: IronTheme.textMedium.withValues(alpha: 0.3)),
          
          // 앱 정보
          ListTile(
            leading: Icon(Icons.info_outline, color: IronTheme.textHigh),
            title: Text(l10n.version, style: TextStyle(color: IronTheme.textHigh)),
            subtitle: Text(AppConstants.appVersion, style: TextStyle(color: IronTheme.textMedium)),
            onTap: () {},
          ),
          
          // 구분선
          Divider(color: IronTheme.textMedium.withValues(alpha: 0.3)),
          
          // 위험 구역 헤더
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '위험 구역',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: IronTheme.danger,
              ),
            ),
          ),
          
          // 계정 삭제 버튼
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: IronTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IronTheme.danger.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: IronTheme.danger),
              title: Text(
                '회원 탈퇴 / 데이터 초기화',
                style: TextStyle(
                  color: IronTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '모든 운동 기록과 설정이 영구적으로 삭제됩니다',
                style: TextStyle(
                  color: IronTheme.textMedium,
                  fontSize: 12,
                ),
              ),
              onTap: _showDeleteAccountDialog,
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: IronTheme.surface,
          title: Text(
            '계정 삭제',
            style: TextStyle(color: IronTheme.textHigh),
          ),
          content: Text(
            '정말로 계정을 삭제하시겠습니까?\n\n모든 운동 기록, 설정, 개인 데이터가 영구적으로 삭제되며 복구할 수 없습니다.',
            style: TextStyle(color: IronTheme.textMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyle(color: IronTheme.textMedium),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllData();
              },
              child: Text(
                '삭제',
                style: TextStyle(color: IronTheme.danger),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllData() async {
    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: IronTheme.surface,
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(
                  '데이터 삭제 중...',
                  style: TextStyle(color: IronTheme.textHigh),
                ),
              ],
            ),
          );
        },
      );

      // Hive 박스들 삭제
      final boxNames = ['user_box', 'session_box', 'settings_box', 'gamification'];
      
      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            await box.clear();
          }
        } catch (e) {
          // 개별 박스 삭제 실패는 무시하고 계속 진행
          print('Failed to clear box $boxName: $e');
        }
      }

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        
        // 성공 메시지 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: IronTheme.surface,
              title: Text(
                '삭제 완료',
                style: TextStyle(color: IronTheme.textHigh),
              ),
              content: Text(
                '모든 데이터가 성공적으로 삭제되었습니다.\n앱을 재시작합니다.',
                style: TextStyle(color: IronTheme.textMedium),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // 앱 종료 (iOS에서는 권장되지 않지만 Android에서는 작동)
                    SystemNavigator.pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: IronTheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: IronTheme.surface,
              title: Text(
                '오류',
                style: TextStyle(color: IronTheme.danger),
              ),
              content: Text(
                '데이터 삭제 중 오류가 발생했습니다.\n다시 시도해 주세요.',
                style: TextStyle(color: IronTheme.textMedium),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '확인',
                    style: TextStyle(color: IronTheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
