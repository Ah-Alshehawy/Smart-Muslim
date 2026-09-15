import 'package:flutter/material.dart';

/// Renders the authentic book-surface canvas for a Mushaf page.
/// Provides warm paper tone with spine lighting in light mode,
/// and deep non-glare slate in dark mode, respecting RTL Arabic book geometry.
class MushafPageSurface extends StatelessWidget {
  final int pageNumber;
  final bool isDark;
  final Widget child;

  const MushafPageSurface({
    super.key,
    required this.pageNumber,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // In an Arabic RTL book:
    // - Odd pages (1, 3, 5...) are on the right: spine is on the LEFT edge, outer edge on the RIGHT.
    // - Even pages (2, 4, 6...) are on the left: spine is on the RIGHT edge, outer edge on the LEFT.
    final isOddPage = pageNumber % 2 != 0;

    final BoxDecoration decoration;

    if (isDark) {
      decoration = BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          left: BorderSide(
            color: isOddPage ? const Color(0xFF1E1E1E) : const Color(0xFF2A2A2A),
            width: isOddPage ? 1.0 : 1.5,
          ),
          right: BorderSide(
            color: isOddPage ? const Color(0xFF2A2A2A) : const Color(0xFF1E1E1E),
            width: isOddPage ? 1.5 : 1.0,
          ),
        ),
      );
    } else {
      // Light Mode: Warm cream parchment with subtle spine shadow
      final gradientColors = isOddPage
          ? const [
              Color(0xFFE5DFC9), // Spine shadow (left)
              Color(0xFFF9F6EB), // Gentle transition
              Color(0xFFFFFDF8), // Reading area light
              Color(0xFFF6F1E1), // Outer page edge (right)
            ]
          : const [
              Color(0xFFF6F1E1), // Outer page edge (left)
              Color(0xFFFFFDF8), // Reading area light
              Color(0xFFF9F6EB), // Gentle transition
              Color(0xFFE5DFC9), // Spine shadow (right)
            ];

      final gradientStops = isOddPage
          ? const [0.0, 0.08, 0.55, 1.0]
          : const [0.0, 0.45, 0.92, 1.0];

      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
          stops: gradientStops,
        ),
        border: Border(
          left: BorderSide(
            color: isOddPage ? const Color(0xFFD3CBB3) : const Color(0xFFDDD5BE),
            width: isOddPage ? 1.0 : 1.5,
          ),
          right: BorderSide(
            color: isOddPage ? const Color(0xFFDDD5BE) : const Color(0xFFD3CBB3),
            width: isOddPage ? 1.5 : 1.0,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      child: child,
    );
  }
}
