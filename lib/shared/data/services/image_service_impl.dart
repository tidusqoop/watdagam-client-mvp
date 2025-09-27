import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

import '../../domain/services/image_service.dart';

/// Implementation of ImageService for graffiti image processing
class ImageServiceImpl implements ImageService {
  final ImagePicker _imagePicker = ImagePicker();
  
  // Internal storage paths
  static const String _graffitiImagesFolder = 'graffiti_images';
  static const String _thumbnailsFolder = 'thumbnails';
  static const String _cacheFolder = 'image_cache';
  
  // Configuration constants
  static const int _maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int _defaultQuality = 85;
  static const Size _maxImageDimensions = Size(2048, 2048);
  static const List<String> _supportedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
  
  // Cache management
  final Map<String, File> _imageCache = {};
  int _maxCacheSize = 50 * 1024 * 1024; // 50MB default
  
  @override
  Future<String> pickFromCamera() async {
    // Request camera permissions
    if (!await requestCameraPermissions()) {
      throw Exception('Camera permission not granted');
    }
    
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: _defaultQuality,
      maxWidth: _maxImageDimensions.width,
      maxHeight: _maxImageDimensions.height,
    );
    
    if (image == null) {
      throw Exception('No image selected from camera');
    }
    
    return image.path;
  }

  @override
  Future<String> pickFromGallery() async {
    // Request gallery permissions
    if (!await requestGalleryPermissions()) {
      throw Exception('Gallery permission not granted');
    }
    
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: _defaultQuality,
      maxWidth: _maxImageDimensions.width,
      maxHeight: _maxImageDimensions.height,
    );
    
    if (image == null) {
      throw Exception('No image selected from gallery');
    }
    
    return image.path;
  }

  @override
  Future<List<String>> pickMultipleFromGallery({int maxImages = 5}) async {
    if (!await requestGalleryPermissions()) {
      throw Exception('Gallery permission not granted');
    }
    
    final List<XFile> images = await _imagePicker.pickMultipleImages(
      imageQuality: _defaultQuality,
      maxWidth: _maxImageDimensions.width,
      maxHeight: _maxImageDimensions.height,
    );
    
    if (images.length > maxImages) {
      return images.take(maxImages).map((image) => image.path).toList();
    }
    
    return images.map((image) => image.path).toList();
  }

  @override
  Future<String?> showImagePicker() async {
    // This would typically show a dialog, but for now we'll default to gallery
    try {
      return await pickFromGallery();
    } catch (e) {
      try {
        return await pickFromCamera();
      } catch (e) {
        return null;
      }
    }
  }

  @override
  Future<String> processAndStore({
    required String imagePath,
    required Size targetSize,
  }) async {
    final File originalFile = File(imagePath);
    
    if (!await originalFile.exists()) {
      throw Exception('Image file does not exist: $imagePath');
    }
    
    // Validate image
    if (!await isValidImage(imagePath)) {
      throw Exception('Invalid image file: $imagePath');
    }
    
    // Load and decode image
    final Uint8List imageBytes = await originalFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image: $imagePath');
    }
    
    // Resize image to target size
    final img.Image resizedImage = img.copyResize(
      image,
      width: targetSize.width.toInt(),
      height: targetSize.height.toInt(),
      interpolation: img.Interpolation.lanczos,
    );
    
    // Compress image
    final List<int> compressedBytes = img.encodeJpg(
      resizedImage,
      quality: _defaultQuality,
    );
    
    // Save to app directory
    final String fileName = 'graffiti_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String savedPath = await saveImageToAppDirectory(
      File.fromRawPath(Uint8List.fromList(compressedBytes)),
      fileName: fileName,
    );
    
    return savedPath;
  }

  @override
  Future<File> resizeImage(File image, Size targetSize) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for resizing');
    }
    
    final img.Image resizedImage = img.copyResize(
      decodedImage,
      width: targetSize.width.toInt(),
      height: targetSize.height.toInt(),
      interpolation: img.Interpolation.lanczos,
    );
    
    final List<int> resizedBytes = img.encodeJpg(resizedImage, quality: _defaultQuality);
    
    final String tempPath = '${image.path}_resized.jpg';
    final File resizedFile = File(tempPath);
    await resizedFile.writeAsBytes(resizedBytes);
    
    return resizedFile;
  }

  @override
  Future<File> compressImage(File image, int qualityPercent) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for compression');
    }
    
    final List<int> compressedBytes = img.encodeJpg(
      decodedImage,
      quality: qualityPercent.clamp(1, 100),
    );
    
    final String tempPath = '${image.path}_compressed.jpg';
    final File compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressedBytes);
    
    return compressedFile;
  }

  @override
  Future<File> cropImage(File image, Rect cropRect) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for cropping');
    }
    
    final img.Image croppedImage = img.copyCrop(
      decodedImage,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );
    
    final List<int> croppedBytes = img.encodeJpg(croppedImage, quality: _defaultQuality);
    
    final String tempPath = '${image.path}_cropped.jpg';
    final File croppedFile = File(tempPath);
    await croppedFile.writeAsBytes(croppedBytes);
    
    return croppedFile;
  }

  @override
  Future<File> rotateImage(File image, int angleDegrees) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for rotation');
    }
    
    final double angleRadians = angleDegrees * (math.pi / 180);
    final img.Image rotatedImage = img.copyRotate(decodedImage, angle: angleRadians);
    
    final List<int> rotatedBytes = img.encodeJpg(rotatedImage, quality: _defaultQuality);
    
    final String tempPath = '${image.path}_rotated.jpg';
    final File rotatedFile = File(tempPath);
    await rotatedFile.writeAsBytes(rotatedBytes);
    
    return rotatedFile;
  }

  @override
  Future<File> applyFilter(File image, ImageFilter filter) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for filtering');
    }
    
    img.Image filteredImage = decodedImage;
    
    switch (filter) {
      case ImageFilter.grayscale:
        filteredImage = img.grayscale(decodedImage);
        break;
      case ImageFilter.sepia:
        filteredImage = img.sepia(decodedImage);
        break;
      case ImageFilter.invert:
        filteredImage = img.invert(decodedImage);
        break;
      case ImageFilter.bright:
        filteredImage = img.adjustColor(decodedImage, brightness: 1.2);
        break;
      case ImageFilter.contrast:
        filteredImage = img.adjustColor(decodedImage, contrast: 1.3);
        break;
      case ImageFilter.saturate:
        filteredImage = img.adjustColor(decodedImage, saturation: 1.4);
        break;
      case ImageFilter.vintage:
        filteredImage = img.sepia(img.adjustColor(decodedImage, contrast: 1.1));
        break;
      case ImageFilter.none:
      default:
        // No filter applied
        break;
    }
    
    final List<int> filteredBytes = img.encodeJpg(filteredImage, quality: _defaultQuality);
    
    final String tempPath = '${image.path}_filtered.jpg';
    final File filteredFile = File(tempPath);
    await filteredFile.writeAsBytes(filteredBytes);
    
    return filteredFile;
  }

  @override
  Future<File> convertFormat(File image, ImageFormat targetFormat) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for format conversion');
    }
    
    List<int> convertedBytes;
    String extension;
    
    switch (targetFormat) {
      case ImageFormat.jpeg:
        convertedBytes = img.encodeJpg(decodedImage, quality: _defaultQuality);
        extension = '.jpg';
        break;
      case ImageFormat.png:
        convertedBytes = img.encodePng(decodedImage);
        extension = '.png';
        break;
      case ImageFormat.webp:
        convertedBytes = img.encodeWebP(decodedImage);
        extension = '.webp';
        break;
      case ImageFormat.bmp:
        convertedBytes = img.encodeBmp(decodedImage);
        extension = '.bmp';
        break;
      case ImageFormat.gif:
        convertedBytes = img.encodeGif(decodedImage);
        extension = '.gif';
        break;
    }
    
    final String basePath = image.path.substring(0, image.path.lastIndexOf('.'));
    final String convertedPath = '$basePath$extension';
    final File convertedFile = File(convertedPath);
    await convertedFile.writeAsBytes(convertedBytes);
    
    return convertedFile;
  }

  @override
  Future<File> optimizeForWeb(File image) async {
    // Resize to reasonable web dimensions and compress
    const Size webSize = Size(1200, 1200);
    final File resized = await resizeImage(image, webSize);
    return await compressImage(resized, 75); // 75% quality for web
  }

  @override
  Future<Size> getImageDimensions(String imagePath) async {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image for dimensions');
    }
    
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  @override
  Future<int> getImageFileSize(String imagePath) async {
    final File imageFile = File(imagePath);
    return await imageFile.length();
  }

  @override
  Future<Map<String, dynamic>> getImageMetadata(String imagePath) async {
    final File imageFile = File(imagePath);
    final FileStat stat = await imageFile.stat();
    final Size dimensions = await getImageDimensions(imagePath);
    final int fileSize = await getImageFileSize(imagePath);
    
    return {
      'path': imagePath,
      'size': fileSize,
      'width': dimensions.width,
      'height': dimensions.height,
      'created': stat.created,
      'modified': stat.modified,
      'accessed': stat.accessed,
    };
  }

  @override
  Future<bool> isValidImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      // Check if file exists
      if (!await imageFile.exists()) return false;
      
      // Check file extension
      if (!isValidImageExtension(imagePath)) return false;
      
      // Check file size
      final int fileSize = await imageFile.length();
      if (!isValidImageSize(fileSize)) return false;
      
      // Try to decode image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return false;
      
      // Check dimensions
      final Size dimensions = Size(image.width.toDouble(), image.height.toDouble());
      if (!isValidImageDimensions(dimensions)) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Color>> getColorPalette(String imagePath) async {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image for color palette');
    }
    
    // Sample colors from the image
    final List<Color> colors = [];
    final int step = math.max(1, (image.width * image.height) ~/ 100); // Sample ~100 pixels
    
    for (int i = 0; i < image.width * image.height; i += step) {
      final int x = i % image.width;
      final int y = i ~/ image.width;
      
      if (y < image.height) {
        final img.Pixel pixel = image.getPixel(x, y);
        colors.add(Color.fromARGB(
          pixel.a.toInt(),
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        ));
      }
    }
    
    // Remove duplicates and return top colors
    final Set<Color> uniqueColors = colors.toSet();
    return uniqueColors.take(10).toList();
  }

  @override
  Future<bool> isTextImage(String imagePath) async {
    // This is a simplified implementation
    // In a real app, you might use OCR or ML models
    final List<Color> palette = await getColorPalette(imagePath);
    
    // If the image has very few colors, it might be text-based
    return palette.length < 5;
  }

  @override
  Future<String> saveImageToAppDirectory(File image, {String? fileName}) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory graffitiDir = Directory('${appDir.path}/$_graffitiImagesFolder');
    
    if (!await graffitiDir.exists()) {
      await graffitiDir.create(recursive: true);
    }
    
    final String finalFileName = fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String destinationPath = '${graffitiDir.path}/$finalFileName';
    
    await image.copy(destinationPath);
    return destinationPath;
  }

  @override
  Future<bool> saveImageToGallery(File image, {String? albumName}) async {
    // This would require platform-specific implementation
    // For now, we'll just copy to a accessible directory
    return false; // Not implemented for this MVP
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    final File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    
    // Remove from cache if present
    _imageCache.remove(imagePath);
  }

  @override
  Future<String> copyImage(String sourcePath, String destinationPath) async {
    final File sourceFile = File(sourcePath);
    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  @override
  Future<String> moveImage(String sourcePath, String destinationPath) async {
    final File sourceFile = File(sourcePath);
    await sourceFile.rename(destinationPath);
    return destinationPath;
  }

  @override
  Future<String> backupImage(String imagePath) async {
    final String backupPath = '${imagePath}_backup';
    return await copyImage(imagePath, backupPath);
  }

  @override
  Future<void> cacheImage(String imagePath) async {
    final File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      _imageCache[imagePath] = imageFile;
    }
  }

  @override
  Future<void> clearImageCache() async {
    _imageCache.clear();
    
    // Also clear cached files
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory cacheDir = Directory('${appDir.path}/$_cacheFolder');
    
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  @override
  Future<File?> getCachedImage(String imagePath) async {
    return _imageCache[imagePath];
  }

  @override
  Future<int> getCacheSize() async {
    int totalSize = 0;
    
    for (final File file in _imageCache.values) {
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }
    
    return totalSize;
  }

  @override
  void setMaxCacheSize(int maxSizeBytes) {
    _maxCacheSize = maxSizeBytes;
  }

  @override
  Future<File> generateThumbnail(String imagePath, Size thumbnailSize) async {
    final File originalFile = File(imagePath);
    final File thumbnail = await resizeImage(originalFile, thumbnailSize);
    
    // Save thumbnail to thumbnails directory
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory thumbnailDir = Directory('${appDir.path}/$_thumbnailsFolder');
    
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    
    final String thumbnailFileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String thumbnailPath = '${thumbnailDir.path}/$thumbnailFileName';
    
    await thumbnail.copy(thumbnailPath);
    await thumbnail.delete(); // Clean up temp file
    
    return File(thumbnailPath);
  }

  @override
  Future<Map<String, File>> generateMultipleThumbnails(
    String imagePath,
    Map<String, Size> thumbnailSizes,
  ) async {
    final Map<String, File> thumbnails = {};
    
    for (final MapEntry<String, Size> entry in thumbnailSizes.entries) {
      thumbnails[entry.key] = await generateThumbnail(imagePath, entry.value);
    }
    
    return thumbnails;
  }

  @override
  Future<File> getOrCreateThumbnail(String imagePath, Size thumbnailSize) async {
    // Check if thumbnail already exists
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory thumbnailDir = Directory('${appDir.path}/$_thumbnailsFolder');
    
    final String imageName = imagePath.split('/').last.split('.').first;
    final String thumbnailPath = '${thumbnailDir.path}/thumb_${imageName}_${thumbnailSize.width.toInt()}x${thumbnailSize.height.toInt()}.jpg';
    
    final File thumbnailFile = File(thumbnailPath);
    
    if (await thumbnailFile.exists()) {
      return thumbnailFile;
    }
    
    // Generate new thumbnail
    return await generateThumbnail(imagePath, thumbnailSize);
  }

  @override
  Future<bool> requestCameraPermissions() async {
    final PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestGalleryPermissions() async {
    final PermissionStatus status = await Permission.photos.request();
    return status.isGranted;
  }

  @override
  Future<bool> hasCameraPermissions() async {
    final PermissionStatus status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> hasGalleryPermissions() async {
    final PermissionStatus status = await Permission.photos.status;
    return status.isGranted;
  }

  @override
  bool isValidImageExtension(String fileName) {
    final String extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return _supportedExtensions.contains(extension);
  }

  @override
  bool isValidImageSize(int fileSizeBytes, {int maxSizeBytes = 10485760}) {
    return fileSizeBytes <= maxSizeBytes && fileSizeBytes > 0;
  }

  @override
  bool isValidImageDimensions(Size dimensions, {Size? maxDimensions}) {
    final Size maxDims = maxDimensions ?? _maxImageDimensions;
    return dimensions.width <= maxDims.width && 
           dimensions.height <= maxDims.height &&
           dimensions.width > 0 && 
           dimensions.height > 0;
  }

  @override
  Future<ImageServiceHealthCheck> performHealthCheck() async {
    final List<String> issues = [];
    final Map<String, dynamic> diagnostics = {};
    
    // Check permissions
    final bool cameraPermission = await hasCameraPermissions();
    final bool galleryPermission = await hasGalleryPermissions();
    
    diagnostics['camera_permission'] = cameraPermission;
    diagnostics['gallery_permission'] = galleryPermission;
    
    if (!cameraPermission) {
      issues.add('Camera permission not granted');
    }
    
    if (!galleryPermission) {
      issues.add('Gallery permission not granted');
    }
    
    // Check storage
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      diagnostics['app_directory'] = appDir.path;
      diagnostics['storage_available'] = true;
    } catch (e) {
      issues.add('Storage access issue: $e');
      diagnostics['storage_available'] = false;
    }
    
    // Check cache size
    final int cacheSize = await getCacheSize();
    diagnostics['cache_size'] = cacheSize;
    diagnostics['cache_limit'] = _maxCacheSize;
    
    if (cacheSize > _maxCacheSize) {
      issues.add('Cache size exceeds limit');
    }
    
    return ImageServiceHealthCheck(
      isHealthy: issues.isEmpty,
      issues: issues,
      diagnostics: diagnostics,
    );
  }

  @override
  List<ImageFormat> getSupportedFormats() {
    return [
      ImageFormat.jpeg,
      ImageFormat.png,
      ImageFormat.webp,
      ImageFormat.bmp,
      ImageFormat.gif,
    ];
  }

  @override
  int getMaxSupportedImageSize() {
    return _maxImageSizeBytes;
  }

  @override
  Future<int> getAvailableStorageSpace() async {
    // This is a simplified implementation
    // In a real app, you might use a platform-specific plugin
    return 1024 * 1024 * 1024; // 1GB placeholder
  }

  @override
  Future<List<String>> processBatch(List<String> imagePaths, Size targetSize) async {
    final List<String> processedPaths = [];
    
    for (final String imagePath in imagePaths) {
      try {
        final String processed = await processAndStore(
          imagePath: imagePath,
          targetSize: targetSize,
        );
        processedPaths.add(processed);
      } catch (e) {
        // Log error and continue with next image
        print('Failed to process image $imagePath: $e');
      }
    }
    
    return processedPaths;
  }

  @override
  Future<void> deleteBatch(List<String> imagePaths) async {
    for (final String imagePath in imagePaths) {
      try {
        await deleteImage(imagePath);
      } catch (e) {
        // Log error and continue
        print('Failed to delete image $imagePath: $e');
      }
    }
  }

  @override
  Future<Map<String, File>> generateThumbnailsBatch(
    List<String> imagePaths,
    Size thumbnailSize,
  ) async {
    final Map<String, File> thumbnails = {};
    
    for (final String imagePath in imagePaths) {
      try {
        final File thumbnail = await generateThumbnail(imagePath, thumbnailSize);
        thumbnails[imagePath] = thumbnail;
      } catch (e) {
        // Log error and continue
        print('Failed to generate thumbnail for $imagePath: $e');
      }
    }
    
    return thumbnails;
  }

  @override
  Future<String> imageToBase64(String imagePath) async {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  @override
  Future<File> base64ToImage(String base64String, {String? fileName}) async {
    final Uint8List imageBytes = base64Decode(base64String);
    final String finalFileName = fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = '${appDir.path}/$finalFileName';
    
    final File imageFile = File(imagePath);
    await imageFile.writeAsBytes(imageBytes);
    
    return imageFile;
  }

  @override
  Future<File> createImageFromWidget(Widget widget, Size size) async {
    // This would require flutter/rendering context
    // Simplified implementation for now
    throw UnimplementedError('createImageFromWidget not implemented in this MVP');
  }

  @override
  Future<File> blurImage(File image, double blurRadius) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for blurring');
    }
    
    final img.Image blurredImage = img.gaussianBlur(decodedImage, radius: blurRadius.toInt());
    final List<int> blurredBytes = img.encodeJpg(blurredImage, quality: _defaultQuality);
    
    final String tempPath = '${image.path}_blurred.jpg';
    final File blurredFile = File(tempPath);
    await blurredFile.writeAsBytes(blurredBytes);
    
    return blurredFile;
  }

  @override
  Future<File> addWatermark(File image, String watermarkText) async {
    final Uint8List imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    
    if (decodedImage == null) {
      throw Exception('Failed to decode image for watermarking');
    }
    
    // Simple text watermark implementation
    final img.Image watermarkedImage = img.drawString(
      decodedImage,
      watermarkText,
      font: img.arial24,
      x: 10,
      y: decodedImage.height - 40,
      color: img.ColorRgb8(255, 255, 255),
    );
    
    final List<int> watermarkedBytes = img.encodeJpg(watermarkedImage, quality: _defaultQuality);
    
    final String tempPath = '${image.path}_watermarked.jpg';
    final File watermarkedFile = File(tempPath);
    await watermarkedFile.writeAsBytes(watermarkedBytes);
    
    return watermarkedFile;
  }
}