import 'package:flutter/material.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';

class CreateBookClubScreen extends StatefulWidget {
  const CreateBookClubScreen({super.key});
  @override
  State<CreateBookClubScreen> createState() => _CreateBookClubScreenState();
}

class _CreateBookClubScreenState extends State<CreateBookClubScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('책모임 만들기')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('새로운 책모임을 만들어보세요', style: AppTypography.headlineSmall),
        const SizedBox(height: 24),
        TextFormField(decoration: const InputDecoration(labelText: '모임 이름 *'), validator: (v) => v?.isEmpty == true ? '이름을 입력해주세요' : null),
        const SizedBox(height: 16),
        TextFormField(decoration: const InputDecoration(labelText: '소개'), maxLines: 3),
        const SizedBox(height: 16),
        TextFormField(decoration: const InputDecoration(labelText: '최대 인원'), keyboardType: TextInputType.number),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () { if (_formKey.currentState!.validate()) Navigator.pop(context); }, child: const Text('모임 만들기')),
      ]))),
    );
  }
}
