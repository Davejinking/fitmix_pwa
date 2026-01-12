# 🔨 IRON LOG 스플래시 스크린 설정 가이드

## 📋 현재 상태

✅ **완료된 작업:**
- `flutter_native_splash` 패키지 추가 (pubspec.yaml)
- `flutter_native_splash.yaml` 설정 파일 생성
- `assets/images/` 디렉토리 생성
- SVG 템플릿 생성 (`splash_logo_template.svg`)

⏳ **필요한 작업:**
- `splash_logo.png` 이미지 생성 및 배치

---

## 🎨 로고 이미지 생성 방법

### 방법 1: 온라인 도구 사용 (가장 쉬움) ⭐

#### Canva 사용:
1. https://www.canva.com/ 접속
2. "Custom size" → 1200 x 1200 px
3. 배경 투명으로 설정
4. 텍스트 추가: "IRON LOG"
   - 폰트: Bebas Neue Bold 또는 Courier Bold
   - 크기: 120-140pt
   - 색상: 흰색 (#FFFFFF)
   - 레터스페이싱: 넓게 (200-300)
5. PNG로 다운로드 (투명 배경)
6. 파일명을 `splash_logo.png`로 변경
7. `assets/images/` 폴더에 저장

#### Figma 사용:
1. https://www.figma.com/ 접속
2. 1200x1200 프레임 생성
3. 텍스트 레이어 추가: "IRON LOG"
   - Font: Courier Bold 또는 Bebas Neue
   - Size: 140
   - Color: #FFFFFF
   - Letter spacing: 200
4. Export → PNG → Transparent background
5. `assets/images/splash_logo.png`로 저장

---

### 방법 2: SVG 템플릿 변환

프로젝트에 포함된 `assets/images/splash_logo_template.svg` 파일을 PNG로 변환:

#### 온라인 변환:
1. https://cloudconvert.com/svg-to-png 접속
2. `splash_logo_template.svg` 업로드
3. Width: 1200, Height: 1200 설정
4. 변환 후 다운로드
5. `splash_logo.png`로 이름 변경
6. `assets/images/` 폴더에 저장

---

### 방법 3: ImageMagick 사용 (개발자용)

```bash
# ImageMagick 설치
brew install imagemagick  # macOS
# 또는
sudo apt-get install imagemagick  # Linux

# 로고 생성
./scripts/generate_splash_logo.sh
```

---

## 🚀 스플래시 스크린 적용

로고 이미지를 생성한 후:

```bash
# 1. 패키지 설치
flutter pub get

# 2. 스플래시 스크린 생성
dart run flutter_native_splash:create

# 3. 앱 재빌드
flutter clean
flutter run
```

---

## 🎯 디자인 사양

### splash_logo.png
- **크기:** 1200 x 1200 px
- **배경:** 투명 (Transparent PNG)
- **텍스트:** "IRON LOG"
- **폰트:** Courier Bold, Bebas Neue, 또는 Stencil
- **색상:** 흰색 (#FFFFFF)
- **스타일:** 대문자, 굵게, 레터스페이싱 넓게
- **정렬:** 중앙

### 배경색
- **색상:** 순수 검정 (#000000)
- **컨셉:** "Tactical Noir Boot Screen"

---

## 📱 미리보기

스플래시 스크린은 다음과 같이 표시됩니다:

```
┌─────────────────────────┐
│                         │
│                         │
│                         │
│      IRON LOG           │  ← 흰색 텍스트
│                         │
│                         │
│                         │
└─────────────────────────┘
     검은 배경 (#000000)
```

---

## ❓ 문제 해결

### "이미지가 표시되지 않아요"
- `assets/images/splash_logo.png` 파일이 존재하는지 확인
- 파일명이 정확한지 확인 (대소문자 구분)
- `dart run flutter_native_splash:create` 재실행
- `flutter clean` 후 재빌드

### "배경이 검정이 아니에요"
- `flutter_native_splash.yaml`에서 `color: "#000000"` 확인
- Android 12의 경우 `android_12.color: "#000000"` 확인

### "텍스트가 너무 작아요/커요"
- 이미지 편집 도구에서 폰트 크기 조정 (120-160pt 권장)
- 레터스페이싱 조정

---

## 📚 참고 자료

- [flutter_native_splash 공식 문서](https://pub.dev/packages/flutter_native_splash)
- [Canva 튜토리얼](https://www.canva.com/learn/)
- [Figma 튜토리얼](https://help.figma.com/)

---

## 🎨 브랜딩 컨셉

**"Tactical Noir Boot Screen"**
- 미니멀리즘: 텍스트만 사용, 아이콘 없음
- 산업적: 모노스페이스 폰트, 굵은 글씨
- 전술적: 검은 배경, 흰색 텍스트, 높은 대비
- 시스템 부팅 화면 느낌

---

**마지막 업데이트:** 2026-01-11
