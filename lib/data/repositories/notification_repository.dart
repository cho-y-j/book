import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../../core/constants/api_constants.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection(ApiConstants.notificationsCollection);

  Future<void> createNotification(NotificationModel notification) async {
    await _notificationsRef.add(notification.toFirestore());
  }

  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _notificationsRef
        .where('targetUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final batch = _firestore.batch();
    final unread = await _notificationsRef
        .where('targetUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<int> getUnreadCount(String uid) async {
    final snapshot = await _notificationsRef
        .where('targetUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
