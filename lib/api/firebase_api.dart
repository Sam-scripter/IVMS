import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/main.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final FCMToken = await _firebaseMessaging.getToken();

    print('FCM TOKEN: $FCMToken');

    // initPushNotifications();
  }

  // void handleMessage(RemoteMessage? message) {
  //   if (message == null) return;
  //
  //   navigatorkey.currentState?.pushNamed('/notifications', arguments: message);
  // }

  // Future initPushNotifications() async {
  //   //handle notifications for if the app was terminated and now opened
  //   _firebaseMessaging.getInitialMessage().then(handleMessage);
  //
  //   //handle notifications for when the message opens the app
  //   FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  // }
}
