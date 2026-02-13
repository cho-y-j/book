import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _allEnabled = true;
  final _settings = {'교환 요청': true, '매칭 알림': true, '채팅': true, '위시리스트 매칭': true, '후기': true, '배송': true, '시스템 공지': false};
  String _selectedSound = '기본 알림음';
  final _sounds = ['책 넘기는 소리', '"책다리" 효과음', '도서관 벨 소리', '연필 쓰는 소리', '기본 알림음', '무음'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: ListView(children: [
        SwitchListTile(title: const Text('전체 알림'), value: _allEnabled, activeColor: AppColors.primary, onChanged: (v) => setState(() { _allEnabled = v; _settings.updateAll((_, __) => v); })),
        const Divider(),
        ..._settings.entries.map((e) => SwitchListTile(title: Text(e.key), value: e.value && _allEnabled, activeColor: AppColors.primary, onChanged: _allEnabled ? (v) => setState(() => _settings[e.key] = v) : null)),
        const Divider(),
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('알림음 선택', style: AppTypography.titleMedium)),
        ..._sounds.map((s) => RadioListTile<String>(title: Text(s), value: s, groupValue: _selectedSound, activeColor: AppColors.primary, onChanged: (v) => setState(() => _selectedSound = v!))),
      ]),
    );
  }
}
