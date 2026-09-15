import 'package:flutter/material.dart';
import '../../data/quran_repository.dart';
import 'mushaf_page.dart';

/// Production-grade Visual Mushaf Page Viewer.
/// Renders authentic 604 Madinah Mushaf pages with RTL swiping,
/// realistic book surface canvas, dynamic header/footer metadata,
/// dark mode color transformation, pinch-to-zoom, and strictly bounded memory lifecycle.
class MushafPageView extends StatefulWidget {
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onTap;

  const MushafPageView({
    super.key,
    this.initialPage = 1,
    this.onPageChanged,
    this.onTap,
  });

  @override
  State<MushafPageView> createState() => MushafPageViewState();
}

class MushafPageViewState extends State<MushafPageView> {
  late PageController _pageController;
  late int _currentPage;

  /// Bounded TransformationControllers cache: retains at most 3 controllers
  /// for the active viewport window [currentPage - 1, currentPage, currentPage + 1].
  /// Any controller outside this window is explicitly disposed to prevent memory accumulation.
  final Map<int, TransformationController> _transformControllers = {};

  /// Current active page accessor
  int get currentPage => _currentPage;

  /// Exposes the number of active live TransformationControllers (for memory tests)
  int get activeTransformControllersCount => _transformControllers.length;

  @override
  void initState() {
    super.initState();
    _currentPage = QuranRepository.clampPageNumber(widget.initialPage);
    // In RTL PageView: index 0 corresponds to page 1
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void didUpdateWidget(covariant MushafPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage) {
      final clamped = QuranRepository.clampPageNumber(widget.initialPage);
      if (clamped != _currentPage) {
        jumpToPage(clamped);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _transformControllers.values) {
      controller.dispose();
    }
    _transformControllers.clear();
    super.dispose();
  }

  /// Programmatically jumps to the specified page (1 to 604)
  void jumpToPage(int pageNumber) {
    final target = QuranRepository.clampPageNumber(pageNumber);
    setState(() {
      _currentPage = target;
    });
    _pruneTransformControllers(target);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(target - 1);
    }
  }

  /// Programmatically animates to the specified page
  void animateToPage(int pageNumber) {
    final target = QuranRepository.clampPageNumber(pageNumber);
    setState(() {
      _currentPage = target;
    });
    _pruneTransformControllers(target);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        target - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  TransformationController _getTransformController(int page) {
    return _transformControllers.putIfAbsent(
      page,
      () => TransformationController(),
    );
  }

  /// Strictly prunes any TransformationController outside the active window.
  /// Disposes each evicted controller cleanly to prevent memory leaks.
  void _pruneTransformControllers(int activePage) {
    final activeRange = {activePage - 1, activePage, activePage + 1};
    final keysToEvict = <int>[];

    for (final entry in _transformControllers.entries) {
      if (!activeRange.contains(entry.key)) {
        entry.value.dispose();
        keysToEvict.add(entry.key);
      }
    }

    for (final key in keysToEvict) {
      _transformControllers.remove(key);
    }
  }

  void _handleDoubleTap(int page) {
    final controller = _getTransformController(page);
    if (controller.value != Matrix4.identity()) {
      controller.value = Matrix4.identity();
    } else {
      controller.value = Matrix4.diagonal3Values(1.8, 1.8, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Explicit RTL directionality guarantees Page 1 is on the far right
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: _pageController,
        itemCount: QuranRepository.totalMushafPages,
        onPageChanged: (index) {
          final pageNumber = index + 1;
          setState(() {
            _currentPage = pageNumber;
          });

          // Reset zoom on leaving previous pages
          for (final entry in _transformControllers.entries) {
            if (entry.key != pageNumber) {
              entry.value.value = Matrix4.identity();
            }
          }

          // Prune out-of-range controllers to enforce bounded memory usage
          _pruneTransformControllers(pageNumber);

          widget.onPageChanged?.call(pageNumber);
        },
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          final transformController = _getTransformController(pageNumber);

          return MushafPage(
            pageNumber: pageNumber,
            isDark: isDark,
            transformationController: transformController,
            onTap: widget.onTap,
            onDoubleTap: () => _handleDoubleTap(pageNumber),
          );
        },
      ),
    );
  }
}
