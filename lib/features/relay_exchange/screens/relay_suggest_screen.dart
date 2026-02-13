import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class RelaySuggestScreen extends StatelessWidget {
  const RelaySuggestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('릴레이 교환 제안')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('릴레이 교환이란?', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text('A→B→C→A 형태로 3명이 동시에 책을 교환하는 방식입니다.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Text('참여자 목록', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: Text('${i + 1}', style: AppTypography.labelLarge.copyWith(color: AppColors.primary))),
                  title: Text('참여자 ${i + 1}', style: AppTypography.labelLarge),
                  subtitle: Text('보낼 책: 책 제목 ${i + 1}', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('릴레이 교환 시작하기'))),
        ]),
      ),
    );
  }
}
