import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/donation_repository.dart';
import '../data/models/donation_model.dart';
import '../data/models/organization_model.dart';
import 'auth_providers.dart';
import 'user_providers.dart';

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

/// 지역 필터
final selectedRegionProvider = StateProvider<String?>((ref) => null);

/// 지역별 기관 목록
final organizationsByRegionProvider =
    FutureProvider<List<OrganizationModel>>((ref) async {
  final region = ref.watch(selectedRegionProvider);
  return ref
      .watch(donationRepositoryProvider)
      .getOrganizationsByRegion(region: region);
});

/// 고향 지역 기관 목록
final hometownOrganizationsProvider =
    FutureProvider<List<OrganizationModel>>((ref) async {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  final region = profile?.hometownRegion;
  if (region == null) return [];
  return ref
      .watch(donationRepositoryProvider)
      .getOrganizationsByRegion(region: region);
});

/// 기관 상세
final organizationDetailProvider =
    FutureProvider.family<OrganizationModel?, String>((ref, orgId) async {
  return ref.watch(donationRepositoryProvider).getOrganization(orgId);
});
