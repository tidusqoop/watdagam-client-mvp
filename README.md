# watdagam

**낙서벽 SNS** - 여행지 낙서벽을 디지털로 재현한 Flutter 앱

사용자들이 "oo왔다감!" 스타일의 낙서 메시지를 생성하고, 크기 조절 및 위치 변경이 가능한 인터랙티브 디지털 벽을 제공합니다.

## 🚀 프로젝트 실행하기

### 빠른 시작 (웹 브라우저)
```bash
# 의존성 설치
flutter pub get

# 웹 브라우저에서 실행
flutter run -d chrome
```

### 모바일 기기에서 실행

**Android:**
```bash
# Android Studio 설치 필요: https://developer.android.com/studio
flutter run
```

**iOS (Mac만 가능):**
```bash
# 사용 가능한 iOS 시뮬레이터 확인
flutter devices

# iOS 시뮬레이터에서 실행
flutter run -d "iPhone 16e"
```

## 🛠 개발 명령어

```bash
flutter pub get          # 의존성 설치
flutter run              # 앱 실행
flutter run -d chrome    # 웹 브라우저에서 실행
flutter build apk        # Android APK 빌드
flutter build ios        # iOS 앱 빌드
flutter test             # 테스트 실행
flutter analyze          # 정적 분석
```

## 📱 현재 MVP 기능

- UI 참조: `sample/sample_wall_ui.png`
- 핵심 사용자 플로우: 낙서 생성 → 크기 조절 (드래그) → 위치 이동 (드래그) → 내용 편집
- 다양한 색상의 인터랙티브 낙서 노트
- 벽 스타일 배경 인터페이스

## 📋 개발 환경 요구사항

- Flutter SDK (현재 버전: 3.35.3)
- Android Studio (Android 개발용)
- Xcode (iOS 개발용, Mac만)
- Chrome 브라우저 (웹 개발용)
