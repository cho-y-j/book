import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/user_providers.dart';

class DealerRequestScreen extends ConsumerStatefulWidget {
  const DealerRequestScreen({super.key});
  @override
  ConsumerState<DealerRequestScreen> createState() => _DealerRequestScreenState();
}

class _DealerRequestScreenState extends ConsumerState<DealerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dealerNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _dealerNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserProfileProvider).valueOrNull;
      if (user == null) throw Exception('로그인이 필요합니다');

      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'role': 'dealer',
        'dealerStatus': 'pending',
        'dealerName': _dealerNameController.text.trim(),
      });

      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업자 신청이 완료되었습니다. 관리자 승인을 기다려주세요.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('업자 신청')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 20),
                        const SizedBox(width: 8),
                        Text('업자 안내', style: AppTypography.titleSmall.copyWith(color: AppColors.info)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '업자로 등록하면 대량의 중고책을 등록하고 판매할 수 있습니다.\n'
                      '현재는 무료이며, 추후 이용료가 부과될 수 있습니다.\n'
                      '신청 후 관리자 승인이 필요합니다.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('상호명', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dealerNameController,
                decoration: const InputDecoration(
                  hintText: '상호명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '상호명을 입력해주세요';
                  if (value.trim().length < 2) return '2글자 이상 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('업자 신청'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
