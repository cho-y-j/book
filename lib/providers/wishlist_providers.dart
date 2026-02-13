import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/wishlist_repository.dart';
import '../data/models/wishlist_model.dart';
import 'auth_providers.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository();
});

final userWishlistsProvider = StreamProvider<List<WishlistModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(wishlistRepositoryProvider).watchUserWishlists(user.uid);
});

final isWishlistedProvider =
    FutureProvider.family<bool, String>((ref, bookInfoId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return ref.watch(wishlistRepositoryProvider).isWishlisted(user.uid, bookInfoId);
});
