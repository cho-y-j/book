import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/errors/exceptions.dart';

class FirebaseStorageDatasource {
  final FirebaseStorage _storage;
  FirebaseStorageDatasource({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadImage(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) { throw ServerException(message: '이미지 업로드 실패: $e'); }
  }

  Future<void> deleteImage(String url) async {
    try { await _storage.refFromURL(url).delete(); }
    catch (e) { throw ServerException(message: '이미지 삭제 실패: $e'); }
  }

  Future<List<String>> uploadMultipleImages(String basePath, List<File> files) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final url = await uploadImage('$basePath/$i', files[i]);
      urls.add(url);
    }
    return urls;
  }
}
