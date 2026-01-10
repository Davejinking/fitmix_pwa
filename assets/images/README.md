# IRON LOG Splash Screen Assets

## 필요한 이미지

### 1. splash_logo.png (메인 로고)
**사양:**
- 크기: 1200x1200px (권장)
- 배경: 투명 (Transparent PNG)
- 텍스트: "IRON LOG" (흰색 #FFFFFF)
- 폰트: Bebas Neue, Stencil, 또는 Courier (Bold, Monospace)
- 스타일: 대문자, 굵게, 레터스페이싱 넓게

**디자인 컨셉:**
- 미니멀한 텍스트 로고
- 아이콘 없음 (텍스트가 곧 로고)
- 전술적/산업적 느낌
- 검은 배경에 흰색 텍스트가 선명하게 보이도록

### 2. branding.png (선택사항)
**사양:**
- 크기: 800x200px (권장)
- 배경: 투명
- 텍스트: "SYSTEM READY" 또는 버전 정보
- 폰트: Courier (작은 크기, 회색)
- 위치: 화면 하단에 표시됨

## 이미지 생성 방법

### 옵션 1: Figma/Canva 사용
1. 1200x1200px 캔버스 생성
2. 배경 투명으로 설정
3. "IRON LOG" 텍스트 추가 (Bebas Neue Bold, 120pt)
4. 레터스페이싱 200-300 적용
5. PNG로 내보내기 (투명 배경)

### 옵션 2: 온라인 텍스트 로고 생성기
- Canva: https://www.canva.com/
- Figma: https://www.figma.com/
- Photopea: https://www.photopea.com/ (무료 Photoshop 대체)

### 옵션 3: 코드로 생성 (ImageMagick)
```bash
# ImageMagick 설치 필요
convert -size 1200x1200 xc:none \
  -font Courier-Bold \
  -pointsize 120 \
  -fill white \
  -gravity center \
  -annotate +0+0 "IRON LOG" \
  splash_logo.png
```

## 스플래시 스크린 적용 방법

1. 이미지 파일을 `assets/images/` 폴더에 저장
2. 터미널에서 실행:
   ```bash
   flutter pub get
   dart run flutter_native_splash:create
   ```
3. 앱 재빌드:
   ```bash
   flutter clean
   flutter run
   ```

## 현재 상태
- ⏳ splash_logo.png 생성 필요
- ⏳ (선택) branding.png 생성 필요
- ✅ flutter_native_splash.yaml 설정 완료
- ✅ pubspec.yaml 업데이트 완료

## 참고
- 현재 "Lifto" 브랜딩에서 "IRON LOG"로 리브랜딩 중
- 덤벨 아이콘 제거 → 텍스트 중심 로고
- 배경색: 순수 검정 (#000000)
- 전술적 노아르 미학 적용
