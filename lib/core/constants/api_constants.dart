import '../config/env_config.dart';

class ApiConstants {
  ApiConstants._();

  // 알라딘 API
  static const aladinBaseUrl = 'http://www.aladin.co.kr/ttb/api';
  static const _fallbackAladinKey = 'ttbpcon16132339001';
  static String get aladinApiKey {
    final key = EnvConfig.aladinApiKey;
    return key.isNotEmpty ? key : _fallbackAladinKey;
  }

  // 네이버 책 검색 API
  static const naverBaseUrl = 'https://openapi.naver.com/v1/search/book.json';
  static String get naverClientId => EnvConfig.naverClientId;
  static String get naverClientSecret => EnvConfig.naverClientSecret;

  // 카카오 책 검색 API
  static const kakaoBaseUrl = 'https://dapi.kakao.com/v3/search/book';
  static String get kakaoRestApiKey => EnvConfig.kakaoRestApiKey;

  // 스마트택배 API
  static const deliveryTrackerBaseUrl = 'https://apis.tracker.delivery/graphql';

  // Firestore Collections
  static const usersCollection = 'users';
  static const bookInfoCollection = 'book_info';
  static const booksCollection = 'books';
  static const exchangeRequestsCollection = 'exchange_requests';
  static const matchesCollection = 'matches';
  static const chatRoomsCollection = 'chat_rooms';
  static const messagesCollection = 'messages';
  static const reviewsCollection = 'reviews';
  static const notificationsCollection = 'notifications';
  static const wishlistsCollection = 'wishlists';
  static const bookClubsCollection = 'book_clubs';
  static const reportsCollection = 'reports';
  static const relayExchangesCollection = 'relay_exchanges';
  static const purchaseRequestsCollection = 'purchase_requests';
  static const sharingRequestsCollection = 'sharing_requests';
  static const donationsCollection = 'donations';
  static const organizationsCollection = 'organizations';
  static const adminCollection = 'admin';

  // Admin email
  static const adminEmail = 'cho.y.j@gmail.com';
}
