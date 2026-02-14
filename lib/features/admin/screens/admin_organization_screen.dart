import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/organization_model.dart';
import '../../../providers/donation_providers.dart';

class AdminOrganizationScreen extends ConsumerWidget {
  const AdminOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgsAsync = ref.watch(organizationsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('기관 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: Column(children: [
        // Seed data button
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.dataset),
            label: const Text('초기 시드 데이터 등록'),
            onPressed: () => _seedData(context, ref),
          )),
        ),
        Expanded(child: orgsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오기 실패: $e')),
          data: (orgs) {
            if (orgs.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.business_outlined, size: 64, color: AppColors.divider),
                const SizedBox(height: 16),
                Text('등록된 기관이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('위의 초기 데이터 등록 버튼을 눌러주세요'),
              ]));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
              itemCount: orgs.length,
              itemBuilder: (_, i) {
                final org = orgs[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(_categoryIcon(org.category), color: Colors.blue, size: 20),
                    ),
                    title: Text(org.name),
                    subtitle: Text('${_categoryLabel(org.category)} · ${org.address}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('기관 삭제'),
                            content: Text('"${org.name}"을(를) 삭제하시겠습니까?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('삭제', style: TextStyle(color: AppColors.error))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(donationRepositoryProvider).deleteOrganization(org.id);
                          ref.invalidate(organizationsStreamProvider);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        )),
      ]),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'library': return Icons.local_library;
      case 'school': return Icons.school;
      case 'ngo': return Icons.volunteer_activism;
      default: return Icons.business;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'library': return '도서관';
      case 'school': return '학교';
      case 'ngo': return 'NGO';
      default: return category;
    }
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    String category = 'library';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('기관 추가'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '기관명')),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: '설명')),
          const SizedBox(height: 8),
          TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: '주소')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(labelText: '카테고리'),
            items: const [
              DropdownMenuItem(value: 'library', child: Text('도서관')),
              DropdownMenuItem(value: 'school', child: Text('학교')),
              DropdownMenuItem(value: 'ngo', child: Text('NGO')),
            ],
            onChanged: (v) => setDialogState(() => category = v ?? 'library'),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final org = OrganizationModel(
                id: '',
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                category: category,
                isActive: true,
                createdAt: DateTime.now(),
              );
              await ref.read(donationRepositoryProvider).createOrganization(org);
              ref.invalidate(organizationsStreamProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      )),
    );
  }

  Future<void> _seedData(BuildContext context, WidgetRef ref) async {
    final seeds = [
      OrganizationModel(id: '', name: '서울도서관', description: '서울특별시 대표 공공도서관. 다양한 장서와 프로그램을 운영합니다.', address: '서울 중구 세종대로 110', category: 'library', isActive: true, createdAt: DateTime.now()),
      OrganizationModel(id: '', name: '국립중앙도서관', description: '대한민국 국가 대표 도서관. 모든 출판물을 수집·보존합니다.', address: '서울 서초구 반포대로 201', category: 'library', isActive: true, createdAt: DateTime.now()),
      OrganizationModel(id: '', name: '한국어린이재단', description: '어린이 교육과 복지를 위한 비영리 재단입니다.', address: '서울 종로구 창경궁로 215', category: 'ngo', isActive: true, createdAt: DateTime.now()),
      OrganizationModel(id: '', name: '아름다운가게', description: '나눔과 순환의 가치를 실천하는 사회적기업입니다.', address: '서울 종로구 자하문로 77', category: 'ngo', isActive: true, createdAt: DateTime.now()),
      OrganizationModel(id: '', name: '서울대학교 도서관', description: '서울대학교 중앙도서관. 기증 도서를 환영합니다.', address: '서울 관악구 관악로 1', category: 'school', isActive: true, createdAt: DateTime.now()),
    ];

    try {
      final repo = ref.read(donationRepositoryProvider);
      for (final org in seeds) {
        await repo.createOrganization(org);
      }
      ref.invalidate(organizationsStreamProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${seeds.length}개 기관을 등록했습니다'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
      }
    }
  }
}
