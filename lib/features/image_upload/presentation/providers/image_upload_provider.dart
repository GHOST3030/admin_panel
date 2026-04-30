import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/image_upload_datasource.dart';

final imageUploadDataSourceProvider = Provider<ImageUploadDataSource>(
  (ref) => ImageUploadDataSource(ref.watch(supabaseClientProvider)),
);

class ImageUploadState {
  const ImageUploadState({
    this.isLoading = false,
    this.uploadedUrl,
    this.error,
    this.previewBytes,
  });
  final bool isLoading;
  final String? uploadedUrl;
  final String? error;
  final Uint8List? previewBytes;

  ImageUploadState copyWith({
    bool? isLoading, String? uploadedUrl,
    String? error, Uint8List? previewBytes,
  }) => ImageUploadState(
    isLoading: isLoading ?? this.isLoading,
    uploadedUrl: uploadedUrl ?? this.uploadedUrl,
    error: error ?? this.error,
    previewBytes: previewBytes ?? this.previewBytes,
  );
}

final imageUploadProvider =
    StateNotifierProvider.autoDispose<ImageUploadNotifier, ImageUploadState>(
  (ref) => ImageUploadNotifier(ref.watch(imageUploadDataSourceProvider)),
);

class ImageUploadNotifier extends StateNotifier<ImageUploadState> {
  ImageUploadNotifier(this._dataSource) : super(const ImageUploadState());
  final ImageUploadDataSource _dataSource;

  Future<String?> upload({
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    state = state.copyWith(isLoading: true, error: null, previewBytes: bytes);
    try {
      final url = await _dataSource.uploadImage(
          path: path, bytes: bytes, mimeType: mimeType);
      state = state.copyWith(isLoading: false, uploadedUrl: url);
      return url;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const ImageUploadState();
}
