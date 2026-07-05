import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'core/constants/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/child_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hero Mission — Gamified To-Do App for Children
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Window Manager for Desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(375, 812),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Hero Mission',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setResizable(false);
    });
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
      ],
      child: const HeroMissionApp(),
    ),
  );
}

class HeroMissionApp extends StatelessWidget {
  const HeroMissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, LanguageProvider, ThemeProvider>(
      builder: (context, authProvider, langProvider, themeProvider, _) {
        final isChild = authProvider.currentUser?.isChild ?? false;
        final isDark = themeProvider.isDarkMode;
        final theme = isChild ? AppTheme.childTheme : AppTheme.parentTheme;
        final darkTheme = AppTheme.darkTheme;

        return MaterialApp(
          title: langProvider.isArabic ? 'مهمة البطل' : 'Hero Mission',
          debugShowCheckedModeBanner: false,
          theme: theme.copyWith(
            textTheme: GoogleFonts.cairoTextTheme(theme.textTheme),
          ),
          darkTheme: darkTheme.copyWith(
            textTheme: GoogleFonts.cairoTextTheme(darkTheme.textTheme),
          ),
          themeMode: themeProvider.themeMode,
          locale: langProvider.currentLocale,
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRouter.splash,
          routes: AppRouter.routes,
        );
      },
    );
  }
}
