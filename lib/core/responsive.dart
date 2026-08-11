import 'package:flutter/material.dart';

/// Breakpoints shared by every screen. Kept intentionally simple (width-only)
/// since CareerMate's layouts only branch between a single-column "mobile"
/// arrangement and a multi-column "desktop" one — no separate tablet layouts
/// exist yet, so isTablet is exposed for future use but not branched on.
class Responsive {
  const Responsive._();

  static const double mobileMax = 640;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= tabletMax;
}
