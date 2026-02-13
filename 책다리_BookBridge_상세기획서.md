# 📚 책다리 (BookBridge) - 상세 기획서

> **버전**: v1.0  
> **최종 수정일**: 2026-02-13  
> **플랫폼**: iOS, Android (Flutter), Web (Flutter Web)  
> **목적**: 이 문서는 Claude Code 오케스트레이션을 통한 개발 가이드로 사용됩니다.

---

## 1. 프로젝트 개요

### 1.1 앱 이름
- **한글**: 책다리
- **영문**: BookBridge
- **의미**: 책(Book)으로 사람과 사람을 연결하는 다리(Bridge)

### 1.2 핵심 컨셉
개인 간(C2C) 책 교환 매칭 플랫폼. 돈이 아닌 책과 책을 교환하는 물물교환 서비스.
- 지역 직거래 + 타지역 택배 거래 모두 지원
- 쌍방 매칭 시스템 (서로의 책장을 보고 교환 성립)
- 커뮤니티 기반 책 정보 DB 축적

### 1.3 당근마켓과의 차별점
| 항목 | 당근마켓 | 책다리 |
|------|---------|--------|
| 거래 방식 | 금전 거래 | 책 ↔ 책 물물교환 |
| 거래 범위 | 동네(지역) 한정 | 직거래 + 택배 (전국) |
| 매칭 | 구매자가 일방적 연락 | 쌍방 매칭 시스템 |
| 상품 | 전 카테고리 | 책 특화 |
| 등록 | 직접 촬영/작성 | 책 정보 자동완성 + 실물 사진 |

---

## 2. 기술 스택

### 2.1 프론트엔드
```
Framework: Flutter 3.x (최신 stable)
Language: Dart
State Management: Riverpod 2.x
Navigation: GoRouter
Local Storage: Hive 또는 SharedPreferences
HTTP Client: Dio
Image: cached_network_image, image_picker, image_cropper
Barcode Scanner: mobile_scanner
Push Notification: firebase_messaging
Maps: google_maps_flutter
```

### 2.2 백엔드
```
Backend: Firebase (초기 MVP) 또는 Supabase
Authentication: Firebase Auth (이메일, Google, Apple, 카카오)
Database: Cloud Firestore
Storage: Firebase Storage (이미지)
Functions: Cloud Functions (Node.js / TypeScript)
Search: Algolia 또는 Firestore 쿼리
Push: Firebase Cloud Messaging (FCM)
```

### 2.3 외부 API
```
책 정보 API: 
  - 1순위: 알라딘 API (국내 책 DB 최대)
  - 2순위: 네이버 책 검색 API
  - 3순위: 카카오 책 검색 API
  - ISBN 기반 조회 지원
택배 추적: 스마트택배 API (Delivery Tracker)
지도: Google Maps API
```

### 2.4 프로젝트 구조 (Flutter)
```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp 설정
│   ├── routes.dart                 # GoRouter 라우팅
│   └── theme/
│       ├── app_theme.dart          # 테마 정의
│       ├── app_colors.dart         # 컬러 팔레트
│       ├── app_typography.dart     # 텍스트 스타일
│       └── app_dimensions.dart     # 간격/크기 상수
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── asset_paths.dart
│   │   └── enums.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart         # Dio 클라이언트
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── location_helper.dart
│   │   └── image_helper.dart
│   └── services/
│       ├── notification_service.dart
│       ├── location_service.dart
│       ├── barcode_service.dart
│       └── storage_service.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── book_model.dart
│   │   ├── book_info_model.dart    # 책 메타 정보 (API/커뮤니티DB)
│   │   ├── exchange_request_model.dart
│   │   ├── match_model.dart
│   │   ├── chat_model.dart
│   │   ├── message_model.dart
│   │   ├── review_model.dart
│   │   ├── notification_model.dart
│   │   ├── report_model.dart
│   │   └── delivery_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── book_repository.dart
│   │   ├── book_info_repository.dart
│   │   ├── exchange_repository.dart
│   │   ├── chat_repository.dart
│   │   ├── review_repository.dart
│   │   ├── notification_repository.dart
│   │   └── delivery_repository.dart
│   └── datasources/
│       ├── remote/
│       │   ├── firebase_auth_datasource.dart
│       │   ├── firestore_datasource.dart
│       │   ├── firebase_storage_datasource.dart
│       │   ├── book_api_datasource.dart   # 알라딘/네이버/카카오 API
│       │   └── delivery_api_datasource.dart
│       └── local/
│           └── local_cache_datasource.dart
├── providers/
│   ├── auth_providers.dart
│   ├── user_providers.dart
│   ├── book_providers.dart
│   ├── exchange_providers.dart
│   ├── chat_providers.dart
│   ├── notification_providers.dart
│   └── location_providers.dart
└── features/
    ├── auth/
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── onboarding_screen.dart
    │   │   ├── login_screen.dart
    │   │   └── signup_screen.dart
    │   └── widgets/
    │       ├── social_login_buttons.dart
    │       └── terms_checkbox.dart
    ├── home/
    │   ├── screens/
    │   │   └── home_screen.dart            # 메인 탭 컨테이너
    │   └── widgets/
    │       ├── home_app_bar.dart
    │       ├── location_selector.dart
    │       ├── book_feed_list.dart
    │       ├── book_feed_card.dart
    │       └── category_filter_chips.dart
    ├── search/
    │   ├── screens/
    │   │   ├── search_screen.dart
    │   │   └── search_results_screen.dart
    │   └── widgets/
    │       ├── search_bar_widget.dart
    │       ├── recent_search_list.dart
    │       ├── search_filter_sheet.dart
    │       └── search_result_card.dart
    ├── book_register/
    │   ├── screens/
    │   │   ├── book_search_register_screen.dart  # 책 검색 후 등록
    │   │   ├── barcode_scan_screen.dart           # 바코드 스캔
    │   │   ├── manual_register_screen.dart        # 수동 등록 (DB에 없는 책)
    │   │   └── book_condition_screen.dart         # 책 상태/실물 사진
    │   └── widgets/
    │       ├── book_info_preview_card.dart
    │       ├── condition_selector.dart
    │       ├── photo_upload_widget.dart
    │       └── isbn_scanner_overlay.dart
    ├── book_detail/
    │   ├── screens/
    │   │   └── book_detail_screen.dart
    │   └── widgets/
    │       ├── book_info_section.dart
    │       ├── owner_info_section.dart
    │       ├── condition_photos_section.dart
    │       ├── exchange_request_button.dart
    │       └── similar_books_section.dart
    ├── my_bookshelf/
    │   ├── screens/
    │   │   ├── my_bookshelf_screen.dart
    │   │   └── book_edit_screen.dart
    │   └── widgets/
    │       ├── bookshelf_grid.dart
    │       ├── bookshelf_list.dart
    │       ├── book_status_badge.dart
    │       └── empty_bookshelf_widget.dart
    ├── wishlist/
    │   ├── screens/
    │   │   └── wishlist_screen.dart
    │   └── widgets/
    │       ├── wishlist_item_card.dart
    │       └── wishlist_match_alert.dart
    ├── exchange/
    │   ├── screens/
    │   │   ├── exchange_request_screen.dart    # 교환 요청 보내기
    │   │   ├── incoming_requests_screen.dart   # 받은 요청 목록
    │   │   ├── requester_bookshelf_screen.dart # 요청자 책장 보기
    │   │   ├── match_confirm_screen.dart       # 매칭 확인
    │   │   ├── exchange_method_screen.dart     # 거래 방식 선택
    │   │   └── exchange_history_screen.dart    # 교환 내역
    │   └── widgets/
    │       ├── exchange_request_card.dart
    │       ├── match_animation_widget.dart     # 매칭 성공 애니메이션
    │       ├── exchange_status_timeline.dart
    │       └── delivery_tracking_widget.dart
    ├── relay_exchange/
    │   ├── screens/
    │   │   ├── relay_suggest_screen.dart       # 릴레이 교환 제안
    │   │   └── relay_route_screen.dart         # 교환 루트 시각화
    │   └── widgets/
    │       ├── relay_chain_widget.dart
    │       └── relay_participant_card.dart
    ├── chat/
    │   ├── screens/
    │   │   ├── chat_list_screen.dart
    │   │   └── chat_room_screen.dart
    │   └── widgets/
    │       ├── chat_bubble.dart
    │       ├── chat_input_bar.dart
    │       ├── image_message_widget.dart
    │       ├── exchange_status_message.dart    # 시스템 메시지
    │       └── chat_list_tile.dart
    ├── profile/
    │   ├── screens/
    │   │   ├── my_profile_screen.dart
    │   │   ├── user_profile_screen.dart       # 다른 사용자 프로필
    │   │   ├── edit_profile_screen.dart
    │   │   └── settings_screen.dart
    │   └── widgets/
    │       ├── profile_header.dart
    │       ├── book_temperature_widget.dart    # 책다리 온도
    │       ├── badge_grid.dart
    │       ├── activity_stats_card.dart
    │       └── review_list_widget.dart
    ├── review/
    │   ├── screens/
    │   │   └── write_review_screen.dart
    │   └── widgets/
    │       ├── star_rating_widget.dart
    │       ├── review_tag_selector.dart
    │       └── review_card.dart
    ├── notification/
    │   ├── screens/
    │   │   ├── notification_list_screen.dart
    │   │   └── notification_settings_screen.dart
    │   └── widgets/
    │       ├── notification_tile.dart
    │       └── alarm_sound_selector.dart      # 커스텀 알림음 선택
    ├── book_club/
    │   ├── screens/
    │   │   ├── book_club_list_screen.dart
    │   │   ├── book_club_detail_screen.dart
    │   │   └── create_book_club_screen.dart
    │   └── widgets/
    │       ├── book_club_card.dart
    │       └── member_list_widget.dart
    ├── ranking/
    │   ├── screens/
    │   │   └── ranking_screen.dart
    │   └── widgets/
    │       ├── popular_books_chart.dart
    │       ├── top_exchanger_list.dart
    │       └── exchange_difficulty_badge.dart
    ├── stats/
    │   ├── screens/
    │   │   └── my_stats_screen.dart           # 환경 기여 통계
    │   └── widgets/
    │       ├── eco_impact_card.dart
    │       ├── exchange_history_chart.dart
    │       └── genre_distribution_chart.dart
    └── common/
        └── widgets/
            ├── custom_app_bar.dart
            ├── loading_widget.dart
            ├── error_widget.dart
            ├── empty_state_widget.dart
            ├── custom_bottom_nav.dart
            ├── book_card.dart                 # 공통 책 카드
            ├── user_avatar.dart
            ├── location_badge.dart
            ├── genre_chip.dart
            └── confirm_dialog.dart
```

---

## 3. 데이터 모델 (Firestore Collections)

### 3.1 users (사용자)
```dart
class UserModel {
  final String uid;                    // Firebase Auth UID
  final String nickname;               // 닉네임
  final String? profileImageUrl;       // 프로필 이미지
  final String email;                  // 이메일
  final String? phone;                 // 전화번호 (선택)
  final String primaryLocation;        // 주 활동 지역 (시/구/동)
  final GeoPoint geoPoint;             // 위치 좌표
  final double bookTemperature;        // 책다리 온도 (초기 36.5)
  final int totalExchanges;            // 총 교환 횟수
  final List<String> badges;           // 획득 뱃지 목록
  final int level;                     // 레벨
  final int points;                    // 포인트
  final String notificationSound;      // 선택된 알림음
  final Map<String, bool> notificationSettings; // 알림 세부 설정
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isVerified;               // 본인인증 여부
  final String status;                 // active, suspended, deleted
}
```

### 3.2 book_info (책 메타 정보 - 커뮤니티 DB)
```dart
class BookInfoModel {
  final String id;                     // 문서 ID (ISBN 기반 또는 자동생성)
  final String? isbn;                  // ISBN (없을 수 있음)
  final String title;                  // 책 제목
  final String author;                 // 저자
  final String? publisher;             // 출판사
  final String? publishDate;           // 출판일
  final String? coverImageUrl;         // 표지 이미지 URL
  final String? description;           // 책 소개/줄거리
  final String genre;                  // 장르 카테고리
  final String? subGenre;              // 세부 장르
  final int pageCount;                 // 페이지 수
  final String source;                 // 'api' | 'user_contributed'
  final String? contributedByUid;      // 사용자 등록인 경우 UID
  final int exchangeCount;             // 이 책의 총 교환 횟수 (인기도)
  final int wishlistCount;             // 위시리스트에 담긴 횟수
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3.3 books (사용자가 등록한 개별 책)
```dart
class BookModel {
  final String id;                     // 문서 ID
  final String ownerUid;               // 소유자 UID
  final String bookInfoId;             // book_info 참조 ID
  final String title;                  // 책 제목 (검색 편의)
  final String author;                 // 저자
  final String? coverImageUrl;         // 표지 이미지
  final List<String> conditionPhotos;  // 실물 사진 URL 목록 (최소 1장, 최대 5장)
  final String condition;              // 'best' | 'good' | 'fair' | 'poor'
  final String? conditionNote;         // 상태 설명 (메모)
  final String status;                 // 'available' | 'reserved' | 'exchanged' | 'hidden'
  final String exchangeType;           // 'local_only' | 'delivery_only' | 'both'
  final String location;               // 거래 희망 지역
  final GeoPoint geoPoint;             // 위치 좌표
  final String genre;                  // 장르
  final List<String> tags;             // 사용자 태그
  final int viewCount;                 // 조회수
  final int wishCount;                 // 찜 횟수
  final int requestCount;              // 교환 요청 횟수
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3.4 exchange_requests (교환 요청)
```dart
class ExchangeRequestModel {
  final String id;
  final String requesterUid;           // 요청자 UID
  final String ownerUid;               // 책 소유자 UID
  final String targetBookId;           // 요청 대상 책 ID
  final String? selectedBookId;        // 소유자가 선택한 요청자의 책 ID (매칭 시)
  final String status;                 // 'pending' | 'viewing' | 'matched' | 'rejected' | 'cancelled' | 'completed'
  final String? message;               // 요청 메시지
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? matchedAt;
  final DateTime? completedAt;
}
```

### 3.5 matches (매칭 성립)
```dart
class MatchModel {
  final String id;
  final String exchangeRequestId;      // 원본 교환 요청 ID
  final String userAUid;               // 사용자 A (최초 요청자)
  final String userBUid;               // 사용자 B (책 소유자)
  final String bookAId;                // A가 보내는 책
  final String bookBId;                // B가 보내는 책
  final String exchangeMethod;         // 'local' | 'delivery'
  final String? meetingLocation;       // 직거래 장소 (직거래인 경우)
  final GeoPoint? meetingGeoPoint;     // 직거래 장소 좌표
  final DateTime? meetingDateTime;     // 직거래 일시
  final String status;                 // 'confirmed' | 'in_progress' | 'completed' | 'cancelled'
  final String chatRoomId;             // 채팅방 ID
  final DeliveryModel? deliveryA;      // A의 배송 정보
  final DeliveryModel? deliveryB;      // B의 배송 정보
  final bool userAConfirmed;           // A 수령 확인
  final bool userBConfirmed;           // B 수령 확인
  final DateTime createdAt;
  final DateTime? completedAt;
}
```

### 3.6 delivery (택배 정보)
```dart
class DeliveryModel {
  final String? carrier;               // 택배사
  final String? trackingNumber;        // 운송장 번호
  final String status;                 // 'pending' | 'shipped' | 'in_transit' | 'delivered'
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
}
```

### 3.7 chat_rooms (채팅방)
```dart
class ChatRoomModel {
  final String id;
  final List<String> participants;     // 참여자 UID 리스트
  final String matchId;                // 매칭 ID
  final String? lastMessage;           // 마지막 메시지 미리보기
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;  // 사용자별 안 읽은 수
  final DateTime createdAt;
}
```

### 3.8 messages (채팅 메시지)
```dart
class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderUid;
  final String type;                   // 'text' | 'image' | 'system' | 'location'
  final String content;                // 메시지 내용
  final String? imageUrl;              // 이미지 URL
  final bool isRead;
  final DateTime createdAt;
}
```

### 3.9 reviews (후기)
```dart
class ReviewModel {
  final String id;
  final String matchId;                // 매칭 ID
  final String reviewerUid;            // 작성자 UID
  final String revieweeUid;            // 대상자 UID
  final double rating;                 // 별점 (1.0 ~ 5.0)
  final double bookConditionAccuracy;  // 책 상태 정확도 (1~5)
  final double responseSpeed;          // 응답 속도 (1~5)
  final double manner;                 // 매너 (1~5)
  final String? comment;               // 텍스트 후기
  final List<String> tags;             // 후기 태그 ["빠른 응답", "상태 정확", "친절"]
  final DateTime createdAt;
}
```

### 3.10 notifications (알림)
```dart
class NotificationModel {
  final String id;
  final String targetUid;              // 수신자 UID
  final String type;                   // 'exchange_request' | 'match' | 'chat' | 'wishlist_match' | 'review' | 'delivery' | 'system' | 'relay'
  final String title;
  final String body;
  final Map<String, dynamic>? data;    // 추가 데이터 (bookId, matchId 등)
  final bool isRead;
  final DateTime createdAt;
}
```

### 3.11 wishlists (위시리스트)
```dart
class WishlistModel {
  final String id;
  final String userUid;
  final String bookInfoId;             // book_info 참조
  final String title;                  // 책 제목 (검색 편의)
  final DateTime createdAt;
  final bool isNotified;               // 매칭 알림 발송 여부
}
```

### 3.12 book_clubs (독서 모임)
```dart
class BookClubModel {
  final String id;
  final String name;
  final String description;
  final String creatorUid;
  final String location;               // 모임 지역
  final GeoPoint geoPoint;
  final List<String> memberUids;
  final int maxMembers;
  final String? currentBookInfoId;     // 현재 읽는 책
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? nextMeetingAt;
}
```

### 3.13 reports (신고)
```dart
class ReportModel {
  final String id;
  final String reporterUid;
  final String reportedUid;
  final String? reportedBookId;
  final String reason;                 // 'fake_book' | 'no_show' | 'fraud' | 'inappropriate' | 'spam' | 'other'
  final String? description;
  final List<String>? evidencePhotos;
  final String status;                 // 'pending' | 'reviewed' | 'resolved'
  final DateTime createdAt;
}
```

### 3.14 relay_exchanges (릴레이/다자 교환)
```dart
class RelayExchangeModel {
  final String id;
  final List<RelayParticipant> participants;  // 참여자 체인
  final String status;                 // 'proposed' | 'all_confirmed' | 'in_progress' | 'completed' | 'cancelled'
  final DateTime createdAt;
  final DateTime? completedAt;
}

class RelayParticipant {
  final String uid;
  final String givingBookId;           // 보내는 책
  final String receivingBookId;        // 받는 책
  final String receivingFromUid;       // 누구로부터 받는지
  final bool confirmed;                // 참여 확인
}
```

---

## 4. 화면 흐름 (Navigation Flow)

### 4.1 바텀 네비게이션 구조
```
[홈] [검색] [등록(+)] [채팅] [마이]
```

### 4.2 상세 화면 흐름

#### 인증 플로우
```
앱 실행 → 스플래시 → 
  ├── (비로그인) → 온보딩(3페이지 스와이프) → 로그인 화면
  │     ├── 카카오 로그인
  │     ├── 구글 로그인
  │     ├── 애플 로그인 (iOS only)
  │     └── 이메일 로그인/회원가입
  │         └── 회원가입 → 닉네임 설정 → 위치 설정 → 완료 → 홈
  └── (로그인됨) → 홈
```

#### 홈 탭 플로우
```
홈 화면
├── 상단: 지역 선택 드롭다운 | 알림 아이콘 (뱃지)
├── 장르 필터 칩 (가로 스크롤): 전체, 소설, 비소설, 자기계발, 만화, ...
├── 정렬: 최신순 | 인기순 | 가까운순
├── 피드 리스트 (무한 스크롤)
│   └── 책 카드 탭 → 책 상세 화면
│       ├── 책 정보 (표지, 제목, 저자, 줄거리)
│       ├── 소유자 정보 (닉네임, 온도, 위치, 거리)
│       ├── 책 상태 (등급 + 실물 사진 갤러리)
│       ├── 교환 요청 버튼
│       │   └── 교환 요청 화면 (메시지 작성) → 요청 발송
│       ├── 찜 버튼
│       └── 신고 버튼
└── 알림 아이콘 → 알림 목록 화면
```

#### 검색 탭 플로우
```
검색 화면
├── 검색바 (텍스트 입력)
├── 최근 검색어
├── 인기 검색어
└── 검색 결과
    ├── 필터 시트 (장르, 지역, 책 상태, 거래방식)
    └── 결과 리스트 → 책 상세 화면
```

#### 등록(+) 탭 플로우
```
등록 화면
├── [바코드 스캔] 버튼
│   └── 카메라 → 바코드 인식 → ISBN → API 조회 → 책 정보 미리보기
│       ├── (정보 있음) → 확인 → 상태 입력 화면
│       └── (정보 없음) → 수동 등록 화면
├── [책 제목 검색] 버튼
│   └── 검색 입력 → API 조회 → 검색 결과 리스트
│       └── 책 선택 → 책 정보 미리보기 → 상태 입력 화면
└── [직접 등록] 버튼
    └── 수동 등록 화면
        ├── 제목, 저자, 출판사, 장르 입력
        ├── 표지 이미지 업로드 (촬영/갤러리)
        ├── 줄거리/소개 입력
        └── 저장 → 커뮤니티 DB에 추가 → 상태 입력 화면

상태 입력 화면 (공통)
├── 책 상태 선택: 최상 / 상 / 중 / 하
├── 상태 메모 (선택)
├── 실물 사진 업로드 (최소 1장, 최대 5장)
│   ├── 앞표지, 뒷표지, 책등, 특이사항 등
│   └── 촬영 가이드 오버레이 표시
├── 거래 방식 선택: 직거래만 / 택배만 / 모두
├── 거래 희망 지역 (직거래 시)
├── 태그 입력 (선택)
└── 등록 완료 → 내 책장에 추가
```

#### 채팅 탭 플로우
```
채팅 목록 화면
├── 채팅방 리스트 (최근 순)
│   ├── 상대 프로필 이미지, 닉네임
│   ├── 마지막 메시지 미리보기
│   ├── 시간
│   └── 안 읽은 메시지 뱃지
└── 채팅방 탭 → 채팅 화면
    ├── 상단: 상대 닉네임 | 교환 상태 바
    ├── 메시지 영역
    │   ├── 텍스트 메시지
    │   ├── 이미지 메시지
    │   ├── 시스템 메시지 (매칭 성립, 배송 상태 등)
    │   └── 위치 공유 메시지
    ├── 입력바: 텍스트 입력 | 이미지 첨부 | 위치 공유
    └── 더보기 메뉴
        ├── 교환 상태 변경
        ├── 운송장 입력 (택배 거래 시)
        ├── 수령 확인
        ├── 상대 프로필 보기
        ├── 신고
        └── 나가기
```

#### 마이 탭 플로우
```
마이 프로필 화면
├── 프로필 헤더
│   ├── 프로필 이미지, 닉네임, 위치
│   ├── 책다리 온도 게이지
│   ├── 교환 횟수, 레벨, 뱃지
│   └── 프로필 편집 버튼
├── [내 책장] → 내 책장 화면
│   ├── 그리드/리스트 뷰 토글
│   ├── 상태 필터: 교환가능 / 예약중 / 교환완료 / 숨김
│   └── 책 탭 → 수정/삭제/상태변경
├── [위시리스트] → 위시리스트 화면
├── [교환 내역] → 교환 내역 화면
│   ├── 진행중 탭
│   │   ├── 보낸 요청 목록
│   │   ├── 받은 요청 목록
│   │   └── 진행중 매칭 목록
│   └── 완료 탭
│       └── 완료된 교환 목록 (후기 작성 버튼)
├── [받은 후기] → 후기 목록 화면
├── [관심 목록 (찜)] → 찜 목록 화면
├── [동네 책모임] → 책모임 목록 화면
├── [나의 통계] → 환경 기여 통계 화면
│   ├── 총 교환 권수
│   ├── 환경 기여도 (종이 절약량, CO2 절감량)
│   ├── 장르별 교환 분포 차트
│   └── 월별 교환 추이 차트
├── [랭킹] → 랭킹 화면
│   ├── 교환왕 (월간/전체)
│   ├── 인기 책 TOP 20
│   └── 교환 난이도 높은 책
└── [설정] → 설정 화면
    ├── 계정 관리
    ├── 알림 설정
    │   ├── 전체 ON/OFF
    │   ├── 유형별 ON/OFF
    │   └── 알림음 선택
    │       ├── 책 넘기는 소리
    │       ├── "책다리" 효과음
    │       ├── 도서관 벨 소리
    │       ├── 연필 쓰는 소리
    │       ├── 기본 알림음
    │       └── 무음
    ├── 지역 설정
    ├── 차단 사용자 관리
    ├── 이용약관/개인정보처리방침
    ├── 오픈소스 라이선스
    ├── 앱 버전
    └── 로그아웃 / 회원탈퇴
```

#### 교환 매칭 플로우 (핵심)
```
== 1:1 교환 ==
A: B의 책 발견 → "교환 요청" 탭
A: 메시지 작성 (선택) → 요청 발송
   → B에게 푸시 알림: "A님이 [책 제목]에 교환을 요청했어요!"

B: 알림 탭 or 교환내역 → 받은 요청 확인
B: "A의 책장 보기" 탭
   → A의 교환가능 책 목록 열람
B: 마음에 드는 책 선택 → "이 책과 교환하기" 탭
   → 매칭 성립!
   → A, B 모두에게 푸시 알림: "매칭이 성립되었어요! 🎉"
   → 매칭 성공 애니메이션 (두 책이 만나는 모션)

A & B: 자동 생성된 채팅방에서 거래 방식 협의
├── 직거래: 장소/시간 협의 → 만남 → 교환 → 수령 확인 → 후기
└── 택배: 주소 교환 → 각자 발송 → 운송장 입력 → 배송 추적 → 수령 확인 → 후기

== 1:N 릴레이 교환 (고급 기능) ==
시스템이 매칭 불일치를 감지:
  A가 B의 책을 원하지만 B는 A의 책에 관심 없음
  그러나 B는 C의 책을 원하고, C는 A의 책을 원함
→ 시스템 제안: "A→B, B→C, C→A 릴레이 교환이 가능해요!"
→ 세 사용자 모두 확인 → 각각 발송 → 완료

== 묶음 교환 ==
A: B에게 교환 요청 시 여러 권 선택 가능
   예: "내 3권 ↔ 네 2권" 제안
B: 수락/수정/거절
```

---

## 5. 핵심 비즈니스 로직

### 5.1 책다리 온도 계산
```
초기 온도: 36.5도

가산 요소:
  교환 완료: +0.5도
  후기 별점 4.5 이상: +0.3도
  후기 별점 4.0 이상: +0.1도
  릴레이 교환 성공: +0.7도
  책모임 활동: +0.2도
  
감산 요소:
  교환 노쇼(미이행): -2.0도
  신고 접수 확인: -3.0도
  후기 별점 2.0 이하: -0.5도
  교환 취소 (매칭 후): -0.3도

범위: 0도 ~ 100도
```

### 5.2 포인트 시스템
```
포인트 획득:
  책 기부 등록 (교환 없이 무료 제공): +100P
  교환 완료: +50P
  후기 작성: +10P
  커뮤니티 DB에 새 책 정보 등록: +30P
  일일 출석: +5P
  
포인트 사용:
  교환 상대 없이 책 가져가기: -100P ~ -300P (책 인기도에 따라)
```

### 5.3 레벨 & 뱃지 시스템
```
레벨:
  Lv.1 새싹 독서가: 0~2회 교환
  Lv.2 책벌레: 3~9회 교환
  Lv.3 책다리 메이트: 10~29회 교환
  Lv.4 책다리 마스터: 30~99회 교환
  Lv.5 책다리 전설: 100회 이상

뱃지:
  📚 첫 교환: 첫 번째 교환 완료
  🔥 연속왕: 7일 연속 앱 접속
  🌈 장르탐험가: 5개 이상 다른 장르 교환
  🤝 릴레이킹: 릴레이 교환 3회 이상 참여
  ⭐ 별점왕: 평균 평점 4.8 이상 (10회 이상)
  🌱 에코히어로: 50권 이상 교환 (환경 기여)
  📖 책모임장: 책모임 3회 이상 개최
  🎯 매칭마스터: 요청 수락률 90% 이상
  💎 초기멤버: 서비스 런칭 후 1개월 내 가입
  📸 등록왕: 커뮤니티 DB에 10권 이상 책 정보 등록
```

### 5.4 교환 난이도 & 인기도 표시
```
교환 난이도 = (위시리스트 등록 수) / (교환 가능 등록 수)
  높음 (🔴): 비율 > 5
  보통 (🟡): 비율 1~5
  낮음 (🟢): 비율 < 1

인기 책 = 최근 30일 기준 교환 요청 수 TOP 순위
```

### 5.5 검색 & 필터 로직
```
검색 대상: 책 제목, 저자, 태그
필터:
  - 장르: 소설, 비소설, 자기계발, 경영, 과학, IT, 만화, 에세이, 시, 역사, 어린이, 외국어, 기타
  - 거래 방식: 직거래 / 택배 / 전체
  - 지역: 시/도 → 시/군/구 → 동/면/리
  - 거리: 1km / 3km / 5km / 10km / 제한없음
  - 책 상태: 최상 / 상 / 중 / 하
  - 정렬: 최신순 / 인기순 / 가까운순 / 교환난이도순
```

### 5.6 위시리스트 매칭 알림 로직
```
트리거: 새 책이 등록될 때
1. 등록된 책의 bookInfoId를 wishlists 컬렉션에서 검색
2. 매칭되는 위시리스트 소유자에게 푸시 알림 발송
   "찾고 계신 [책 제목]이 [지역]에 등록되었어요! 📚"
3. isNotified = true로 업데이트
```

---

## 6. UI/UX 디자인 가이드라인

### 6.1 컬러 팔레트
```dart
class AppColors {
  // Primary - 따뜻한 브라운 계열 (책/나무 느낌)
  static const primary = Color(0xFF8B6914);       // 골든 브라운
  static const primaryLight = Color(0xFFD4A843);  // 라이트 골드
  static const primaryDark = Color(0xFF5C4510);   // 다크 브라운
  
  // Secondary - 그린 계열 (환경/성장)
  static const secondary = Color(0xFF4A7C59);     // 포레스트 그린
  static const secondaryLight = Color(0xFF7DB88E);
  
  // Accent
  static const accent = Color(0xFFE8734A);        // 코랄 오렌지 (CTA)
  
  // Neutral
  static const background = Color(0xFFF5F0E8);    // 크림색 배경 (종이 느낌)
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2D2416);
  static const textSecondary = Color(0xFF7A6B5A);
  static const divider = Color(0xFFE0D5C5);
  
  // Status
  static const success = Color(0xFF4A7C59);
  static const warning = Color(0xFFE8A834);
  static const error = Color(0xFFD64045);
  static const info = Color(0xFF4A90A4);
  
  // Temperature
  static const tempCold = Color(0xFF4A90A4);      // 낮은 온도
  static const tempWarm = Color(0xFFE8A834);      // 보통 온도
  static const tempHot = Color(0xFFD64045);       // 높은 온도
}
```

### 6.2 타이포그래피
```dart
// 폰트: 프리텐다드 (Pretendard) - 한글 가독성 우수, 무료
// 보조 폰트: Nanum Myeongjo - 책 제목 등 포인트용

class AppTypography {
  static const headlineLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const headlineMedium = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const headlineSmall = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const titleLarge = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400);
}
```

### 6.3 아이콘 & 일러스트 스타일
```
스타일: 라인 아이콘 + 따뜻한 일러스트
라이브러리: Lucide Icons 또는 커스텀 SVG
빈 상태 일러스트: 
  - 빈 책장: 책이 없는 나무 선반 일러스트
  - 검색 결과 없음: 돋보기 든 귀여운 책벌레
  - 매칭 성공: 두 책이 다리 위에서 만나는 모션
  - 첫 교환 축하: 책 위에 앉은 캐릭터 + 축하 이펙트
앱 아이콘: 두 권의 책이 다리 모양으로 연결된 미니멀 디자인
```

### 6.4 애니메이션
```
매칭 성공: Lottie 애니메이션 - 두 책이 날아와서 다리 위에서 만남
교환 완료: confetti 이펙트
레벨업: 뱃지 획득 팝업 + 빛나는 이펙트
책 등록: 책이 책장에 꽂히는 애니메이션
당겨서 새로고침: 책 넘기는 모션
```

---

## 7. 알림 시스템 상세

### 7.1 알림 유형
```
1. exchange_request: "A님이 [책 제목]에 교환을 요청했어요!"
2. match: "축하해요! [책 제목] ↔ [책 제목] 매칭이 성사되었어요! 🎉"
3. chat: "A님: [메시지 미리보기]"
4. wishlist_match: "찾고 계신 [책 제목]이 근처에 등록되었어요! 📚"
5. delivery_shipped: "A님이 책을 발송했어요! 운송장: XXX"
6. delivery_arrived: "책이 도착했어요! 수령 확인을 해주세요."
7. review_request: "교환이 완료되었어요! 후기를 남겨주세요. ⭐"
8. review_received: "A님이 후기를 남겼어요!"
9. relay_suggest: "릴레이 교환이 가능해요! 확인해보세요. 🔄"
10. level_up: "레벨업! [레벨명]이 되었어요! 🎉"
11. badge: "[뱃지명] 뱃지를 획득했어요! 🏆"
12. system: 공지사항, 이벤트 등
```

### 7.2 커스텀 알림음 (사운드 파일)
```
assets/sounds/
├── notification_page_turn.mp3        # 책 넘기는 소리
├── notification_bookbridge.mp3       # "책다리" 효과음
├── notification_library_bell.mp3     # 도서관 벨
├── notification_pencil_write.mp3     # 연필 쓰는 소리
├── notification_book_close.mp3       # 책 닫는 소리 (뚝)
├── notification_bookmark.mp3         # 책갈피 끼우는 소리
├── notification_default.mp3          # 기본 알림음
└── notification_silent.mp3           # 무음 (진동만)
```

---

## 8. 보안 & 정책

### 8.1 Firestore Security Rules
```
- 사용자는 자신의 프로필만 수정 가능
- 책은 소유자만 수정/삭제 가능
- 채팅은 참여자만 읽기/쓰기 가능
- 후기는 매칭 당사자만 작성 가능, 수정 불가
- 신고는 누구나 작성 가능, 수정/삭제 불가
- 관리자 역할: reports 처리, 사용자 제재
```

### 8.2 이용 정책
```
- 교환 가능 물품: 책만 (전자책 코드, 잡지는 별도 카테고리)
- 금지 물품: 불법 복제본, 성인물(별도 인증 필요), 손상이 심한 책
- 제재 기준:
  - 1차 경고: 부적절 등록
  - 2차 경고: 7일 이용 제한
  - 3차: 영구 정지
- 노쇼 3회 → 30일 교환 요청 불가
```

---

## 9. 개발 단계 (Phased Approach)

### Phase 1: MVP (핵심 기능) - 8~12주
```
[ ] 프로젝트 세팅 (Flutter, Firebase, 폴더 구조)
[ ] 인증 (카카오, 구글, 애플, 이메일)
[ ] 사용자 프로필 (기본 CRUD)
[ ] 책 등록 (API 자동완성 + 바코드 스캔 + 수동 등록)
[ ] 커뮤니티 책 DB (book_info 컬렉션)
[ ] 내 책장 (등록된 책 관리)
[ ] 홈 피드 (지역 기반 책 목록)
[ ] 검색 & 필터
[ ] 교환 요청 & 매칭 (1:1 기본)
[ ] 채팅 (1:1 실시간)
[ ] 기본 푸시 알림
[ ] 후기 & 평가
[ ] 책다리 온도
```

### Phase 2: 확장 기능 - 4~6주
```
[ ] 택배 거래 (운송장 입력, 배송 추적)
[ ] 위시리스트 & 매칭 알림
[ ] 포인트 시스템
[ ] 레벨 & 뱃지
[ ] 찜 기능
[ ] 커스텀 알림음
[ ] 묶음 교환 (다권 교환)
[ ] 신고/차단 기능
[ ] 랭킹 (교환왕, 인기 책)
[ ] 환경 기여 통계
```

### Phase 3: 고급 기능 - 4~6주
```
[ ] 릴레이 교환 (1:N 다자 교환 매칭 알고리즘)
[ ] 동네 책모임
[ ] 교환 난이도 표시
[ ] 매칭 애니메이션 (Lottie)
[ ] Flutter Web 최적화
[ ] 성능 최적화 & 캐싱
[ ] 접근성 (a11y)
[ ] 다국어 지원 (추후)
```

### Phase 4: 런칭 준비 - 2~3주
```
[ ] App Store / Play Store 심사 준비
[ ] 랜딩 페이지 (웹)
[ ] 개인정보처리방침, 이용약관 작성
[ ] 베타 테스트
[ ] 버그 수정 & QA
[ ] 앱스토어 스크린샷 & 설명문
```

---

## 10. Firebase 컬렉션 인덱스 (필수)

### Firestore Composite Indexes
```
books:
  - status ASC, createdAt DESC (피드 쿼리)
  - status ASC, genre ASC, createdAt DESC (장르 필터)
  - status ASC, location ASC, createdAt DESC (지역 필터)
  - ownerUid ASC, status ASC, createdAt DESC (내 책장)

exchange_requests:
  - ownerUid ASC, status ASC, createdAt DESC (받은 요청)
  - requesterUid ASC, status ASC, createdAt DESC (보낸 요청)

wishlists:
  - bookInfoId ASC, createdAt DESC (위시리스트 매칭)
  - userUid ASC, createdAt DESC (내 위시리스트)

notifications:
  - targetUid ASC, isRead ASC, createdAt DESC

messages:
  - chatRoomId ASC, createdAt ASC

reviews:
  - revieweeUid ASC, createdAt DESC
```

---

## 11. 에셋 목록

### 11.1 이미지
```
assets/images/
├── logo/
│   ├── logo_full.svg            # 전체 로고 (텍스트 포함)
│   ├── logo_icon.svg            # 아이콘만
│   └── logo_splash.svg          # 스플래시용
├── onboarding/
│   ├── onboarding_1.svg         # 슬라이드 1: 내 책장에 등록해요
│   ├── onboarding_2.svg         # 슬라이드 2: 원하는 책을 찾아요
│   └── onboarding_3.svg         # 슬라이드 3: 책으로 연결되는 다리
├── empty_states/
│   ├── empty_bookshelf.svg      # 빈 책장
│   ├── empty_search.svg         # 검색 결과 없음
│   ├── empty_chat.svg           # 채팅 없음
│   ├── empty_notification.svg   # 알림 없음
│   └── empty_wishlist.svg       # 위시리스트 없음
├── badges/
│   ├── badge_first_exchange.svg
│   ├── badge_streak.svg
│   ├── badge_genre_explorer.svg
│   ├── badge_relay_king.svg
│   ├── badge_star.svg
│   ├── badge_eco_hero.svg
│   ├── badge_club_leader.svg
│   ├── badge_matching_master.svg
│   ├── badge_early_bird.svg
│   └── badge_contributor.svg
└── misc/
    ├── camera_guide_overlay.png  # 책 촬영 가이드
    └── default_book_cover.svg    # 기본 책 표지
```

### 11.2 Lottie 애니메이션
```
assets/lottie/
├── match_success.json           # 매칭 성공
├── exchange_complete.json       # 교환 완료 (confetti)
├── level_up.json                # 레벨업
├── loading_book.json            # 로딩 (책 넘기기)
├── pull_refresh.json            # 당겨서 새로고침
└── empty_search.json            # 검색 중 애니메이션
```

---

## 12. 테스트 전략

```
Unit Tests:
  - 모든 Repository 메서드
  - 비즈니스 로직 (온도 계산, 포인트 계산, 매칭 알고리즘)
  - Validator (입력값 검증)

Widget Tests:
  - 주요 화면별 렌더링 테스트
  - 사용자 인터랙션 테스트

Integration Tests:
  - 교환 요청 → 매칭 → 채팅 → 완료 전체 플로우
  - 책 등록 플로우 (바코드 스캔 → 등록)
  - 인증 플로우
```

---

## 13. Claude Code 오케스트레이션 작업 분할 가이드

이 기획서를 Claude Code 오케스트레이션으로 작업할 때 아래 순서로 Task를 나누는 것을 권장합니다:

### Task 1: 프로젝트 초기 세팅
```
- Flutter 프로젝트 생성
- 폴더 구조 생성 (위 프로젝트 구조 참고)
- pubspec.yaml 패키지 추가
- 테마/컬러/타이포그래피 설정
- GoRouter 기본 라우팅 설정
- Firebase 프로젝트 연결 설정
```

### Task 2: 데이터 레이어
```
- 모든 데이터 모델 클래스 생성
- Firestore datasource 구현
- Repository 구현
- Riverpod providers 설정
```

### Task 3: 인증 기능
```
- Firebase Auth 연동
- 로그인/회원가입 화면
- 소셜 로그인 (카카오, 구글, 애플)
- 온보딩 화면
- 스플래시 화면
```

### Task 4: 홈 & 검색
```
- 홈 피드 화면
- 책 카드 위젯
- 검색 화면
- 필터 시트
- 지역 선택
```

### Task 5: 책 등록 기능
```
- 책 검색 API 연동 (알라딘/네이버/카카오)
- 바코드 스캔 기능
- 자동완성 등록 화면
- 수동 등록 화면
- 커뮤니티 DB 저장
- 책 상태/사진 등록 화면
```

### Task 6: 내 책장 & 위시리스트
```
- 내 책장 화면 (그리드/리스트)
- 책 수정/삭제/상태변경
- 위시리스트 화면
- 위시리스트 매칭 알림 로직
```

### Task 7: 교환 매칭 시스템
```
- 교환 요청 발송
- 받은 요청 목록
- 요청자 책장 열람
- 매칭 수락/거절
- 매칭 성립 로직
- 교환 내역 화면
```

### Task 8: 채팅
```
- 채팅방 목록 화면
- 1:1 실시간 채팅 (Firestore)
- 이미지 전송
- 시스템 메시지
- 안 읽은 메시지 카운트
```

### Task 9: 푸시 알림
```
- FCM 연동
- 알림 수신/표시
- 알림 목록 화면
- 알림 설정 화면
- 커스텀 알림음 적용
```

### Task 10: 후기 & 프로필
```
- 후기 작성 화면
- 별점/태그 평가
- 책다리 온도 계산 로직
- 프로필 화면
- 뱃지/레벨 시스템
```

### Task 11: 확장 기능
```
- 택배 거래 (운송장, 배송 추적)
- 포인트 시스템
- 묶음 교환
- 찜 기능
- 랭킹 화면
- 환경 기여 통계
- 신고/차단
```

### Task 12: 고급 기능
```
- 릴레이 교환 알고리즘
- 동네 책모임
- Lottie 애니메이션 적용
- Flutter Web 최적화
```

### Task 13: QA & 런칭
```
- 테스트 작성
- 성능 최적화
- 앱스토어 준비
```

---

> **참고**: 각 Task는 독립적으로 오케스트레이션의 하나의 작업 단위로 사용할 수 있습니다. Task 간의 의존성(예: Task 2는 Task 1 완료 후)을 고려하여 순차적으로 진행하세요.
