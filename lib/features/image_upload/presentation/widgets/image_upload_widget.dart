import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_upload_provider.dart';

// Note: Add `file_picker: ^8.0.0` and `uuid: ^4.4.0` to pubspec.yaml

class ImageUploadWidget extends ConsumerWidget {
  const ImageUploadWidget({
    super.key,
    required this.folder,
    this.onUploaded,
    this.currentUrl,
  });

  final String folder;
  final void Function(String url)? onUploaded;
  final String? currentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageUploadProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview
        if (state.previewBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(state.previewBytes!, height: 160, fit: BoxFit.cover),
          )
        else if (currentUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(currentUrl!, height: 160, fit: BoxFit.cover),
          )
        else
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(child: Icon(Icons.image_outlined, size: 48, color: Colors.grey)),
          ),

        const SizedBox(height: 12),

        // Upload button
        if (state.isLoading)
          const LinearProgressIndicator()
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Upload Image'),
            onPressed: () => _pickAndUpload(context, ref),
          ),

        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(state.error!, style: const TextStyle(color: Colors.red)),
          ),

        if (state.uploadedUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Uploaded ✓', style: TextStyle(color: Colors.green[700])),
          ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    // Placeholder — real implementation uses file_picker
    // Example:
    // final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    // if (result == null) return;
    // final file = result.files.first;
    // final bytes = file.bytes!;
    // final ext = file.extension ?? 'jpg';
    // final path = '$folder/${const Uuid().v4()}.$ext';
    // final url = await ref.read(imageUploadProvider.notifier)
    //     .upload(path: path, bytes: bytes, mimeType: 'image/$ext');
    // if (url != null) onUploaded?.call(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add file_picker to enable image uploads')),
    );
  }
}
