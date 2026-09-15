import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/update_service.dart';
import 'features/update/presentation/pages/update_required_page.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Update Service and check status
  await UpdateService.initialize();
  final updateStatus = await UpdateService.checkUpdateStatus();

  // Force upright orientation & status bar styling
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // If the app is too old (Kill-Switch), block access
  if (updateStatus == UpdateStatus.forced) {
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UpdateRequiredPage(),
    ));
    return;
  }

  // Otherwise, run the normal app
  runApp(const SmartMuslimApp());
}
