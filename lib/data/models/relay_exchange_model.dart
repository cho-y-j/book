import 'package:cloud_firestore/cloud_firestore.dart';

class RelayParticipant {
  final String uid;
  final String givingBookId;
  final String receivingBookId;
  final String receivingFromUid;
  final bool confirmed;

  const RelayParticipant({
    required this.uid,
    required this.givingBookId,
    required this.receivingBookId,
    required this.receivingFromUid,
    this.confirmed = false,
  });

  factory RelayParticipant.fromMap(Map<String, dynamic> data) {
    return RelayParticipant(
      uid: data['uid'] ?? '',
      givingBookId: data['givingBookId'] ?? '',
      receivingBookId: data['receivingBookId'] ?? '',
      receivingFromUid: data['receivingFromUid'] ?? '',
      confirmed: data['confirmed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'givingBookId': givingBookId,
      'receivingBookId': receivingBookId,
      'receivingFromUid': receivingFromUid,
      'confirmed': confirmed,
    };
  }
}

class RelayExchangeModel {
  final String id;
  final List<RelayParticipant> participants;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const RelayExchangeModel({
    required this.id,
    required this.participants,
    this.status = 'proposed',
    required this.createdAt,
    this.completedAt,
  });

  factory RelayExchangeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RelayExchangeModel(
      id: doc.id,
      participants: (data['participants'] as List<dynamic>?)
              ?.map((p) => RelayParticipant.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      status: data['status'] ?? 'proposed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants.map((p) => p.toMap()).toList(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
