import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/enums.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/models/organization_model.dart';
import '../../../providers/donation_providers.dart';

class BookConditionScreen extends ConsumerStatefulWidget {
  const BookConditionScreen({super.key});
  @override
  ConsumerState<BookConditionScreen> createState() => _BookConditionScreenState();
}

class _BookConditionScreenState extends ConsumerState<BookConditionScreen> {
  BookCondition _condition = BookCondition.good;
  ExchangeType _exchangeType = ExchangeType.both;
  ListingType _listingType = ListingType.exchange;
  final _noteController = TextEditingController();
  final _priceController = TextEditingController();
  final List<XFile> _photoFiles = [];
  final List<Uint8List> _photoBytes = [];
  final _picker = ImagePicker();
  bool _isSubmitting = false;
  Map<String, dynamic>? _bookData;
  OrganizationModel? _selectedOrganization;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookData ??= GoRouterState.of(context).extra as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photoFiles.length >= 5) return;
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _photoFiles.add(picked);
          _photoBytes.add(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진 선택 실패: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('갤러리에서 선택'),
            onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close, color: AppColors.textSecondary),
            title: const Text('취소'),
            onTap: () => Navigator.pop(ctx),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _notifyWishlistMatches({
    required String bookInfoId,
    required String bookTitle,
    required String bookId,
    required String ownerUid,
  }) async {
    try {
      final wishlists = await FirebaseFirestore.instance
          .collection('wishlists')
          .where('bookInfoId', isEqualTo: bookInfoId)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in wishlists.docs) {
        final wishUserUid = doc.data()['userUid'] as String?;
        if (wishUserUid == null || wishUserUid == ownerUid) continue;
        final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notifRef, {
          'targetUid': wishUserUid,
          'type': 'wishlist_match',
          'title': '위시리스트 매칭!',
          'body': '원하시던 "$bookTitle"이(가) 등록되었습니다!',
          'data': {'type': 'wishlist_match', 'id': bookId},
          'isRead': false,
          'createdAt': Timestamp.now(),
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  Future<void> _submitBook() async {
    if (_listingType == ListingType.donation && _selectedOrganization == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기증할 기관을 선택해주세요')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. 사진 업로드
      final storage = FirebaseStorage.instance;
      final photoUrls = <String>[];
      for (int i = 0; i < _photoFiles.length; i++) {
        final ref = storage.ref().child('books/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await ref.putData(_photoBytes[i], SettableMetadata(contentType: 'image/jpeg'));
        final url = await ref.getDownloadURL();
        photoUrls.add(url);
      }

      // 2. 가격 처리
      final needsPrice = _listingType == ListingType.sale || _listingType == ListingType.both;
      final price = needsPrice && _priceController.text.isNotEmpty
          ? int.parse(_priceController.text) : null;

      // 3. Firestore에 책 등록
      final now = DateTime.now();
      final bookDoc = {
        'ownerUid': user.uid,
        'bookInfoId': _bookData?['isbn13'] ?? _bookData?['isbn'] ?? 'manual',
        'title': _bookData?['title'] ?? '직접 등록',
        'author': _bookData?['author'] ?? '',
        'coverImageUrl': _bookData?['cover'] ?? '',
        'conditionPhotos': photoUrls,
        'condition': _condition.name,
        'conditionNote': _noteController.text.isNotEmpty ? _noteController.text : null,
        'status': 'available',
        'exchangeType': _exchangeType == ExchangeType.localOnly ? 'local_only'
            : _exchangeType == ExchangeType.deliveryOnly ? 'delivery_only' : 'both',
        'listingType': _listingType.name,
        'price': price,
        'isDealer': false,
        'location': '',
        'geoPoint': const GeoPoint(37.5665, 126.9780),
        'genre': _bookData?['categoryName']?.toString().split('>').elementAtOrNull(1)?.trim() ?? '기타',
        'tags': <String>[],
        'viewCount': 0,
        'wishCount': 0,
        'requestCount': 0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        // 알라딘 API 상세정보
        'publisher': _bookData?['publisher'],
        'pubDate': _bookData?['pubDate'],
        'description': _bookData?['description'],
        'originalPrice': _bookData?['priceStandard'],
      };

      final docRef = await FirebaseFirestore.instance.collection(ApiConstants.booksCollection).add(bookDoc);

      // 4. 기증인 경우 DonationModel 생성
      if (_listingType == ListingType.donation && _selectedOrganization != null) {
        final donation = DonationModel(
          id: '',
          donorUid: user.uid,
          bookId: docRef.id,
          bookTitle: bookDoc['title'] as String,
          organizationId: _selectedOrganization!.id,
          organizationName: _selectedOrganization!.name,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(donationRepositoryProvider).createDonation(donation);
      }

      // 5. 위시리스트 매칭 알림 생성
      await _notifyWishlistMatches(
        bookInfoId: bookDoc['bookInfoId'] as String,
        bookTitle: bookDoc['title'] as String,
        bookId: docRef.id,
        ownerUid: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('책이 등록되었습니다!'), backgroundColor: AppColors.success));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showExchangeType = _listingType != ListingType.sharing && _listingType != ListingType.donation;
    final showPrice = _listingType == ListingType.sale || _listingType == ListingType.both;

    return Scaffold(
      appBar: AppBar(title: const Text('책 상태 입력')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // 선택한 책 정보 미리보기
          if (_bookData != null) Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.1), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            child: Row(children: [
              if (_bookData!['cover'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(_bookData!['cover'], width: 50, height: 70, fit: BoxFit.cover),
                ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_bookData!['title'] ?? '', style: AppTypography.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(_bookData!['author'] ?? '', style: AppTypography.bodySmall),
                if (_bookData!['publisher'] != null)
                  Text(_bookData!['publisher'], style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ])),
            ]),
          ),
          if (_bookData != null) const SizedBox(height: 24),

          // 책 상태
          Text('책 상태를 선택해주세요', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(
            label: Text(c.label), selected: _condition == c,
            selectedColor: AppColors.primaryLight,
            onSelected: (_) => setState(() => _condition = c),
          )).toList()),
          const SizedBox(height: 16),
          TextFormField(controller: _noteController, decoration: const InputDecoration(labelText: '상태 메모 (선택)', hintText: '예: 밑줄 약간 있음'), maxLines: 2),
          const SizedBox(height: 24),

          // 실물 사진 (선택)
          Text('실물 사진 (선택, 최대 5장)', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              if (_photoFiles.length < 5) GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 32),
                    const SizedBox(height: 4),
                    Text('${_photoFiles.length}/5', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ]),
                ),
              ),
              ..._photoBytes.asMap().entries.map((e) => Container(
                width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    child: Image.memory(e.value, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(top: 4, right: 4, child: GestureDetector(
                    onTap: () => setState(() { _photoFiles.removeAt(e.key); _photoBytes.removeAt(e.key); }),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  )),
                ]),
              )),
            ]),
          ),
          if (_photoFiles.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('사진을 추가하면 교환 확률이 높아져요', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            ),
          const SizedBox(height: 24),

          // 등록 유형 (교환/판매/나눔/기증)
          Text('등록 유형', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: ListingType.values.map((t) => ChoiceChip(
            label: Text(t.label), selected: _listingType == t,
            selectedColor: AppColors.primaryLight,
            onSelected: (_) => setState(() {
              _listingType = t;
              _selectedOrganization = null;
            }),
          )).toList()),

          // 가격 입력 (판매/교환+판매)
          if (showPrice) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '판매 가격 (원)', hintText: '예: 10000', prefixText: '₩ '),
              keyboardType: TextInputType.number,
            ),
          ],

          // 기증 기관 선택
          if (_listingType == ListingType.donation) ...[
            const SizedBox(height: 16),
            Text('기증 기관 선택', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Consumer(builder: (context, ref, _) {
              final orgsAsync = ref.watch(organizationsProvider);
              return orgsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('기관 목록 로딩 실패: $e'),
                data: (orgs) {
                  if (orgs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.divider.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                      child: const Text('등록된 기관이 없습니다. 관리자에게 문의해주세요.', textAlign: TextAlign.center),
                    );
                  }
                  return Column(children: orgs.map((org) => RadioListTile<String>(
                    title: Text(org.name),
                    subtitle: Text('${_categoryLabel(org.category)} · ${org.address}', style: AppTypography.bodySmall),
                    value: org.id,
                    groupValue: _selectedOrganization?.id,
                    onChanged: (_) => setState(() => _selectedOrganization = org),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )).toList());
                },
              );
            }),
          ],
          const SizedBox(height: 24),

          // 거래 방식 (교환/판매/교환+판매만)
          if (showExchangeType) ...[
            Text('거래 방식', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: ExchangeType.values.map((t) => ChoiceChip(
              label: Text(t.label), selected: _exchangeType == t,
              selectedColor: AppColors.primaryLight,
              onSelected: (_) => setState(() => _exchangeType = t),
            )).toList()),
            const SizedBox(height: 24),
          ],

          // 등록 버튼
          ElevatedButton(
            onPressed: !_isSubmitting ? _submitBook : null,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('등록 완료'),
          ),
        ]),
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'library': return '도서관';
      case 'school': return '학교';
      case 'ngo': return 'NGO';
      default: return category;
    }
  }
}
