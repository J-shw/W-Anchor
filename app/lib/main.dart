import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/screens/main_screen.dart';
import 'package:w_anchor/providers/settings_provider.dart';
import 'package:w_anchor/utils/constants.dart';
import 'package:w_anchor/services/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:w_anchor/services/notification_service.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationService.initialize();
  await notificationService.createNotificationChannel();
  
  await Permission.location.request();
  await Permission.locationAlways.request();
  await Permission.notification.request();


  await initializeService();

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

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'W Anchor',
      initialNotificationContent: 'Initializing service...',
      foregroundServiceNotificationId: notificationId,
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
      title: 'W Anchor',
      
      themeMode: switch (themeMode) {
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
        AppTheme.system => ThemeMode.system,
      },
      
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}