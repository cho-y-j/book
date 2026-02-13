import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/enums.dart';

class ManualRegisterScreen extends ConsumerStatefulWidget {
  const ManualRegisterScreen({super.key});
  @override
  ConsumerState<ManualRegisterScreen> createState() => _ManualRegisterScreenState();
}

class _ManualRegisterScreenState extends ConsumerState<ManualRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _descriptionController = TextEditingController();
  BookGenre _selectedGenre = BookGenre.novel;

  @override
  void dispose() { _titleController.dispose(); _authorController.dispose(); _publisherController.dispose(); _descriptionController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직접 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('책 정보를 입력해주세요', style: AppTypography.headlineSmall),
          const SizedBox(height: 24),
          Center(child: GestureDetector(onTap: () {},
            child: Container(width: 120, height: 170, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: AppColors.textSecondary), SizedBox(height: 4), Text('표지 촬영', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))])),
          )),
          const SizedBox(height: 24),
          TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: '제목 *'), validator: (v) => v?.isEmpty == true ? '제목을 입력해주세요' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _authorController, decoration: const InputDecoration(labelText: '저자 *'), validator: (v) => v?.isEmpty == true ? '저자를 입력해주세요' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _publisherController, decoration: const InputDecoration(labelText: '출판사')),
          const SizedBox(height: 16),
          DropdownButtonFormField<BookGenre>(
            value: _selectedGenre, decoration: const InputDecoration(labelText: '장르 *'),
            items: BookGenre.values.where((g) => g != BookGenre.all).map((g) => DropdownMenuItem(value: g, child: Text(g.label))).toList(),
            onChanged: (v) => setState(() => _selectedGenre = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: '줄거리/소개'), maxLines: 4),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () { if (_formKey.currentState!.validate()) context.push(AppRoutes.bookCondition); }, child: const Text('다음: 책 상태 입력')),
        ])),
      ),
    );
  }
}
