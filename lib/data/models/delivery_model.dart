import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryModel {
  final String? carrier;
  final String? trackingNumber;
  final String status; // 'pending' | 'shipped' | 'in_transit' | 'delivered'
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  const DeliveryModel({
    this.carrier,
    this.trackingNumber,
    this.status = 'pending',
    this.shippedAt,
    this.deliveredAt,
  });

  factory DeliveryModel.fromMap(Map<String, dynamic> data) {
    return DeliveryModel(
      carrier: data['carrier'],
      trackingNumber: data['trackingNumber'],
      status: data['status'] ?? 'pending',
      shippedAt: (data['shippedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'status': status,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }
}
