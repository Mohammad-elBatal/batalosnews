import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebbaseMessaging = FirebaseMessaging.instance;
  Future<void> initiNotifications() async {
    await _firebbaseMessaging.requestPermission();
    String? token = await _firebbaseMessaging.getToken();
    print("Firebase Token: $token");
  }
}