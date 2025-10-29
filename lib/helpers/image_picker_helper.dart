import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Chọn ảnh từ gallery hoặc camera
  /// Trả về Map với 'bytes' (Uint8List) và 'path' (String cho mobile)
  static Future<Map<String, dynamic>?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Đọc bytes từ file
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      return {
        'bytes': imageBytes,
        'path': pickedFile.path,
        'name': pickedFile.name,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  /// Hiển thị dialog chọn nguồn ảnh (chỉ cho mobile)
  static Future<ImageSource?> showImageSourceDialog(context) async {
    if (kIsWeb) {
      return ImageSource.gallery; // Web chỉ hỗ trợ gallery
    }

    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a dialog to pick an image from the device (camera or gallery).
  /// Handles platform differences for web.
  static Future<XFile?> pickImageFromDevice(BuildContext context) async {
    ImageSource? source;
    if (kIsWeb) {
      source = ImageSource.gallery;
    } else {
      source = await showImageSourceDialog(context);
    }

    if (source == null) return null;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      return null;
    }
  }
}