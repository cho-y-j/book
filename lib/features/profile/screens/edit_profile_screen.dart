import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _initialized = false;
  bool _isSaving = false;
  Uint8List? _newImageBytes;
  String? _currentImageUrl;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nicknameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(child: Wrap(children: [
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('갤러리에서 선택'),
          onTap: () => Navigator.pop(ctx, ImageSource.gallery),
        ),
        if (!kIsWeb)
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('카메라로 촬영'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
      ])),
    );
    if (source == null) return;
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _newImageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진 선택 실패: $e')));
      }
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: _locationController.text);
        return AlertDialog(
          title: const Text('활동 지역 설정'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: '예: 서울시 강남구', labelText: '지역'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            TextButton(
              onPressed: () {
                setState(() => _locationController.text = ctrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'nickname': _nicknameController.text.trim(),
        'primaryLocation': _locationController.text.trim(),
      };

      // 새 이미지 업로드
      if (_newImageBytes != null) {
        final storageRef = FirebaseStorage.instance.ref()
            .child('profiles/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putData(_newImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
        final url = await storageRef.getDownloadURL();
        updates['profileImageUrl'] = url;
      }

      await ref.read(userRepositoryProvider).updateUser(uid, updates);
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 수정되었습니다'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);
    if (!_initialized && userAsync.value != null) {
      _nicknameController.text = userAsync.value?.nickname ?? '';
      _locationController.text = userAsync.value?.primaryLocation ?? '';
      _currentImageUrl = userAsync.value?.profileImageUrl;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
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
        child: Column(children: [
          // 프로필 이미지
          Center(child: GestureDetector(
            onTap: _pickImage,
            child: Stack(children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _newImageBytes != null
                    ? MemoryImage(_newImageBytes!)
                    : (_currentImageUrl != null ? CachedNetworkImageProvider(_currentImageUrl!) : null),
                child: (_newImageBytes == null && _currentImageUrl == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ]),
          )),
          const SizedBox(height: 8),
          Text('사진을 탭하여 변경', style: AppTypography.caption),
          const SizedBox(height: 24),

          // 닉네임
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: '닉네임', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),

          // 활동 지역
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('활동 지역'),
            subtitle: Text(
              _locationController.text.isNotEmpty ? _locationController.text : '미설정',
              style: TextStyle(color: _locationController.text.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLocationDialog,
          ),
        ]),
      ),
    );
  }
}
