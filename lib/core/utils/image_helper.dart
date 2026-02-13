import 'dart:io';

class ImageHelper {
  ImageHelper._();

  static const maxImageSize = 5 * 1024 * 1024; // 5MB
  static const maxPhotos = 5;
  static const minPhotos = 1;

  static bool isValidImageSize(File file) {
    return file.lengthSync() <= maxImageSize;
  }

  static bool canAddMorePhotos(int currentCount) {
    return currentCount < maxPhotos;
  }

  static bool hasMinimumPhotos(int count) {
    return count >= minPhotos;
  }

  static String generateImagePath(String userId, String bookId, int index) {
    return 'books/$userId/$bookId/photo_$index.jpg';
  }

  static String generateProfileImagePath(String userId) {
    return 'profiles/$userId/profile.jpg';
  }
}
