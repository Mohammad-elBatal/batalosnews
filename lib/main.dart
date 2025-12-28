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

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {

    switch (taskName) {
      case 'simpleTask':
        await BackgroundNewsService().checkAndNotify();
        break;
    }

    return true;
  });
}


void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationServices().initialize();
  await FirebaseApi().initiNotifications();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerOneOffTask(
    "1",
    "simpleTask",
    inputData: <String, dynamic>{
      'key': 'value',
    },
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initiNotifications(); 
  await loadConfig();
  registerHTTPService();
  runApp(const MyApp());
}

Future<void> loadConfig() async {
  String configContent =
      await rootBundle.loadString("assets/config/main.json");
  Map configData = jsonDecode(configContent);
  GetIt.instance.registerSingleton<AppConfig>(
    AppConfig(NEWS_BASE_API_URL: configData["NEWS_BASE_API_URL"], NEWS_API_KEY: configData["NEWS_API_KEY"]),
  );
}

void registerHTTPService() {
  GetIt.instance.registerSingleton<HTTPService>(HTTPService());
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