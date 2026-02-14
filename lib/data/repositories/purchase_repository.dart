import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_request_model.dart';
import '../../core/constants/api_constants.dart';

class PurchaseRepository {
  final FirebaseFirestore _firestore;

  PurchaseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _purchaseRef =>
      _firestore.collection(ApiConstants.purchaseRequestsCollection);

  Future<String> createPurchaseRequest(PurchaseRequestModel request) async {
    final doc = await _purchaseRef.add(request.toFirestore());
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
    await _purchaseRef.doc(requestId).update(data);
  }

  Stream<List<PurchaseRequestModel>> watchIncomingRequests(String sellerUid) {
    return _purchaseRef
        .where('sellerUid', isEqualTo: sellerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PurchaseRequestModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<PurchaseRequestModel>> watchSentRequests(String buyerUid) {
    return _purchaseRef
        .where('buyerUid', isEqualTo: buyerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PurchaseRequestModel.fromFirestore(doc))
            .toList());
  }

  Future<List<PurchaseRequestModel>> getIncomingRequests(String sellerUid) async {
    final snap = await _purchaseRef
        .where('sellerUid', isEqualTo: sellerUid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) => PurchaseRequestModel.fromFirestore(doc)).toList();
  }
}
