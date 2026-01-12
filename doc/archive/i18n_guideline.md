# FitMix i18n (국제화) 가이드라인

## 목차
1. [개요](#개요)
2. [ARB 키 네이밍 규칙](#arb-키-네이밍-규칙)
3. [카테고리별 네이밍 패턴](#카테고리별-네이밍-패턴)
4. [Placeholder 사용 규칙](#placeholder-사용-규칙)
5. [코드에서 사용하기](#코드에서-사용하기)
6. [체크리스트](#체크리스트)

---

## 개요

FitMix 프로젝트는 Flutter의 공식 국제화 시스템을 사용하며, ARB (Application Resource Bundle) 파일로 다국어를 관리합니다.

**지원 언어:**
- 한국어 (ko): `lib/l10n/app_ko.arb`
- 영어 (en): `lib/l10n/app_en.arb`
- 일본어 (ja): `lib/l10n/app_ja.arb`

---

## ARB 키 네이밍 규칙

### 기본 원칙

1. **camelCase 사용**: 모든 키는 camelCase로 작성
2. **명확하고 구체적**: 키 이름만으로 용도를 파악할 수 있어야 함
3. **일관성 유지**: 유사한 UI 요소는 유사한 네이밍 패턴 사용
4. **접두사 사용 지양**: 페이지나 위젯 이름을 접두사로 붙이지 않음 (예외: 중복 방지 필요 시)

### 네이밍 패턴

```
[의미][대상][타입]
```

**예시:**
- `startWorkout` - 운동 시작하기 (동사 + 명사)
- `myGoal` - 내 목표 (소유격 + 명사)
- `weeklyAverageVolume` - 주간 평균 볼륨 (형용사 + 명사)
- `editGoal` - 목표 수정 (동사 + 명사)

---

## 카테고리별 네이밍 패턴

### 1. 앱 전역 (Global)

앱 이름, 브랜드명 등 전역적으로 사용되는 텍스트

```json
{
  "appName": "FitMix PS0",
  "fitMix": "FitMix",
  "burnFit": "BURN FIT"
}
```

**규칙:**
- 단순 명사형
- 브랜드명은 그대로 유지

---

### 2. 네비게이션 (Navigation)

탭, 페이지 제목 등

```json
{
  "home": "홈",
  "calendar": "캘린더",
  "library": "라이브러리",
  "analysis": "분석"
}
```

**규칙:**
- 단순 명사형
- 페이지/탭 이름과 동일하게

---

### 3. 버튼 및 액션 (Buttons & Actions)

사용자 액션을 유도하는 버튼 텍스트

```json
{
  "startWorkout": "운동 시작하기",
  "createNow": "바로 만들기",
  "editGoal": "목표 수정",
  "upgrade": "업그레이드"
}
```

**규칙:**
- 동사 + 명사 형태
- 명령형 또는 동작을 나타내는 표현
- 버튼의 기능을 명확히 표현

---

### 4. 카드 제목 (Card Titles)

홈 화면 등에서 사용되는 카드 컴포넌트의 제목

```json
{
  "myGoal": "내 목표",
  "activityTrend": "운동량 변화"
}
```

**규칙:**
- 명사형
- 소유격(my) 또는 설명적 형용사 사용 가능

---

### 5. 데이터 표시 (Data Display)

통계, 목표 등 데이터를 표시하는 텍스트

```json
{
  "workoutDaysGoal": "운동 일수: {days} / {goal} 일",
  "workoutVolumeGoal": "운동 볼륨: {volume} / {goal} kg",
  "weeklyAverageVolume": "이번 주 평균 운동 볼륨은 {volume}kg 입니다.",
  "weeklyComparison": "저번 주 대비 {diff}kg"
}
```

**규칙:**
- 명사 + 설명 형태
- Placeholder를 포함한 완전한 문장
- 단위 포함 (kg, 일 등)

---

### 6. 필터/탭 (Filters & Tabs)

데이터 필터링이나 탭 전환에 사용되는 짧은 레이블

```json
{
  "time": "시간",
  "volume": "볼륨",
  "density": "밀도"
}
```

**규칙:**
- 단순 명사형
- 짧고 간결하게

---

### 7. 요일 (Weekdays)

요일 표시용 텍스트

```json
{
  "weekdayMon": "월",
  "weekdayTue": "화",
  "weekdayWed": "수",
  "weekdayThu": "목",
  "weekdayFri": "금",
  "weekdaySat": "토",
  "weekdaySun": "일"
}
```

**규칙:**
- `weekday` + 영문 요일 약자 (Mon, Tue, Wed...)
- 일관된 접두사 사용으로 그룹화

---

### 8. 인사말 및 사용자 관련 (Greetings & User)

사용자에게 표시되는 인사말이나 사용자 관련 텍스트

```json
{
  "greetingWithName": "안녕하세요, {name}님",
  "defaultUser": "사용자"
}
```

**규칙:**
- `greeting` 접두사 사용
- `default` 접두사로 기본값 표시

---

### 9. 에러 및 상태 메시지 (Errors & Status)

에러, 경고, 알림 메시지

```json
{
  "unknownPage": "알 수 없는 페이지",
  "updateNote": "9월 22일 업데이트 노트"
}
```

**규칙:**
- 명사형 또는 완전한 문장
- 상황을 명확히 설명

---

## Placeholder 사용 규칙

### 기본 문법

ARB 파일에서 동적 값을 삽입할 때 placeholder를 사용합니다.

```json
{
  "greetingWithName": "안녕하세요, {name}님",
  "@greetingWithName": {
    "description": "사용자 인사말",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

### Placeholder 네이밍

1. **의미 있는 이름**: `{value}`, `{data}` 대신 `{name}`, `{volume}` 사용
2. **camelCase**: 여러 단어는 camelCase로 작성
3. **단수형**: 일반적으로 단수형 사용

### 타입 지정

```json
{
  "workoutDaysGoal": "운동 일수: {days} / {goal} 일",
  "@workoutDaysGoal": {
    "description": "운동 일수 목표 표시",
    "placeholders": {
      "days": {
        "type": "int"
      },
      "goal": {
        "type": "int"
      }
    }
  }
}
```

**지원 타입:**
- `String`: 문자열
- `int`: 정수
- `double`: 실수
- `DateTime`: 날짜/시간

### 여러 Placeholder 사용

```json
{
  "workoutVolumeGoal": "운동 볼륨: {volume} / {goal} kg",
  "@workoutVolumeGoal": {
    "description": "운동 볼륨 목표 표시",
    "placeholders": {
      "volume": {
        "type": "String"
      },
      "goal": {
        "type": "String"
      }
    }
  }
}
```

---

## 코드에서 사용하기

### 1. Import 확장 메서드

```dart
import '../core/l10n_extensions.dart';
```

### 2. 기본 사용법

```dart
// 단순 텍스트
Text(context.l10n.home)

// 버튼 레이블
ElevatedButton(
  onPressed: () {},
  child: Text(context.l10n.startWorkout),
)

// AppBar 제목
AppBar(
  title: Text(context.l10n.myGoal),
)
```

### 3. Placeholder가 있는 경우

```dart
// 단일 placeholder
Text(context.l10n.greetingWithName('홍길동'))

// 여러 placeholder
Text(context.l10n.workoutDaysGoal(15, 20))

// 문자열 변환이 필요한 경우
Text(context.l10n.weeklyAverageVolume(volume.toStringAsFixed(0)))
```

### 4. 조건부 텍스트

```dart
Text(
  _currentUser != null 
    ? context.l10n.greetingWithName(_currentUser!.displayName ?? context.l10n.defaultUser)
    : context.l10n.burnFit
)
```

---

## 체크리스트

새로운 UI 텍스트를 추가할 때 다음 사항을 확인하세요:

### ARB 파일 작성

- [ ] 키 이름이 camelCase인가?
- [ ] 키 이름이 용도를 명확히 표현하는가?
- [ ] 유사한 기능의 기존 키와 일관된 네이밍을 사용하는가?
- [ ] `@키이름` 메타데이터에 `description`을 작성했는가?
- [ ] Placeholder가 필요한 경우 타입을 명시했는가?
- [ ] 세 언어(ko, en, ja) 모두에 추가했는가?

### 코드 작성

- [ ] 하드코딩된 문자열을 모두 제거했는가?
- [ ] `context.l10n.xxx` 형태로 사용하는가?
- [ ] Placeholder 인자를 올바른 순서로 전달하는가?
- [ ] 숫자 포맷팅이 필요한 경우 적절히 처리했는가?

### 테스트

- [ ] 세 언어 모두에서 UI가 정상적으로 표시되는가?
- [ ] 긴 텍스트가 레이아웃을 깨뜨리지 않는가?
- [ ] Placeholder 값이 올바르게 표시되는가?

---

## 예시: 새로운 기능 추가

### 시나리오: "운동 기록 삭제" 기능 추가

#### 1. ARB 키 설계

```json
// app_ko.arb
{
  "deleteRecord": "기록 삭제",
  "deleteRecordConfirm": "정말 이 운동 기록을 삭제하시겠습니까?",
  "deleteRecordSuccess": "운동 기록이 삭제되었습니다.",
  "cancel": "취소",
  "delete": "삭제"
}

// app_en.arb
{
  "deleteRecord": "Delete Record",
  "deleteRecordConfirm": "Are you sure you want to delete this workout record?",
  "deleteRecordSuccess": "Workout record has been deleted.",
  "cancel": "Cancel",
  "delete": "Delete"
}

// app_ja.arb
{
  "deleteRecord": "記録を削除",
  "deleteRecordConfirm": "本当にこのワークアウト記録を削除しますか？",
  "deleteRecordSuccess": "ワークアウト記録が削除されました。",
  "cancel": "キャンセル",
  "delete": "削除"
}
```

#### 2. 코드에서 사용

```dart
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteRecord),
        content: Text(context.l10n.deleteRecordConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await deleteWorkoutRecord();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.deleteRecordSuccess)),
        );
      }
    }
  },
)
```

---

## 참고 자료

- [Flutter 공식 국제화 가이드](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB 파일 형식 스펙](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- FitMix 프로젝트 ARB 파일: `lib/l10n/app_*.arb`

---

**마지막 업데이트:** 2024-11-16
