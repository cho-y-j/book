import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nicknameController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() { _nicknameController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);
    if (!_initialized && userAsync.value != null) {
      _nicknameController.text = userAsync.value?.nickname ?? '';
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 편집'), actions: [
        TextButton(onPressed: () async {
          final uid = ref.read(currentUserProvider)?.uid;
          if (uid != null) {
            await ref.read(userRepositoryProvider).updateUser(uid, {'nickname': _nicknameController.text.trim()});
            ref.invalidate(currentUserProfileProvider);
          }
          if (mounted) Navigator.pop(context);
        }, child: Text('저장', style: TextStyle(color: AppColors.primary))),
      ]),
      body: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(children: [
        Center(child: Stack(children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userAsync.value?.profileImageUrl != null ? NetworkImage(userAsync.value!.profileImageUrl!) : null,
            child: userAsync.value?.profileImageUrl == null ? const Icon(Icons.person, size: 50) : null,
          ),
          Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
        ])),
        const SizedBox(height: 24),
        TextFormField(controller: _nicknameController, decoration: const InputDecoration(labelText: '닉네임')),
        const SizedBox(height: 16),
        ListTile(title: const Text('활동 지역'), subtitle: Text(userAsync.value?.primaryLocation ?? '미설정'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
      ])),
    );
  }
}
