// lib/services/image_upload_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../utils/constants.dart';  // Optional: For API base URL if not in ApiService

/// ImageUploadService handles uploading images (e.g., menu photos) from local device to cloud storage.
/// It proxies uploads through the backend (/api/upload) to Cloudinary for security (API keys server-side).
/// Usage: String? url = await ImageUploadService.uploadImage(localPath);
/// Returns the public URL (e.g., Cloudinary) on success, null on failure.
/// Requires backend route: POST /api/upload with multer-cloudinary (multipart 'image' field).
/// Dependencies: dio (already in pubspec), image_picker for localPath.
class ImageUploadService {
  static const String _uploadEndpoint = '/upload';  // Backend endpoint
  static final Dio _dio = Dio();  // Separate Dio for uploads (no auth interceptor needed if public, but add if required)

  /// Uploads an image from local path to the backend, which forwards to Cloudinary.
  /// - localPath: File path from image_picker (e.g., '/storage/emulated/0/.../image.jpg').
  /// - Returns: Cloudinary public URL (e.g., 'https://res.cloudinary.com/.../menu_item.jpg') or null on error.
  /// - Throws: DioException on network/upload failure (handle in UI with try-catch).
  /// Optional: Compress image before upload (uncomment and add 'image: ^4.1.3' to pubspec if needed).
  static Future<String?> uploadImage(String localPath) async {
    if (!File(localPath).existsSync()) {
      throw Exception('Image file does not exist at path: $localPath');
    }

    try {
      // Optional: Compress image (requires 'image' package)
      // final compressedPath = await _compressImage(localPath);
      // final uploadPath = compressedPath ?? localPath;
      final uploadPath = localPath;

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          uploadPath,
          filename: path.basename(uploadPath),  // e.g., 'menu1.jpg'
          contentType: MediaType('image', path.extension(uploadPath).substring(1).toLowerCase()),
        ),
      });

      // Upload to backend (add auth if required for owner uploads)
      final response = await _dio.post(
        '${ApiService.baseUrl}$_uploadEndpoint',  // e.g., 'http://localhost:5000/api/upload'
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            // If auth needed: 'Authorization': 'Bearer ${await AuthService.getToken()}',
          },
          sendTimeout: const Duration(minutes: 2),  // Large files
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['image'] != null) {
        return data['image'] as String;  // Backend returns { image: 'https://cloudinary.url' }
      } else {
        throw Exception('Invalid response from server: ${data.toString()}');
      }
    } on DioException catch (e) {
      String errorMsg;
      if (e.response?.statusCode == 413) {
        errorMsg = 'Image too large. Please select a smaller file.';
      } else if (e.response?.statusCode == 400) {
        errorMsg = 'Invalid image format. Use JPG, PNG, or JPEG.';
      } else {
        errorMsg = 'Upload failed: ${e.response?.data['error'] ?? e.message}';
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Image upload error: ${e.toString()}');
    }
  }

  /// Optional: Compress image to reduce size (e.g., < 2MB for faster upload).
  /// Requires adding 'image: ^4.1.3' to pubspec.yaml and 'flutter pub get'.
  /// Uncomment if needed.
  /*
  import 'package:image/image.dart' as img;

  static Future<String?> _compressImage(String localPath) async {
    try {
      final file = File(localPath);
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      // Resize if larger than 800x800
      if (image.width > 800 || image.height > 800) {
        image = img.copyResize(image, width: 800, height: 800);
      }

      // Compress to 80% quality
      final compressedBytes = img.encodeJpg(image, quality: 80);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final compressedPath = '${tempDir.path}/compressed_${path.basename(localPath)}';
      await File(compressedPath).writeAsBytes(compressedBytes);

      return compressedPath;
    } catch (e) {
      print('Compression failed: $e');
      return null;  // Fallback to original
    }
  }
  */

  /// Deletes an image from Cloudinary (if needed, e.g., on menu item delete).
  /// - publicId: Cloudinary public ID (extract from URL, e.g., 'canteen_menus/item123').
  /// Requires backend endpoint: DELETE /api/upload/:publicId.
  /// Returns true on success.
  static Future<bool> deleteImage(String publicId) async {
    try {
      final response = await _dio.delete(
        '${ApiService.baseUrl}$_uploadEndpoint/$publicId',
        // options: Options(headers: {'Authorization': 'Bearer ${await AuthService.getToken()}'}),  // If auth needed
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete image failed: $e');
      return false;
    }
  }
}