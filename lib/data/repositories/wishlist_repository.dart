import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_model.dart';
import '../../core/constants/api_constants.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _wishlistsRef =>
      _firestore.collection(ApiConstants.wishlistsCollection);

  Future<String> addWishlist(WishlistModel wishlist) async {
    final doc = await _wishlistsRef.add(wishlist.toFirestore());
    return doc.id;
  }

  Future<void> removeWishlist(String wishlistId) async {
    await _wishlistsRef.doc(wishlistId).delete();
  }

  Future<void> removeByBookInfoId(String userUid, String bookInfoId) async {
    final snapshot = await _wishlistsRef
        .where('userUid', isEqualTo: userUid)
        .where('bookInfoId', isEqualTo: bookInfoId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<WishlistModel>> watchUserWishlists(String uid) {
    return _wishlistsRef
        .where('userUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => WishlistModel.fromFirestore(d)).toList());
  }

  Future<bool> isWishlisted(String userUid, String bookInfoId) async {
    final snapshot = await _wishlistsRef
        .where('userUid', isEqualTo: userUid)
        .where('bookInfoId', isEqualTo: bookInfoId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// 특정 bookInfoId를 위시리스트에 넣은 사용자들 조회 (매칭 알림용)
  Future<List<WishlistModel>> getWishlistsByBookInfoId(String bookInfoId) async {
    final snapshot = await _wishlistsRef
        .where('bookInfoId', isEqualTo: bookInfoId)
        .get();
    return snapshot.docs.map((d) => WishlistModel.fromFirestore(d)).toList();
  }

  /// 알림이 활성화된 위시리스트 조회 (bookInfoId 기반)
  Future<List<WishlistModel>> getAlertWishlistsByBookInfoId(String bookInfoId) async {
    final snapshot = await _wishlistsRef
        .where('bookInfoId', isEqualTo: bookInfoId)
        .where('alertEnabled', isEqualTo: true)
        .get();
    return snapshot.docs.map((d) => WishlistModel.fromFirestore(d)).toList();
  }

  /// 알림 설정 업데이트
  Future<void> updateAlertSettings(
    String wishlistId, {
    required bool alertEnabled,
    List<String>? preferredConditions,
    List<String>? preferredListingTypes,
    String? alertNote,
  }) async {
    final data = <String, dynamic>{
      'alertEnabled': alertEnabled,
    };
    if (preferredConditions != null) {
      data['preferredConditions'] = preferredConditions;
    }
    if (preferredListingTypes != null) {
      data['preferredListingTypes'] = preferredListingTypes;
    }
    if (alertNote != null) {
      data['alertNote'] = alertNote;
    }
    await _wishlistsRef.doc(wishlistId).update(data);
  }

  /// isNotified 플래그 업데이트
  Future<void> markAsNotified(String wishlistId) async {
    await _wishlistsRef.doc(wishlistId).update({'isNotified': true});
  }
}
