import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/notification_service.dart';
// Auth
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
// Main tabs
import '../features/home/screens/home_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/book_register/screens/book_search_register_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/profile/screens/my_profile_screen.dart';
// Book
import '../features/book_detail/screens/book_detail_screen.dart';
import '../features/book_register/screens/barcode_scan_screen.dart';
import '../features/book_register/screens/manual_register_screen.dart';
import '../features/book_register/screens/book_title_search_screen.dart';
import '../features/book_register/screens/book_condition_screen.dart';
// My Bookshelf
import '../features/my_bookshelf/screens/my_bookshelf_screen.dart';
import '../features/my_bookshelf/screens/book_edit_screen.dart';
// Exchange
import '../features/exchange/screens/exchange_history_screen.dart';
import '../features/exchange/screens/exchange_request_screen.dart';
import '../features/exchange/screens/incoming_requests_screen.dart';
import '../features/exchange/screens/requester_bookshelf_screen.dart';
import '../features/exchange/screens/match_confirm_screen.dart';
import '../features/exchange/screens/exchange_method_screen.dart';
// Chat
import '../features/chat/screens/chat_room_screen.dart';
// Profile
import '../features/profile/screens/user_profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/settings_screen.dart';
// Notification
import '../features/notification/screens/notification_list_screen.dart';
import '../features/notification/screens/notification_settings_screen.dart';
// Review
import '../features/review/screens/write_review_screen.dart';
import '../features/review/screens/received_reviews_screen.dart';
// Wishlist
import '../features/wishlist/screens/wishlist_screen.dart';
import '../features/wishlist/screens/wishlist_matches_screen.dart';
import '../data/models/wishlist_model.dart';
// Book Club
import '../features/book_club/screens/book_club_list_screen.dart';
import '../features/book_club/screens/book_club_detail_screen.dart';
import '../features/book_club/screens/create_book_club_screen.dart';
// Ranking & Stats
import '../features/ranking/screens/ranking_screen.dart';
import '../features/stats/screens/my_stats_screen.dart';
// Relay Exchange
import '../features/relay_exchange/screens/relay_suggest_screen.dart';
import '../features/relay_exchange/screens/relay_route_screen.dart';
// Purchase
import '../features/purchase/screens/purchase_request_screen.dart';
import '../features/purchase/screens/incoming_purchase_requests_screen.dart';
// Sharing
import '../features/sharing/screens/sharing_request_screen.dart';
import '../features/sharing/screens/incoming_sharing_requests_screen.dart';
// Donation
import '../features/donation/screens/organization_list_screen.dart';
import '../features/donation/screens/donation_screen.dart';
import '../features/donation/screens/donation_history_screen.dart';
// Admin
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_user_list_screen.dart';
import '../features/admin/screens/admin_user_detail_screen.dart';
import '../features/admin/screens/admin_dealer_screen.dart';
import '../features/admin/screens/admin_book_list_screen.dart';
import '../features/admin/screens/admin_report_screen.dart';
import '../features/admin/screens/admin_organization_screen.dart';
// Partner
import '../features/dealer/screens/partner_request_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Auth
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';

  // Main tabs
  static const home = '/home';
  static const search = '/search';
  static const bookRegister = '/book-register';
  static const chatList = '/chat';
  static const myProfile = '/my-profile';

  // Book
  static const bookDetail = '/book/:bookId';
  static const barcodeScan = '/barcode-scan';
  static const bookTitleSearch = '/book-title-search';
  static const manualRegister = '/manual-register';
  static const bookCondition = '/book-condition';

  // My Bookshelf
  static const myBookshelf = '/my-bookshelf';
  static const bookEdit = '/book-edit/:bookId';

  // Exchange
  static const exchangeHistory = '/exchange-history';
  static const exchangeRequest = '/exchange-request/:bookId';
  static const incomingRequests = '/incoming-requests';
  static const requesterBookshelf = '/requester-bookshelf/:uid';
  static const matchConfirm = '/match-confirm/:matchId';
  static const exchangeMethod = '/exchange-method/:matchId';

  // Chat
  static const chatRoom = '/chat-room/:chatRoomId';

  // Profile
  static const userProfile = '/user/:userId';
  static const editProfile = '/edit-profile';
  static const settings = '/settings';

  // Notification
  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';

  // Review
  static const writeReview = '/write-review/:matchId';
  static const receivedReviews = '/received-reviews';

  // Wishlist
  static const wishlist = '/wishlist';
  static const wishlistMatches = '/wishlist-matches';

  // Book Club
  static const bookClubList = '/book-clubs';
  static const bookClubDetail = '/book-club/:clubId';
  static const createBookClub = '/create-book-club';

  // Ranking & Stats
  static const ranking = '/ranking';
  static const myStats = '/my-stats';

  // Relay Exchange
  static const relaySuggest = '/relay-suggest';
  static const relayRoute = '/relay-route';

  // Purchase
  static const purchaseRequest = '/purchase-request/:bookId';
  static const incomingPurchaseRequests = '/incoming-purchase-requests';

  // Sharing
  static const sharingRequest = '/sharing-request/:bookId';
  static const incomingSharingRequests = '/incoming-sharing-requests';

  // Donation
  static const organizations = '/organizations';
  static const donation = '/donation/:organizationId';
  static const donationHistory = '/donation-history';

  // Admin
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminUserDetail = '/admin/user/:userId';
  static const adminDealers = '/admin/dealers';
  static const adminPartners = '/admin/partners';
  static const adminBooks = '/admin/books';
  static const adminReports = '/admin/reports';
  static const adminOrganizations = '/admin/organizations';

  // Partner
  static const dealerRequest = '/dealer-request';
  static const partnerRequest = '/partner-request';

  /// Helper to build paths with parameters
  static String bookDetailPath(String bookId) => '/book/$bookId';
  static String bookEditPath(String bookId) => '/book-edit/$bookId';
  static String exchangeRequestPath(String bookId) => '/exchange-request/$bookId';
  static String requesterBookshelfPath(String uid) => '/requester-bookshelf/$uid';
  static String matchConfirmPath(String matchId) => '/match-confirm/$matchId';
  static String exchangeMethodPath(String matchId) => '/exchange-method/$matchId';
  static String chatRoomPath(String chatRoomId) => '/chat-room/$chatRoomId';
  static String userProfilePath(String userId) => '/user/$userId';
  static String writeReviewPath(String matchId) => '/write-review/$matchId';
  static String bookClubDetailPath(String clubId) => '/book-club/$clubId';
  static String purchaseRequestPath(String bookId) => '/purchase-request/$bookId';
  static String sharingRequestPath(String bookId) => '/sharing-request/$bookId';
  static String donationPath(String organizationId) => '/donation/$organizationId';
  static String adminUserDetailPath(String userId) => '/admin/user/$userId';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    // 포그라운드에서 알림 탭 시 pendingRoute 처리
    final pending = NotificationService.pendingRoute;
    if (pending != null && pending.isNotEmpty && state.uri.toString() != pending) {
      // 로그인된 상태에서만 (splash/login/signup이 아닌 경우)
      final currentPath = state.uri.toString();
      if (currentPath != '/' && currentPath != '/login' && currentPath != '/signup' && currentPath != '/onboarding') {
        NotificationService.pendingRoute = null;
        return pending;
      }
    }
    return null;
  },
  routes: [
    // === Auth ===
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),

    // === Main Shell (Bottom Navigation) ===
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
        GoRoute(path: AppRoutes.bookRegister, builder: (_, __) => const BookSearchRegisterScreen()),
        GoRoute(path: AppRoutes.chatList, builder: (_, __) => const ChatListScreen()),
        GoRoute(path: AppRoutes.myProfile, builder: (_, __) => const MyProfileScreen()),
      ],
    ),

    // === Book ===
    GoRoute(path: AppRoutes.bookDetail, builder: (_, state) => BookDetailScreen(bookId: state.pathParameters['bookId']!)),
    GoRoute(path: AppRoutes.barcodeScan, builder: (_, __) => const BarcodeScanScreen()),
    GoRoute(path: AppRoutes.bookTitleSearch, builder: (_, __) => const BookTitleSearchScreen()),
    GoRoute(path: AppRoutes.manualRegister, builder: (_, __) => const ManualRegisterScreen()),
    GoRoute(path: AppRoutes.bookCondition, builder: (_, __) => const BookConditionScreen()),

    // === My Bookshelf ===
    GoRoute(path: AppRoutes.myBookshelf, builder: (_, __) => const MyBookshelfScreen()),
    GoRoute(path: AppRoutes.bookEdit, builder: (_, state) => BookEditScreen(bookId: state.pathParameters['bookId']!)),

    // === Exchange ===
    GoRoute(path: AppRoutes.exchangeHistory, builder: (_, __) => const ExchangeHistoryScreen()),
    GoRoute(path: AppRoutes.exchangeRequest, builder: (_, state) => ExchangeRequestScreen(targetBookId: state.pathParameters['bookId']!)),
    GoRoute(path: AppRoutes.incomingRequests, builder: (_, __) => const IncomingRequestsScreen()),
    GoRoute(path: AppRoutes.requesterBookshelf, builder: (_, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return RequesterBookshelfScreen(
        requesterUid: state.pathParameters['uid']!,
        exchangeRequestId: extra?['exchangeRequestId'] as String?,
        targetBookId: extra?['targetBookId'] as String?,
      );
    }),
    GoRoute(path: AppRoutes.matchConfirm, builder: (_, state) => MatchConfirmScreen(matchId: state.pathParameters['matchId']!)),
    GoRoute(path: AppRoutes.exchangeMethod, builder: (_, state) => ExchangeMethodScreen(matchId: state.pathParameters['matchId']!)),

    // === Chat ===
    GoRoute(path: AppRoutes.chatRoom, builder: (_, state) => ChatRoomScreen(chatRoomId: state.pathParameters['chatRoomId']!)),

    // === Profile ===
    GoRoute(path: AppRoutes.userProfile, builder: (_, state) => UserProfileScreen(userId: state.pathParameters['userId']!)),
    GoRoute(path: AppRoutes.editProfile, builder: (_, __) => const EditProfileScreen()),
    GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),

    // === Notification ===
    GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationListScreen()),
    GoRoute(path: AppRoutes.notificationSettings, builder: (_, __) => const NotificationSettingsScreen()),

    // === Review ===
    GoRoute(path: AppRoutes.writeReview, builder: (_, state) => WriteReviewScreen(matchId: state.pathParameters['matchId']!)),
    GoRoute(path: AppRoutes.receivedReviews, builder: (_, __) => const ReceivedReviewsScreen()),

    // === Wishlist ===
    GoRoute(path: AppRoutes.wishlist, builder: (_, __) => const WishlistScreen()),
    GoRoute(path: AppRoutes.wishlistMatches, builder: (_, state) {
      final wishlist = state.extra as WishlistModel?;
      if (wishlist == null) {
        return const Scaffold(body: Center(child: Text('잘못된 접근입니다')));
      }
      return WishlistMatchesScreen(wishlist: wishlist);
    }),

    // === Book Club ===
    GoRoute(path: AppRoutes.bookClubList, builder: (_, __) => const BookClubListScreen()),
    GoRoute(path: AppRoutes.bookClubDetail, builder: (_, state) => BookClubDetailScreen(clubId: state.pathParameters['clubId']!)),
    GoRoute(path: AppRoutes.createBookClub, builder: (_, __) => const CreateBookClubScreen()),

    // === Ranking & Stats ===
    GoRoute(path: AppRoutes.ranking, builder: (_, __) => const RankingScreen()),
    GoRoute(path: AppRoutes.myStats, builder: (_, __) => const MyStatsScreen()),

    // === Relay Exchange ===
    GoRoute(path: AppRoutes.relaySuggest, builder: (_, __) => const RelaySuggestScreen()),
    GoRoute(path: AppRoutes.relayRoute, builder: (_, __) => const RelayRouteScreen()),

    // === Purchase ===
    GoRoute(path: AppRoutes.purchaseRequest, builder: (_, state) => PurchaseRequestScreen(bookId: state.pathParameters['bookId']!)),
    GoRoute(path: AppRoutes.incomingPurchaseRequests, builder: (_, __) => const IncomingPurchaseRequestsScreen()),

    // === Sharing ===
    GoRoute(path: AppRoutes.sharingRequest, builder: (_, state) => SharingRequestScreen(bookId: state.pathParameters['bookId']!)),
    GoRoute(path: AppRoutes.incomingSharingRequests, builder: (_, __) => const IncomingSharingRequestsScreen()),

    // === Donation ===
    GoRoute(path: AppRoutes.organizations, builder: (_, __) => const OrganizationListScreen()),
    GoRoute(path: AppRoutes.donation, builder: (_, state) => DonationScreen(organizationId: state.pathParameters['organizationId']!)),
    GoRoute(path: AppRoutes.donationHistory, builder: (_, __) => const DonationHistoryScreen()),

    // === Admin (nested to avoid GoRouter duplicate key issues) ===
    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (_, __) => const AdminDashboardScreen(),
      routes: [
        GoRoute(path: 'users', builder: (_, __) => const AdminUserListScreen()),
        GoRoute(path: 'user/:userId', builder: (_, state) => AdminUserDetailScreen(userId: state.pathParameters['userId']!)),
        GoRoute(path: 'dealers', builder: (_, __) => const AdminDealerScreen()),
        GoRoute(path: 'partners', builder: (_, __) => const AdminDealerScreen()),
        GoRoute(path: 'books', builder: (_, __) => const AdminBookListScreen()),
        GoRoute(path: 'reports', builder: (_, __) => const AdminReportScreen()),
        GoRoute(path: 'organizations', builder: (_, __) => const AdminOrganizationScreen()),
      ],
    ),

    // === Partner ===
    GoRoute(path: AppRoutes.dealerRequest, builder: (_, __) => const PartnerRequestScreen()),
    GoRoute(path: AppRoutes.partnerRequest, builder: (_, __) => const PartnerRequestScreen()),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/book-register')) return 2;
    if (location.startsWith('/chat')) return 3;
    if (location.startsWith('/my-profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0: context.go(AppRoutes.home);
            case 1: context.go(AppRoutes.search);
            case 2: context.go(AppRoutes.bookRegister);
            case 3: context.go(AppRoutes.chatList);
            case 4: context.go(AppRoutes.myProfile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '등록'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}
