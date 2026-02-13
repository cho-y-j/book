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

class ManualRegisterScreen extends ConsumerStatefulWidget {
  const ManualRegisterScreen({super.key});
  @override
  ConsumerState<ManualRegisterScreen> createState() => _ManualRegisterScreenState();
}

class _ManualRegisterScreenState extends ConsumerState<ManualRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  BookGenre _selectedGenre = BookGenre.novel;
  BookCondition _condition = BookCondition.good;
  ExchangeType _exchangeType = ExchangeType.both;
  final List<XFile> _photoFiles = [];
  final List<Uint8List> _photoBytes = [];
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photoFiles.length >= 5) return;
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() { _photoFiles.add(picked); _photoBytes.add(bytes); });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진 선택 실패: $e')));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(child: Wrap(children: [
        ListTile(leading: const Icon(Icons.photo_library), title: const Text('갤러리에서 선택'),
          onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); }),
        if (!kIsWeb)
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('카메라로 촬영'),
            onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); }),
      ])),
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
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final storage = FirebaseStorage.instance;
      final photoUrls = <String>[];
      for (int i = 0; i < _photoFiles.length; i++) {
        final ref = storage.ref().child('books/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await ref.putData(_photoBytes[i], SettableMetadata(contentType: 'image/jpeg'));
        photoUrls.add(await ref.getDownloadURL());
      }

      final now = DateTime.now();
      final title = _titleController.text.trim();
      final bookInfoId = 'manual_${title.hashCode}';
      final docRef = await FirebaseFirestore.instance.collection(ApiConstants.booksCollection).add({
        'ownerUid': user.uid,
        'bookInfoId': bookInfoId,
        'title': title,
        'author': _authorController.text.trim(),
        'coverImageUrl': '',
        'conditionPhotos': photoUrls,
        'condition': _condition.name,
        'conditionNote': _noteController.text.isNotEmpty ? _noteController.text : null,
        'status': 'available',
        'exchangeType': _exchangeType == ExchangeType.localOnly ? 'local_only'
            : _exchangeType == ExchangeType.deliveryOnly ? 'delivery_only' : 'both',
        'location': '',
        'geoPoint': const GeoPoint(37.5665, 126.9780),
        'genre': _selectedGenre.label,
        'tags': <String>[],
        'viewCount': 0, 'wishCount': 0, 'requestCount': 0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      // 위시리스트 매칭 알림
      await _notifyWishlistMatches(
        bookInfoId: bookInfoId,
        bookTitle: title,
        bookId: docRef.id,
        ownerUid: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('책이 등록되었습니다!'), backgroundColor: AppColors.success));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직접 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('책 정보를 입력해주세요', style: AppTypography.headlineSmall),
          const SizedBox(height: 24),
          TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: '제목 *'), validator: (v) => v?.isEmpty == true ? '제목을 입력해주세요' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _authorController, decoration: const InputDecoration(labelText: '저자 *'), validator: (v) => v?.isEmpty == true ? '저자를 입력해주세요' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _publisherController, decoration: const InputDecoration(labelText: '출판사')),
          const SizedBox(height: 16),
          DropdownButtonFormField<BookGenre>(
            value: _selectedGenre, decoration: const InputDecoration(labelText: '장르 *'),
            items: BookGenre.values.where((g) => g != BookGenre.all).map((g) => DropdownMenuItem(value: g, child: Text(g.label))).toList(),
            onChanged: (v) => setState(() => _selectedGenre = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: '줄거리/소개'), maxLines: 3),
          const SizedBox(height: 24),

          // 책 상태
          Text('책 상태', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(
            label: Text(c.label), selected: _condition == c, selectedColor: AppColors.primaryLight,
            onSelected: (_) => setState(() => _condition = c),
          )).toList()),
          const SizedBox(height: 16),
          TextFormField(controller: _noteController, decoration: const InputDecoration(labelText: '상태 메모 (선택)', hintText: '예: 밑줄 약간 있음'), maxLines: 2),
          const SizedBox(height: 24),

          // 실물 사진
          Text('실물 사진 (최소 1장, 최대 5장)', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          SizedBox(height: 110, child: ListView(scrollDirection: Axis.horizontal, children: [
            if (_photoFiles.length < 5) GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), border: Border.all(color: AppColors.primary)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 32),
                  const SizedBox(height: 4),
                  Text('${_photoFiles.length}/5', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ]),
              ),
            ),
            ..._photoBytes.asMap().entries.map((e) => Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
              child: Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), child: Image.memory(e.value, width: 100, height: 100, fit: BoxFit.cover)),
                Positioned(top: 4, right: 4, child: GestureDetector(
                  onTap: () => setState(() { _photoFiles.removeAt(e.key); _photoBytes.removeAt(e.key); }),
                  child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                )),
              ]),
            )),
          ])),
          const SizedBox(height: 24),

          // 거래 방식
          Text('거래 방식', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: ExchangeType.values.map((t) => ChoiceChip(
            label: Text(t.label), selected: _exchangeType == t, selectedColor: AppColors.primaryLight,
            onSelected: (_) => setState(() => _exchangeType = t),
          )).toList()),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: (_photoFiles.isNotEmpty && !_isSubmitting) ? _submitBook : null,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('등록 완료'),
          ),
          if (_photoFiles.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 8),
              child: Text('실물 사진을 최소 1장 추가해주세요', style: AppTypography.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.center)),
        ])),
      ),
    );
  }
}
