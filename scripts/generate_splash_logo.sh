#!/bin/bash

# IRON LOG Splash Logo Generator
# 이 스크립트는 ImageMagick을 사용하여 간단한 텍스트 로고를 생성합니다.

echo "🔨 IRON LOG 스플래시 로고 생성 중..."

# ImageMagick 설치 확인
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick이 설치되어 있지 않습니다."
    echo "📦 설치 방법:"
    echo "   macOS: brew install imagemagick"
    echo "   Ubuntu: sudo apt-get install imagemagick"
    echo "   Windows: https://imagemagick.org/script/download.php"
    exit 1
fi

# 출력 디렉토리 확인
OUTPUT_DIR="assets/images"
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo "📁 디렉토리 생성: $OUTPUT_DIR"
fi

# 메인 로고 생성 (1200x1200px)
echo "🎨 splash_logo.png 생성 중..."
convert -size 1200x1200 xc:none \
  -font Courier-Bold \
  -pointsize 140 \
  -fill white \
  -gravity center \
  -kerning 20 \
  -annotate +0+0 "IRON LOG" \
  "$OUTPUT_DIR/splash_logo.png"

if [ $? -eq 0 ]; then
    echo "✅ splash_logo.png 생성 완료!"
else
    echo "❌ 로고 생성 실패. Courier-Bold 폰트가 없을 수 있습니다."
    echo "💡 대체 폰트로 재시도 중..."
    
    # 대체 폰트로 재시도
    convert -size 1200x1200 xc:none \
      -font Helvetica-Bold \
      -pointsize 140 \
      -fill white \
      -gravity center \
      -kerning 20 \
      -annotate +0+0 "IRON LOG" \
      "$OUTPUT_DIR/splash_logo.png"
    
    if [ $? -eq 0 ]; then
        echo "✅ splash_logo.png 생성 완료! (Helvetica-Bold 사용)"
    else
        echo "❌ 로고 생성 실패. 수동으로 이미지를 생성해주세요."
        exit 1
    fi
fi

# 선택사항: 브랜딩 이미지 생성 (800x200px)
echo "🎨 branding.png 생성 중 (선택사항)..."
convert -size 800x200 xc:none \
  -font Courier \
  -pointsize 24 \
  -fill "#666666" \
  -gravity center \
  -annotate +0+0 "SYSTEM READY" \
  "$OUTPUT_DIR/branding.png"

if [ $? -eq 0 ]; then
    echo "✅ branding.png 생성 완료!"
else
    echo "⚠️  branding.png 생성 실패 (선택사항이므로 무시)"
fi

echo ""
echo "🎉 완료!"
echo "📍 생성된 파일:"
ls -lh "$OUTPUT_DIR"/*.png 2>/dev/null || echo "   (파일 목록 표시 실패)"
echo ""
echo "📝 다음 단계:"
echo "   1. flutter pub get"
echo "   2. dart run flutter_native_splash:create"
echo "   3. flutter clean && flutter run"
