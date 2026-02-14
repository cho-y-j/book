import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/donation_providers.dart';

class OrganizationListScreen extends ConsumerStatefulWidget {
  const OrganizationListScreen({super.key});
  @override
  ConsumerState<OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends ConsumerState<OrganizationListScreen> {
  String _categoryFilter = 'all';

  String _categoryLabel(String category) {
    switch (category) {
      case 'library': return '도서관';
      case 'school': return '학교';
      case 'ngo': return 'NGO';
      default: return category;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'library': return Icons.local_library;
      case 'school': return Icons.school;
      case 'ngo': return Icons.volunteer_activism;
      default: return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('기증 기관')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterChip(label: '전체', selected: _categoryFilter == 'all', onTap: () => setState(() => _categoryFilter = 'all')),
              const SizedBox(width: 8),
              _FilterChip(label: '도서관', selected: _categoryFilter == 'library', onTap: () => setState(() => _categoryFilter = 'library')),
              const SizedBox(width: 8),
              _FilterChip(label: '학교', selected: _categoryFilter == 'school', onTap: () => setState(() => _categoryFilter = 'school')),
              const SizedBox(width: 8),
              _FilterChip(label: 'NGO', selected: _categoryFilter == 'ngo', onTap: () => setState(() => _categoryFilter = 'ngo')),
            ]),
          ),
        ),
        Expanded(child: orgsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
          data: (orgs) {
            final filtered = _categoryFilter == 'all' ? orgs : orgs.where((o) => o.category == _categoryFilter).toList();
            if (filtered.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.business_outlined, size: 64, color: AppColors.divider),
                const SizedBox(height: 16),
                Text('등록된 기관이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
              ]));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final org = filtered[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push(AppRoutes.donationPath(org.id)),
                    child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Icon(_categoryIcon(org.category), color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(org.name, style: AppTypography.titleMedium),
                        const SizedBox(height: 2),
                        Text(org.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(_categoryLabel(org.category), style: AppTypography.caption.copyWith(color: Colors.blue)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(org.address, style: AppTypography.caption, overflow: TextOverflow.ellipsis)),
                        ]),
                      ])),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ])),
                  ),
                );
              },
            );
          },
        )),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.blue : AppColors.divider),
        ),
        child: Text(label, style: AppTypography.bodySmall.copyWith(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }
}
