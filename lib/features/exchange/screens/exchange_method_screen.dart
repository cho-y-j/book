import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/exchange_providers.dart';

class ExchangeMethodScreen extends ConsumerStatefulWidget {
  final String matchId;
  const ExchangeMethodScreen({super.key, required this.matchId});
  @override
  ConsumerState<ExchangeMethodScreen> createState() => _ExchangeMethodScreenState();
}

class _ExchangeMethodScreenState extends ConsumerState<ExchangeMethodScreen> {
  String _method = 'local';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('거래 방식 선택')),
      body: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('어떻게 교환할까요?', style: AppTypography.headlineSmall),
        const SizedBox(height: 24),
        _MethodCard(icon: Icons.handshake, title: '직거래', description: '약속 장소에서 직접 만나 교환', selected: _method == 'local', onTap: () => setState(() => _method = 'local')),
        const SizedBox(height: 12),
        _MethodCard(icon: Icons.local_shipping, title: '택배', description: '각자 택배로 발송하여 교환', selected: _method == 'delivery', onTap: () => setState(() => _method = 'delivery')),
        const Spacer(),
        ElevatedButton(onPressed: () {
          ref.read(exchangeRepositoryProvider).updateMatchStatus(widget.matchId, _method == 'local' ? 'local_exchange' : 'delivery_exchange');
          Navigator.pop(context);
        }, child: const Text('선택 완료')),
      ])),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon; final String title; final String description; final bool selected; final VoidCallback onTap;
  const _MethodCard({required this.icon, required this.title, required this.description, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), side: BorderSide(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1)),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Row(children: [
        Icon(icon, size: 40, color: selected ? AppColors.primary : AppColors.textSecondary),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTypography.titleMedium), const SizedBox(height: 4), Text(description, style: AppTypography.bodySmall)])),
        if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
      ]))),
    );
  }
}
