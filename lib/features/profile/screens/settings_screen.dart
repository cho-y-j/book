import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(children: [
        const _SectionHeader(title: '계정'),
        ListTile(title: const Text('알림 설정'), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: () => context.push(AppRoutes.notificationSettings)),
        ListTile(title: const Text('지역 설정'), subtitle: const Text('서울시 강남구'), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: () {}),
        ListTile(title: const Text('차단 사용자 관리'), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: () {}),
        const _SectionHeader(title: '정보'),
        ListTile(title: const Text('이용약관'), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: () {}),
        ListTile(title: const Text('개인정보처리방침'), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: () {}),
        ListTile(title: const Text('오픈소스 라이선스'), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: () {}),
        const ListTile(title: Text('앱 버전'), trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary))),
        const _SectionHeader(title: '계정'),
        ListTile(title: Text('로그아웃', style: TextStyle(color: AppColors.error)), onTap: () async {
          final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('로그아웃'), content: const Text('로그아웃 하시겠습니까?'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('확인'))],
          ));
          if (confirmed == true && context.mounted) {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          }
        }),
        ListTile(title: Text('회원탈퇴', style: TextStyle(color: AppColors.error)), onTap: () {}),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)));
  }
}
