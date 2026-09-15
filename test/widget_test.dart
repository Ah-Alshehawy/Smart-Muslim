import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/core/theme/app_theme.dart';
import 'package:smart_muslim/features/splash/splash_screen.dart';
import 'package:smart_muslim/features/about/about_contact_screen.dart';

void main() {
  testWidgets('Smart Muslim Splash Screen rendering and verbatim dedication test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify title and verbatim dedication text presence
    expect(find.text('المسلم الذكي'), findsOneWidget);
    expect(find.text('صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ'), findsOneWidget);
    expect(find.text('Developed by: Eng. Ahmed Alshehawy'), findsOneWidget);

    // Replace tree to dispose splash screen cleanly before timer expires
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('About & Contact Screen renders developer and app info', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AboutContactScreen(),
      ),
    );

    await tester.pump();

    expect(find.text('عن التطبيق والاتصال بنا'), findsWidgets);
    expect(find.text('المسلم الذكي | Smart Muslim'), findsWidgets);
    expect(find.text('مبادئ التطبيق والخصوصية'), findsWidgets);
    expect(find.text('مجاني بالكامل وبدون إعلانات'), findsWidgets);
    expect(find.text('خصوصية تامة وبدون تتبع'), findsWidgets);
  });
}
