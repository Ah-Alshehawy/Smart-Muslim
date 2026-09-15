import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_muslim/core/theme/theme_cubit.dart';
import 'package:smart_muslim/features/quran/data/quran_repository.dart';
import 'package:smart_muslim/features/quran/domain/surah_model.dart';
import 'package:smart_muslim/features/quran/presentation/screens/quran_reader_screen.dart';
import 'package:smart_muslim/features/quran/presentation/widgets/mushaf_metadata_overlay.dart';
import 'package:smart_muslim/features/quran/presentation/widgets/mushaf_page.dart';
import 'package:smart_muslim/features/quran/presentation/widgets/mushaf_page_surface.dart';
import 'package:smart_muslim/features/quran/presentation/widgets/mushaf_page_view.dart';
import 'package:smart_muslim/features/quran/presentation/widgets/mushaf_plate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1. Mushaf Asset Path & Range Validation Tests', () {
    test('getMushafPageAssetPath returns deterministic zero-padded paths', () {
      expect(QuranRepository.getMushafPageAssetPath(1), equals('assets/quran/mushaf/pages/001.webp'));
      expect(QuranRepository.getMushafPageAssetPath(9), equals('assets/quran/mushaf/pages/009.webp'));
      expect(QuranRepository.getMushafPageAssetPath(10), equals('assets/quran/mushaf/pages/010.webp'));
      expect(QuranRepository.getMushafPageAssetPath(99), equals('assets/quran/mushaf/pages/099.webp'));
      expect(QuranRepository.getMushafPageAssetPath(100), equals('assets/quran/mushaf/pages/100.webp'));
      expect(QuranRepository.getMushafPageAssetPath(604), equals('assets/quran/mushaf/pages/604.webp'));
    });

    test('getMushafPageAssetPath strictly rejects out-of-bounds page numbers', () {
      expect(() => QuranRepository.getMushafPageAssetPath(0), throwsA(isA<ArgumentError>()));
      expect(() => QuranRepository.getMushafPageAssetPath(-1), throwsA(isA<ArgumentError>()));
      expect(() => QuranRepository.getMushafPageAssetPath(605), throwsA(isA<ArgumentError>()));
      expect(() => QuranRepository.getMushafPageAssetPath(1000), throwsA(isA<ArgumentError>()));
    });

    test('clampPageNumber safely clamps any integer into [1, 604]', () {
      expect(QuranRepository.clampPageNumber(-100), equals(1));
      expect(QuranRepository.clampPageNumber(0), equals(1));
      expect(QuranRepository.clampPageNumber(1), equals(1));
      expect(QuranRepository.clampPageNumber(250), equals(250));
      expect(QuranRepository.clampPageNumber(604), equals(604));
      expect(QuranRepository.clampPageNumber(605), equals(604));
      expect(QuranRepository.clampPageNumber(9999), equals(604));
    });
  });

  group('2. Physical Asset Existence & SHA-256 Manifest Verification Tests', () {
    final manifestFile = File('assets/quran/mushaf/mushaf_manifest.json');

    test('mushaf_manifest.json exists and is valid', () {
      expect(manifestFile.existsSync(), isTrue);
      final jsonContent = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      expect(jsonContent['total_pages'], equals(604));
      expect(jsonContent['format'], equals('WEBP'));
      expect(jsonContent['compression'], contains('Lossless'));
      final pagesList = jsonContent['pages'] as List<dynamic>;
      expect(pagesList.length, equals(604));
    });

    test('All 604 WebP files exist on disk with correct sizes and valid SHA-256', () {
      final jsonContent = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      final pagesList = jsonContent['pages'] as List<dynamic>;

      for (int i = 0; i < 604; i++) {
        final pageData = pagesList[i] as Map<String, dynamic>;
        final pageNum = pageData['page'] as int;
        final filename = pageData['filename'] as String;
        final expectedSha = pageData['sha256'] as String;
        final expectedBytes = pageData['byte_size'] as int;

        expect(pageNum, equals(i + 1));
        final file = File('assets/quran/mushaf/pages/$filename');
        expect(file.existsSync(), isTrue, reason: 'File $filename should exist');

        final bytes = file.readAsBytesSync();
        expect(bytes.length, equals(expectedBytes));

        final actualSha = sha256.convert(bytes).toString();
        expect(actualSha, equals(expectedSha), reason: 'SHA-256 mismatch for page $pageNum');
      }
    });
  });

  group('3. Actual Asset Decoding & Dimension Verification Tests', () {
    test('Representative WebP assets decode successfully with 1024x1656 dimensions', () async {
      final samplePages = [1, 2, 10, 100, 300, 604];

      for (final page in samplePages) {
        final path = QuranRepository.getMushafPageAssetPath(page);
        final file = File(path);
        expect(file.existsSync(), isTrue);

        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        expect(image.width, equals(1024), reason: 'Page $page width must be 1024');
        expect(image.height, equals(1656), reason: 'Page $page height must be 1656');
        image.dispose();
      }
    });
  });

  group('4. Surah & Juz Metadata Presentation Tests', () {
    setUpAll(() async {
      // Load canonical json datasets into memory
      final surahsRaw = File('assets/quran/quran_surahs.json').readAsStringSync();
      final pagesRaw = File('assets/quran/quran_pages.json').readAsStringSync();
      final juzRaw = File('assets/quran/quran_juz.json').readAsStringSync();

      // Test parsing through JSON structures directly to ensure domain consistency
      expect(jsonDecode(surahsRaw), isA<List>());
      expect(jsonDecode(pagesRaw), isA<List>());
      expect(jsonDecode(juzRaw), isA<List>());
    });

    test('toArabicDigits converts Western numerals to Eastern Arabic correctly', () {
      expect(QuranRepository.toArabicDigits(0), equals('٠'));
      expect(QuranRepository.toArabicDigits(1), equals('١'));
      expect(QuranRepository.toArabicDigits(42), equals('٤٢'));
      expect(QuranRepository.toArabicDigits(604), equals('٦٠٤'));
    });

    test('getSurahForPage resolves canonical Surahs across transitions', () {
      // Page 1: Al-Fatihah
      final s1 = QuranRepository.getSurahForPage(1);
      expect(s1?.nameArabic, equals('الفاتحة'));

      // Page 2: Al-Baqarah
      final s2 = QuranRepository.getSurahForPage(2);
      expect(s2?.nameArabic, equals('البقرة'));

      // Page 50: Al-Imran
      final s50 = QuranRepository.getSurahForPage(50);
      expect(s50?.nameArabic, equals('آل عمران'));

      // Page 604: Last page containing Al-Ikhlas, Al-Falaq, An-Nas
      final s604 = QuranRepository.getSurahForPage(604);
      expect(s604, isNotNull);
    });

    test('saveLastRead and getLastRead persistence roundtrip', () async {
      await QuranRepository.saveLastRead(
        surahNumber: 2,
        ayahNumber: 255,
        pageNumber: 42,
      );

      final lastRead = await QuranRepository.getLastRead();
      expect(lastRead, isNotNull);
      expect(lastRead!['surah'], equals(2));
      expect(lastRead['ayah'], equals(255));
      expect(lastRead['page'], equals(42));
    });
  });

  group('5. Presentation & Dark Mode Color Matrix Inversion Tests', () {
    test('MushafPlate.darkCalligraphyMatrix inverts black to cream while preserving alpha', () {
      const matrix = MushafPlate.darkCalligraphyMatrix;
      expect(matrix.length, equals(20));

      // Test black ink: R=0, G=0, B=0, A=255
      const r = 0.0, g = 0.0, b = 0.0, a = 255.0;
      final rPrime = matrix[0] * r + matrix[1] * g + matrix[2] * b + matrix[3] * a + matrix[4];
      final gPrime = matrix[5] * r + matrix[6] * g + matrix[7] * b + matrix[8] * a + matrix[9];
      final bPrime = matrix[10] * r + matrix[11] * g + matrix[12] * b + matrix[13] * a + matrix[14];
      final aPrime = matrix[15] * r + matrix[16] * g + matrix[17] * b + matrix[18] * a + matrix[19];

      expect(rPrime, equals(235.0), reason: 'Inverted red must be cream/white (235)');
      expect(gPrime, equals(235.0), reason: 'Inverted green must be cream/white (235)');
      expect(bPrime, equals(235.0), reason: 'Inverted blue must be cream/white (235)');
      expect(aPrime, equals(255.0), reason: 'Opaque alpha must remain 255');

      // Test transparent pixel: R=0, G=0, B=0, A=0
      const transparentA = 0.0;
      final transAPrime = matrix[15] * r + matrix[16] * g + matrix[17] * b + matrix[18] * transparentA + matrix[19];
      expect(transAPrime, equals(0.0), reason: 'Transparent alpha must remain 0');
    });

    testWidgets('MushafPlate renders ColorFiltered in dark mode, raw image in light mode', (tester) async {
      // Light mode test
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MushafPlate(pageNumber: 1, isDark: false),
          ),
        ),
      );
      expect(find.byType(ColorFiltered), findsNothing);
      expect(find.byType(Image), findsOneWidget);

      // Dark mode test
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MushafPlate(pageNumber: 1, isDark: true),
          ),
        ),
      );
      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('MushafPage renders surface, metadata header, plate, and metadata footer', (tester) async {
      final controller = TransformationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MushafPage(
              pageNumber: 1,
              isDark: false,
              transformationController: controller,
            ),
          ),
        ),
      );

      expect(find.byType(MushafPageSurface), findsOneWidget);
      expect(find.byType(MushafMetadataHeader), findsOneWidget);
      expect(find.byType(MushafPlate), findsOneWidget);
      expect(find.byType(MushafMetadataFooter), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      controller.dispose();
    });
  });

  group('6. Bounded TransformationController Lifecycle Tests', () {
    testWidgets('TransformationControllers do not accumulate unboundedly across page navigation', (tester) async {
      final pageKey = GlobalKey<MushafPageViewState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MushafPageView(
              key: pageKey,
              initialPage: 1,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final state = pageKey.currentState!;
      expect(state.currentPage, equals(1));
      expect(state.activeTransformControllersCount, inInclusiveRange(1, 3));

      // Jump through multiple disparate pages
      final targetPages = [10, 50, 100, 300, 604];
      for (final page in targetPages) {
        state.jumpToPage(page);
        await tester.pump(const Duration(milliseconds: 100));

        expect(state.currentPage, equals(page));
        // Strict invariant: Bounded window MUST NEVER exceed 3 live controllers
        expect(
          state.activeTransformControllersCount,
          lessThanOrEqualTo(3),
          reason: 'Active controllers count must never exceed 3 at page $page',
        );
      }

      // Final count at page 604
      expect(state.activeTransformControllersCount, lessThanOrEqualTo(3));
    });
  });

  group('7. RTL Navigation & Reader Integration Tests', () {
    testWidgets('MushafPageView strictly enforces RTL text direction', (tester) async {
      int recordedPage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MushafPageView(
              initialPage: 1,
              onPageChanged: (page) => recordedPage = page,
            ),
          ),
        ),
      );

      // Verify Directionality is RTL
      final directionalityWidgets = tester.widgetList<Directionality>(find.byType(Directionality));
      final rtlWidgets = directionalityWidgets.where((d) => d.textDirection == TextDirection.rtl);
      expect(rtlWidgets.isNotEmpty, isTrue);

      expect(find.byType(PageView), findsOneWidget);
      expect(recordedPage, equals(1));
    });

    testWidgets('QuranReaderScreen renders visual Mushaf mode with full navigation', (tester) async {
      const testSurah = SurahModel(
        number: 1,
        nameArabic: 'الفاتحة',
        nameEnglish: 'Al-Fatihah',
        revelationType: 'مكية',
        totalAyahs: 7,
        startPage: 1,
      );

      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: const MaterialApp(
            home: QuranReaderScreen(
              surah: testSurah,
              initialPage: 1,
            ),
          ),
        ),
      );

      expect(find.byType(MushafPageView), findsOneWidget);
      expect(find.text('السابقة'), findsOneWidget);
      expect(find.text('التالية'), findsOneWidget);
      expect(find.byIcon(Icons.find_in_page_outlined), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);

      themeCubit.close();
    });
  });

  group('8. ThemeCubit & Immersive Fullscreen Reader Tests', () {
    test('ThemeCubit emits and persists light, dark, and system modes', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = ThemeCubit();
      expect(cubit.state, equals(ThemeMode.system));

      await cubit.setThemeMode(ThemeMode.light);
      expect(cubit.state, equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('smart_muslim_theme_mode'), equals('light'));

      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, equals(ThemeMode.dark));
      expect(prefs.getString('smart_muslim_theme_mode'), equals('dark'));

      // New cubit instance restores saved dark mode
      final restoredCubit = ThemeCubit();
      await restoredCubit.loadTheme();
      expect(restoredCubit.state, equals(ThemeMode.dark));

      await cubit.close();
      await restoredCubit.close();
    });

    testWidgets('QuranReaderScreen toggles true immersive fullscreen mode', (tester) async {
      const testSurah = SurahModel(
        number: 1,
        nameArabic: 'الفاتحة',
        nameEnglish: 'Al-Fatihah',
        revelationType: 'مكية',
        totalAyahs: 7,
        startPage: 1,
      );

      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: const MaterialApp(
            home: QuranReaderScreen(
              surah: testSurah,
              initialPage: 1,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Normal mode: AppBar, bottom bar, and fullscreen icon are visible
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      expect(find.text('السابقة'), findsOneWidget);
      expect(find.text('التالية'), findsOneWidget);

      // Enter Fullscreen via action button
      await tester.tap(find.byIcon(Icons.fullscreen));
      await tester.pump(const Duration(milliseconds: 100));

      // Immersive mode: AppBar and bottom bar are completely removed
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('السابقة'), findsNothing);
      expect(find.text('التالية'), findsNothing);
      expect(find.byType(MushafPageView), findsOneWidget);

      // Tap on the page exits Fullscreen (wait for gesture arena double-tap timeout)
      await tester.tap(find.byType(MushafPageView));
      await tester.pump(const Duration(milliseconds: 400));

      // Normal mode restored
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('السابقة'), findsOneWidget);
      expect(find.text('التالية'), findsOneWidget);

      await themeCubit.close();
    });

    testWidgets('QuranReaderScreen theme selector opens and switches theme', (tester) async {
      const testSurah = SurahModel(
        number: 1,
        nameArabic: 'الفاتحة',
        nameEnglish: 'Al-Fatihah',
        revelationType: 'مكية',
        totalAyahs: 7,
        startPage: 1,
      );

      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: const MaterialApp(
            home: QuranReaderScreen(
              surah: testSurah,
              initialPage: 1,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on theme action icon
      final themeButtonFinder = find.byIcon(Icons.dark_mode_outlined);
      expect(themeButtonFinder, findsOneWidget);
      await tester.tap(themeButtonFinder);
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.text('مظهر القراءة والسمة'), findsOneWidget);
      expect(find.text('الوضع النهاري (فاتح)'), findsOneWidget);
      expect(find.text('الوضع الليلي (داكن)'), findsOneWidget);
      expect(find.text('تلقائي (حسب مظهر النظام)'), findsOneWidget);

      // Select Dark Mode
      await tester.tap(find.text('الوضع الليلي (داكن)'));
      await tester.pumpAndSettle();

      expect(themeCubit.state, equals(ThemeMode.dark));

      await themeCubit.close();
    });
  });
}
