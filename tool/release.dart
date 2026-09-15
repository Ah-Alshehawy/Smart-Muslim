// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Future<int> runStep(String description, String executable, List<String> arguments) async {
  print('\n>>> $description');
  print('Command: $executable ${arguments.join(' ')}');

  final process = await Process.start(
    executable,
    arguments,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    print('FAILED with exit code $exitCode');
  }
  return exitCode;
}

void main(List<String> args) async {
  print('====================================================');
  print('SMART MUSLIM — AUTOMATED BUILD & RELEASE PIPELINE');
  print('====================================================');

  String channel = 'dev';
  String version = '0.2.0-dev.1';
  int buildNumber = 2;
  String mode = 'release'; // 'release' or 'debug'

  for (final arg in args) {
    if (arg.startsWith('--channel=')) {
      channel = arg.split('=')[1];
    } else if (arg.startsWith('--version=')) {
      version = arg.split('=')[1];
    } else if (arg.startsWith('--build-number=')) {
      buildNumber = int.tryParse(arg.split('=')[1]) ?? 2;
    } else if (arg.startsWith('--mode=')) {
      mode = arg.split('=')[1].toLowerCase();
    }
  }

  print('Target Channel     : $channel');
  print('Target Version     : $version');
  print('Target Build Number: $buildNumber');
  print('Build Mode         : $mode');
  print('Timestamp          : ${DateTime.now().toIso8601String()}');
  print('----------------------------------------------------');

  final flutterBin = Platform.isWindows ? 'C:\\flutter\\bin\\flutter.bat' : 'flutter';

  // Step 1: flutter pub get
  final codePub = await runStep('[1/5] Resolving dependencies...', flutterBin, ['pub', 'get']);
  if (codePub != 0) exit(codePub);

  // Step 2: flutter analyze
  final codeAnalyze = await runStep('[2/5] Running static analysis...', flutterBin, ['analyze']);
  if (codeAnalyze != 0) exit(codeAnalyze);

  // Step 3: flutter test
  final codeTest = await runStep('[3/5] Running test suites...', flutterBin, ['test']);
  if (codeTest != 0) exit(codeTest);

  // Step 4: flutter build apk
  final buildArgs = mode == 'debug'
      ? ['build', 'apk', '--debug', '--build-name=$version', '--build-number=$buildNumber']
      : ['build', 'apk', '--release', '--build-name=$version', '--build-number=$buildNumber'];

  final codeBuild = await runStep(
    '[4/5] Building $mode APK for Android...',
    flutterBin,
    buildArgs,
  );
  if (codeBuild != 0) exit(codeBuild);

  // Step 5: Checksum, size, packaging & manifest
  print('\n>>> [5/5] Calculating artifact checksum and packaging release...');
  final apkSource = mode == 'debug'
      ? File('build/app/outputs/flutter-apk/app-debug.apk')
      : File('build/app/outputs/flutter-apk/app-release.apk');

  if (!apkSource.existsSync()) {
    print('ERROR: Built APK file not found at ${apkSource.path}');
    exit(1);
  }

  final bytes = apkSource.readAsBytesSync();
  final sha256Digest = sha256.convert(bytes).toString().toUpperCase();
  final sizeBytes = bytes.length;
  final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(2);

  print('APK Size   : $sizeMB MB ($sizeBytes bytes)');
  print('SHA-256    : $sha256Digest');

  final releaseDir = Directory('releases/$channel');
  if (!releaseDir.existsSync()) {
    releaseDir.createSync(recursive: true);
  }

  final artifactFileName = mode == 'debug'
      ? 'smart-muslim-$version-debug.apk'
      : 'smart-muslim-$version.apk';
  final shaFileName = mode == 'debug'
      ? 'smart-muslim-$version-debug.sha256'
      : 'smart-muslim-$version.sha256';
  final manifestFileName = mode == 'debug'
      ? 'smart-muslim-$version-debug-manifest.json'
      : 'smart-muslim-$version-manifest.json';

  final targetApkPath = 'releases/$channel/$artifactFileName';
  final targetShaPath = 'releases/$channel/$shaFileName';
  final targetManifestPath = 'releases/$channel/$manifestFileName';

  apkSource.copySync(targetApkPath);
  File(targetShaPath).writeAsStringSync(sha256Digest);

  final manifestData = {
    'appName': 'Smart Muslim',
    'appNameArabic': 'المسلم الذكي',
    'version': version,
    'buildNumber': buildNumber,
    'buildMode': mode,
    'channel': channel,
    'timestamp': DateTime.now().toIso8601String(),
    'artifact': artifactFileName,
    'artifactPath': targetApkPath,
    'fileSizeBytes': sizeBytes,
    'fileSizeMB': sizeMB,
    'sha256': sha256Digest,
    'qaStatus': {
      'flutterAnalyze': 'PASS (0 issues)',
      'flutterTest': 'PASS',
      'physicalVerification': 'VERIFIED_AWAITING_DEVICE',
    },
    'coreFeatures': [
      'Astronomical Prayer Calculation with persistent settings',
      '27 Egyptian Governorates + Arab and World Cities',
      'Live Qibla Compass with Magnetometer sensor stream & smoothing',
      'Canonical Holy Quran 114 Surahs / 6236 Ayahs (rn0x/Quran-Data integration)',
      'Authentic 604-page Madinah Mushaf Page Bounds & 30 Juz structure',
      '3 Quran Reading Modes: Text (Verse-By-Verse), Mushaf Page (1-604), Compact',
      'Hadith Library with 42 Nawawi + Sahih selections and gradings',
      'Authenticated Athkar with interactive counter',
      'Per-prayer Adhan sound customization & in-app Test Audio',
      'Dedicated Contact Us screen for Smart Business Solutions',
    ],
  };

  File(targetManifestPath).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifestData),
  );

  print('\n====================================================');
  print('BUILD PIPELINE COMPLETED SUCCESSFULLY!');
  print('Artifact APK      : $targetApkPath ($sizeMB MB)');
  print('SHA-256 Hash      : $sha256Digest');
  print('Release Manifest  : $targetManifestPath');
  print('====================================================');
}
