import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:book_bridge/firebase_options.dart';

void main() {
  group('도서 등록 통합 테스트', () {
    test('Firebase 초기화 및 연결 확인', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

      // Firebase Auth 연결 확인
      final auth = FirebaseAuth.instance;
      print('Auth 연결됨: ${auth.app.name}');

      // Firestore 연결 확인
      final firestore = FirebaseFirestore.instance;
      print('Firestore 연결됨: ${firestore.app.name}');

      // Storage 연결 확인
      final storage = FirebaseStorage.instance;
      print('Storage 연결됨: ${storage.bucket}');

      expect(auth, isNotNull);
      expect(firestore, isNotNull);
      expect(storage, isNotNull);
    });

    test('테스트 계정 로그인 → 사진 업로드 → Firestore 책 등록 → 삭제', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      } catch (_) {}

      // 1. 테스트 계정 생성/로그인
      final auth = FirebaseAuth.instance;
      UserCredential cred;
      try {
        cred = await auth.createUserWithEmailAndPassword(
          email: 'test-register@bookbridge.com',
          password: 'test123456',
        );
        print('테스트 계정 생성됨: ${cred.user!.uid}');
      } catch (e) {
        cred = await auth.signInWithEmailAndPassword(
          email: 'test-register@bookbridge.com',
          password: 'test123456',
        );
        print('테스트 계정 로그인: ${cred.user!.uid}');
      }
      final uid = cred.user!.uid;

      // 2. 테스트 이미지 생성 (1x1 red pixel JPEG)
      final testImageBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
        0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
        0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
        0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
        0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
        0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
        0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
        0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
        0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01, 0x03,
        0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D,
        0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06,
        0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08,
        0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24, 0x33, 0x62, 0x72,
        0x82, 0x09, 0x0A, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28,
        0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45,
        0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, 0x7B, 0x94,
        0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xD9,
      ]);

      // 3. Firebase Storage에 사진 업로드
      print('사진 업로드 중...');
      final storageRef = FirebaseStorage.instance.ref().child('books/$uid/test_photo.jpg');
      await storageRef.putData(testImageBytes, SettableMetadata(contentType: 'image/jpeg'));
      final photoUrl = await storageRef.getDownloadURL();
      print('사진 업로드 완료: $photoUrl');
      expect(photoUrl, contains('firebasestorage'));

      // 4. Firestore에 책 등록
      print('Firestore에 책 등록 중...');
      final now = DateTime.now();
      final docRef = await FirebaseFirestore.instance.collection('books').add({
        'ownerUid': uid,
        'bookInfoId': '9788936434120',
        'title': '소년이 온다 (테스트)',
        'author': '한강',
        'coverImageUrl': 'https://image.aladin.co.kr/product/4086/97/cover200/8936434128_2.jpg',
        'conditionPhotos': [photoUrl],
        'condition': 'good',
        'conditionNote': '테스트 등록',
        'status': 'available',
        'exchangeType': 'both',
        'location': '서울 강남구',
        'geoPoint': const GeoPoint(37.5665, 126.9780),
        'genre': '소설',
        'tags': <String>[],
        'viewCount': 0,
        'wishCount': 0,
        'requestCount': 0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      print('책 등록 완료! Document ID: ${docRef.id}');

      // 5. 등록 확인
      final doc = await docRef.get();
      expect(doc.exists, true);
      expect(doc.data()?['title'], '소년이 온다 (테스트)');
      expect(doc.data()?['author'], '한강');
      expect(doc.data()?['conditionPhotos'], isNotEmpty);
      print('등록 데이터 확인 완료!');

      // 6. 정리 (테스트 데이터 삭제)
      await storageRef.delete();
      await docRef.delete();
      await cred.user!.delete();
      print('테스트 데이터 정리 완료');
    });
  });
}
