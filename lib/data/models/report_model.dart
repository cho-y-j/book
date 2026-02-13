import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterUid;
  final String reportedUid;
  final String? reportedBookId;
  final String reason;
  final String? description;
  final List<String>? evidencePhotos;
  final String status; // 'pending' | 'reviewed' | 'resolved'
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterUid,
    required this.reportedUid,
    this.reportedBookId,
    required this.reason,
    this.description,
    this.evidencePhotos,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterUid: data['reporterUid'] ?? '',
      reportedUid: data['reportedUid'] ?? '',
      reportedBookId: data['reportedBookId'],
      reason: data['reason'] ?? 'other',
      description: data['description'],
      evidencePhotos: data['evidencePhotos'] != null
          ? List<String>.from(data['evidencePhotos'])
          : null,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reportedBookId': reportedBookId,
      'reason': reason,
      'description': description,
      'evidencePhotos': evidencePhotos,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
