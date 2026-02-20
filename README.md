# book_bridge

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

 전체 구조를 정리해드립니다.                               
                                                                      
  ---                                                                 
  현재 프로젝트 구조 상세                                             
                                                                      
  1. Firebase 프로젝트                                                
                                                                      
  항목: 프로젝트 ID                                                   
  값: book-bridge-2026                                                
  ────────────────────────────────────────                            
  항목: 콘솔                                                          
  값: https://console.firebase.google.com/project/book-bridge-2026

  2. 사용 중인 Firebase 서비스 5개

  서비스: Firebase Auth
  역할: 회원가입/로그인 (이메일+비밀번호)
  설정 파일: Firebase 콘솔에서 관리
  ────────────────────────────────────────
  서비스: Cloud Firestore
  역할: 메인 데이터베이스 (책, 유저, 채팅, 거래 등)
  설정 파일: firestore.rules, firestore.indexes.json
  ────────────────────────────────────────
  서비스: Firebase Storage
  역할: 이미지 저장 (책 사진, 프로필, 사업자등록증)
  설정 파일: storage.rules
  ────────────────────────────────────────
  서비스: Firebase Hosting
  역할: 웹사이트 배포
  설정 파일: firebase.json → build/web 폴더
  ────────────────────────────────────────
  서비스: Firebase Cloud Messaging (FCM)
  역할: 푸시 알림
  설정 파일: lib/core/services/notification_service.dart
  ────────────────────────────────────────
  서비스: Cloud Functions
  역할: 서버 로직 (책 등록 시 위시리스트 매칭 알림)
  설정 파일: functions/index.js

  3. 배포 방식 — 전부 수동 (자동화 없음)

  CI/CD(GitHub Actions 등)는 설정되어 있지 않습니다. 모든 배포는
  터미널 명령어로 직접 실행합니다:

  # 웹사이트 배포 (2단계)
  flutter build web          ← Flutter 웹 빌드 → build/web/ 폴더 생성
  firebase deploy --only hosting  ← build/web/ 을 Firebase Hosting에
  업로드

  # Firestore 규칙/인덱스 배포
  firebase deploy --only firestore:rules
  firebase deploy --only firestore:indexes

  # Storage 규칙 배포
  firebase deploy --only storage

  # Cloud Functions 배포
  firebase deploy --only functions

  # 전부 한번에 배포
  firebase deploy

  4. 웹사이트 현황

  ┌─────────────┬──────────────────────────────────────────┐
  │    항목     │                    값                    │
  ├─────────────┼──────────────────────────────────────────┤
  │ URL         │ https://book-bridge-2026.web.app         │
  ├─────────────┼──────────────────────────────────────────┤
  │ 마지막 배포 │ 2026-02-14 00:05                         │
  ├─────────────┼──────────────────────────────────────────┤
  │ 소스        │ build/web/ 폴더 (Flutter 웹 빌드 결과물) │
  └─────────────┴──────────────────────────────────────────┘

  현재 웹사이트는 앱과 동일한 Flutter 코드가 웹으로 빌드된 것입니다.
  별도의 웹 전용 사이트는 없습니다.

  5. 앱 배포 현황

  플랫폼: Android
  방식: flutter build apk → APK 파일 직접 전달
  상태: 구글 드라이브로 설치
  ────────────────────────────────────────
  플랫폼: iOS
  방식: 미설정
  상태: Apple Developer 계정 필요
  ────────────────────────────────────────
  플랫폼: 웹
  방식: Firebase Hosting
  상태: https://book-bridge-2026.web.app

  6. 데이터 흐름 요약

  사용자 (앱/웹)
      ↓
  Flutter 앱 (Riverpod 상태관리)
      ↓
  Firebase Auth ← 로그인/회원가입
  Cloud Firestore ← 책, 유저, 채팅, 거래, 위시리스트, 알림 데이터
  Firebase Storage ← 이미지 업로드/다운로드
  알라딘 API ← 책 검색 (ISBN/제목) — 외부 API, CORS 때문에 웹에서 제한
      ↓
  Cloud Functions ← 책 등록 시 위시리스트 매칭 → FCM 푸시 알림

  7. Firestore 컬렉션 구조

  ┌──────────────────────┬─────────────┐
  │        컬렉션        │    내용     │
  ├──────────────────────┼─────────────┤
  │ users                │ 유저 프로필 │
  ├──────────────────────┼─────────────┤
  │ books                │ 등록된 책   │
  ├──────────────────────┼─────────────┤
  │ chatRooms / messages │ 채팅        │
  ├──────────────────────┼─────────────┤
  │ exchangeRequests     │ 교환 요청   │
  ├──────────────────────┼─────────────┤
  │ purchaseRequests     │ 구매 요청   │
  ├──────────────────────┼─────────────┤
  │ sharingRequests      │ 나눔 요청   │
  ├──────────────────────┼─────────────┤
  │ donations            │ 기증        │
  ├──────────────────────┼─────────────┤
  │ organizations        │ 기관        │
  ├──────────────────────┼─────────────┤
  │ wishlists            │ 위시리스트  │
  ├──────────────────────┼─────────────┤
  │ notifications        │ 알림        │
  ├──────────────────────┼─────────────┤
  │ bookClubs            │ 책모임      │
  └──────────────────────┴─────────────┘

---

## 개발 일지

### 2026-02-20 — 채팅 시스템 개선 + 버그 수정

#### 수정된 버그
| # | 문제 | 원인 | 해결 |
|---|------|------|------|
| 1 | 바코드 스캔 시 없는 책이면 검은 화면 + 먹통 | `showDialog` → `Navigator.pop(context)`에서 async gap 이후 context가 부모 화면을 pop | `ConsumerStatefulWidget` + Stack 기반 로딩 오버레이로 전환 (Navigator.pop 완전 제거) |
| 2 | 채팅 목록에 내 채팅방이 안 보임 | Firestore `arrayContains` + `orderBy` 복합 쿼리에 인덱스 미생성 → 쿼리 자체 실패 | `orderBy` 제거, 로컬 정렬로 전환 |
| 3 | 빠른 답변 칩이 모바일에서 안 보임 | 커스텀 `Material+InkWell` 위젯 모바일 렌더링 이슈 | Flutter 기본 `OutlinedButton`으로 교체 |
| 4 | AI 답변이 엉뚱한 말을 함 | 프롬프트에 책 제목/거래유형/역할 정보 부족, auto_greeting 메시지 필터링됨 | 프롬프트 대폭 개선 (앱 맥락 + 역할 + 전체 대화 포함) |

#### 새로 추가된 기능
| # | 기능 | 설명 |
|---|------|------|
| 1 | 구매/나눔 즉시 채팅 | 별도 요청 화면 없이 확인 다이얼로그 → 즉시 채팅방 생성 → 바로 채팅방 이동 |
| 2 | 채팅방 제목 탭 → 상품 상세 | 채팅방 AppBar의 책 제목 탭 시 해당 책 상세 페이지로 이동 |
| 3 | 알림 탭 네비게이션 | 알림 목록에서 항목 탭 시 해당 책/채팅방으로 이동 |
| 4 | Firestore 실시간 푸시 | 새 알림 생성 시 로컬 푸시 알림 표시 (앱 포그라운드) |
| 5 | 위시리스트 매칭 결과 화면 | 위시리스트 항목 탭 시 매칭된 책 목록 표시 |

#### 변경된 파일 (핵심)
```
lib/features/book_register/screens/book_search_register_screen.dart  — 바코드 스캔 검은화면 수정
lib/data/repositories/chat_repository.dart                           — 채팅 목록 쿼리 수정
lib/features/chat/screens/chat_room_screen.dart                      — 빠른답변 + 제목탭 + AI호출
lib/data/datasources/remote/deepseek_datasource.dart                 — AI 프롬프트 개선
lib/providers/chat_providers.dart                                    — AI provider 맥락 확장
lib/features/book_detail/screens/book_detail_screen.dart             — 구매/나눔 즉시 채팅
lib/features/purchase/screens/purchase_request_screen.dart           — 채팅방 즉시 생성
lib/features/sharing/screens/sharing_request_screen.dart             — 채팅방 즉시 생성
lib/features/purchase/screens/incoming_purchase_requests_screen.dart — 기존 채팅방 재사용
lib/features/sharing/screens/incoming_sharing_requests_screen.dart   — 기존 채팅방 재사용
```

### 2026-02-19 — 푸시 알림 + 커스텀 알림음 + 책 알림(위시리스트 매칭) + GPS 선택적

- Phase 1: 푸시 알림 활성화 (NotificationService 싱글톤, FCM 백그라운드 핸들러)
- Phase 2: 커스텀 알림음 5종 생성 + 미리듣기 + SharedPreferences 저장
- Phase 3: 위시리스트 매칭 알림 (alertEnabled, conditions, listingTypes)
- Phase 4: GPS 선택적 권한 요청
- Phase 5: 통합 테스트 240+ 통과
