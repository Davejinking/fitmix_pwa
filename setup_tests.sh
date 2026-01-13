#!/bin/bash

# 색상 코드
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Flutter 테스트 환경 설정 및 실행 ===${NC}"

# 1. Flutter 의존성 설치
echo -e "\n${GREEN}[1/3] 패키지 의존성 설치 중...${NC}"
flutter pub get

if [ $? -ne 0 ]; then
    echo -e "${RED}패키지 설치 실패. Flutter SDK가 설치되어 있는지 확인해주세요.${NC}"
    exit 1
fi

# 2. 코드 생성 (필요한 경우)
# echo -e "\n${GREEN}[2/3] 코드 생성 실행 중 (build_runner)...${NC}"
# dart run build_runner build --delete-conflicting-outputs

# 3. 테스트 실행
echo -e "\n${GREEN}[3/3] 테스트 실행 중...${NC}"
echo "타겟: test/pages/exercise_detail_page_test.dart"

flutter test test/pages/exercise_detail_page_test.dart

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ 모든 테스트가 성공적으로 통과했습니다!${NC}"
else
    echo -e "\n${RED}❌ 테스트 실패. 로그를 확인해주세요.${NC}"
    exit 1
fi
