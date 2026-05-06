import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/exceptions.dart';

class ImageUploadDataSource {
  const ImageUploadDataSource(this._client);
  final SupabaseClient _client;

  static const String _bucket = 'product-images';

  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      await _client.storage.from(_bucket).uploadBinary(
        path, bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: true),
      );
      return _client.storage.from(_bucket).getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      await _client.storage.from(_bucket).remove([path]);
    } on StorageException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
