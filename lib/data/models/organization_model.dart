import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? contactInfo;
  final String? imageUrl;
  final String category; // 'library' | 'school' | 'ngo'
  final bool isActive;
  final DateTime createdAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.contactInfo,
    this.imageUrl,
    required this.category,
    this.isActive = true,
    required this.createdAt,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contactInfo: data['contactInfo'],
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'library',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'contactInfo': contactInfo,
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
