import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../domain/entities/graffiti_note.dart';
import '../../domain/value_objects/graffiti_content.dart';
import '../../data/models/graffiti_note.dart';
import '../../../../shared/utils/color_utils.dart';
import '../../../../utils/time_utils.dart';
import 'canvas/drag_handler.dart';

/// Enhanced graffiti note widget with image support and improved display logic
class EnhancedGraffitiNoteWidget extends StatefulWidget {
  final GraffitiNote note;
  final DragHandler? dragHandler;
  final TransformationController? transformationController;
  final bool isEditable;
  final bool showMetadata;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(GraffitiNote)? onEdit;
  final Function(GraffitiNote)? onDelete;

  const EnhancedGraffitiNoteWidget({
    super.key,
    required this.note,
    this.dragHandler,
    this.transformationController,
    this.isEditable = true,
    this.showMetadata = true,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EnhancedGraffitiNoteWidget> createState() => _EnhancedGraffitiNoteWidgetState();
}

class _EnhancedGraffitiNoteWidgetState extends State<EnhancedGraffitiNoteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isHovered = false;
  bool _isDragging = false;
  bool _showContextMenu = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: widget.note.properties.opacity,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.note.position.offset.dx,
      top: widget.note.position.offset.dy,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildGraffitiContent(),
          );
        },
      ),
    );
  }

  Widget _buildGraffitiContent() {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        if (widget.isEditable) {
          _handleTap();
        }
      },
      onLongPress: () {
        widget.onLongPress?.call();
        if (widget.isEditable) {
          _showContextMenuDialog();
        }
      },
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: MouseRegion(
        onEnter: (_) => _handleMouseEnter(),
        onExit: (_) => _handleMouseExit(),
        child: Container(
          width: widget.note.size.dimensions.width,
          height: widget.note.size.dimensions.height,
          child: Stack(
            children: [
              // Main graffiti container
              _buildMainContainer(),
              
              // Interaction indicators
              if (_isHovered && widget.isEditable)
                _buildHoverIndicator(),
              
              // Context menu indicator
              if (_showContextMenu)
                _buildContextMenuIndicator(),
              
              // Loading/Error states
              if (widget.note.hasImage)
                _buildImageLoadingState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.note.properties.backgroundColor.withOpacity(
          _opacityAnimation.value,
        ),
        borderRadius: BorderRadius.circular(
          widget.note.properties.cornerRadius,
        ),
        border: _buildBorder(),
        boxShadow: _buildShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          widget.note.properties.cornerRadius,
        ),
        child: _buildContent(),
      ),
    );
  }

  Border? _buildBorder() {
    if (_isDragging) {
      return Border.all(
        color: const Color(0xFF007AFF),
        width: 2,
      );
    }
    
    if (_isHovered) {
      return Border.all(
        color: ColorUtils.getBorderColor(widget.note.properties.backgroundColor),
        width: 1.5,
      );
    }
    
    return Border.all(
      color: ColorUtils.getBorderColor(widget.note.properties.backgroundColor)
          .withOpacity(0.3),
      width: 1,
    );
  }

  List<BoxShadow> _buildShadow() {
    if (_isDragging) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 8),
          blurRadius: 16,
        ),
      ];
    }
    
    if (_isHovered) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ];
  }

  Widget _buildContent() {
    final bool hasImage = widget.note.hasImage;
    final bool hasText = widget.note.content.text.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Content area
          Expanded(
            child: _buildContentArea(hasImage, hasText),
          ),
          
          // Metadata area
          if (widget.showMetadata)
            _buildMetadataArea(),
        ],
      ),
    );
  }

  Widget _buildContentArea(bool hasImage, bool hasText) {
    if (hasImage && hasText) {
      return _buildImageWithTextLayout();
    } else if (hasImage) {
      return _buildImageOnlyLayout();
    } else {
      return _buildTextOnlyLayout();
    }
  }

  Widget _buildImageWithTextLayout() {
    final imageSize = _calculateImageSize();
    
    return Column(
      children: [
        // Image area
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildImage(),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Text area
        Expanded(
          flex: 2,
          child: _buildTextContent(),
        ),
      ],
    );
  }

  Widget _buildImageOnlyLayout() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildTextOnlyLayout() {
    return Center(
      child: _buildTextContent(),
    );
  }

  Widget _buildImage() {
    if (widget.note.content.imagePath == null) {
      return _buildImagePlaceholder();
    }
    
    return Image.file(
      File(widget.note.content.imagePath!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImageError();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildImageLoading(loadingProgress);
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.red[300],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              '이미지 오류',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageLoading(ImageChunkEvent loadingProgress) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF007AFF),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '로딩 중...',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Text(
      widget.note.content.text,
      style: TextStyle(
        fontSize: _getTextSize(),
        color: ColorUtils.getContrastColor(
          widget.note.properties.backgroundColor,
        ),
        height: 1.3,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: _getMaxLines(),
    );
  }

  Widget _buildMetadataArea() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Author info
          Expanded(
            child: _buildAuthorInfo(),
          ),
          
          // Time info
          _buildTimeInfo(),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo() {
    final String? author = widget.note.userId; // This should be mapped to actual user name
    if (author == null || author.isEmpty) return const SizedBox.shrink();
    
    return Text(
      author,
      style: TextStyle(
        fontSize: 9,
        color: ColorUtils.getContrastColor(
          widget.note.properties.backgroundColor,
        ).withOpacity(0.7),
        fontWeight: FontWeight.w400,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTimeInfo() {
    return Text(
      widget.note.relativeTimeString,
      style: TextStyle(
        fontSize: 8,
        color: ColorUtils.getContrastColor(
          widget.note.properties.backgroundColor,
        ).withOpacity(0.6),
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildHoverIndicator() {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.drag_indicator,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }

  Widget _buildContextMenuIndicator() {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }

  Widget _buildImageLoadingState() {
    // This would show loading state for image processing
    return const SizedBox.shrink();
  }

  // Helper methods
  Size _calculateImageSize() {
    final noteSize = widget.note.size.dimensions;
    const padding = 24.0; // Total padding
    const textAreaHeight = 40.0; // Approximate text area height
    
    return Size(
      noteSize.width - padding,
      noteSize.height - padding - textAreaHeight,
    );
  }

  double _getTextSize() {
    switch (widget.note.size) {
      case GraffitiSize.small:
        return 12;
      case GraffitiSize.medium:
        return 14;
      case GraffitiSize.large:
        return 16;
    }
  }

  int _getMaxLines() {
    if (widget.note.hasImage) {
      return 2; // Limited lines when image is present
    }
    
    switch (widget.note.size) {
      case GraffitiSize.small:
        return 3;
      case GraffitiSize.medium:
        return 4;
      case GraffitiSize.large:
        return 6;
    }
  }

  // Event handlers
  void _handleMouseEnter() {
    if (!widget.isEditable) return;
    setState(() => _isHovered = true);
    _animationController.forward();
  }

  void _handleMouseExit() {
    if (!widget.isEditable) return;
    setState(() => _isHovered = false);
    _animationController.reverse();
  }

  void _handleTap() {
    // Handle tap for editing
    if (widget.onEdit != null) {
      widget.onEdit!(widget.note);
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.isEditable || widget.dragHandler == null) return;
    setState(() => _isDragging = true);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.isEditable || widget.dragHandler == null) return;
    
    widget.dragHandler!.handlePanUpdate(
      widget.note,
      details,
      widget.transformationController,
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.isEditable) return;
    setState(() => _isDragging = false);
  }

  void _showContextMenuDialog() {
    setState(() => _showContextMenu = true);
    
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => GraffitiContextMenu(
        note: widget.note,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
        onClose: () {
          setState(() => _showContextMenu = false);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Context menu for graffiti note actions
class GraffitiContextMenu extends StatelessWidget {
  final GraffitiNote note;
  final Function(GraffitiNote)? onEdit;
  final Function(GraffitiNote)? onDelete;
  final VoidCallback onClose;

  const GraffitiContextMenu({
    super.key,
    required this.note,
    this.onEdit,
    this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),
        
        // Menu
        Positioned(
          left: note.position.offset.dx + note.size.dimensions.width,
          top: note.position.offset.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    _buildMenuItem(
                      icon: Icons.edit,
                      label: '수정',
                      onTap: () {
                        onClose();
                        onEdit!(note);
                      },
                    ),
                  
                  if (onEdit != null && onDelete != null)
                    const Divider(height: 1),
                  
                  if (onDelete != null)
                    _buildMenuItem(
                      icon: Icons.delete,
                      label: '삭제',
                      onTap: () {
                        onClose();
                        onDelete!(note);
                      },
                      isDestructive: true,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDestructive ? Colors.red : const Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDestructive ? Colors.red : const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}