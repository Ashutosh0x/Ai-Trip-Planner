import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'firebase_service.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Upload profile picture to Firebase Storage
  static Future<String?> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      // Create a unique filename
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Create reference to the file location
      final Reference ref = _storage.ref().child('profile_pictures/$fileName');
      
      // Upload the file
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  /// Delete profile picture from Firebase Storage
  static Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      // Extract the file path from the URL
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.last;
      
      // Create reference and delete
      final Reference ref = _storage.ref().child('profile_pictures/$filePath');
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
