class SoundHelper {
  SoundHelper._();

  static const Map<String, String> soundNameToFile = {
    '책 넘기는 소리': 'notification_page_turn.mp3',
    '"책가지" 효과음': 'notification_bookbridge.mp3',
    '도서관 벨 소리': 'notification_library_bell.mp3',
    '연필 쓰는 소리': 'notification_pencil.mp3',
    '기본 알림음': 'notification_default.mp3',
    '무음': '',
  };

  static String fileForSoundName(String name) =>
      soundNameToFile[name] ?? 'notification_default.mp3';

  static String soundNameForFile(String file) =>
      soundNameToFile.entries
          .firstWhere(
            (e) => e.value == file,
            orElse: () => const MapEntry('기본 알림음', 'notification_default.mp3'),
          )
          .key;
}
