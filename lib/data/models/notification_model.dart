import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String targetUid;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.targetUid,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      targetUid: d['targetUid'] ?? '',
      type: d['type'] ?? 'system',
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      data: d['data'] as Map<String, dynamic>?,
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'targetUid': targetUid,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
