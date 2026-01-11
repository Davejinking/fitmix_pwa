/// 구독 등급별 제한 상수
class SubscriptionLimits {
  /// 무료 사용자 루틴 저장 제한 (3개 - 황금 비율)
  /// Push / Pull / Legs 3분할에 딱 맞는 개수
  static const int freeRoutineLimit = 3;
  
  /// PRO 사용자는 무제한
  static const int proRoutineLimit = -1; // -1 = unlimited
  
  /// 현재 사용자가 루틴을 더 저장할 수 있는지 확인
  static bool canSaveMoreRoutines({
    required bool isPro,
    required int currentCount,
  }) {
    if (isPro) return true; // PRO는 무제한
    return currentCount < freeRoutineLimit;
  }
  
  /// 남은 루틴 슬롯 개수 반환
  static int remainingSlots({
    required bool isPro,
    required int currentCount,
  }) {
    if (isPro) return -1; // 무제한
    final remaining = freeRoutineLimit - currentCount;
    return remaining > 0 ? remaining : 0;
  }
}
