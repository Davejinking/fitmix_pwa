# Scripts

## fetch_exercises.dart

ExerciseDB API에서 모든 운동 데이터를 다운로드하여 로컬 JSON 파일로 저장하는 스크립트입니다.

### 사용법

```bash
dart scripts/fetch_exercises.dart
```

### 동작

1. ExerciseDB API에서 최대 1300개의 운동 데이터를 가져옵니다
2. `assets/data/exercises.json` 파일로 저장합니다
3. 앱은 이 로컬 JSON 파일을 사용하여 운동 데이터를 로드합니다

### 주의사항

- API 키가 만료되면 스크립트를 다시 실행해야 합니다
- 데이터를 업데이트하려면 스크립트를 다시 실행하세요
- 스크립트 실행 후 앱을 재시작해야 변경사항이 반영됩니다

### API 정보

- **API**: ExerciseDB (RapidAPI)
- **Endpoint**: https://exercisedb.p.rapidapi.com/exercises
- **Limit**: 1300개
- **데이터 포함**: 운동 이름, 부위, 장비, GIF URL, 설명 등
