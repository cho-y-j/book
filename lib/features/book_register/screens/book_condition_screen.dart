import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/enums.dart';

class BookConditionScreen extends ConsumerStatefulWidget {
  const BookConditionScreen({super.key});
  @override
  ConsumerState<BookConditionScreen> createState() => _BookConditionScreenState();
}

class _BookConditionScreenState extends ConsumerState<BookConditionScreen> {
  BookCondition _condition = BookCondition.good;
  ExchangeType _exchangeType = ExchangeType.both;
  final _noteController = TextEditingController();
  final List<String> _photos = [];

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('책 상태 입력')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('책 상태를 선택해주세요', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(
            label: Text(c.label), selected: _condition == c,
            selectedColor: AppColors.primaryLight,
            onSelected: (_) => setState(() => _condition = c),
          )).toList()),
          const SizedBox(height: 16),
          TextFormField(controller: _noteController, decoration: const InputDecoration(labelText: '상태 메모 (선택)', hintText: '예: 밑줄 약간 있음'), maxLines: 2),
          const SizedBox(height: 24),
          Text('실물 사진 (최소 1장, 최대 5장)', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [
            GestureDetector(
              onTap: () { if (_photos.length < 5) setState(() => _photos.add('photo_${_photos.length}')); },
              child: Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), border: Border.all(color: AppColors.primary, style: BorderStyle.solid)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: AppColors.primary), Text('촬영', style: TextStyle(fontSize: 12, color: AppColors.primary))]),
              ),
            ),
            ..._photos.map((p) => Container(width: 100, height: 100, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              child: Stack(children: [
                const Center(child: Icon(Icons.image, color: AppColors.textSecondary)),
                Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _photos.remove(p)),
                  child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                )),
              ]),
            )),
          ])),
          const SizedBox(height: 24),
          Text('거래 방식', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: ExchangeType.values.map((t) => ChoiceChip(
            label: Text(t.label), selected: _exchangeType == t,
            selectedColor: AppColors.primaryLight,
            onSelected: (_) => setState(() => _exchangeType = t),
          )).toList()),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _photos.isNotEmpty ? () { Navigator.pop(context); } : null,
            child: const Text('등록 완료'),
          ),
          if (_photos.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('실물 사진을 최소 1장 촬영해주세요', style: AppTypography.bodySmall.copyWith(color: AppColors.error), textAlign: TextAlign.center)),
        ]),
      ),
    );
  }
}
