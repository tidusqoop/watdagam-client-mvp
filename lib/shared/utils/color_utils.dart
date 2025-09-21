import 'package:flutter/material.dart';

/// Utility class for color calculations
class ColorUtils {
  /// Calculate darker border color from background color
  static Color getBorderColor(Color backgroundColor) {
    final HSVColor hsv = HSVColor.fromColor(backgroundColor);
    return hsv
        .withSaturation((hsv.saturation + 0.3).clamp(0.0, 1.0))
        .withValue((hsv.value - 0.4).clamp(0.0, 1.0))
        .toColor();
  }
  
  /// Get contrast color for text based on background luminance
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black54 : Colors.white;
  }
}