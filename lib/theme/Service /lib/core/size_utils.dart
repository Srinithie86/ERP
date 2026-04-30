import 'package:flutter/widgets.dart';

class SizeConfig {
  static double screenWidth = _defaultWidth();
  static double screenHeight = _defaultHeight();

  static double _defaultWidth() {
    final view = WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
        ? WidgetsBinding.instance.platformDispatcher.views.first
        : null;
    return view?.physicalSize.width != null && view!.devicePixelRatio > 0
        ? view.physicalSize.width / view.devicePixelRatio
        : 375;
  }

  static double _defaultHeight() {
    final view = WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
        ? WidgetsBinding.instance.platformDispatcher.views.first
        : null;
    return view?.physicalSize.height != null && view!.devicePixelRatio > 0
        ? view.physicalSize.height / view.devicePixelRatio
        : 812;
  }

  static void init(BuildContext context) {
    if (!context.mounted) return;
    final size = MediaQuery.sizeOf(context);
    if (size.width > 0) screenWidth = size.width;
    if (size.height > 0) screenHeight = size.height;
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
