import 'package:flutter/material.dart';
import '../../domain/value_objects/graffiti_content.dart';
import '../../data/models/graffiti_note.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../shared/utils/color_utils.dart';
import 'graffiti_size_selector.dart';
import 'graffiti_image_picker.dart';

/// Enhanced 낙서 추가 다이얼로그 with size selection and image support
class EnhancedAddGraffitiDialog extends StatefulWidget {
  final Function(String content, GraffitiSize size, Color color, String? author, AuthorAlignment alignment, String? imagePath) onAdd;

  const EnhancedAddGraffitiDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<EnhancedAddGraffitiDialog> createState() => _EnhancedAddGraffitiDialogState();
}

class _EnhancedAddGraffitiDialogState extends State<EnhancedAddGraffitiDialog> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  
  GraffitiSize _selectedSize = GraffitiSize.medium;
  Color _selectedColor = ColorPalette.graffitiColors.first;
  AuthorAlignment _authorAlignment = AuthorAlignment.center;
  String? _selectedImagePath;
  
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Header with Progress
            _buildHeader(context),
            
            // Content Area
            Flexible(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildContentStep(),
                  _buildSizeStep(),
                  _buildImageStep(),
                  _buildCustomizationStep(),
                ],
              ),
            ),
            
            // Navigation
            _buildNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final List<String> stepTitles = ['내용', '크기', '이미지', '스타일'];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Title and close button
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('✏️', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '새 낙서 만들기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.close,
                      color: Color(0xFF6B6B6B),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress indicator
          Row(
            children: List.generate(stepTitles.length, (index) {
              final bool isActive = index == _currentStep;
              final bool isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: isCompleted || isActive 
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFFE5E5E5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stepTitles[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive 
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFF9B9B9B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < stepTitles.length - 1)
                      const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '어떤 이야기를 남기고 싶나요? ✨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '나만의 특별한 메시지를 작성해보세요',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 24),
          
          // Content Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _contentController.text.isNotEmpty 
                  ? const Color(0xFF007AFF) 
                  : const Color(0xFFE5E5E5),
                width: _contentController.text.isNotEmpty ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 6,
              maxLength: 200,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: '여기에 메시지를 입력하세요...\n\n예: "서울 여행 왔다감! 🎉"\n"이곳 정말 아름다워요 💝"',
                hintStyle: TextStyle(
                  color: Color(0xFF9B9B9B),
                  fontSize: 16,
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
                counterStyle: TextStyle(
                  color: Color(0xFF9B9B9B),
                  fontSize: 12,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Emoji Section
          const Text(
            '빠른 이모지 추가',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ColorPalette.quickEmojis.length,
              itemBuilder: (context, index) {
                final emoji = ColorPalette.quickEmojis[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _contentController.text += emoji;
                        _contentController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _contentController.text.length),
                        );
                        setState(() {});
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '낙서 크기를 선택하세요 📐',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '크기에 따라 입력할 수 있는 글자수가 달라집니다',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 24),
          
          GraffitiSizeSelector(
            selectedSize: _selectedSize,
            onSizeSelected: (size) {
              setState(() => _selectedSize = size);
              
              // Truncate content if it exceeds new size limit
              if (_contentController.text.length > size.maxCharacters) {
                _contentController.text = _contentController.text.substring(0, size.maxCharacters);
                _contentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _contentController.text.length),
                );
              }
            },
            showPreview: true,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildImageStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이미지 추가 (선택사항) 📸',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '낙서에 특별함을 더해줄 이미지를 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 24),
          
          GraffitiImagePicker(
            selectedImagePath: _selectedImagePath,
            onImageSelected: (imagePath) {
              setState(() => _selectedImagePath = imagePath);
            },
            showPreview: true,
            targetSize: _selectedSize.dimensions,
            allowRemoval: true,
          ),
          
          if (_selectedImagePath == null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF007AFF).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF007AFF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '이미지 없이도 멋진 낙서를 만들 수 있습니다!',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF007AFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomizationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '스타일을 완성하세요 🎨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '색상과 작성자 정보를 설정해주세요',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 24),
          
          // Color Selection
          const Text(
            '배경 색상',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: ColorPalette.graffitiColors.length,
            itemBuilder: (context, index) {
              final color = ColorPalette.graffitiColors[index];
              final isSelected = color == _selectedColor;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : const Color(0xFFE5E5E5),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          color: ColorUtils.getContrastColor(color),
                          size: 24,
                        ),
                      )
                    : null,
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Author Section
          const Text(
            '작성자 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: TextField(
              controller: _authorController,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
              decoration: const InputDecoration(
                hintText: '작성자 이름 (선택사항)',
                hintStyle: TextStyle(
                  color: Color(0xFF9B9B9B),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Color(0xFF9B9B9B),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Author Alignment
          const Text(
            '작성자 표시 위치',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildAlignmentButton('중앙', AuthorAlignment.center),
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE5E5E5)),
                Expanded(
                  child: _buildAlignmentButton('오른쪽', AuthorAlignment.right),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Preview
          _buildFinalPreview(),
        ],
      ),
    );
  }

  Widget _buildAlignmentButton(String label, AuthorAlignment alignment) {
    final isSelected = _authorAlignment == alignment;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _authorAlignment = alignment),
        child: Container(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF6B6B6B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최종 미리보기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Center(
            child: Container(
              width: _selectedSize.dimensions.width * 0.8,
              height: _selectedSize.dimensions.height * 0.8,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorUtils.getContrastColor(_selectedColor).withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImagePath != null) ...[
                      Expanded(
                        flex: 2,
                        child: Icon(
                          Icons.image,
                          color: ColorUtils.getContrastColor(_selectedColor).withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          _contentController.text.isNotEmpty 
                              ? _contentController.text
                              : '미리보기 텍스트',
                          style: TextStyle(
                            fontSize: 10,
                            color: ColorUtils.getContrastColor(_selectedColor),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    if (_authorController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '- ${_authorController.text}',
                        style: TextStyle(
                          fontSize: 8,
                          color: ColorUtils.getContrastColor(_selectedColor).withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: _authorAlignment == AuthorAlignment.center 
                            ? TextAlign.center 
                            : TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _previousStep(),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: const Center(
                      child: Text(
                        '이전',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          // Next/Create button
          Expanded(
            flex: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _canProceed() ? () => _nextStep() : null,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _canProceed()
                      ? const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                    color: _canProceed() ? null : const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _currentStep == 3 ? '낙서 만들기' : '다음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _canProceed() ? Colors.white : const Color(0xFF9B9B9B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Content step
        return _contentController.text.trim().isNotEmpty;
      case 1: // Size step
        return true; // Size is always selected
      case 2: // Image step
        return true; // Image is optional
      case 3: // Customization step
        return true; // All customization is optional
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createGraffiti();
    }
  }

  void _createGraffiti() {
    if (_contentController.text.trim().isNotEmpty) {
      widget.onAdd(
        _contentController.text.trim(),
        _selectedSize,
        _selectedColor,
        _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
        _authorAlignment,
        _selectedImagePath,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _authorController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}