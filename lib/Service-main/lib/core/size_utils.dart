import 'package:flutter/widgets.dart';

class SizeConfig {
  static double screenWidth = 375;
  static double screenHeight = 812;

  static void init(BuildContext context) {
    if (!context.mounted) return;
    final size = MediaQuery.sizeOf(context);
    screenWidth = size.width;
    screenHeight = size.height;
  }
}

extension MediaQuerySizing on num {
  /// Responsive width relative to standard 375 design width
  double get w => (this / 375) * SizeConfig.screenWidth;
  
  /// Responsive height relative to standard 812 design height
  double get h => (this / 812) * SizeConfig.screenHeight;
  
  /// Responsive font size, matching width scaling
  double get sp => w; 
  
  /// Responsive radius size, matching width scaling
  double get r => w;
}
