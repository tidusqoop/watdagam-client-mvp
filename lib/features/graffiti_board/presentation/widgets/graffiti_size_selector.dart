import 'package:flutter/material.dart';
import '../../domain/value_objects/graffiti_content.dart';

/// Widget for selecting graffiti size with visual preview and descriptions
class GraffitiSizeSelector extends StatelessWidget {
  final GraffitiSize selectedSize;
  final Function(GraffitiSize) onSizeSelected;
  final bool showPreview;
  final EdgeInsets padding;

  const GraffitiSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
    this.showPreview = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),
          
          // Size options
          ...GraffitiSize.values.map((size) => _buildSizeOption(context, size)),
          
          if (showPreview) ...[
            const SizedBox(height: 20),
            _buildPreview(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '크기 선택',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B6B),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeOption(BuildContext context, GraffitiSize size) {
    final bool isSelected = selectedSize == size;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSizeSelected(size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0F8FF) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5E5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Visual size preview
                _buildSizePreview(size, isSelected),
                const SizedBox(width: 16),
                
                // Size information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            size.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF007AFF).withOpacity(0.1)
                                  : const Color(0xFFE5E5E5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${size.dimensions.width.toInt()}×${size.dimensions.height.toInt()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF6B6B6B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF6B6B6B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSizeFeatures(size),
                    ],
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizePreview(GraffitiSize size, bool isSelected) {
    return Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size.dimensions.width * 0.25, // Scale down for preview
          height: size.dimensions.height * 0.25,
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF007AFF).withOpacity(0.2)
                : const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFBBBBBB),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              size.displayName,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF6B6B6B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeFeatures(GraffitiSize size) {
    List<String> features = [];
    
    switch (size) {
      case GraffitiSize.small:
        features = ['빠른 작성', '간단한 메시지', '공간 효율적'];
        break;
      case GraffitiSize.medium:
        features = ['균형잡힌 크기', '적당한 글자수', '가장 인기'];
        break;
      case GraffitiSize.large:
        features = ['시선집중', '상세한 내용', '강한 임팩트'];
        break;
    }
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: features.map((feature) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          feature,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '미리보기',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Center(
            child: Container(
              width: selectedSize.dimensions.width * 0.8, // Scale for preview
              height: selectedSize.dimensions.height * 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF007AFF).withOpacity(0.1),
                    const Color(0xFF007AFF).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${selectedSize.displayName} 크기',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedSize.dimensions.width.toInt()} × ${selectedSize.dimensions.height.toInt()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF007AFF).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '선택한 크기로 낙서가 캔버스에 표시됩니다',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF6B6B6B),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Compact version of GraffitiSizeSelector for use in dialogs
class CompactGraffitiSizeSelector extends StatelessWidget {
  final GraffitiSize selectedSize;
  final Function(GraffitiSize) onSizeSelected;

  const CompactGraffitiSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: GraffitiSize.values.map((size) {
          final bool isSelected = selectedSize == size;
          final bool isFirst = size == GraffitiSize.values.first;
          final bool isLast = size == GraffitiSize.values.last;
          
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  left: isFirst ? const Radius.circular(12) : Radius.zero,
                  right: isLast ? const Radius.circular(12) : Radius.zero,
                ),
                onTap: () => onSizeSelected(size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.horizontal(
                      left: isFirst ? const Radius.circular(12) : Radius.zero,
                      right: isLast ? const Radius.circular(12) : Radius.zero,
                    ),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5E5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        size.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size.description,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF6B6B6B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Size selector for bottom sheet or popup
class PopupGraffitiSizeSelector extends StatelessWidget {
  final Function(GraffitiSize) onSizeSelected;

  const PopupGraffitiSizeSelector({
    super.key,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '낙서 크기 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B6B6B),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Size options in grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
            children: GraffitiSize.values.map((size) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    onSizeSelected(size);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Size preview
                        Container(
                          width: size.dimensions.width * 0.3,
                          height: size.dimensions.height * 0.3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF007AFF).withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              size.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Size info
                        Text(
                          size.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          size.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}