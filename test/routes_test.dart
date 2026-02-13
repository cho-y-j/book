import 'package:flutter_test/flutter_test.dart';
import 'package:book_bridge/app/routes.dart';

void main() {
  group('AppRoutes', () {
    test('모든 라우트 상수 정의됨', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.signup, '/signup');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.search, '/search');
      expect(AppRoutes.bookRegister, '/book-register');
      expect(AppRoutes.chatList, '/chat');
      expect(AppRoutes.myProfile, '/my-profile');
      expect(AppRoutes.bookDetail, '/book/:bookId');
      expect(AppRoutes.barcodeScan, '/barcode-scan');
      expect(AppRoutes.manualRegister, '/manual-register');
      expect(AppRoutes.bookCondition, '/book-condition');
      expect(AppRoutes.myBookshelf, '/my-bookshelf');
      expect(AppRoutes.bookEdit, '/book-edit/:bookId');
      expect(AppRoutes.exchangeHistory, '/exchange-history');
      expect(AppRoutes.exchangeRequest, '/exchange-request/:bookId');
      expect(AppRoutes.incomingRequests, '/incoming-requests');
      expect(AppRoutes.requesterBookshelf, '/requester-bookshelf/:uid');
      expect(AppRoutes.matchConfirm, '/match-confirm/:matchId');
      expect(AppRoutes.exchangeMethod, '/exchange-method/:matchId');
      expect(AppRoutes.chatRoom, '/chat-room/:chatRoomId');
      expect(AppRoutes.userProfile, '/user/:userId');
      expect(AppRoutes.editProfile, '/edit-profile');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.notifications, '/notifications');
      expect(AppRoutes.notificationSettings, '/notification-settings');
      expect(AppRoutes.writeReview, '/write-review/:matchId');
      expect(AppRoutes.wishlist, '/wishlist');
      expect(AppRoutes.bookClubList, '/book-clubs');
      expect(AppRoutes.bookClubDetail, '/book-club/:clubId');
      expect(AppRoutes.createBookClub, '/create-book-club');
      expect(AppRoutes.ranking, '/ranking');
      expect(AppRoutes.myStats, '/my-stats');
      expect(AppRoutes.relaySuggest, '/relay-suggest');
      expect(AppRoutes.relayRoute, '/relay-route');
    });

    test('path helper가 올바른 경로 생성', () {
      expect(AppRoutes.bookDetailPath('abc123'), '/book/abc123');
      expect(AppRoutes.bookEditPath('abc123'), '/book-edit/abc123');
      expect(AppRoutes.exchangeRequestPath('book1'), '/exchange-request/book1');
      expect(AppRoutes.requesterBookshelfPath('uid1'), '/requester-bookshelf/uid1');
      expect(AppRoutes.matchConfirmPath('match1'), '/match-confirm/match1');
      expect(AppRoutes.exchangeMethodPath('match1'), '/exchange-method/match1');
      expect(AppRoutes.chatRoomPath('room1'), '/chat-room/room1');
      expect(AppRoutes.userProfilePath('user1'), '/user/user1');
      expect(AppRoutes.writeReviewPath('match1'), '/write-review/match1');
      expect(AppRoutes.bookClubDetailPath('club1'), '/book-club/club1');
    });

    test('appRouter가 정상 생성됨', () {
      expect(appRouter, isNotNull);
      expect(appRouter.configuration.routes.isNotEmpty, isTrue);
    });
  });
}
