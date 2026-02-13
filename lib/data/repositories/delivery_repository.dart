import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/api_constants.dart';

class DeliveryRepository {
  final FirebaseFirestore _firestore;

  DeliveryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> updateDeliveryInfo({
    required String matchId,
    required String userPosition, // 'A' or 'B'
    required String carrier,
    required String trackingNumber,
  }) async {
    final field = 'delivery$userPosition';
    await _firestore
        .collection(ApiConstants.matchesCollection)
        .doc(matchId)
        .update({
      '$field.carrier': carrier,
      '$field.trackingNumber': trackingNumber,
      '$field.status': 'shipped',
      '$field.shippedAt': Timestamp.now(),
    });
  }

  Future<void> updateDeliveryStatus({
    required String matchId,
    required String userPosition,
    required String status,
  }) async {
    final field = 'delivery$userPosition';
    final updates = <String, dynamic>{'$field.status': status};
    if (status == 'delivered') {
      updates['$field.deliveredAt'] = Timestamp.now();
    }
    await _firestore
        .collection(ApiConstants.matchesCollection)
        .doc(matchId)
        .update(updates);
  }
}
