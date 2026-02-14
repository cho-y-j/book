import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:book_bridge/data/models/book_model.dart';
import 'package:book_bridge/data/models/user_model.dart';
import 'package:book_bridge/data/models/purchase_request_model.dart';
import 'package:book_bridge/data/models/sharing_request_model.dart';
import 'package:book_bridge/data/models/donation_model.dart';
import 'package:book_bridge/data/models/organization_model.dart';
import 'package:book_bridge/data/repositories/book_repository.dart';
import 'package:book_bridge/data/repositories/purchase_repository.dart';
import 'package:book_bridge/data/repositories/admin_repository.dart';
import 'package:book_bridge/data/repositories/sharing_repository.dart';
import 'package:book_bridge/data/repositories/donation_repository.dart';

const _defaultGeoPoint = GeoPoint(37.5665, 126.9780);

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('BookModel 직렬화 테스트', () {
    test('교환 전용 책 생성 및 직렬화', () {
      final book = BookModel(
        id: 'book1',
        ownerUid: 'user1',
        bookInfoId: 'isbn123',
        title: '테스트 책',
        author: '테스트 저자',
        condition: 'good',
        status: 'available',
        listingType: 'exchange',
        genre: '소설',
        viewCount: 0,
        wishCount: 0,
        requestCount: 0,
        location: '',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = book.toFirestore();
      expect(map['listingType'], 'exchange');
      expect(map['price'], isNull);
      expect(map['isDealer'], false);
    });

    test('판매 책 생성 - 가격 포함', () {
      final book = BookModel(
        id: 'book2',
        ownerUid: 'user1',
        bookInfoId: 'isbn456',
        title: '판매할 책',
        author: '판매 저자',
        condition: 'best',
        status: 'available',
        listingType: 'sale',
        price: 15000,
        genre: '자기개발',
        viewCount: 0,
        wishCount: 0,
        requestCount: 0,
        location: '',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = book.toFirestore();
      expect(map['listingType'], 'sale');
      expect(map['price'], 15000);
    });

    test('교환+판매 책 생성', () {
      final book = BookModel(
        id: 'book3',
        ownerUid: 'dealer1',
        bookInfoId: 'isbn789',
        title: '교환판매 책',
        author: '업자',
        condition: 'fair',
        status: 'available',
        listingType: 'both',
        price: 8000,
        isDealer: true,
        genre: '만화',
        viewCount: 0,
        wishCount: 0,
        requestCount: 0,
        location: '',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = book.toFirestore();
      expect(map['listingType'], 'both');
      expect(map['price'], 8000);
      expect(map['isDealer'], true);
    });

    test('기존 책 (listingType 없음) 역호환성', () async {
      // 기존 책 데이터 (listingType 필드 없음)
      await fakeFirestore.collection('books').doc('old_book').set({
        'ownerUid': 'user1',
        'bookInfoId': 'old_isbn',
        'title': '오래된 책',
        'author': '구 저자',
        'condition': 'good',
        'status': 'available',
        'genre': '소설',
        'viewCount': 5,
        'wishCount': 2,
        'requestCount': 0,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('books').doc('old_book').get();
      final book = BookModel.fromFirestore(doc);

      expect(book.listingType, 'exchange'); // 기본값
      expect(book.price, isNull);
      expect(book.isDealer, false);
    });
  });

  group('UserModel 직렬화 테스트', () {
    test('일반 유저 생성', () {
      final user = UserModel(
        uid: 'user1',
        email: 'test@test.com',
        nickname: '테스트유저',
        bookTemperature: 36.5,
        totalExchanges: 0,
        level: 1,
        points: 0,
        badges: [],
        primaryLocation: '서울',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 1, 1),
        lastActiveAt: DateTime(2024, 1, 1),
      );

      final map = user.toFirestore();
      expect(map['role'], 'user');
      expect(map['dealerStatus'], isNull);
      expect(map['totalSales'], 0);
    });

    test('업자 유저 생성', () {
      final dealer = UserModel(
        uid: 'dealer1',
        email: 'dealer@test.com',
        nickname: '업자님',
        role: 'dealer',
        dealerStatus: 'approved',
        dealerName: '중고서점',
        totalSales: 15,
        bookTemperature: 40.0,
        totalExchanges: 5,
        level: 3,
        points: 500,
        badges: ['dealer'],
        primaryLocation: '서울',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 1, 1),
        lastActiveAt: DateTime(2024, 1, 1),
      );

      final map = dealer.toFirestore();
      expect(map['role'], 'dealer');
      expect(map['dealerStatus'], 'approved');
      expect(map['dealerName'], '중고서점');
      expect(map['totalSales'], 15);
    });

    test('관리자 유저 생성', () {
      final admin = UserModel(
        uid: 'admin1',
        email: 'cho.y.j@gmail.com',
        nickname: '관리자',
        role: 'admin',
        bookTemperature: 36.5,
        totalExchanges: 0,
        level: 1,
        points: 0,
        badges: [],
        primaryLocation: '서울',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 1, 1),
        lastActiveAt: DateTime(2024, 1, 1),
      );

      expect(admin.role, 'admin');
    });

    test('기존 유저 (role 없음) 역호환성', () async {
      await fakeFirestore.collection('users').doc('old_user').set({
        'email': 'old@test.com',
        'nickname': '구유저',
        'bookTemperature': 37.0,
        'totalExchanges': 3,
        'level': 2,
        'points': 100,
        'badges': [],
        'createdAt': Timestamp.now(),
        'lastActiveAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('users').doc('old_user').get();
      final user = UserModel.fromFirestore(doc);

      expect(user.role, 'user'); // 기본값
      expect(user.dealerStatus, isNull);
      expect(user.totalSales, 0);
    });
  });

  group('PurchaseRequestModel 테스트', () {
    test('구매 요청 생성 및 직렬화', () {
      final request = PurchaseRequestModel(
        id: 'pr1',
        buyerUid: 'buyer1',
        sellerUid: 'seller1',
        bookId: 'book1',
        bookTitle: '테스트 책',
        price: 15000,
        status: 'pending',
        message: '구매 원합니다',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = request.toFirestore();
      expect(map['buyerUid'], 'buyer1');
      expect(map['sellerUid'], 'seller1');
      expect(map['price'], 15000);
      expect(map['status'], 'pending');
      expect(map['message'], '구매 원합니다');
    });

    test('구매 요청 Firestore 읽기', () async {
      await fakeFirestore.collection('purchase_requests').doc('pr1').set({
        'buyerUid': 'buyer1',
        'sellerUid': 'seller1',
        'bookId': 'book1',
        'bookTitle': '테스트 책',
        'price': 15000,
        'status': 'pending',
        'message': '구매 원합니다',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('purchase_requests').doc('pr1').get();
      final request = PurchaseRequestModel.fromFirestore(doc);

      expect(request.buyerUid, 'buyer1');
      expect(request.price, 15000);
      expect(request.status, 'pending');
    });
  });

  group('BookRepository 쿼리 테스트', () {
    late BookRepository bookRepo;

    setUp(() async {
      bookRepo = BookRepository(firestore: fakeFirestore);

      // 테스트 데이터 삽입
      final books = [
        {
          'ownerUid': 'user1', 'bookInfoId': 'isbn1', 'title': '교환 책 1',
          'author': '저자1', 'condition': 'good', 'status': 'available',
          'listingType': 'exchange', 'genre': '소설',
          'viewCount': 10, 'wishCount': 3, 'requestCount': 0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        },
        {
          'ownerUid': 'user2', 'bookInfoId': 'isbn2', 'title': '판매 책 1',
          'author': '저자2', 'condition': 'best', 'status': 'available',
          'listingType': 'sale', 'price': 12000, 'genre': '소설',
          'viewCount': 20, 'wishCount': 5, 'requestCount': 1,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 2)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 2)),
        },
        {
          'ownerUid': 'dealer1', 'bookInfoId': 'isbn3', 'title': '교환+판매 책',
          'author': '업자', 'condition': 'fair', 'status': 'available',
          'listingType': 'both', 'price': 8000, 'isDealer': true, 'genre': '만화',
          'viewCount': 5, 'wishCount': 1, 'requestCount': 0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 3)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 3)),
        },
        {
          'ownerUid': 'user1', 'bookInfoId': 'isbn4', 'title': '숨김 책',
          'author': '저자4', 'condition': 'good', 'status': 'hidden',
          'listingType': 'exchange', 'genre': '소설',
          'viewCount': 0, 'wishCount': 0, 'requestCount': 0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 4)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 4)),
        },
        {
          // 기존 책 (listingType 없음)
          'ownerUid': 'user3', 'bookInfoId': 'old_isbn', 'title': '구 데이터 책',
          'author': '구 저자', 'condition': 'good', 'status': 'available',
          'genre': '에세이',
          'viewCount': 100, 'wishCount': 20, 'requestCount': 5,
          'createdAt': Timestamp.fromDate(DateTime(2023, 12, 1)),
          'updatedAt': Timestamp.fromDate(DateTime(2023, 12, 1)),
        },
      ];

      for (final book in books) {
        await fakeFirestore.collection('books').add(book);
      }
    });

    test('전체 available 책 조회', () async {
      final books = await bookRepo.getAvailableBooks();
      expect(books.length, 4); // hidden 제외
      expect(books.every((b) => b.status == 'available'), true);
    });

    test('사용자 책 목록 조회', () async {
      final books = await bookRepo.getUserBooks('user1');
      expect(books.length, 2); // 교환 책 1 + 숨김 책
    });

    test('기존 책 listingType 기본값 확인', () async {
      final books = await bookRepo.getAvailableBooks();
      final oldBook = books.firstWhere((b) => b.title == '구 데이터 책');
      expect(oldBook.listingType, 'exchange'); // 기본값 'exchange'
      expect(oldBook.price, isNull);
    });
  });

  group('PurchaseRepository 테스트', () {
    late PurchaseRepository purchaseRepo;

    setUp(() {
      purchaseRepo = PurchaseRepository(firestore: fakeFirestore);
    });

    test('구매 요청 생성', () async {
      final request = PurchaseRequestModel(
        id: '',
        buyerUid: 'buyer1',
        sellerUid: 'seller1',
        bookId: 'book1',
        bookTitle: '판매 책 1',
        price: 12000,
        status: 'pending',
        message: '구매하고 싶습니다',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await purchaseRepo.createPurchaseRequest(request);
      expect(id, isNotEmpty);

      // Firestore에서 확인
      final doc = await fakeFirestore.collection('purchase_requests').doc(id).get();
      expect(doc.exists, true);
      expect(doc.data()!['buyerUid'], 'buyer1');
      expect(doc.data()!['price'], 12000);
      expect(doc.data()!['status'], 'pending');
    });

    test('구매 요청 상태 업데이트 - 수락', () async {
      final id = await purchaseRepo.createPurchaseRequest(PurchaseRequestModel(
        id: '',
        buyerUid: 'buyer1',
        sellerUid: 'seller1',
        bookId: 'book1',
        bookTitle: '테스트',
        price: 10000,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await purchaseRepo.updateStatus(id, 'accepted');

      final doc = await fakeFirestore.collection('purchase_requests').doc(id).get();
      expect(doc.data()!['status'], 'accepted');
    });

    test('구매 요청 완료 - completedAt 설정', () async {
      final id = await purchaseRepo.createPurchaseRequest(PurchaseRequestModel(
        id: '',
        buyerUid: 'buyer1',
        sellerUid: 'seller1',
        bookId: 'book1',
        bookTitle: '테스트',
        price: 10000,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await purchaseRepo.updateStatus(id, 'completed');

      final doc = await fakeFirestore.collection('purchase_requests').doc(id).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!['completedAt'], isNotNull);
    });

    test('판매자의 수신 구매 요청 스트림', () async {
      // 3개 구매 요청 생성
      for (int i = 0; i < 3; i++) {
        await purchaseRepo.createPurchaseRequest(PurchaseRequestModel(
          id: '',
          buyerUid: 'buyer$i',
          sellerUid: 'seller1',
          bookId: 'book$i',
          bookTitle: '책 $i',
          price: 10000 + i * 1000,
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // 다른 판매자의 구매 요청도 생성
      await purchaseRepo.createPurchaseRequest(PurchaseRequestModel(
        id: '',
        buyerUid: 'buyer0',
        sellerUid: 'seller2',
        bookId: 'book99',
        bookTitle: '다른 책',
        price: 5000,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final requests = await purchaseRepo.getIncomingRequests('seller1');
      expect(requests.length, 3);
      expect(requests.every((r) => r.sellerUid == 'seller1'), true);
    });
  });

  group('AdminRepository 테스트', () {
    late AdminRepository adminRepo;

    setUp(() async {
      adminRepo = AdminRepository(firestore: fakeFirestore);

      // 테스트 유저 데이터
      final users = [
        {
          'email': 'admin@test.com', 'nickname': '관리자', 'role': 'admin',
          'status': 'active', 'bookTemperature': 36.5, 'totalExchanges': 0,
          'totalSales': 0, 'level': 1, 'points': 0, 'badges': [],
          'createdAt': Timestamp.now(), 'lastActiveAt': Timestamp.now(),
        },
        {
          'email': 'user1@test.com', 'nickname': '유저1', 'role': 'user',
          'status': 'active', 'bookTemperature': 37.0, 'totalExchanges': 3,
          'totalSales': 0, 'level': 2, 'points': 150, 'badges': [],
          'createdAt': Timestamp.now(), 'lastActiveAt': Timestamp.now(),
        },
        {
          'email': 'dealer1@test.com', 'nickname': '업자1', 'role': 'dealer',
          'dealerStatus': 'approved', 'dealerName': '중고서점A',
          'status': 'active', 'bookTemperature': 40.0, 'totalExchanges': 5,
          'totalSales': 20, 'level': 4, 'points': 1000, 'badges': ['dealer'],
          'createdAt': Timestamp.now(), 'lastActiveAt': Timestamp.now(),
        },
        {
          'email': 'dealer2@test.com', 'nickname': '업자2', 'role': 'dealer',
          'dealerStatus': 'pending', 'dealerName': '북마켓',
          'status': 'active', 'bookTemperature': 36.5, 'totalExchanges': 0,
          'totalSales': 0, 'level': 1, 'points': 0, 'badges': [],
          'createdAt': Timestamp.now(), 'lastActiveAt': Timestamp.now(),
        },
        {
          'email': 'suspended@test.com', 'nickname': '정지유저', 'role': 'user',
          'status': 'suspended', 'bookTemperature': 30.0, 'totalExchanges': 0,
          'totalSales': 0, 'level': 1, 'points': 0, 'badges': [],
          'createdAt': Timestamp.now(), 'lastActiveAt': Timestamp.now(),
        },
      ];

      for (final user in users) {
        await fakeFirestore.collection('users').add(user);
      }

      // 테스트 책 데이터
      for (int i = 0; i < 5; i++) {
        await fakeFirestore.collection('books').add({
          'ownerUid': 'user$i', 'title': '책 $i', 'author': '저자 $i',
          'status': 'available', 'createdAt': Timestamp.now(),
        });
      }
    });

    test('전체 유저 조회', () async {
      final users = await adminRepo.getAllUsers();
      expect(users.length, 5);
    });

    test('역할별 유저 필터', () async {
      final dealers = await adminRepo.getAllUsers(role: 'dealer');
      expect(dealers.length, 2);
      expect(dealers.every((u) => u.role == 'dealer'), true);
    });

    test('대기 중인 업자 요청', () async {
      final pending = await adminRepo.getPendingDealerRequests();
      expect(pending.length, 1);
      expect(pending.first.dealerName, '북마켓');
      expect(pending.first.dealerStatus, 'pending');
    });

    test('업자 승인', () async {
      final pending = await adminRepo.getPendingDealerRequests();
      final dealerDoc = await fakeFirestore.collection('users')
          .where('dealerStatus', isEqualTo: 'pending').get();
      final dealerId = dealerDoc.docs.first.id;

      await adminRepo.approveDealerRequest(dealerId);

      final doc = await fakeFirestore.collection('users').doc(dealerId).get();
      expect(doc.data()!['dealerStatus'], 'approved');
    });

    test('업자 거절', () async {
      final dealerDoc = await fakeFirestore.collection('users')
          .where('dealerStatus', isEqualTo: 'pending').get();
      final dealerId = dealerDoc.docs.first.id;

      await adminRepo.rejectDealerRequest(dealerId);

      final doc = await fakeFirestore.collection('users').doc(dealerId).get();
      expect(doc.data()!['role'], 'user');
      expect(doc.data()!['dealerStatus'], isNull);
    });

    test('유저 정지', () async {
      final userDoc = await fakeFirestore.collection('users')
          .where('nickname', isEqualTo: '유저1').get();
      final userId = userDoc.docs.first.id;

      await adminRepo.suspendUser(userId);

      final doc = await fakeFirestore.collection('users').doc(userId).get();
      expect(doc.data()!['status'], 'suspended');
    });

    test('유저 정지 해제', () async {
      final userDoc = await fakeFirestore.collection('users')
          .where('status', isEqualTo: 'suspended').get();
      final userId = userDoc.docs.first.id;

      await adminRepo.unsuspendUser(userId);

      final doc = await fakeFirestore.collection('users').doc(userId).get();
      expect(doc.data()!['status'], 'active');
    });

    test('역할 변경', () async {
      final userDoc = await fakeFirestore.collection('users')
          .where('nickname', isEqualTo: '유저1').get();
      final userId = userDoc.docs.first.id;

      await adminRepo.updateUserRole(userId, 'dealer');

      final doc = await fakeFirestore.collection('users').doc(userId).get();
      expect(doc.data()!['role'], 'dealer');
    });

    test('책 삭제', () async {
      final bookDoc = await fakeFirestore.collection('books').limit(1).get();
      final bookId = bookDoc.docs.first.id;

      await adminRepo.deleteBook(bookId);

      final doc = await fakeFirestore.collection('books').doc(bookId).get();
      expect(doc.exists, false);
    });
  });

  group('전체 거래 플로우 통합 테스트', () {
    late PurchaseRepository purchaseRepo;

    setUp(() {
      purchaseRepo = PurchaseRepository(firestore: fakeFirestore);
    });

    test('판매 책 등록 → 구매 요청 → 수락 → 완료 전체 플로우', () async {
      // 1. 판매자가 책 등록
      final bookRef = await fakeFirestore.collection('books').add({
        'ownerUid': 'seller1',
        'title': '판매용 프로그래밍 책',
        'author': '개발자',
        'status': 'available',
        'listingType': 'sale',
        'price': 20000,
        'condition': 'good',
        'genre': '컴퓨터',
        'viewCount': 0, 'wishCount': 0, 'requestCount': 0,
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      });
      expect(bookRef.id, isNotEmpty);

      // 2. 구매자가 구매 요청
      final requestId = await purchaseRepo.createPurchaseRequest(PurchaseRequestModel(
        id: '',
        buyerUid: 'buyer1',
        sellerUid: 'seller1',
        bookId: bookRef.id,
        bookTitle: '판매용 프로그래밍 책',
        price: 20000,
        status: 'pending',
        message: '구매하고 싶습니다. 직거래 가능한가요?',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(requestId, isNotEmpty);

      // 3. 판매자가 구매 요청 확인
      final incoming = await purchaseRepo.getIncomingRequests('seller1');
      expect(incoming.length, 1);
      expect(incoming.first.bookTitle, '판매용 프로그래밍 책');
      expect(incoming.first.price, 20000);

      // 4. 판매자가 수락
      await purchaseRepo.updateStatus(requestId, 'accepted');
      var doc = await fakeFirestore.collection('purchase_requests').doc(requestId).get();
      expect(doc.data()!['status'], 'accepted');

      // 5. 거래 완료
      await purchaseRepo.updateStatus(requestId, 'completed');
      doc = await fakeFirestore.collection('purchase_requests').doc(requestId).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!['completedAt'], isNotNull);

      // 6. 책 상태를 sold로 변경
      await fakeFirestore.collection('books').doc(bookRef.id).update({'status': 'sold'});
      final bookDoc = await fakeFirestore.collection('books').doc(bookRef.id).get();
      expect(bookDoc.data()!['status'], 'sold');
    });

    test('교환+판매 책 - 교환 요청과 구매 요청 동시 가능', () async {
      // 1. 교환+판매 책 등록
      final bookRef = await fakeFirestore.collection('books').add({
        'ownerUid': 'seller1',
        'title': '교환판매 가능 책',
        'author': '작가',
        'status': 'available',
        'listingType': 'both',
        'price': 15000,
        'condition': 'good',
        'genre': '소설',
        'viewCount': 0, 'wishCount': 0, 'requestCount': 0,
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      });

      // 2. 교환 요청
      await fakeFirestore.collection('exchange_requests').add({
        'requesterUid': 'user_a',
        'ownerUid': 'seller1',
        'bookId': bookRef.id,
        'offeredBookId': 'book_x',
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      // 3. 구매 요청
      await purchaseRepo.createPurchaseRequest(PurchaseRequestModel(
        id: '',
        buyerUid: 'user_b',
        sellerUid: 'seller1',
        bookId: bookRef.id,
        bookTitle: '교환판매 가능 책',
        price: 15000,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // 4. 교환 요청과 구매 요청 모두 존재
      final exchanges = await fakeFirestore.collection('exchange_requests')
          .where('ownerUid', isEqualTo: 'seller1').get();
      final purchases = await purchaseRepo.getIncomingRequests('seller1');

      expect(exchanges.docs.length, 1);
      expect(purchases.length, 1);
    });
  });

  group('업자 플로우 통합 테스트', () {
    late AdminRepository adminRepo;

    setUp(() {
      adminRepo = AdminRepository(firestore: fakeFirestore);
    });

    test('업자 신청 → 관리자 승인 → 책 등록(업자 뱃지) 전체 플로우', () async {
      // 1. 일반 유저 등록
      final userRef = fakeFirestore.collection('users').doc('new_dealer');
      await userRef.set({
        'email': 'new_dealer@test.com',
        'nickname': '새업자',
        'role': 'user',
        'status': 'active',
        'bookTemperature': 36.5,
        'totalExchanges': 0,
        'totalSales': 0,
        'level': 1,
        'points': 0,
        'badges': [],
        'createdAt': Timestamp.now(),
        'lastActiveAt': Timestamp.now(),
      });

      // 2. 업자 신청
      await userRef.update({
        'role': 'dealer',
        'dealerStatus': 'pending',
        'dealerName': '새로운 서점',
      });

      var userDoc = await userRef.get();
      expect(userDoc.data()!['role'], 'dealer');
      expect(userDoc.data()!['dealerStatus'], 'pending');

      // 3. 관리자가 승인
      await adminRepo.approveDealerRequest('new_dealer');

      userDoc = await userRef.get();
      expect(userDoc.data()!['dealerStatus'], 'approved');

      // 4. 승인된 업자가 책 등록 (isDealer: true)
      final bookRef = await fakeFirestore.collection('books').add({
        'ownerUid': 'new_dealer',
        'title': '업자의 책',
        'author': '작가',
        'status': 'available',
        'listingType': 'sale',
        'price': 5000,
        'isDealer': true,
        'condition': 'good',
        'genre': '소설',
        'viewCount': 0, 'wishCount': 0, 'requestCount': 0,
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      });

      final bookDoc = await fakeFirestore.collection('books').doc(bookRef.id).get();
      final book = BookModel.fromFirestore(bookDoc);
      expect(book.isDealer, true);
      expect(book.price, 5000);
    });

    test('업자 거절 → 일반 유저로 복원', () async {
      final userRef = fakeFirestore.collection('users').doc('reject_dealer');
      await userRef.set({
        'email': 'reject@test.com',
        'nickname': '거절업자',
        'role': 'dealer',
        'dealerStatus': 'pending',
        'dealerName': '거절될 서점',
        'status': 'active',
        'bookTemperature': 36.5,
        'totalExchanges': 0,
        'totalSales': 0,
        'level': 1,
        'points': 0,
        'badges': [],
        'createdAt': Timestamp.now(),
        'lastActiveAt': Timestamp.now(),
      });

      await adminRepo.rejectDealerRequest('reject_dealer');

      final userDoc = await userRef.get();
      expect(userDoc.data()!['role'], 'user');
      expect(userDoc.data()!['dealerStatus'], isNull);
    });
  });

  group('홈 피드 필터링 로직 테스트', () {
    test('교환 필터 - sale 전용 책 제외', () {
      final allBooks = [
        BookModel(id: '1', ownerUid: 'u1', bookInfoId: 'b1', title: '교환 책', author: '저자1', condition: 'good', status: 'available', listingType: 'exchange', genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '2', ownerUid: 'u2', bookInfoId: 'b2', title: '판매 책', author: '저자2', condition: 'good', status: 'available', listingType: 'sale', price: 10000, genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '3', ownerUid: 'u3', bookInfoId: 'b3', title: '둘다 책', author: '저자3', condition: 'good', status: 'available', listingType: 'both', price: 8000, genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      // 교환 필터: sale 전용만 제외
      final exchangeFiltered = allBooks.where((b) => b.listingType != 'sale').toList();
      expect(exchangeFiltered.length, 2);
      expect(exchangeFiltered.any((b) => b.listingType == 'exchange'), true);
      expect(exchangeFiltered.any((b) => b.listingType == 'both'), true);
      expect(exchangeFiltered.any((b) => b.listingType == 'sale'), false);
    });

    test('전체 필터 - 모든 책 표시', () {
      final allBooks = [
        BookModel(id: '1', ownerUid: 'u1', bookInfoId: 'b1', title: '교환', author: 'a', condition: 'good', status: 'available', listingType: 'exchange', genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '2', ownerUid: 'u2', bookInfoId: 'b2', title: '판매', author: 'a', condition: 'good', status: 'available', listingType: 'sale', price: 10000, genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      expect(allBooks.length, 2); // 필터 없이 전부
    });

    test('교환 필터 - 나눔/기증도 제외', () {
      final allBooks = [
        BookModel(id: '1', ownerUid: 'u1', bookInfoId: 'b1', title: '교환 책', author: 'a', condition: 'good', status: 'available', listingType: 'exchange', genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '2', ownerUid: 'u2', bookInfoId: 'b2', title: '판매 책', author: 'a', condition: 'good', status: 'available', listingType: 'sale', price: 10000, genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '3', ownerUid: 'u3', bookInfoId: 'b3', title: '나눔 책', author: 'a', condition: 'good', status: 'available', listingType: 'sharing', genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '4', ownerUid: 'u4', bookInfoId: 'b4', title: '기증 책', author: 'a', condition: 'good', status: 'available', listingType: 'donation', genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        BookModel(id: '5', ownerUid: 'u5', bookInfoId: 'b5', title: '교환+판매', author: 'a', condition: 'good', status: 'available', listingType: 'both', price: 5000, genre: '소설', viewCount: 0, wishCount: 0, requestCount: 0, location: '', geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      final exchangeFiltered = allBooks.where((b) =>
        b.listingType != 'sale' && b.listingType != 'sharing' && b.listingType != 'donation'
      ).toList();
      expect(exchangeFiltered.length, 2); // exchange + both만
      expect(exchangeFiltered.any((b) => b.title == '교환 책'), true);
      expect(exchangeFiltered.any((b) => b.title == '교환+판매'), true);
    });
  });

  // ========== 나눔/기증 신규 테스트 ==========

  group('BookModel 나눔/기증 + 상세정보 필드 테스트', () {
    test('나눔(sharing) 책 생성 및 직렬화', () {
      final book = BookModel(
        id: 'share1',
        ownerUid: 'user1',
        bookInfoId: 'isbn_share',
        title: '나눔할 소설책',
        author: '나눔 저자',
        condition: 'good',
        status: 'available',
        listingType: 'sharing',
        genre: '소설',
        viewCount: 0, wishCount: 0, requestCount: 0,
        location: '서울 강남구',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final map = book.toFirestore();
      expect(map['listingType'], 'sharing');
      expect(map['price'], isNull);
      expect(map['isDealer'], false);
      expect(book.listingType, 'sharing');
    });

    test('기증(donation) 책 생성 및 직렬화', () {
      final book = BookModel(
        id: 'donate1',
        ownerUid: 'user2',
        bookInfoId: 'isbn_donate',
        title: '기증할 교과서',
        author: '교과서 저자',
        condition: 'fair',
        status: 'available',
        listingType: 'donation',
        genre: '교육',
        viewCount: 0, wishCount: 0, requestCount: 0,
        location: '서울 종로구',
        geoPoint: _defaultGeoPoint,
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final map = book.toFirestore();
      expect(map['listingType'], 'donation');
      expect(map['price'], isNull);
    });

    test('알라딘 상세정보 필드 저장/읽기', () async {
      await fakeFirestore.collection('books').doc('aladin_book').set({
        'ownerUid': 'user1',
        'bookInfoId': 'isbn_aladin',
        'title': '달러구트 꿈 백화점',
        'author': '이미예',
        'condition': 'good',
        'status': 'available',
        'listingType': 'exchange',
        'genre': '소설',
        'viewCount': 0, 'wishCount': 0, 'requestCount': 0,
        'publisher': '팩토리나인',
        'pubDate': '2020-07-08',
        'description': '잠들어야만 입장 가능한 신비한 꿈 백화점 이야기',
        'originalPrice': 13800,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('books').doc('aladin_book').get();
      final book = BookModel.fromFirestore(doc);

      expect(book.publisher, '팩토리나인');
      expect(book.pubDate, '2020-07-08');
      expect(book.description, contains('꿈 백화점'));
      expect(book.originalPrice, 13800);
    });

    test('상세정보 없는 기존 책 역호환성', () async {
      await fakeFirestore.collection('books').doc('old_no_detail').set({
        'ownerUid': 'user1',
        'bookInfoId': 'isbn_old',
        'title': '오래된 책',
        'author': '구 저자',
        'condition': 'good',
        'status': 'available',
        'genre': '소설',
        'viewCount': 5,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('books').doc('old_no_detail').get();
      final book = BookModel.fromFirestore(doc);

      expect(book.publisher, isNull);
      expect(book.pubDate, isNull);
      expect(book.description, isNull);
      expect(book.originalPrice, isNull);
      expect(book.listingType, 'exchange'); // 기본값
    });

    test('나눔완료(shared) / 기증완료(donated) 상태', () {
      final sharedBook = BookModel(
        id: 's1', ownerUid: 'u1', bookInfoId: 'b1', title: '나눔완료 책', author: 'a',
        condition: 'good', status: 'shared', listingType: 'sharing', genre: '소설',
        viewCount: 0, wishCount: 0, requestCount: 0, location: '',
        geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final donatedBook = BookModel(
        id: 'd1', ownerUid: 'u2', bookInfoId: 'b2', title: '기증완료 책', author: 'a',
        condition: 'good', status: 'donated', listingType: 'donation', genre: '소설',
        viewCount: 0, wishCount: 0, requestCount: 0, location: '',
        geoPoint: _defaultGeoPoint, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );

      expect(sharedBook.status, 'shared');
      expect(donatedBook.status, 'donated');
      expect(sharedBook.toFirestore()['status'], 'shared');
      expect(donatedBook.toFirestore()['status'], 'donated');
    });
  });

  group('SharingRequestModel 테스트', () {
    test('나눔 요청 생성 및 직렬화', () {
      final request = SharingRequestModel(
        id: 'sr1',
        requesterUid: 'requester1',
        ownerUid: 'owner1',
        bookId: 'book1',
        bookTitle: '나눔 요청 책',
        status: 'pending',
        message: '나눔 받고 싶습니다',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final map = request.toFirestore();
      expect(map['requesterUid'], 'requester1');
      expect(map['ownerUid'], 'owner1');
      expect(map['status'], 'pending');
      expect(map['message'], '나눔 받고 싶습니다');
      expect(map['completedAt'], isNull);
    });

    test('나눔 요청 Firestore 읽기', () async {
      await fakeFirestore.collection('sharing_requests').doc('sr1').set({
        'requesterUid': 'req1',
        'ownerUid': 'own1',
        'bookId': 'book1',
        'bookTitle': '테스트 나눔',
        'status': 'accepted',
        'message': '감사합니다',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('sharing_requests').doc('sr1').get();
      final request = SharingRequestModel.fromFirestore(doc);

      expect(request.requesterUid, 'req1');
      expect(request.ownerUid, 'own1');
      expect(request.status, 'accepted');
      expect(request.message, '감사합니다');
      expect(request.completedAt, isNull);
    });
  });

  group('DonationModel 테스트', () {
    test('기증 생성 및 직렬화', () {
      final donation = DonationModel(
        id: 'don1',
        donorUid: 'donor1',
        bookId: 'book1',
        bookTitle: '기증할 책',
        organizationId: 'org1',
        organizationName: '서울도서관',
        status: 'pending',
        message: '도서관에 기증합니다',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final map = donation.toFirestore();
      expect(map['donorUid'], 'donor1');
      expect(map['organizationId'], 'org1');
      expect(map['organizationName'], '서울도서관');
      expect(map['status'], 'pending');
      expect(map['message'], '도서관에 기증합니다');
    });

    test('기증 Firestore 읽기', () async {
      await fakeFirestore.collection('donations').doc('don1').set({
        'donorUid': 'donor1',
        'bookId': 'book1',
        'bookTitle': '기증 책',
        'organizationId': 'org1',
        'organizationName': '국립중앙도서관',
        'status': 'in_transit',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('donations').doc('don1').get();
      final donation = DonationModel.fromFirestore(doc);

      expect(donation.donorUid, 'donor1');
      expect(donation.organizationName, '국립중앙도서관');
      expect(donation.status, 'in_transit');
    });
  });

  group('OrganizationModel 테스트', () {
    test('기관 생성 및 직렬화', () {
      final org = OrganizationModel(
        id: 'org1',
        name: '서울도서관',
        description: '서울시 대표 공공도서관',
        address: '서울 중구 세종대로 110',
        category: 'library',
        isActive: true,
        contactInfo: '02-1234-5678',
        createdAt: DateTime(2024, 1, 1),
      );

      final map = org.toFirestore();
      expect(map['name'], '서울도서관');
      expect(map['category'], 'library');
      expect(map['isActive'], true);
      expect(map['contactInfo'], '02-1234-5678');
    });

    test('기관 Firestore 읽기', () async {
      await fakeFirestore.collection('organizations').doc('org1').set({
        'name': '한국어린이재단',
        'description': '어린이 교육 재단',
        'address': '서울 종로구',
        'category': 'ngo',
        'isActive': true,
        'createdAt': Timestamp.now(),
      });

      final doc = await fakeFirestore.collection('organizations').doc('org1').get();
      final org = OrganizationModel.fromFirestore(doc);

      expect(org.name, '한국어린이재단');
      expect(org.category, 'ngo');
      expect(org.isActive, true);
      expect(org.contactInfo, isNull);
    });
  });

  group('SharingRepository 테스트', () {
    late SharingRepository sharingRepo;

    setUp(() {
      sharingRepo = SharingRepository(firestore: fakeFirestore);
    });

    test('나눔 요청 생성', () async {
      final request = SharingRequestModel(
        id: '',
        requesterUid: 'req1',
        ownerUid: 'own1',
        bookId: 'book1',
        bookTitle: '나눔 테스트 책',
        status: 'pending',
        message: '나눔 부탁드립니다',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await sharingRepo.createSharingRequest(request);
      expect(id, isNotEmpty);

      final doc = await fakeFirestore.collection('sharing_requests').doc(id).get();
      expect(doc.exists, true);
      expect(doc.data()!['requesterUid'], 'req1');
      expect(doc.data()!['status'], 'pending');
    });

    test('나눔 요청 상태 업데이트 - 수락', () async {
      final id = await sharingRepo.createSharingRequest(SharingRequestModel(
        id: '', requesterUid: 'req1', ownerUid: 'own1',
        bookId: 'book1', bookTitle: '테스트', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      await sharingRepo.updateStatus(id, 'accepted');

      final doc = await fakeFirestore.collection('sharing_requests').doc(id).get();
      expect(doc.data()!['status'], 'accepted');
    });

    test('나눔 요청 완료 - completedAt 설정', () async {
      final id = await sharingRepo.createSharingRequest(SharingRequestModel(
        id: '', requesterUid: 'req1', ownerUid: 'own1',
        bookId: 'book1', bookTitle: '테스트', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      await sharingRepo.updateStatus(id, 'completed');

      final doc = await fakeFirestore.collection('sharing_requests').doc(id).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!['completedAt'], isNotNull);
    });

    test('소유자의 수신 나눔 요청 스트림', () async {
      for (int i = 0; i < 3; i++) {
        await sharingRepo.createSharingRequest(SharingRequestModel(
          id: '', requesterUid: 'req$i', ownerUid: 'owner1',
          bookId: 'book$i', bookTitle: '책 $i', status: 'pending',
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ));
      }
      // 다른 소유자의 요청
      await sharingRepo.createSharingRequest(SharingRequestModel(
        id: '', requesterUid: 'req99', ownerUid: 'owner2',
        bookId: 'book99', bookTitle: '다른 책', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      final requests = await sharingRepo.watchIncomingRequests('owner1').first;
      expect(requests.length, 3);
      expect(requests.every((r) => r.ownerUid == 'owner1'), true);
    });

    test('요청자의 보낸 나눔 요청 스트림', () async {
      for (int i = 0; i < 2; i++) {
        await sharingRepo.createSharingRequest(SharingRequestModel(
          id: '', requesterUid: 'myuser', ownerUid: 'own$i',
          bookId: 'book$i', bookTitle: '책 $i', status: 'pending',
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ));
      }

      final sent = await sharingRepo.watchSentRequests('myuser').first;
      expect(sent.length, 2);
      expect(sent.every((r) => r.requesterUid == 'myuser'), true);
    });
  });

  group('DonationRepository 테스트', () {
    late DonationRepository donationRepo;

    setUp(() {
      donationRepo = DonationRepository(firestore: fakeFirestore);
    });

    test('기증 생성', () async {
      final donation = DonationModel(
        id: '',
        donorUid: 'donor1',
        bookId: 'book1',
        bookTitle: '기증 테스트 책',
        organizationId: 'org1',
        organizationName: '서울도서관',
        status: 'pending',
        message: '기증합니다',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await donationRepo.createDonation(donation);
      expect(id, isNotEmpty);

      final doc = await fakeFirestore.collection('donations').doc(id).get();
      expect(doc.exists, true);
      expect(doc.data()!['donorUid'], 'donor1');
      expect(doc.data()!['organizationName'], '서울도서관');
      expect(doc.data()!['status'], 'pending');
    });

    test('기증 상태 업데이트 - accepted → in_transit → completed', () async {
      final id = await donationRepo.createDonation(DonationModel(
        id: '', donorUid: 'donor1', bookId: 'book1', bookTitle: '테스트',
        organizationId: 'org1', organizationName: '도서관', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      // accepted
      await donationRepo.updateDonationStatus(id, 'accepted');
      var doc = await fakeFirestore.collection('donations').doc(id).get();
      expect(doc.data()!['status'], 'accepted');
      expect(doc.data()!['completedAt'], isNull);

      // in_transit
      await donationRepo.updateDonationStatus(id, 'in_transit');
      doc = await fakeFirestore.collection('donations').doc(id).get();
      expect(doc.data()!['status'], 'in_transit');

      // completed
      await donationRepo.updateDonationStatus(id, 'completed');
      doc = await fakeFirestore.collection('donations').doc(id).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!['completedAt'], isNotNull);
    });

    test('사용자의 기증 내역 스트림', () async {
      for (int i = 0; i < 3; i++) {
        await donationRepo.createDonation(DonationModel(
          id: '', donorUid: 'donor1', bookId: 'book$i', bookTitle: '기증 $i',
          organizationId: 'org$i', organizationName: '기관 $i', status: 'pending',
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ));
      }
      // 다른 기증자
      await donationRepo.createDonation(DonationModel(
        id: '', donorUid: 'donor2', bookId: 'book99', bookTitle: '다른 기증',
        organizationId: 'org1', organizationName: '기관1', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      final donations = await donationRepo.watchUserDonations('donor1').first;
      expect(donations.length, 3);
      expect(donations.every((d) => d.donorUid == 'donor1'), true);
    });

    test('기관 CRUD', () async {
      // Create
      final orgId = await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '테스트 도서관', description: '테스트용', address: '서울',
        category: 'library', isActive: true, createdAt: DateTime.now(),
      ));
      expect(orgId, isNotEmpty);

      // Read
      final orgs = await donationRepo.getOrganizations();
      expect(orgs.length, 1);
      expect(orgs.first.name, '테스트 도서관');

      // Update
      await donationRepo.updateOrganization(orgId, {'name': '수정된 도서관'});
      final updatedDoc = await fakeFirestore.collection('organizations').doc(orgId).get();
      expect(updatedDoc.data()!['name'], '수정된 도서관');

      // Soft delete (isActive = false)
      await donationRepo.deleteOrganization(orgId);
      final deletedOrgs = await donationRepo.getOrganizations();
      expect(deletedOrgs.length, 0); // isActive=false이므로 필터링됨
    });

    test('카테고리별 기관 필터', () async {
      await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '서울도서관', description: '도서관', address: '서울',
        category: 'library', isActive: true, createdAt: DateTime.now(),
      ));
      await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '서울대학교', description: '학교', address: '관악구',
        category: 'school', isActive: true, createdAt: DateTime.now(),
      ));
      await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '아름다운가게', description: 'NGO', address: '종로',
        category: 'ngo', isActive: true, createdAt: DateTime.now(),
      ));

      final all = await donationRepo.getOrganizations();
      expect(all.length, 3);

      final libraries = await donationRepo.getOrganizations(category: 'library');
      expect(libraries.length, 1);
      expect(libraries.first.name, '서울도서관');

      final schools = await donationRepo.getOrganizations(category: 'school');
      expect(schools.length, 1);
      expect(schools.first.name, '서울대학교');

      final ngos = await donationRepo.getOrganizations(category: 'ngo');
      expect(ngos.length, 1);
      expect(ngos.first.name, '아름다운가게');
    });

    test('기관 실시간 스트림', () async {
      await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '스트림 도서관', description: '', address: '',
        category: 'library', isActive: true, createdAt: DateTime.now(),
      ));

      final orgs = await donationRepo.watchOrganizations().first;
      expect(orgs.length, 1);
      expect(orgs.first.name, '스트림 도서관');
    });
  });

  group('BookRepository 나눔/기증 스트림 테스트', () {
    late BookRepository bookRepo;

    setUp(() async {
      bookRepo = BookRepository(firestore: fakeFirestore);

      // 다양한 listingType 책 데이터 삽입
      final books = [
        {'ownerUid': 'u1', 'bookInfoId': 'b1', 'title': '교환 책', 'author': '저자', 'condition': 'good', 'status': 'available', 'listingType': 'exchange', 'genre': '소설', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1))},
        {'ownerUid': 'u2', 'bookInfoId': 'b2', 'title': '판매 책', 'author': '저자', 'condition': 'good', 'status': 'available', 'listingType': 'sale', 'price': 10000, 'genre': '소설', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 2)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 2))},
        {'ownerUid': 'u3', 'bookInfoId': 'b3', 'title': '나눔 책 1', 'author': '저자', 'condition': 'good', 'status': 'available', 'listingType': 'sharing', 'genre': '소설', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 3)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 3))},
        {'ownerUid': 'u4', 'bookInfoId': 'b4', 'title': '나눔 책 2', 'author': '저자', 'condition': 'fair', 'status': 'available', 'listingType': 'sharing', 'genre': '에세이', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 4)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 4))},
        {'ownerUid': 'u5', 'bookInfoId': 'b5', 'title': '기증 책 1', 'author': '저자', 'condition': 'good', 'status': 'available', 'listingType': 'donation', 'genre': '소설', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 5)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 5))},
        {'ownerUid': 'u6', 'bookInfoId': 'b6', 'title': '기증 책 2', 'author': '저자', 'condition': 'good', 'status': 'available', 'listingType': 'donation', 'genre': '교육', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 6)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 6))},
        {'ownerUid': 'u7', 'bookInfoId': 'b7', 'title': '숨긴 나눔 책', 'author': '저자', 'condition': 'good', 'status': 'hidden', 'listingType': 'sharing', 'genre': '소설', 'viewCount': 0, 'wishCount': 0, 'requestCount': 0, 'createdAt': Timestamp.fromDate(DateTime(2024, 1, 7)), 'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 7))},
      ];

      for (final book in books) {
        await fakeFirestore.collection('books').add(book);
      }
    });

    test('나눔 목록 스트림 - available sharing만', () async {
      final sharingBooks = await bookRepo.watchSharingListings().first;
      expect(sharingBooks.length, 2); // hidden 제외
      expect(sharingBooks.every((b) => b.listingType == 'sharing'), true);
      expect(sharingBooks.every((b) => b.status == 'available'), true);
    });

    test('기증 목록 스트림 - available donation만', () async {
      final donationBooks = await bookRepo.watchDonationListings().first;
      expect(donationBooks.length, 2);
      expect(donationBooks.every((b) => b.listingType == 'donation'), true);
      expect(donationBooks.every((b) => b.status == 'available'), true);
    });

    test('전체 available 책 조회 - 모든 listingType 포함', () async {
      final allBooks = await bookRepo.getAvailableBooks();
      expect(allBooks.length, 6); // hidden 제외, 나머지 6개 전부
    });
  });

  group('나눔 전체 플로우 통합 테스트', () {
    late BookRepository bookRepo;
    late SharingRepository sharingRepo;

    setUp(() {
      bookRepo = BookRepository(firestore: fakeFirestore);
      sharingRepo = SharingRepository(firestore: fakeFirestore);
    });

    test('나눔 등록 → 요청 → 수락 → 완료 전체 플로우', () async {
      // 1. 소유자가 나눔 책 등록
      final bookId = await bookRepo.createBook(BookModel(
        id: '',
        ownerUid: 'owner1',
        bookInfoId: 'isbn_sharing_flow',
        title: '무료로 드립니다',
        author: '좋은 사람',
        condition: 'good',
        status: 'available',
        listingType: 'sharing',
        genre: '소설',
        location: '서울 마포구',
        geoPoint: _defaultGeoPoint,
        viewCount: 0, wishCount: 0, requestCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(bookId, isNotEmpty);

      // 2. 등록 확인 - 나눔 목록에 노출
      final sharingList = await bookRepo.watchSharingListings().first;
      expect(sharingList.any((b) => b.title == '무료로 드립니다'), true);

      // 3. 요청자가 나눔 요청
      final requestId = await sharingRepo.createSharingRequest(SharingRequestModel(
        id: '',
        requesterUid: 'requester1',
        ownerUid: 'owner1',
        bookId: bookId,
        bookTitle: '무료로 드립니다',
        status: 'pending',
        message: '감사히 받겠습니다!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(requestId, isNotEmpty);

      // 4. 소유자가 요청 확인
      final incoming = await sharingRepo.watchIncomingRequests('owner1').first;
      expect(incoming.length, 1);
      expect(incoming.first.message, '감사히 받겠습니다!');
      expect(incoming.first.status, 'pending');

      // 5. 소유자가 수락
      await sharingRepo.updateStatus(requestId, 'accepted');
      var doc = await fakeFirestore.collection('sharing_requests').doc(requestId).get();
      expect(doc.data()!['status'], 'accepted');

      // 6. 나눔 완료
      await sharingRepo.updateStatus(requestId, 'completed');
      doc = await fakeFirestore.collection('sharing_requests').doc(requestId).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!['completedAt'], isNotNull);

      // 7. 책 상태를 shared로 변경
      await bookRepo.updateBook(bookId, {'status': 'shared'});
      final bookDoc = await fakeFirestore.collection('books').doc(bookId).get();
      expect(bookDoc.data()!['status'], 'shared');

      // 8. 나눔 목록에서 사라짐 (status != available)
      final sharingListAfter = await bookRepo.watchSharingListings().first;
      expect(sharingListAfter.any((b) => b.id == bookId), false);
    });

    test('나눔 요청 거절 플로우', () async {
      final requestId = await sharingRepo.createSharingRequest(SharingRequestModel(
        id: '', requesterUid: 'req1', ownerUid: 'own1',
        bookId: 'book1', bookTitle: '거절될 나눔', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      await sharingRepo.updateStatus(requestId, 'rejected');

      final doc = await fakeFirestore.collection('sharing_requests').doc(requestId).get();
      expect(doc.data()!['status'], 'rejected');
      expect(doc.data()!['completedAt'], isNull); // 거절은 completedAt 없음
    });
  });

  group('기증 전체 플로우 통합 테스트', () {
    late BookRepository bookRepo;
    late DonationRepository donationRepo;

    setUp(() {
      bookRepo = BookRepository(firestore: fakeFirestore);
      donationRepo = DonationRepository(firestore: fakeFirestore);
    });

    test('기관 등록 → 책 기증 → 상태 변경 전체 플로우', () async {
      // 1. 관리자가 기관 등록
      final orgId = await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '서울도서관', description: '서울시 대표 도서관',
        address: '서울 중구 세종대로 110', category: 'library',
        isActive: true, createdAt: DateTime.now(),
      ));
      expect(orgId, isNotEmpty);

      // 2. 기관 목록 확인
      final orgs = await donationRepo.getOrganizations();
      expect(orgs.length, 1);
      expect(orgs.first.name, '서울도서관');

      // 3. 사용자가 기증할 책 등록
      final bookId = await bookRepo.createBook(BookModel(
        id: '', ownerUid: 'donor1', bookInfoId: 'isbn_donate_flow',
        title: '기증할 프로그래밍 책', author: '개발자',
        condition: 'good', status: 'available', listingType: 'donation',
        genre: '컴퓨터', location: '서울',
        geoPoint: _defaultGeoPoint,
        viewCount: 0, wishCount: 0, requestCount: 0,
        publisher: '한빛미디어', pubDate: '2023-03-15',
        description: 'Flutter 프로그래밍 입문서', originalPrice: 32000,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      // 4. 기증 요청 생성
      final donationId = await donationRepo.createDonation(DonationModel(
        id: '', donorUid: 'donor1', bookId: bookId,
        bookTitle: '기증할 프로그래밍 책',
        organizationId: orgId, organizationName: '서울도서관',
        status: 'pending', message: '도서관에 기증합니다',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));
      expect(donationId, isNotEmpty);

      // 5. 기증 내역 확인
      final donations = await donationRepo.watchUserDonations('donor1').first;
      expect(donations.length, 1);
      expect(donations.first.organizationName, '서울도서관');

      // 6. 기관이 수락
      await donationRepo.updateDonationStatus(donationId, 'accepted');

      // 7. 배송 중
      await donationRepo.updateDonationStatus(donationId, 'in_transit');

      // 8. 기증 완료
      await donationRepo.updateDonationStatus(donationId, 'completed');
      final doc = await fakeFirestore.collection('donations').doc(donationId).get();
      expect(doc.data()!['status'], 'completed');
      expect(doc.data()!['completedAt'], isNotNull);

      // 9. 책 상태를 donated로 변경
      await bookRepo.updateBook(bookId, {'status': 'donated'});
      final bookDoc = await fakeFirestore.collection('books').doc(bookId).get();
      expect(bookDoc.data()!['status'], 'donated');

      // 10. 책에 상세정보가 함께 저장되었는지 확인
      final book = BookModel.fromFirestore(bookDoc);
      expect(book.publisher, '한빛미디어');
      expect(book.originalPrice, 32000);
      expect(book.description, contains('Flutter'));
    });

    test('여러 기관에 여러 책 기증', () async {
      // 기관 2개 등록
      final org1Id = await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '도서관A', description: '', address: '서울',
        category: 'library', isActive: true, createdAt: DateTime.now(),
      ));
      final org2Id = await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '학교B', description: '', address: '부산',
        category: 'school', isActive: true, createdAt: DateTime.now(),
      ));

      // 한 유저가 2권 기증
      await donationRepo.createDonation(DonationModel(
        id: '', donorUid: 'donor1', bookId: 'book1', bookTitle: '기증1',
        organizationId: org1Id, organizationName: '도서관A', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));
      await donationRepo.createDonation(DonationModel(
        id: '', donorUid: 'donor1', bookId: 'book2', bookTitle: '기증2',
        organizationId: org2Id, organizationName: '학교B', status: 'pending',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      final donations = await donationRepo.watchUserDonations('donor1').first;
      expect(donations.length, 2);

      // 기관별 기증 확인
      expect(donations.any((d) => d.organizationName == '도서관A'), true);
      expect(donations.any((d) => d.organizationName == '학교B'), true);
    });

    test('기관 비활성화(soft delete) 후 목록에서 제외', () async {
      final orgId = await donationRepo.createOrganization(OrganizationModel(
        id: '', name: '삭제될 기관', description: '', address: '',
        category: 'ngo', isActive: true, createdAt: DateTime.now(),
      ));

      var orgs = await donationRepo.getOrganizations();
      expect(orgs.length, 1);

      await donationRepo.deleteOrganization(orgId);

      orgs = await donationRepo.getOrganizations();
      expect(orgs.length, 0);

      // 실제 문서는 남아있음 (soft delete)
      final doc = await fakeFirestore.collection('organizations').doc(orgId).get();
      expect(doc.exists, true);
      expect(doc.data()!['isActive'], false);
    });
  });

  group('시드 데이터 시뮬레이션 테스트', () {
    late DonationRepository donationRepo;

    setUp(() {
      donationRepo = DonationRepository(firestore: fakeFirestore);
    });

    test('5개 기관 시드 데이터 등록 및 조회', () async {
      final seeds = [
        OrganizationModel(id: '', name: '서울도서관', description: '서울특별시 대표 공공도서관', address: '서울 중구 세종대로 110', category: 'library', isActive: true, createdAt: DateTime.now()),
        OrganizationModel(id: '', name: '국립중앙도서관', description: '대한민국 국가 대표 도서관', address: '서울 서초구 반포대로 201', category: 'library', isActive: true, createdAt: DateTime.now()),
        OrganizationModel(id: '', name: '한국어린이재단', description: '어린이 교육과 복지를 위한 재단', address: '서울 종로구 창경궁로 215', category: 'ngo', isActive: true, createdAt: DateTime.now()),
        OrganizationModel(id: '', name: '아름다운가게', description: '나눔과 순환의 사회적기업', address: '서울 종로구 자하문로 77', category: 'ngo', isActive: true, createdAt: DateTime.now()),
        OrganizationModel(id: '', name: '서울대학교 도서관', description: '서울대학교 중앙도서관', address: '서울 관악구 관악로 1', category: 'school', isActive: true, createdAt: DateTime.now()),
      ];

      for (final org in seeds) {
        await donationRepo.createOrganization(org);
      }

      // 전체 조회
      final all = await donationRepo.getOrganizations();
      expect(all.length, 5);

      // 카테고리별
      final libraries = await donationRepo.getOrganizations(category: 'library');
      expect(libraries.length, 2);

      final ngos = await donationRepo.getOrganizations(category: 'ngo');
      expect(ngos.length, 2);

      final schools = await donationRepo.getOrganizations(category: 'school');
      expect(schools.length, 1);
      expect(schools.first.name, '서울대학교 도서관');
    });
  });
}
