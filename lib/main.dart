import 'dart:convert';
import 'package:batalosnews/api/firebase_api.dart';
import 'package:batalosnews/firebase_options.dart';
import 'package:batalosnews/services/http_service.dart';
import 'package:batalosnews/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:batalosnews/pages/homepage.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:batalosnews/models/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:batalosnews/services/background_news_service.dart';
Future<void> setupDependencies() async {
  if (!GetIt.instance.isRegistered<AppConfig>()) {
      String configContent = await rootBundle.loadString("assets/config/main.json");
      Map configData = jsonDecode(configContent);
      GetIt.instance.registerSingleton<AppConfig>(
        AppConfig(
          NEWS_BASE_API_URL: configData["NEWS_BASE_API_URL"], 
          NEWS_API_KEY: configData["NEWS_API_KEY"]
        ),
      );
  }
  if (!GetIt.instance.isRegistered<HTTPService>()) {
    GetIt.instance.registerSingleton<HTTPService>(HTTPService());
  }
}
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); 

    try {
      await setupDependencies();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      if (taskName == 'simpleTask') {
        final backgroundService = BackgroundNewsService();
        await backgroundService.checkAndNotify();
      }
      if (taskName == 'simpleOneOffTask') {
        Future.delayed(const Duration(seconds: 120));
        final backgroundService = BackgroundNewsService();
        await backgroundService.checkAndNotify();
      }
      return Future.value(true);
    } catch (e) {
      print("❌ Background Task Failed: $e");
      return Future.value(false);
    }
  });
}
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initiNotifications();
  NotificationServices().initialize(isBackground: false);
  await setupDependencies();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerOneOffTask(
    "0",
    "simpleOneOffTask",
    inputData: <String, dynamic>{
      'key': 'value',
    },
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  Workmanager().registerPeriodicTask(
    "1",
    "simpleTask",
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batalos News',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: Homepage(),
    );
  }
}