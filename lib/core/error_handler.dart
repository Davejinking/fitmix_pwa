import 'package:flutter/material.dart';

/// 전역 에러 처리 및 사용자 피드백 관리
class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 에러 메시지를 사용자 친화적으로 변환
  static String getUserFriendlyMessage(dynamic error) {
    if (error is StateError) {
      return error.message;
    } else if (error is Exception) {
      final message = error.toString();
      if (message.contains('복사할 세션이 없습니다')) {
        return '복사할 운동 기록이 없습니다.';
      } else if (message.contains('세션 복사 중 오류')) {
        return '운동 기록 복사 중 문제가 발생했습니다.';
      } else if (message.contains('기간별 세션 조회 중 오류')) {
        return '기간별 운동 기록 조회 중 문제가 발생했습니다.';
      } else if (message.contains('운동 세션 조회 중 오류')) {
        return '운동 기록 조회 중 문제가 발생했습니다.';
      }
    }
    return '알 수 없는 오류가 발생했습니다.';
  }

  /// 에러 다이얼로그 표시
  static Future<void> showErrorDialog(BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 확인 다이얼로그 표시
  static Future<bool> showConfirmDialog(BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    ).then((result) => result ?? false);
  }
}
