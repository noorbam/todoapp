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
import 'package:google_fonts/google_fonts.dart';

/// KidQuest — Gamified To-Do App for Children
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
      title: 'KidQuest',
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
      ],
      child: const KidQuestApp(),
    ),
  );
}

class KidQuestApp extends StatelessWidget {
  const KidQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LanguageProvider>(
      builder: (context, authProvider, langProvider, _) {
        final isChild = authProvider.currentUser?.isChild ?? false;
        final theme = isChild ? AppTheme.childTheme : AppTheme.parentTheme;

        return MaterialApp(
          title: 'KidQuest',
          debugShowCheckedModeBanner: false,
          theme: theme.copyWith(
            textTheme: langProvider.isArabic 
              ? GoogleFonts.cairoTextTheme(theme.textTheme)
              : GoogleFonts.nunitoTextTheme(theme.textTheme),
          ),
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
