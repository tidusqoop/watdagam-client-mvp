import 'package:flutter/material.dart';
import '../../data/models/graffiti_note.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../shared/utils/color_utils.dart';

/// 개선된 낙서 추가 다이얼로그
class AddGraffitiDialog extends StatefulWidget {
  final Function(String content, Color color, String? author, AuthorAlignment alignment) onAdd;

  const AddGraffitiDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddGraffitiDialog> createState() => _AddGraffitiDialogState();
}

class _AddGraffitiDialogState extends State<AddGraffitiDialog> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  Color _selectedColor = ColorPalette.graffitiColors.first;
  AuthorAlignment _authorAlignment = AuthorAlignment.center;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Header
            _buildHeader(context),
            
            // Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Input Section
                    _buildContentInput(),
                    SizedBox(height: 24),
                    
                    // Quick Emoji Section
                    _buildEmojiSection(),
                    SizedBox(height: 24),
                    
                    // Author Input Section
                    _buildAuthorSection(),
                    SizedBox(height: 24),
                    
                    // Color Selection Section
                    _buildColorSection(),
                    SizedBox(height: 32),
                    
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Header with Icon and Close Button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('✏️', style: TextStyle(fontSize: 16)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
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
              child: Container(
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
    );
  }

  // Enhanced Content Input with Custom Styling
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('내용'),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _contentController.text.isNotEmpty 
                ? Color(0xFF007AFF) 
                : Color(0xFFE5E5E5),
              width: _contentController.text.isNotEmpty ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: '어떤 이야기를 남길까요? ✨',
              hintStyle: TextStyle(
                color: Color(0xFF9B9B9B),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (_contentController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_contentController.text.length}/100',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Enhanced Emoji Quick Selection
  Widget _buildEmojiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('빠른 이모지'),
        SizedBox(height: 8),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ColorPalette.quickEmojis.length,
            itemBuilder: (context, index) {
              final emoji = ColorPalette.quickEmojis[index];
              return Padding(
                padding: EdgeInsets.only(right: 8),
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
                        color: Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 20),
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
    );
  }

  // Enhanced Author Input Section
  Widget _buildAuthorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('작성자'),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E5E5)),
          ),
          child: TextField(
            controller: _authorController,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: '작성자 이름 (선택사항)',
              hintStyle: TextStyle(
                color: Color(0xFF9B9B9B),
                fontSize: 16,
              ),
              prefixIcon: Container(
                width: 20,
                height: 20,
                child: Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildAlignmentButton('중앙', AuthorAlignment.center),
              ),
              Container(width: 1, height: 32, color: Color(0xFFE5E5E5)),
              Expanded(
                child: _buildAlignmentButton('오른쪽', AuthorAlignment.right),
              ),
            ],
          ),
        ),
      ],
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
                color: isSelected ? Color(0xFF007AFF) : Color(0xFF6B6B6B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Color Selection Grid
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('색상 선택'),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Color(0xFFE5E5E5),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                  ],
                ),
                child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: ColorUtils.getContrastColor(color),
                        size: 20,
                      ),
                    )
                  : null,
              ),
            );
          },
        ),
      ],
    );
  }

  // Enhanced Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Button
        Container(
          width: double.infinity,
          height: 52,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _contentController.text.trim().isNotEmpty
                ? () {
                    widget.onAdd(
                      _contentController.text.trim(),
                      _selectedColor,
                      _authorController.text.trim().isEmpty
                        ? null
                        : _authorController.text.trim(),
                      _authorAlignment,
                    );
                    Navigator.of(context).pop();
                  }
                : null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _contentController.text.trim().isNotEmpty
                    ? LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                  color: _contentController.text.trim().isEmpty
                    ? Color(0xFFE5E5E5)
                    : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '낙서 만들기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _contentController.text.trim().isNotEmpty
                        ? Colors.white
                        : Color(0xFF9B9B9B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        // Secondary Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 44,
              child: Center(
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Widget _buildSectionLabel(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B6B6B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}