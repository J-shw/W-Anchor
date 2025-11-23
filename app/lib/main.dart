import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/providers/settings_provider.dart';
import 'package:w_anchor/utils/constants.dart';
import 'package:w_anchor/services/foreground_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:w_anchor/screens/permission_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationService.initialize();
  await notificationService.createNotificationChannel();

  await initializeForegroundService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, AnchorProvider>(
          create: (context) => AnchorProvider(),
          update: (context, settings, anchor) {
            if (anchor == null) return AnchorProvider();
            anchor.updateSettings(settings);
            return anchor;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> initializeForegroundService() async {
  final service = FlutterBackgroundService();
  
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: false,
      notificationChannelId: serviceChannelId,
      initialNotificationTitle: 'W Anchor',
      initialNotificationContent: 'Initializing service...',
      foregroundServiceNotificationId: serviceNotificationId,
    ),
    iosConfiguration: IosConfiguration(), 
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().theme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'W Anchor',
      
      themeMode: switch (themeMode) {
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
        AppTheme.system => ThemeMode.system,
      },
      
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const PermissionScreen(),
    );
  }
}