import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../shared/domain/services/image_service.dart';
import '../../../../shared/data/services/image_service_impl.dart';

/// Widget for selecting and managing images in graffiti notes
class GraffitiImagePicker extends StatefulWidget {
  final String? selectedImagePath;
  final Function(String?) onImageSelected;
  final bool showPreview;
  final Size? targetSize;
  final bool allowRemoval;

  const GraffitiImagePicker({
    super.key,
    this.selectedImagePath,
    required this.onImageSelected,
    this.showPreview = true,
    this.targetSize,
    this.allowRemoval = true,
  });

  @override
  State<GraffitiImagePicker> createState() => _GraffitiImagePickerState();
}

class _GraffitiImagePickerState extends State<GraffitiImagePicker> {
  final ImageService _imageService = ImageServiceImpl();
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        
        if (widget.selectedImagePath != null && widget.showPreview) ...[
          _buildImagePreview(),
          const SizedBox(height: 16),
        ],
        
        if (_errorMessage != null) ...[
          _buildErrorMessage(),
          const SizedBox(height: 12),
        ],
        
        _buildActionButtons(),
        
        if (_isProcessing) ...[
          const SizedBox(height: 16),
          _buildProcessingIndicator(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '이미지 추가',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B6B6B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: Image.file(
                File(widget.selectedImagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF0F0F0),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Color(0xFF9B9B9B),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '이미지를 불러올 수 없습니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9B9B9B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Overlay controls
            if (widget.allowRemoval)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _removeImage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Image info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getImageFileName(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.selectedImagePath != null) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit,
              label: '다른 이미지',
              onTap: _showImagePickerOptions,
              isSecondary: true,
            ),
          ),
          if (widget.allowRemoval) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.delete_outline,
                label: '이미지 제거',
                onTap: _removeImage,
                isSecondary: true,
                isDestructive: true,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.camera_alt,
            label: '카메라',
            onTap: _pickFromCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.photo_library,
            label: '갤러리',
            onTap: _pickFromGallery,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
    bool isDestructive = false,
  }) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    if (isDestructive) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
      iconColor = Colors.red;
    } else if (isSecondary) {
      backgroundColor = const Color(0xFFF8F9FA);
      textColor = const Color(0xFF6B6B6B);
      iconColor = const Color(0xFF6B6B6B);
    } else {
      backgroundColor = const Color(0xFF007AFF);
      textColor = Colors.white;
      iconColor = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isProcessing ? null : onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: isSecondary 
                ? Border.all(color: const Color(0xFFE5E5E5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '이미지 처리 중...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  String _getImageFileName() {
    if (widget.selectedImagePath == null) return '';
    return widget.selectedImagePath!.split('/').last;
  }

  Future<void> _pickFromCamera() async {
    await _pickImage(() => _imageService.pickFromCamera());
  }

  Future<void> _pickFromGallery() async {
    await _pickImage(() => _imageService.pickFromGallery());
  }

  Future<void> _pickImage(Future<String> Function() pickFunction) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final String imagePath = await pickFunction();
      
      // Process image if target size is specified
      String finalImagePath = imagePath;
      if (widget.targetSize != null) {
        finalImagePath = await _imageService.processAndStore(
          imagePath: imagePath,
          targetSize: widget.targetSize!,
        );
        
        // Clean up original if it's different from processed
        if (finalImagePath != imagePath) {
          await _imageService.deleteImage(imagePath);
        }
      }

      widget.onImageSelected(finalImagePath);
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _removeImage() {
    widget.onImageSelected(null);
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ImagePickerOptionsBottomSheet(
        onCameraSelected: () {
          Navigator.of(context).pop();
          _pickFromCamera();
        },
        onGallerySelected: () {
          Navigator.of(context).pop();
          _pickFromGallery();
        },
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    final String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission')) {
      return '카메라/갤러리 접근 권한이 필요합니다';
    } else if (errorString.contains('no image selected')) {
      return '이미지가 선택되지 않았습니다';
    } else if (errorString.contains('invalid')) {
      return '지원하지 않는 이미지 형식입니다';
    } else if (errorString.contains('size')) {
      return '이미지 크기가 너무 큽니다';
    } else {
      return '이미지 처리 중 오류가 발생했습니다';
    }
  }
}

/// Bottom sheet for image picker options
class ImagePickerOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const ImagePickerOptionsBottomSheet({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '이미지 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '낙서에 추가할 이미지를 선택해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
          
          // Options
          _buildOption(
            icon: Icons.camera_alt,
            title: '카메라로 촬영',
            subtitle: '새로운 사진을 촬영합니다',
            onTap: onCameraSelected,
          ),
          
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: const Color(0xFFF0F0F0),
          ),
          
          _buildOption(
            icon: Icons.photo_library,
            title: '갤러리에서 선택',
            subtitle: '저장된 사진에서 선택합니다',
            onTap: onGallerySelected,
          ),
          
          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF007AFF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9B9B9B),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact image picker for inline use
class CompactGraffitiImagePicker extends StatelessWidget {
  final String? selectedImagePath;
  final Function(String?) onImageSelected;

  const CompactGraffitiImagePicker({
    super.key,
    this.selectedImagePath,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showImagePicker(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image preview or placeholder
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selectedImagePath != null 
                        ? null 
                        : const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(8),
                    image: selectedImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(selectedImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: selectedImagePath == null
                      ? const Icon(
                          Icons.add_photo_alternate,
                          color: Color(0xFF9B9B9B),
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Text
                Expanded(
                  child: Text(
                    selectedImagePath != null 
                        ? '이미지 선택됨'
                        : '이미지 추가 (선택사항)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedImagePath != null 
                          ? const Color(0xFF007AFF)
                          : const Color(0xFF6B6B6B),
                    ),
                  ),
                ),
                
                // Action icon
                Icon(
                  selectedImagePath != null 
                      ? Icons.edit 
                      : Icons.add,
                  color: const Color(0xFF9B9B9B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GraffitiImagePicker(
        selectedImagePath: selectedImagePath,
        onImageSelected: onImageSelected,
        showPreview: true,
      ),
    );
  }
}