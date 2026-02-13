import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exchange_request_model.dart';
import '../models/match_model.dart';
import '../../core/constants/api_constants.dart';

class ExchangeRepository {
  final FirebaseFirestore _firestore;

  ExchangeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requestsRef =>
      _firestore.collection(ApiConstants.exchangeRequestsCollection);

  CollectionReference<Map<String, dynamic>> get _matchesRef =>
      _firestore.collection(ApiConstants.matchesCollection);

  // Exchange Requests
  Future<String> createRequest(ExchangeRequestModel request) async {
    final doc = await _requestsRef.add(request.toFirestore());
    return doc.id;
  }

  Future<List<ExchangeRequestModel>> getIncomingRequests(String uid) async {
    final snapshot = await _requestsRef
        .where('ownerUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => ExchangeRequestModel.fromFirestore(d))
        .toList();
  }

  Future<List<ExchangeRequestModel>> getSentRequests(String uid) async {
    final snapshot = await _requestsRef
        .where('requesterUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => ExchangeRequestModel.fromFirestore(d))
        .toList();
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _requestsRef.doc(requestId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  // Matches
  Future<String> createMatch(MatchModel match) async {
    final doc = await _matchesRef.add(match.toFirestore());
    return doc.id;
  }

  Future<MatchModel?> getMatch(String matchId) async {
    final doc = await _matchesRef.doc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromFirestore(doc);
  }

  Future<List<MatchModel>> getUserMatches(String uid) async {
    final snapshotA = await _matchesRef
        .where('userAUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    final snapshotB = await _matchesRef
        .where('userBUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final matches = [
      ...snapshotA.docs.map((d) => MatchModel.fromFirestore(d)),
      ...snapshotB.docs.map((d) => MatchModel.fromFirestore(d)),
    ];
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches;
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    await _matchesRef.doc(matchId).update({'status': status});
  }

  Future<void> confirmReceived(String matchId, String uid) async {
    final match = await getMatch(matchId);
    if (match == null) return;

    if (match.userAUid == uid) {
      await _matchesRef.doc(matchId).update({'userAConfirmed': true});
    } else {
      await _matchesRef.doc(matchId).update({'userBConfirmed': true});
    }
  }
}
