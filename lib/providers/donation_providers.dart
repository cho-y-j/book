import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/donation_repository.dart';
import '../data/models/donation_model.dart';
import '../data/models/organization_model.dart';
import 'auth_providers.dart';

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository();
});

final userDonationsProvider = StreamProvider<List<DonationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(donationRepositoryProvider).watchUserDonations(user.uid);
});

final organizationsProvider =
    FutureProvider<List<OrganizationModel>>((ref) async {
  return ref.watch(donationRepositoryProvider).getOrganizations();
});

final organizationsStreamProvider =
    StreamProvider<List<OrganizationModel>>((ref) {
  return ref.watch(donationRepositoryProvider).watchOrganizations();
});
