import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('지역 설정'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '예: 서울시 강남구', labelText: '지역'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              final uid = ref.read(currentUserProvider)?.uid;
              if (uid != null && ctrl.text.trim().isNotEmpty) {
                await ref.read(userRepositoryProvider).updateUser(uid, {'primaryLocation': ctrl.text.trim()});
                ref.invalidate(currentUserProfileProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지역이 설정되었습니다')));
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsers(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('차단 사용자 관리'),
        content: const Text('차단한 사용자가 없습니다.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인'))],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '책다리 이용약관\n\n'
            '제1조 (목적)\n이 약관은 책다리(이하 "서비스")의 이용 조건 및 절차에 관한 사항을 규정합니다.\n\n'
            '제2조 (서비스 이용)\n① 서비스는 회원 가입 후 이용할 수 있습니다.\n② 회원은 타인의 개인정보를 침해해서는 안 됩니다.\n\n'
            '제3조 (책임 제한)\n서비스는 회원 간 거래에 대해 중개 역할만 하며, 거래 당사자 간 분쟁에 대해 책임지지 않습니다.\n\n'
            '제4조 (이용 제한)\n부적절한 콘텐츠 게시, 사기 행위 등의 경우 이용이 제한될 수 있습니다.',
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기'))],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('개인정보처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '책다리 개인정보처리방침\n\n'
            '1. 수집하는 개인정보\n- 이메일, 닉네임, 활동 지역\n- 프로필 사진 (선택)\n\n'
            '2. 개인정보의 이용목적\n- 서비스 제공 및 회원 관리\n- 교환 거래 중개\n- 알림 발송\n\n'
            '3. 개인정보의 보유기간\n- 회원 탈퇴 시까지 보유\n- 탈퇴 후 30일 이내 파기\n\n'
            '4. 개인정보의 제3자 제공\n- 원칙적으로 제3자에게 제공하지 않습니다.',
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기'))],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?\n\n탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Firestore 사용자 문서 삭제
                  await ref.read(userRepositoryProvider).updateUser(user.uid, {'status': 'deleted'});
                  await user.delete();
                }
                if (context.mounted) context.go(AppRoutes.login);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('탈퇴 실패: 재로그인 후 다시 시도해주세요\n$e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: Text('탈퇴', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final location = userAsync.value?.primaryLocation ?? '미설정';

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(children: [
        const _SectionHeader(title: '계정'),
        ListTile(
          leading: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          title: const Text('알림 설정'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => context.push(AppRoutes.notificationSettings),
        ),
        ListTile(
          leading: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
          title: const Text('지역 설정'),
          subtitle: Text(location),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => _showLocationDialog(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.block_outlined, color: AppColors.textSecondary),
          title: const Text('차단 사용자 관리'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => _showBlockedUsers(context),
        ),
        const _SectionHeader(title: '정보'),
        ListTile(
          leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
          title: const Text('이용약관'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => _showTerms(context),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
          title: const Text('개인정보처리방침'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => _showPrivacyPolicy(context),
        ),
        ListTile(
          leading: const Icon(Icons.source_outlined, color: AppColors.textSecondary),
          title: const Text('오픈소스 라이선스'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => showLicensePage(context: context, applicationName: '책다리', applicationVersion: '1.0.0'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
          title: Text('앱 버전'),
          trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const _SectionHeader(title: '계정 관리'),
        ListTile(
          leading: Icon(Icons.logout, color: AppColors.error),
          title: Text('로그아웃', style: TextStyle(color: AppColors.error)),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('로그아웃 하시겠습니까?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인')),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_forever, color: AppColors.error),
          title: Text('회원탈퇴', style: TextStyle(color: AppColors.error)),
          onTap: () => _showDeleteAccount(context, ref),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
    );
  }
}
