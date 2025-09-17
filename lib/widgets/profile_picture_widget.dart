import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class ProfilePictureWidget extends StatefulWidget {
  final String? imageUrl;
  final String? userId;
  final double size;
  final bool showEditButton;
  final Function(String?)? onImageChanged;
  final bool isLoading;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    this.userId,
    this.size = 80,
    this.showEditButton = true,
    this.onImageChanged,
    this.isLoading = false,
  });

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile Picture Container
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: const Color(0xFF9B59B6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: _buildImageContent(),
          ),
        ),
        
        // Edit Button
        if (widget.showEditButton && !widget.isLoading)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF9B59B6),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 3),
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        
        // Loading Indicator
        if (_isUploading || widget.isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return _buildDefaultIcon();
    }
  }

  Widget _buildDefaultIcon() {
    return const Icon(
      Icons.add_a_photo,
      size: 40,
      color: Colors.white,
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null || (widget.imageUrl != null && widget.imageUrl!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isUploading = true;
      });

      File? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await StorageService.pickImageFromGallery();
      } else {
        imageFile = await StorageService.pickImageFromCamera();
      }

      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
        });

        // Upload to Firebase if userId is provided
        if (widget.userId != null) {
          try {
            final String? downloadUrl = await StorageService.uploadProfilePicture(
              userId: widget.userId!,
              imageFile: imageFile,
            );
            
            if (downloadUrl != null && widget.onImageChanged != null) {
              widget.onImageChanged!(downloadUrl);
            }
          } catch (e) {
            // Show error but keep the selected image
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (widget.onImageChanged != null) {
          // Just return the local file path if no userId
          widget.onImageChanged!(imageFile.path);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    
    if (widget.onImageChanged != null) {
      widget.onImageChanged!(null);
    }
  }
}
