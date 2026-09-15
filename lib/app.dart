import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';
import 'features/splash/splash_screen.dart';

class SmartMuslimApp extends StatelessWidget {
  const SmartMuslimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit()..loadTheme(),
        ),
        BlocProvider<PrayerBloc>(
          create: (context) => PrayerBloc(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'المسلم الذكي — Smart Muslim',
            debugShowCheckedModeBanner: false,

            // RTL & Localization Setup
            locale: const Locale('ar'),
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Light & Dark Themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // Entry point: Splash Screen with verbatim dedication
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
