import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/quran_repository.dart';

/// Renders the transparent Madinah Mushaf calligraphic page plate.
/// In Light Mode: displays rich black/charcoal calligraphy over the paper surface.
/// In Dark Mode: applies a runtime color matrix to transform black calligraphy into
/// radiant cream/white text while preserving full transparency of background pixels.
class MushafPlate extends StatelessWidget {
  final int pageNumber;
  final bool isDark;

  /// Transformation matrix that inverts ink brightness (0 -> 235) while preserving alpha (A -> A)
  static const List<double> darkCalligraphyMatrix = <double>[
    -1, 0, 0, 0, 235,
    0, -1, 0, 0, 235,
    0, 0, -1, 0, 235,
    0, 0, 0, 1, 0,
  ];

  const MushafPlate({
    super.key,
    required this.pageNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = QuranRepository.getMushafPageAssetPath(pageNumber);

    Widget imageWidget = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      cacheWidth: 1024,
      filterQuality: FilterQuality.high,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.emeraldGreen,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: AppColors.danger,
              ),
              const SizedBox(height: 8),
              Text(
                'تعذر تحميل صفحة $pageNumber',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                assetPath,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );

    if (isDark) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(darkCalligraphyMatrix),
        child: imageWidget,
      );
    }

    return AspectRatio(
      aspectRatio: 1024 / 1656,
      child: imageWidget,
    );
  }
}
