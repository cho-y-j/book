import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:book_bridge/data/models/book_model.dart';
import 'package:book_bridge/data/models/user_model.dart';
import 'package:book_bridge/data/models/purchase_request_model.dart';
import 'package:book_bridge/data/repositories/book_repository.dart';
import 'package:book_bridge/data/repositories/purchase_repository.dart';
import 'package:book_bridge/data/repositories/admin_repository.dart';

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
  });
}
