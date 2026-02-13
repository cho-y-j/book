import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';

class BookEditScreen extends ConsumerStatefulWidget {
  final String bookId;
  const BookEditScreen({super.key, required this.bookId});
  @override
  ConsumerState<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends ConsumerState<BookEditScreen> {
  BookCondition _condition = BookCondition.good;
  ExchangeType _exchangeType = ExchangeType.both;
  final _noteController = TextEditingController();
  bool _initialized = false;
  bool _isSaving = false;

  // 기존 사진 URL + 새로 추가된 사진
  List<String> _existingPhotoUrls = [];
  final List<Uint8List> _newPhotoBytes = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _initFromBook() {
    final book = ref.read(bookDetailProvider(widget.bookId)).value;
    if (book == null || _initialized) return;
    _condition = BookCondition.values.firstWhere(
      (c) => c.name == book.condition,
      orElse: () => BookCondition.good,
    );
    _exchangeType = switch (book.exchangeType) {
      'local_only' => ExchangeType.localOnly,
      'delivery_only' => ExchangeType.deliveryOnly,
      _ => ExchangeType.both,
    };
    _noteController.text = book.conditionNote ?? '';
    _existingPhotoUrls = List.from(book.conditionPhotos);
    _initialized = true;
  }

  int get _totalPhotos => _existingPhotoUrls.length + _newPhotoBytes.length;

  Future<void> _pickImage(ImageSource source) async {
    if (_totalPhotos >= 5) return;
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _newPhotoBytes.add(bytes));
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
      builder: (ctx) => SafeArea(child: Wrap(children: [
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('갤러리에서 선택'),
          onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
        ),
        if (!kIsWeb)
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('카메라로 촬영'),
            onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
          ),
      ])),
    );
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // 새 사진 업로드
      final allPhotoUrls = List<String>.from(_existingPhotoUrls);
      for (int i = 0; i < _newPhotoBytes.length; i++) {
        final storageRef = FirebaseStorage.instance.ref()
            .child('books/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_edit_$i.jpg');
        await storageRef.putData(_newPhotoBytes[i], SettableMetadata(contentType: 'image/jpeg'));
        final url = await storageRef.getDownloadURL();
        allPhotoUrls.add(url);
      }

      await ref.read(bookRepositoryProvider).updateBook(widget.bookId, {
        'condition': _condition.name,
        'conditionNote': _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        'exchangeType': _exchangeType == ExchangeType.localOnly ? 'local_only'
            : _exchangeType == ExchangeType.deliveryOnly ? 'delivery_only' : 'both',
        'conditionPhotos': allPhotoUrls,
        'updatedAt': DateTime.now(),
      });

      ref.invalidate(bookDetailProvider(widget.bookId));
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid != null) ref.invalidate(userBooksProvider(uid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수정 완료!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookDetailProvider(widget.bookId));

    return bookAsync.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('책 수정')), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(title: const Text('책 수정')), body: Center(child: Text('불러오기 실패: $e'))),
      data: (book) {
        if (book == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('존재하지 않는 책입니다')));
        }

        if (!_initialized) _initFromBook();

        return Scaffold(
          appBar: AppBar(
            title: const Text('책 수정'),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('저장', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // 책 정보 (읽기 전용)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Row(children: [
                  if (book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(imageUrl: book.coverImageUrl!, width: 50, height: 70, fit: BoxFit.cover),
                    ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(book.title, style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(book.author, style: AppTypography.bodySmall),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),

              // 책 상태
              Text('책 상태', style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(
                label: Text(c.label),
                selected: _condition == c,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => setState(() => _condition = c),
              )).toList()),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: '상태 메모 (선택)', hintText: '예: 밑줄 약간 있음'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // 실물 사진
              Text('실물 사진 ($_totalPhotos/5)', style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  // 추가 버튼
                  if (_totalPhotos < 5) GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 100, height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 32),
                        const SizedBox(height: 4),
                        Text('$_totalPhotos/5', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ]),
                    ),
                  ),
                  // 기존 사진
                  ..._existingPhotoUrls.asMap().entries.map((e) => _buildPhotoTile(
                    child: CachedNetworkImage(imageUrl: e.value, width: 100, height: 100, fit: BoxFit.cover),
                    onDelete: () => setState(() => _existingPhotoUrls.removeAt(e.key)),
                  )),
                  // 새 사진
                  ..._newPhotoBytes.asMap().entries.map((e) => _buildPhotoTile(
                    child: Image.memory(e.value, width: 100, height: 100, fit: BoxFit.cover),
                    onDelete: () => setState(() => _newPhotoBytes.removeAt(e.key)),
                  )),
                ]),
              ),
              const SizedBox(height: 24),

              // 거래 방식
              Text('거래 방식', style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: ExchangeType.values.map((t) => ChoiceChip(
                label: Text(t.label),
                selected: _exchangeType == t,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => setState(() => _exchangeType = t),
              )).toList()),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildPhotoTile({required Widget child, required VoidCallback onDelete}) {
    return Container(
      width: 100, height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), child: child),
        Positioned(top: 4, right: 4, child: GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        )),
      ]),
    );
  }
}
