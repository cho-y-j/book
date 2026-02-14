import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import '../models/organization_model.dart';
import '../../core/constants/api_constants.dart';

class DonationRepository {
  final FirebaseFirestore _firestore;

  DonationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _donationsRef =>
      _firestore.collection(ApiConstants.donationsCollection);

  CollectionReference<Map<String, dynamic>> get _orgsRef =>
      _firestore.collection(ApiConstants.organizationsCollection);

  // --- Donations ---
  Future<String> createDonation(DonationModel donation) async {
    final doc = await _donationsRef.add(donation.toFirestore());
    return doc.id;
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': Timestamp.now(),
    };
    if (status == 'completed') {
      data['completedAt'] = Timestamp.now();
    }
    await _donationsRef.doc(donationId).update(data);
  }

  Stream<List<DonationModel>> watchUserDonations(String donorUid) {
    return _donationsRef
        .where('donorUid', isEqualTo: donorUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DonationModel.fromFirestore(doc))
            .toList());
  }

  // --- Organizations ---
  Future<List<OrganizationModel>> getOrganizations({String? category}) async {
    Query<Map<String, dynamic>> query =
        _orgsRef.where('isActive', isEqualTo: true).orderBy('name');
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    final snap = await query.get();
    return snap.docs
        .map((doc) => OrganizationModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<OrganizationModel>> watchOrganizations() {
    return _orgsRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OrganizationModel.fromFirestore(doc))
            .toList());
  }

  Future<String> createOrganization(OrganizationModel org) async {
    final doc = await _orgsRef.add(org.toFirestore());
    return doc.id;
  }

  Future<void> updateOrganization(
      String orgId, Map<String, dynamic> data) async {
    await _orgsRef.doc(orgId).update(data);
  }

  Future<void> deleteOrganization(String orgId) async {
    await _orgsRef.doc(orgId).update({'isActive': false});
  }
}
