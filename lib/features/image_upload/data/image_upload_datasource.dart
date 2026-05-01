import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/logging/app_logger.dart';

final _log = AppLogger.getLogger('ImageUploadDataSource');

class ImageUploadDataSource {
  const ImageUploadDataSource(this._client);
  final SupabaseClient _client;

  static const String _bucket = 'product-images';

  Future<String> uploadImage({
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    _log.info('Image upload started: path=$path, size=${bytes.length} bytes, mime=$mimeType');
    try {
      await _client.storage.from(_bucket).uploadBinary(
        path, bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: true),
      );
      final url = _client.storage.from(_bucket).getPublicUrl(path);
      _log.info('Image upload completed: path=$path');
      return url;
    } on StorageException catch (e) {
      _log.severe('Image upload failed: path=$path, error=${e.message}', e);
      throw ServerException(message: e.message);
    } catch (e, st) {
      _log.severe('Unexpected error during image upload: path=$path', e, st);
      throw ServerException(message: e.toString());
    }
  }

  Future<void> deleteImage(String path) async {
    _log.info('Image delete started: path=$path');
    try {
      await _client.storage.from(_bucket).remove([path]);
      _log.info('Image deleted: path=$path');
    } on StorageException catch (e) {
      _log.severe('Image delete failed: path=$path, error=${e.message}', e);
      throw ServerException(message: e.message);
    }
  }
}
