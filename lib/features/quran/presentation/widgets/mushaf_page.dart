import 'package:flutter/material.dart';
import 'mushaf_metadata_overlay.dart';
import 'mushaf_page_surface.dart';
import 'mushaf_plate.dart';

/// Complete Visual Mushaf Page presentation:
/// Combines the authentic book surface canvas, dynamic header/footer metadata,
/// and the high-resolution transparent calligraphic plate within an InteractiveViewer.
class MushafPage extends StatelessWidget {
  final int pageNumber;
  final bool isDark;
  final TransformationController transformationController;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const MushafPage({
    super.key,
    required this.pageNumber,
    required this.isDark,
    required this.transformationController,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return MushafPageSurface(
      pageNumber: pageNumber,
      isDark: isDark,
      child: SafeArea(
        top: true,
        bottom: true,
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: InteractiveViewer(
            transformationController: transformationController,
            minScale: 1.0,
            maxScale: 3.5,
            panEnabled: true,
            scaleEnabled: true,
            child: Column(
              children: [
                // Top Metadata Header (Surah name & Juz' number)
                MushafMetadataHeader(
                  pageNumber: pageNumber,
                  isDark: isDark,
                ),

                // Central Reading Area: Aspect ratio preserved transparent plate
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: MushafPlate(
                        pageNumber: pageNumber,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                // Bottom Metadata Footer (Arabic page number)
                MushafMetadataFooter(
                  pageNumber: pageNumber,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
