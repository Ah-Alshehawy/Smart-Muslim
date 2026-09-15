import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_muslim/features/adhkar/data/tasbih_preferences.dart';
import 'package:smart_muslim/features/adhkar/domain/tasbih_alert_mode.dart';
import 'package:smart_muslim/features/adhkar/domain/tasbih_alert_service.dart';
import 'package:smart_muslim/features/adhkar/presentation/screens/tasbeeh_counter_screen.dart';
import 'package:smart_muslim/l10n/app_localizations.dart';

/// Test double for [TasbihAlertService] tracking calls deterministically.
class MockTasbihAlertService implements TasbihAlertService {
  final List<TasbihAlertMode> triggeredAlerts = [];
  int vibrationTriggers = 0;
  int soundTriggers = 0;

  @override
  Future<void> triggerAlert(TasbihAlertMode mode) async {
    triggeredAlerts.add(mode);
    switch (mode) {
      case TasbihAlertMode.vibration:
        vibrationTriggers++;
        break;
      case TasbihAlertMode.sound:
        soundTriggers++;
        break;
      case TasbihAlertMode.soundAndVibration:
        vibrationTriggers++;
        soundTriggers++;
        break;
      case TasbihAlertMode.off:
        break;
    }
  }

  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. TasbihAlertMode Transitions & Defaults', () {
    test('Initial default value is vibration', () {
      const mode = TasbihAlertMode.vibration;
      expect(mode, equals(TasbihAlertMode.vibration));
    });

    test('Cycling follows exact sequence: vibration -> sound -> soundAndVibration -> off -> vibration', () {
      var mode = TasbihAlertMode.vibration;

      mode = mode.next;
      expect(mode, equals(TasbihAlertMode.sound));

      mode = mode.next;
      expect(mode, equals(TasbihAlertMode.soundAndVibration));

      mode = mode.next;
      expect(mode, equals(TasbihAlertMode.off));

      mode = mode.next;
      expect(mode, equals(TasbihAlertMode.vibration));
    });

    test('String deserialization falls back safely to vibration for null or invalid data', () {
      expect(TasbihAlertMode.fromString(null), equals(TasbihAlertMode.vibration));
      expect(TasbihAlertMode.fromString(''), equals(TasbihAlertMode.vibration));
      expect(TasbihAlertMode.fromString('unknown_value'), equals(TasbihAlertMode.vibration));
      expect(TasbihAlertMode.fromString('sound'), equals(TasbihAlertMode.sound));
      expect(TasbihAlertMode.fromString('soundAndVibration'), equals(TasbihAlertMode.soundAndVibration));
      expect(TasbihAlertMode.fromString('off'), equals(TasbihAlertMode.off));
    });
  });

  group('2. TasbihPreferences Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Returns vibration when no preference has been saved yet', () async {
      final prefs = TasbihPreferences(await SharedPreferences.getInstance());
      final mode = await prefs.getAlertMode();
      expect(mode, equals(TasbihAlertMode.vibration));
    });

    test('Persists and restores vibration mode', () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      final prefs = TasbihPreferences(sharedPrefs);
      await prefs.setAlertMode(TasbihAlertMode.vibration);

      final reloaded = await prefs.getAlertMode();
      expect(reloaded, equals(TasbihAlertMode.vibration));
    });

    test('Persists and restores sound mode', () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      final prefs = TasbihPreferences(sharedPrefs);
      await prefs.setAlertMode(TasbihAlertMode.sound);

      final reloaded = await prefs.getAlertMode();
      expect(reloaded, equals(TasbihAlertMode.sound));
    });

    test('Persists and restores soundAndVibration mode', () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      final prefs = TasbihPreferences(sharedPrefs);
      await prefs.setAlertMode(TasbihAlertMode.soundAndVibration);

      final reloaded = await prefs.getAlertMode();
      expect(reloaded, equals(TasbihAlertMode.soundAndVibration));
    });

    test('Persists and restores off mode', () async {
      final sharedPrefs = await SharedPreferences.getInstance();
      final prefs = TasbihPreferences(sharedPrefs);
      await prefs.setAlertMode(TasbihAlertMode.off);

      final reloaded = await prefs.getAlertMode();
      expect(reloaded, equals(TasbihAlertMode.off));
    });
  });

  group('3. Alert Playback Mode Execution Tests', () {
    late MockTasbihAlertService mockService;

    setUp(() {
      mockService = MockTasbihAlertService();
    });

    test('Mode vibration: vibration incremented, sound untouched', () async {
      await mockService.triggerAlert(TasbihAlertMode.vibration);
      expect(mockService.vibrationTriggers, equals(1));
      expect(mockService.soundTriggers, equals(0));
    });

    test('Mode sound: sound incremented, vibration untouched', () async {
      await mockService.triggerAlert(TasbihAlertMode.sound);
      expect(mockService.vibrationTriggers, equals(0));
      expect(mockService.soundTriggers, equals(1));
    });

    test('Mode soundAndVibration: both incremented', () async {
      await mockService.triggerAlert(TasbihAlertMode.soundAndVibration);
      expect(mockService.vibrationTriggers, equals(1));
      expect(mockService.soundTriggers, equals(1));
    });

    test('Mode off: neither incremented', () async {
      await mockService.triggerAlert(TasbihAlertMode.off);
      expect(mockService.vibrationTriggers, equals(0));
      expect(mockService.soundTriggers, equals(0));
    });
  });

  group('4. Bundled Audio Asset Integrity & Provenance', () {
    test('tasbih_beep.wav exists on disk with minimal file size under 60 KB', () {
      final file = File('assets/audio/tasbih_beep.wav');
      expect(file.existsSync(), isTrue, reason: 'assets/audio/tasbih_beep.wav must exist');
      final length = file.lengthSync();
      expect(length, greaterThan(100));
      expect(length, lessThan(60 * 1024), reason: 'Audio asset must be minimal (~44 KB)');
    });

    test('tasbih_beep.wav is a valid RIFF WAVE file', () {
      final bytes = File('assets/audio/tasbih_beep.wav').readAsBytesSync();
      // 'RIFF' header
      expect(String.fromCharCodes(bytes.sublist(0, 4)), equals('RIFF'));
      // 'WAVE' format
      expect(String.fromCharCodes(bytes.sublist(8, 12)), equals('WAVE'));
    });
  });

  group('5. TasbeehCounterScreen Widget & Interaction Tests', () {
    late MockTasbihAlertService mockService;
    late TasbihPreferences preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = TasbihPreferences(await SharedPreferences.getInstance());
      mockService = MockTasbihAlertService();
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: TasbeehCounterScreen(
          preferences: preferences,
          alertService: mockService,
        ),
      );
    }

    testWidgets('Renders circular alert button in AppBar and old top-left reset button is removed', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Circular alert button exists
      expect(find.byKey(const Key('tasbih_alert_mode_button')), findsOneWidget);

      // Default state icon is vibration
      expect(find.byKey(const Key('tasbih_alert_icon_vibration')), findsOneWidget);

      // Top-left reset button is removed: only one reset button ('تصفير') remains at the bottom
      expect(find.text('تصفير'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'تصفير'), findsOneWidget);
    });

    testWidgets('Tapping circular button cycles through all 4 states and updates persistence', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final button = find.byKey(const Key('tasbih_alert_mode_button'));

      // 1. Initial state: Vibration
      expect(find.byKey(const Key('tasbih_alert_icon_vibration')), findsOneWidget);

      // Tap 1 -> Sound
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tasbih_alert_icon_sound')), findsOneWidget);
      expect(await preferences.getAlertMode(), equals(TasbihAlertMode.sound));

      // Tap 2 -> Sound + Vibration
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tasbih_alert_icon_sound_and_vibration')), findsOneWidget);
      expect(await preferences.getAlertMode(), equals(TasbihAlertMode.soundAndVibration));

      // Tap 3 -> Off
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tasbih_alert_icon_off')), findsOneWidget);
      expect(await preferences.getAlertMode(), equals(TasbihAlertMode.off));

      // Tap 4 -> Vibration
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tasbih_alert_icon_vibration')), findsOneWidget);
      expect(await preferences.getAlertMode(), equals(TasbihAlertMode.vibration));
    });

    testWidgets('Target 33: exactly one completion alert fires upon reaching 33', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final counterGesture = find.byKey(const Key('tasbih_counter_tap_target'));

      // Increment 32 times: no alerts
      for (int i = 0; i < 32; i++) {
        await tester.tap(counterGesture);
        await tester.pump();
      }
      expect(mockService.triggeredAlerts.length, equals(0));
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('32'));

      // 33rd tap: target reached!
      await tester.tap(counterGesture);
      await tester.pump();

      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('33'));
      expect(mockService.triggeredAlerts.length, equals(1));
      expect(mockService.triggeredAlerts.first, equals(TasbihAlertMode.vibration));
    });

    testWidgets('Next tap wraps counter to 1 and starts new cycle without immediate alert', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final counterGesture = find.byKey(const Key('tasbih_counter_tap_target'));

      // Reach 33
      for (int i = 0; i < 33; i++) {
        await tester.tap(counterGesture);
        await tester.pump();
      }
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('33'));
      expect(mockService.triggeredAlerts.length, equals(1));

      // Tap 34th time: wraps to 1 for cycle 2
      await tester.tap(counterGesture);
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('1'));
      // Still only 1 alert from the previous completion
      expect(mockService.triggeredAlerts.length, equals(1));

      // Advance to 33 in cycle 2
      for (int i = 1; i < 33; i++) {
        await tester.tap(counterGesture);
        await tester.pump();
      }
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('33'));
      // Second completion event fired
      expect(mockService.triggeredAlerts.length, equals(2));
    });

    testWidgets('Target switching to 100 triggers alert at 100', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select 100 target
      await tester.tap(find.text('100 مرة'));
      await tester.pumpAndSettle();

      final counterGesture = find.byKey(const Key('tasbih_counter_tap_target'));
      for (int i = 0; i < 99; i++) {
        await tester.tap(counterGesture);
        await tester.pump();
      }
      expect(mockService.triggeredAlerts.length, equals(0));

      // 100th tap: target reached
      await tester.tap(counterGesture);
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('100'));
      expect(mockService.triggeredAlerts.length, equals(1));
    });

    testWidgets('Target switching to 1000 triggers alert at 1000', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select 1000 target
      await tester.tap(find.text('1000 مرة'));
      await tester.pumpAndSettle();

      final counterGesture = find.byKey(const Key('tasbih_counter_tap_target'));
      for (int i = 0; i < 999; i++) {
        await tester.tap(counterGesture);
        await tester.pump();
      }
      expect(mockService.triggeredAlerts.length, equals(0));

      // 1000th tap: target reached
      await tester.tap(counterGesture);
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('1000'));
      expect(mockService.triggeredAlerts.length, equals(1));
    });

    testWidgets('Reset button resets counter to 0 with NO completion alert', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final counterGesture = find.byKey(const Key('tasbih_counter_tap_target'));
      // Increment 10 times
      for (int i = 0; i < 10; i++) {
        await tester.tap(counterGesture);
        await tester.pump();
      }
      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('10'));

      // Tap Reset button
      await tester.tap(find.widgetWithText(ElevatedButton, 'تصفير'));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.byKey(const Key('tasbih_counter_value_text'))).data, equals('0'));
      // No alert triggered
      expect(mockService.triggeredAlerts.length, equals(0));
    });
  });
}
