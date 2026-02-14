import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/book_club_model.dart';
import '../../../providers/book_club_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';

class CreateBookClubScreen extends ConsumerStatefulWidget {
  const CreateBookClubScreen({super.key});
  @override
  ConsumerState<CreateBookClubScreen> createState() => _CreateBookClubScreenState();
}

class _CreateBookClubScreenState extends ConsumerState<CreateBookClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '20');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProfileProvider).value;
      final club = BookClubModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        creatorUid: uid,
        location: user?.primaryLocation ?? '',
        geoPoint: user?.geoPoint ?? const GeoPoint(0, 0),
        memberUids: [uid],
        maxMembers: int.tryParse(_maxMembersController.text) ?? 20,
        createdAt: DateTime.now(),
      );

      await ref.read(bookClubRepositoryProvider).createBookClub(club);
      ref.invalidate(bookClubsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('책모임이 생성되었습니다!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('책모임 만들기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('새로운 책모임을 만들어보세요', style: AppTypography.headlineSmall),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '모임 이름 *', prefixIcon: Icon(Icons.groups)),
              validator: (v) => v?.trim().isEmpty == true ? '이름을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: '소개', hintText: '모임에 대해 소개해주세요'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxMembersController,
              decoration: const InputDecoration(labelText: '최대 인원', prefixIcon: Icon(Icons.people)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _create,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('모임 만들기'),
            ),
          ]),
        ),
      ),
    );
  }
}
