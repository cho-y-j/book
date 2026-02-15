import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/sound_helper.dart';
import '../../../providers/auth_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _allEnabled = true;
  final _settings = <String, bool>{
    '교환 요청': true,
    '매칭 알림': true,
    '채팅': true,
    '위시리스트 매칭': true,
    '후기': true,
    '배송': true,
    '시스템 공지': false,
  };
  String _selectedSound = '기본 알림음';
  final _sounds = ['책 넘기는 소리', '"책가지" 효과음', '도서관 벨 소리', '연필 쓰는 소리', '기본 알림음', '무음'];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('settings').doc('notification')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _allEnabled = data['allEnabled'] ?? true;
          _selectedSound = data['sound'] ?? '기본 알림음';
          final savedSettings = data['categories'] as Map<String, dynamic>?;
          if (savedSettings != null) {
            for (final key in _settings.keys) {
              if (savedSettings.containsKey(key)) {
                _settings[key] = savedSettings[key] as bool;
              }
            }
          }
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('settings').doc('notification')
        .set({
      'allEnabled': _allEnabled,
      'sound': _selectedSound,
      'categories': _settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Save sound file to SharedPreferences for NotificationService
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationSound', SoundHelper.fileForSoundName(_selectedSound));
  }

  Future<void> _previewSound(String soundName) async {
    final file = SoundHelper.fileForSoundName(soundName);
    if (file.isEmpty) return; // 무음
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$file'));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: [
              SwitchListTile(
                title: const Text('전체 알림'),
                value: _allEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  setState(() {
                    _allEnabled = v;
                    _settings.updateAll((_, __) => v);
                  });
                  _saveSettings();
                },
              ),
              const Divider(),
              ..._settings.entries.map((e) => SwitchListTile(
                title: Text(e.key),
                value: e.value && _allEnabled,
                activeColor: AppColors.primary,
                onChanged: _allEnabled
                    ? (v) {
                        setState(() => _settings[e.key] = v);
                        _saveSettings();
                      }
                    : null,
              )),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('알림음 선택', style: AppTypography.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '선택하면 미리듣기가 재생됩니다',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ),
              ..._sounds.map((s) => RadioListTile<String>(
                title: Text(s),
                subtitle: s == '무음' ? const Text('알림음을 재생하지 않습니다') : null,
                value: s,
                groupValue: _selectedSound,
                activeColor: AppColors.primary,
                secondary: s != '무음'
                    ? IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: () => _previewSound(s),
                        tooltip: '미리듣기',
                      )
                    : const Icon(Icons.volume_off, color: AppColors.textSecondary),
                onChanged: (v) {
                  setState(() => _selectedSound = v!);
                  _saveSettings();
                  _previewSound(v!);
                },
              )),
            ]),
    );
  }
}
