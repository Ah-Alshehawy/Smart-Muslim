import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../data/quran_repository.dart';
import '../../data/quran_tafsir_data.dart';
import '../../domain/ayah_model.dart';
import '../../domain/surah_model.dart';
import '../widgets/mushaf_page_view.dart';

enum QuranReadingMode {
  mushafPageView,
  textVerseByVerse,
  compactContinuous,
}

class QuranReaderScreen extends StatefulWidget {
  final SurahModel surah;
  final int? initialAyah;
  final int? initialPage;

  const QuranReaderScreen({
    super.key,
    required this.surah,
    this.initialAyah,
    this.initialPage,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> with WidgetsBindingObserver {
  late SurahModel _currentSurah;
  QuranReadingMode _readingMode = QuranReadingMode.mushafPageView;
  double _fontSize = 24.0;
  int? _bookmarkedAyah;
  List<AyahModel> _ayahs = [];

  // Mushaf page navigation
  late int _currentPage;
  final GlobalKey<MushafPageViewState> _mushafKey = GlobalKey<MushafPageViewState>();
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentSurah = widget.surah;
    _bookmarkedAyah = widget.initialAyah;

    // Resolve initial page
    if (widget.initialPage != null) {
      _currentPage = QuranRepository.clampPageNumber(widget.initialPage!);
    } else if (widget.initialAyah != null) {
      final ayah = QuranRepository.getAyah(widget.surah.number, widget.initialAyah!);
      _currentPage = ayah?.page ?? widget.surah.startPage;
    } else {
      _currentPage = widget.surah.startPage;
    }

    _loadSurahData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
  }

  void _setFullscreen(bool fullscreen) {
    if (_isFullscreen == fullscreen) return;
    setState(() {
      _isFullscreen = fullscreen;
    });
    if (fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFullscreen() {
    _setFullscreen(!_isFullscreen);
  }

  void _showThemeSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, currentMode) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.palette_outlined, color: AppColors.emeraldGreen),
                  SizedBox(width: 8),
                  Text('مظهر القراءة والسمة'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('الوضع النهاري (فاتح)'),
                    subtitle: const Text('أرضية ورقية دافئة وخط أسود كالمصحف الشريف'),
                    leading: const Icon(Icons.wb_sunny_outlined, color: AppColors.sandGold),
                    trailing: currentMode == ThemeMode.light
                        ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      dialogContext.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                      Navigator.pop(dialogContext);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('الوضع الليلي (داكن)'),
                    subtitle: const Text('أرضية داكنة مريحة للعين وخط ناصع'),
                    leading: const Icon(Icons.nightlight_round, color: AppColors.emeraldGreenLight),
                    trailing: currentMode == ThemeMode.dark
                        ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      dialogContext.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                      Navigator.pop(dialogContext);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('تلقائي (حسب مظهر النظام)'),
                    subtitle: const Text('يتوافق مع وضع الهاتف'),
                    leading: const Icon(Icons.brightness_auto, color: AppColors.emeraldGreen),
                    trailing: currentMode == ThemeMode.system
                        ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      dialogContext.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _loadSurahData() {
    _ayahs = QuranRepository.getSurahAyahs(_currentSurah.number);
    _saveCurrentProgress();
  }

  void _saveCurrentProgress() {
    final firstAyah = _ayahs.isNotEmpty ? _ayahs.first.numberInSurah : 1;
    QuranRepository.saveLastRead(
      surahNumber: _currentSurah.number,
      ayahNumber: _bookmarkedAyah ?? firstAyah,
      pageNumber: _currentPage,
    );
  }

  void _onMushafPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      final matchedSurah = QuranRepository.getSurahForPage(newPage);
      if (matchedSurah != null && matchedSurah.number != _currentSurah.number) {
        _currentSurah = matchedSurah;
        _ayahs = QuranRepository.getSurahAyahs(_currentSurah.number);
      }
    });
    _saveCurrentProgress();
  }

  void _changeSurah(SurahModel newSurah) {
    setState(() {
      _currentSurah = newSurah;
      _currentPage = newSurah.startPage;
      _bookmarkedAyah = null;
      _loadSurahData();
    });
    if (_readingMode == QuranReadingMode.mushafPageView) {
      _mushafKey.currentState?.jumpToPage(_currentPage);
    }
  }

  int get _currentJuz {
    final pageAyahs = QuranRepository.getPageAyahs(_currentPage);
    if (pageAyahs.isNotEmpty) {
      return pageAyahs.first.juz;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFullscreen) {
          _setFullscreen(false);
        }
      },
      child: Scaffold(
        appBar: _isFullscreen
            ? null
            : AppBar(
                title: Text(
                  _readingMode == QuranReadingMode.mushafPageView
                      ? 'سورة ${_currentSurah.nameArabic} • ص ${_convertToArabicNumerals(_currentPage)}'
                      : 'سورة ${_currentSurah.nameArabic}',
                  style: AppTypography.titleLarge(isDark).copyWith(fontSize: 17),
                ),
                actions: [
                  // Jump to Page Dialog button
                  if (_readingMode == QuranReadingMode.mushafPageView)
                    IconButton(
                      icon: const Icon(Icons.find_in_page_outlined),
                      tooltip: 'انتقال لصفحة',
                      onPressed: () => _showJumpToPageDialog(context, isDark),
                    ),

                  // Bookmark action
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline),
                    tooltip: 'حفظ كعلامة مرجعية',
                    onPressed: () {
                      _saveCurrentProgress();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ صفحة ${_convertToArabicNumerals(_currentPage)} (سورة ${_currentSurah.nameArabic}) كعلامة مرجعية',
                          ),
                          backgroundColor: AppColors.emeraldGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  // Theme Switcher button (Day / Night / System)
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    ),
                    tooltip: isDark ? 'التبديل للوضع النهاري (فاتح)' : 'التبديل للوضع الليلي (داكن)',
                    onPressed: () => _showThemeSelectorDialog(context),
                  ),

                  // Fullscreen button (Mushaf mode only)
                  if (_readingMode == QuranReadingMode.mushafPageView)
                    IconButton(
                      icon: const Icon(Icons.fullscreen),
                      tooltip: 'ملء الشاشة والقراءة الغامرة',
                      onPressed: () => _setFullscreen(true),
                    ),

                  // Reading Mode Selector
                  PopupMenuButton<QuranReadingMode>(
                    icon: const Icon(Icons.auto_stories),
                    tooltip: 'نمط القراءة',
                    initialValue: _readingMode,
                    onSelected: (mode) {
                      if (_isFullscreen) {
                        _setFullscreen(false);
                      }
                      setState(() => _readingMode = mode);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: QuranReadingMode.mushafPageView,
                        child: Row(
                          children: [
                            Icon(Icons.menu_book, size: 18, color: AppColors.emeraldGreen),
                            SizedBox(width: 8),
                            Text('المصحف المصور (صفحات)'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: QuranReadingMode.textVerseByVerse,
                        child: Row(
                          children: [
                            Icon(Icons.format_list_numbered_rtl, size: 18, color: AppColors.emeraldGreen),
                            SizedBox(width: 8),
                            Text('عرض نصي (آية بآية)'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: QuranReadingMode.compactContinuous,
                        child: Row(
                          children: [
                            Icon(Icons.view_agenda_outlined, size: 18, color: AppColors.emeraldGreen),
                            SizedBox(width: 8),
                            Text('عرض مدمج متصل'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (_readingMode != QuranReadingMode.mushafPageView)
                    IconButton(
                      icon: const Icon(Icons.format_size),
                      tooltip: 'حجم الخط',
                      onPressed: _showFontSizeDialog,
                    ),
                ],
              ),
        body: _buildReaderBody(isDark),
        bottomNavigationBar: (!_isFullscreen && _readingMode == QuranReadingMode.mushafPageView)
            ? _buildMushafBottomBar(isDark)
            : (!_isFullscreen ? _buildTextBottomNavigationBar(isDark) : null),
      ),
    );
  }

  Widget _buildReaderBody(bool isDark) {
    switch (_readingMode) {
      case QuranReadingMode.mushafPageView:
        return _buildMushafVisualViewer(isDark);
      case QuranReadingMode.textVerseByVerse:
        return _buildTextReadingMode(isDark);
      case QuranReadingMode.compactContinuous:
        return _buildCompactContinuousMode(isDark);
    }
  }

  // ==========================================
  // MODE A: True Visual Mushaf Viewer (Default)
  // ==========================================
  Widget _buildMushafVisualViewer(bool isDark) {
    return Column(
      children: [
        // Sub-header displaying Surah Name, Juz, and Page info (hidden in fullscreen)
        if (!_isFullscreen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سورة ${_currentSurah.nameArabic} (${_currentSurah.revelationType})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'الجزء ${_convertToArabicNumerals(_currentJuz)} • صفحة ${_convertToArabicNumerals(_currentPage)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sandGoldDark,
                  ),
                ),
              ],
            ),
          ),

        // 604-Page Visual Canvas
        Expanded(
          child: MushafPageView(
            key: _mushafKey,
            initialPage: _currentPage,
            onPageChanged: _onMushafPageChanged,
            onTap: _toggleFullscreen,
          ),
        ),
      ],
    );
  }

  Widget _buildMushafBottomBar(bool isDark) {
    final hasPrev = _currentPage > 1;
    final hasNext = _currentPage < QuranRepository.totalMushafPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Page Button
          TextButton.icon(
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('السابقة', style: TextStyle(fontSize: 12)),
            onPressed: hasPrev
                ? () {
                    _mushafKey.currentState?.animateToPage(_currentPage - 1);
                  }
                : null,
          ),

          // Quick Jump Page Button
          InkWell(
            onTap: () => _showJumpToPageDialog(context, isDark),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Text(
                '${_convertToArabicNumerals(_currentPage)} / ${_convertToArabicNumerals(604)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.emeraldGreen,
                ),
              ),
            ),
          ),

          // Next Page Button
          TextButton.icon(
            label: const Text('التالية', style: TextStyle(fontSize: 12)),
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            onPressed: hasNext
                ? () {
                    _mushafKey.currentState?.animateToPage(_currentPage + 1);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _showJumpToPageDialog(BuildContext context, bool isDark) {
    int selectedPage = _currentPage;
    final TextEditingController textController = TextEditingController(text: _currentPage.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              title: const Text('الانتقال إلى صفحة في المصحف'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر صفحة من ١ إلى ٦٠٤',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'رقم الصفحة',
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null && parsed >= 1 && parsed <= 604) {
                        setDialogState(() {
                          selectedPage = parsed;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: selectedPage.toDouble(),
                    min: 1.0,
                    max: 604.0,
                    divisions: 603,
                    activeColor: AppColors.emeraldGreen,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedPage = val.round();
                        textController.text = selectedPage.toString();
                      });
                    },
                  ),
                  Text(
                    'صفحة ${_convertToArabicNumerals(selectedPage)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final target = int.tryParse(textController.text) ?? selectedPage;
                    final clamped = QuranRepository.clampPageNumber(target);
                    Navigator.pop(dialogContext);
                    _mushafKey.currentState?.jumpToPage(clamped);
                  },
                  child: const Text('انتقال'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MODE B: Text Verse-By-Verse Mode
  // ==========================================
  Widget _buildTextReadingMode(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        _buildSurahHeaderBanner(isDark),
        const SizedBox(height: 12),
        if (_currentSurah.number != 9 && _currentSurah.number != 1) _buildBismillahBanner(isDark),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.emeraldGreen.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _ayahs.map((ayah) => _buildAyahTile(ayah, isDark)).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODE C: Compact Continuous Mode
  // ==========================================
  Widget _buildCompactContinuousMode(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSurahHeaderBanner(isDark),
        const SizedBox(height: 12),
        if (_currentSurah.number != 9 && _currentSurah.number != 1) _buildBismillahBanner(isDark),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: RichText(
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: _ayahs.map((ayah) {
                return TextSpan(
                  text: '${ayah.textUthmani} ﴿${_convertToArabicNumerals(ayah.numberInSurah)}﴾ ',
                  style: AppTypography.quranText(fontSize: _fontSize - 2, isDark: isDark).copyWith(
                    height: 2.0,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahHeaderBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.emeraldGreenDark, AppColors.darkCard]
              : [AppColors.emeraldGreen, AppColors.emeraldGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        children: [
          Text(
            'سورة ${_currentSurah.nameArabic}',
            style: const TextStyle(
              fontFamily: AppTypography.arabicFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentSurah.revelationType} • ${_currentSurah.totalAyahs} آية • ${_currentSurah.nameEnglish}',
            style: const TextStyle(
              fontFamily: AppTypography.arabicFontFamily,
              fontSize: 13,
              color: AppColors.sandGoldLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillahBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sandGold.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
          style: AppTypography.quranText(fontSize: _fontSize, isDark: isDark).copyWith(
            color: AppColors.emeraldGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahTile(AyahModel ayah, bool isDark) {
    final isBookmarked = _bookmarkedAyah == ayah.numberInSurah;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showAyahActionSheet(ayah, isDark),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isBookmarked
              ? AppColors.sandGold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${ayah.textUthmani} ﴿${_convertToArabicNumerals(ayah.numberInSurah)}﴾',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTypography.quranText(fontSize: _fontSize, isDark: isDark).copyWith(
                height: 2.1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isBookmarked)
                  const Row(
                    children: [
                      Icon(Icons.bookmark, color: AppColors.sandGold, size: 14),
                      SizedBox(width: 4),
                      Text('علامة مرجعية', style: TextStyle(color: AppColors.sandGold, fontSize: 11)),
                    ],
                  )
                else
                  const SizedBox(),
                Text(
                  'آية ${ayah.numberInSurah} • ص ${ayah.page}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBottomNavigationBar(bool isDark) {
    final currentIndex = QuranRepository.allSurahs.indexWhere((s) => s.number == _currentSurah.number);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < QuranRepository.allSurahs.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: Text(hasPrev ? 'سورة ${QuranRepository.allSurahs[currentIndex - 1].nameArabic}' : 'البداية'),
            onPressed: hasPrev ? () => _changeSurah(QuranRepository.allSurahs[currentIndex - 1]) : null,
          ),
          Text(
            '${_currentSurah.number} / 114',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            label: Text(hasNext ? 'سورة ${QuranRepository.allSurahs[currentIndex + 1].nameArabic}' : 'الختام'),
            icon: const Icon(Icons.arrow_forward),
            onPressed: hasNext ? () => _changeSurah(QuranRepository.allSurahs[currentIndex + 1]) : null,
          ),
        ],
      ),
    );
  }

  void _showAyahActionSheet(AyahModel ayah, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final tafsir = QuranTafsirData.getAyahTafsir(ayah.surahNumber, ayah.numberInSurah);

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الآية (${ayah.numberInSurah}) من سورة ${_currentSurah.nameArabic}',
                    style: AppTypography.titleMedium(isDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_stories, color: AppColors.emeraldGreen, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'التفسير الميسر',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.emeraldGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tafsir,
                      style: AppTypography.bodyMedium(isDark).copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.bookmark_add),
                      label: const Text('حفظ كعلامة'),
                      onPressed: () {
                        setState(() {
                          _bookmarkedAyah = ayah.numberInSurah;
                        });
                        QuranRepository.saveLastRead(
                          surahNumber: _currentSurah.number,
                          ayahNumber: ayah.numberInSurah,
                          pageNumber: ayah.page,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم حفظ الآية (${ayah.numberInSurah}) كعلامة مرجعية'),
                            backgroundColor: AppColors.emeraldGreen,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.copy),
                      label: const Text('نسخ الآية'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '${ayah.textUthmani} ﴿${ayah.numberInSurah}﴾'));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ نص الآية إلى الحافظة')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('حجم خط المصحف'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: AppTypography.quranText(fontSize: _fontSize),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _fontSize,
                    min: 18.0,
                    max: 36.0,
                    divisions: 9,
                    activeColor: AppColors.emeraldGreen,
                    label: '${_fontSize.toInt()} pt',
                    onChanged: (val) {
                      setDialogState(() => _fontSize = val);
                      setState(() => _fontSize = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('تم'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _convertToArabicNumerals(int number) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String str = number.toString();
    for (int i = 0; i < englishDigits.length; i++) {
      str = str.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return str;
  }
}
