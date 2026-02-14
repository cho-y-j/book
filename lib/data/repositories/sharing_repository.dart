import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sharing_request_model.dart';
import '../../core/constants/api_constants.dart';

class SharingRepository {
  final FirebaseFirestore _firestore;

  SharingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sharingRef =>
      _firestore.collection(ApiConstants.sharingRequestsCollection);

  Future<String> createSharingRequest(SharingRequestModel request) async {
    final doc = await _sharingRef.add(request.toFirestore());
    return doc.id;
  }

  Future<void> updateStatus(String requestId, String status) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': Timestamp.now(),
    };
    if (status == 'completed') {
      data['completedAt'] = Timestamp.now();
    }
    await _sharingRef.doc(requestId).update(data);
  }

  Future<void> updateChatRoomId(String requestId, String chatRoomId) async {
    await _sharingRef.doc(requestId).update({
      'chatRoomId': chatRoomId,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<SharingRequestModel>> watchIncomingRequests(String ownerUid) {
    return _sharingRef
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SharingRequestModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<SharingRequestModel>> watchSentRequests(String requesterUid) {
    return _sharingRef
        .where('requesterUid', isEqualTo: requesterUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SharingRequestModel.fromFirestore(doc))
            .toList());
  }
}
