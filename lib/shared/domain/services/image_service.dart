import 'dart:io';
import 'package:flutter/material.dart';

/// Service interface for image-related operations including capture, processing, and storage
abstract class ImageService {
  /// Picks an image from the device camera
  Future<String> pickFromCamera();

  /// Picks an image from the device gallery
  Future<String> pickFromGallery();

  /// Picks multiple images from the gallery
  Future<List<String>> pickMultipleFromGallery({int maxImages = 5});

  /// Shows a picker dialog allowing user to choose between camera and gallery
  Future<String?> showImagePicker();

  // Image processing and optimization

  /// Processes and stores an image with the specified target size
  Future<String> processAndStore({
    required String imagePath,
    required Size targetSize,
  });

  /// Resizes an image to the specified dimensions
  Future<File> resizeImage(File image, Size targetSize);

  /// Compresses an image with the specified quality (0-100)
  Future<File> compressImage(File image, int qualityPercent);

  /// Crops an image to the specified rectangle
  Future<File> cropImage(File image, Rect cropRect);

  /// Rotates an image by the specified angle in degrees
  Future<File> rotateImage(File image, int angleDegrees);

  /// Applies filters to an image
  Future<File> applyFilter(File image, ImageFilter filter);

  /// Converts image format (e.g., PNG to JPEG)
  Future<File> convertFormat(File image, ImageFormat targetFormat);

  /// Optimizes image for web or app usage
  Future<File> optimizeForWeb(File image);

  // Image analysis and metadata

  /// Gets image dimensions
  Future<Size> getImageDimensions(String imagePath);

  /// Gets image file size in bytes
  Future<int> getImageFileSize(String imagePath);

  /// Gets image metadata (EXIF data)
  Future<Map<String, dynamic>> getImageMetadata(String imagePath);

  /// Checks if an image file is valid
  Future<bool> isValidImage(String imagePath);

  /// Gets image color palette
  Future<List<Color>> getColorPalette(String imagePath);

  /// Detects if image is primarily text-based
  Future<bool> isTextImage(String imagePath);

  // Storage and file management

  /// Saves an image to the app's document directory
  Future<String> saveImageToAppDirectory(File image, {String? fileName});

  /// Saves an image to the device's gallery
  Future<bool> saveImageToGallery(File image, {String? albumName});

  /// Deletes an image file
  Future<void> deleteImage(String imagePath);

  /// Copies an image to a new location
  Future<String> copyImage(String sourcePath, String destinationPath);

  /// Moves an image to a new location
  Future<String> moveImage(String sourcePath, String destinationPath);

  /// Creates a backup of an image
  Future<String> backupImage(String imagePath);

  // Cache management

  /// Caches an image for faster access
  Future<void> cacheImage(String imagePath);

  /// Clears image cache
  Future<void> clearImageCache();

  /// Gets cached image if available
  Future<File?> getCachedImage(String imagePath);

  /// Gets cache size in bytes
  Future<int> getCacheSize();

  /// Sets maximum cache size
  void setMaxCacheSize(int maxSizeBytes);

  // Thumbnail generation

  /// Generates a thumbnail from an image
  Future<File> generateThumbnail(String imagePath, Size thumbnailSize);

  /// Generates multiple thumbnail sizes
  Future<Map<String, File>> generateMultipleThumbnails(
    String imagePath,
    Map<String, Size> thumbnailSizes,
  );

  /// Gets or creates a thumbnail
  Future<File> getOrCreateThumbnail(String imagePath, Size thumbnailSize);

  // Permission and validation

  /// Requests camera permissions
  Future<bool> requestCameraPermissions();

  /// Requests gallery/photo permissions
  Future<bool> requestGalleryPermissions();

  /// Checks if camera permissions are granted
  Future<bool> hasCameraPermissions();

  /// Checks if gallery permissions are granted
  Future<bool> hasGalleryPermissions();

  /// Validates image file extension
  bool isValidImageExtension(String fileName);

  /// Validates image file size
  bool isValidImageSize(int fileSizeBytes, {int maxSizeBytes = 10485760}); // 10MB default

  /// Validates image dimensions
  bool isValidImageDimensions(Size dimensions, {Size? maxDimensions});

  // Error handling and diagnostics

  /// Performs image service health check
  Future<ImageServiceHealthCheck> performHealthCheck();

  /// Gets supported image formats
  List<ImageFormat> getSupportedFormats();

  /// Gets maximum supported image size
  int getMaxSupportedImageSize();

  /// Gets available storage space
  Future<int> getAvailableStorageSpace();

  // Batch operations

  /// Processes multiple images
  Future<List<String>> processBatch(
    List<String> imagePaths,
    Size targetSize,
  );

  /// Deletes multiple images
  Future<void> deleteBatch(List<String> imagePaths);

  /// Generates thumbnails for multiple images
  Future<Map<String, File>> generateThumbnailsBatch(
    List<String> imagePaths,
    Size thumbnailSize,
  );

  // Utility methods

  /// Converts image to base64 string
  Future<String> imageToBase64(String imagePath);

  /// Converts base64 string to image file
  Future<File> base64ToImage(String base64String, {String? fileName});

  /// Creates an image from a widget (screenshot)
  Future<File> createImageFromWidget(Widget widget, Size size);

  /// Blurs an image
  Future<File> blurImage(File image, double blurRadius);

  /// Adds watermark to an image
  Future<File> addWatermark(File image, String watermarkText);
}

/// Enum representing supported image formats
enum ImageFormat {
  jpeg,
  png,
  webp,
  bmp,
  gif,
}

/// Enum representing image filters
enum ImageFilter {
  none,
  grayscale,
  sepia,
  vintage,
  bright,
  contrast,
  saturate,
  invert,
}

/// Class representing image service health check results
class ImageServiceHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final Map<String, dynamic> diagnostics;

  const ImageServiceHealthCheck({
    required this.isHealthy,
    required this.issues,
    required this.diagnostics,
  });
}