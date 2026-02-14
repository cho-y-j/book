import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/book_model.dart';
import '../../core/constants/api_constants.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stats
  Stream<Map<String, dynamic>> watchStats() {
    // Aggregate stats from collections in real-time
    // Return stream that combines user count, book count, etc.
    return _firestore.collection(ApiConstants.adminCollection).doc('stats').snapshots().map((doc) {
      return doc.data() ?? {};
    });
  }

  Future<Map<String, int>> getStats() async {
    final users = await _firestore.collection(ApiConstants.usersCollection).count().get();
    final books = await _firestore.collection(ApiConstants.booksCollection).count().get();
    final exchanges = await _firestore.collection(ApiConstants.exchangeRequestsCollection)
        .where('status', isEqualTo: 'completed').count().get();
    final purchases = await _firestore.collection(ApiConstants.purchaseRequestsCollection)
        .where('status', isEqualTo: 'completed').count().get();
    final dealers = await _firestore.collection(ApiConstants.usersCollection)
        .where('role', isEqualTo: 'dealer').count().get();
    final pendingReports = await _firestore.collection(ApiConstants.reportsCollection)
        .where('status', isEqualTo: 'pending').count().get();

    return {
      'totalUsers': users.count ?? 0,
      'totalBooks': books.count ?? 0,
      'totalExchanges': exchanges.count ?? 0,
      'totalSales': purchases.count ?? 0,
      'totalDealers': dealers.count ?? 0,
      'pendingReports': pendingReports.count ?? 0,
    };
  }

  // User management
  Future<List<UserModel>> getAllUsers({String? role, String? status, int limit = 50}) async {
    Query<Map<String, dynamic>> query = _firestore.collection(ApiConstants.usersCollection)
        .orderBy('createdAt', descending: true).limit(limit);
    if (role != null) query = query.where('role', isEqualTo: role);
    if (status != null) query = query.where('status', isEqualTo: status);
    final snap = await query.get();
    return snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection(ApiConstants.usersCollection).doc(uid).update({'role': role});
  }

  Future<void> suspendUser(String uid) async {
    await _firestore.collection(ApiConstants.usersCollection).doc(uid).update({'status': 'suspended'});
  }

  Future<void> unsuspendUser(String uid) async {
    await _firestore.collection(ApiConstants.usersCollection).doc(uid).update({'status': 'active'});
  }

  // Dealer management
  Future<List<UserModel>> getPendingDealerRequests() async {
    final snap = await _firestore.collection(ApiConstants.usersCollection)
        .where('role', isEqualTo: 'dealer')
        .where('dealerStatus', isEqualTo: 'pending')
        .get();
    return snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<void> approveDealerRequest(String uid) async {
    await _firestore.collection(ApiConstants.usersCollection).doc(uid).update({
      'dealerStatus': 'approved',
    });
  }

  Future<void> rejectDealerRequest(String uid) async {
    await _firestore.collection(ApiConstants.usersCollection).doc(uid).update({
      'role': 'user',
      'dealerStatus': null,
    });
  }

  // Book management
  Future<List<BookModel>> getAllBooks({String? status, int limit = 50}) async {
    Query<Map<String, dynamic>> query = _firestore.collection(ApiConstants.booksCollection)
        .orderBy('createdAt', descending: true).limit(limit);
    if (status != null) query = query.where('status', isEqualTo: status);
    final snap = await query.get();
    return snap.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection(ApiConstants.booksCollection).doc(bookId).delete();
  }

  // Report management
  Future<List<Map<String, dynamic>>> getPendingReports() async {
    final snap = await _firestore.collection(ApiConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> resolveReport(String reportId, String resolution) async {
    await _firestore.collection(ApiConstants.reportsCollection).doc(reportId).update({
      'status': 'resolved',
      'resolution': resolution,
      'resolvedAt': Timestamp.now(),
    });
  }
}
