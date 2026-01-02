#!/bin/bash

# ============================================================================
# Lifto 테스트 환경 자동 세팅 스크립트 (Jules Optimized)
# ============================================================================
# 목적: Jules(Cloud AI)가 세션 초기화 후 즉시 테스트 작성/실행할 수 있도록
#      개발 환경을 자동으로 준비합니다.
# ============================================================================

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ============================================================================
# 0. Flutter SDK 경로 설정 (Jules 환경 대응)
# ============================================================================

log_info "Step 0: Flutter SDK 경로 확인..."

# 현재 디렉토리에 flutter_sdk가 있는지 확인하고 PATH에 추가
if [ -d "$(pwd)/flutter_sdk/bin" ]; then
    export PATH="$PATH:$(pwd)/flutter_sdk/bin"
    log_success "로컬 Flutter SDK 감지 및 PATH 추가됨"
fi

# ============================================================================
# 1. 환경 검증 및 설치
# ============================================================================

log_info "Step 1: 환경 검증 중..."

# Flutter 설치 확인 및 자동 설치
if ! command -v flutter &> /dev/null; then
    log_warning "Flutter가 설치되지 않았습니다. 자동 설치를 시도합니다..."
    
    if [ ! -d "flutter_sdk" ]; then
        log_info "Flutter SDK 다운로드 중 (Stable Channel)..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter_sdk
    fi
    
    export PATH="$PATH:$(pwd)/flutter_sdk/bin"
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter 설치 실패. 수동으로 설치해주세요."
        exit 1
    fi
    log_success "Flutter 설치 완료"
else
    log_success "Flutter 설치 확인됨"
fi

# Dart 설치 확인
if ! command -v dart &> /dev/null; then
    log_error "Dart가 설치되지 않았습니다. (Flutter에 포함되어 있어야 함)"
    exit 1
fi

log_success "Dart 설치 확인됨"

# 프로젝트 루트 확인
if [ ! -f "pubspec.yaml" ]; then
    log_error "pubspec.yaml을 찾을 수 없습니다. 프로젝트 루트에서 실행하세요."
    exit 1
fi

# ============================================================================
# 2. 패키지 설치
# ============================================================================

log_info "Step 2: 패키지 설치 중..."

flutter pub get

log_success "패키지 설치 완료"

# ============================================================================
# 3. 에셋 및 리소스 생성 (빌드 에러 방지)
# ============================================================================

log_info "Step 3: 필수 에셋 디렉토리 생성 중..."

# assets/sounds 폴더 및 더미 파일 생성
if [ ! -d "assets/sounds" ]; then
    mkdir -p assets/sounds
    touch assets/sounds/dummy.mp3
    log_success "assets/sounds 생성됨"
fi

# assets/audio 폴더 및 더미 파일 생성
if [ ! -d "assets/audio" ]; then
    mkdir -p assets/audio
    touch assets/audio/dummy.mp3
    log_success "assets/audio 생성됨"
fi

# ============================================================================
# 4. 코드 생성 (필요한 경우)
# ============================================================================

log_info "Step 4: 코드 생성 중..."

# Localization 코드 생성 (중요: 테스트에서 AppLocalizations 참조 시 필수)
if [ -f "l10n.yaml" ]; then
    log_info "Localization 코드 생성 중..."
    flutter gen-l10n
    log_success "Localization 생성 완료"
fi

# build_runner 확인 (Hive 등 모델 생성)
if grep -q "build_runner" pubspec.yaml; then
    log_info "build_runner 감지됨. 코드 생성 실행..."
    # --delete-conflicting-outputs 옵션으로 충돌 해결
    dart run build_runner build --delete-conflicting-outputs
    log_success "코드 생성 완료"
else
    log_warning "build_runner가 설정되지 않았습니다."
fi

# ============================================================================
# 5. 테스트 폴더 구조 확인
# ============================================================================

log_info "Step 5: 테스트 폴더 구조 확인 중..."

mkdir -p test/bugs
mkdir -p test/features

log_success "테스트 폴더 구조 확인 완료"

# ============================================================================
# 6. 환경 정보 출력
# ============================================================================

log_info "Step 6: 환경 정보 출력 중..."

echo ""
echo -e "${BLUE}=== 환경 정보 ===${NC}"
echo "Flutter 버전: $(flutter --version | head -1)"
echo "Dart 버전: $(dart --version)"
echo "프로젝트: $(grep '^name:' pubspec.yaml | cut -d' ' -f2)"
echo ""

# ============================================================================
# 7. 완료
# ============================================================================

log_success "테스트 환경 설정 완료!"
echo ""
echo -e "${BLUE}=== 테스트 실행 준비 완료 ===${NC}"
echo "이제 'flutter test' 명령어가 지연 없이 실행됩니다."
echo ""
