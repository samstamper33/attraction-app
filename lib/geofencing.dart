import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum GeofenceEvent {
  enter,
  exit,
}

class GeoFencing {
  String geofenceState = 'N/A';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late String notificationTitle;
  late String geofenceNotificationBody;

  void init() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Request permission for notifications
    var notificationSettings = await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    print('Initializing Geofencing Manager...');
    await Geolocator.requestPermission();
    print('Initialization done');

    // Initialize FlutterLocalNotificationsPlugin
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void registerLocationNotifications(
      List<Map<String, dynamic>> locationNotifications) {
    for (var locationNotification in locationNotifications) {
      registerGeofence(locationNotification);
    }
  }

  void registerGeofence(Map<String, dynamic> locationNotification) {
    final double latitude = locationNotification['position']['latitude'];
    final double longitude = locationNotification['position']['longitude'];
    final double radius = locationNotification['radius'];
    geofenceNotificationBody = locationNotification['message'];
    bool isInsideGeofence = false; // Flag to track geofence state

    print("Attempting to register: ${locationNotification['id']}");

    Geolocator.getPositionStream().listen((Position position) {
      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        latitude,
        longitude,
      );

      if (distance <= radius && !isInsideGeofence) {
        handleGeofenceEvent(locationNotification['id'], GeofenceEvent.enter);
        isInsideGeofence = true; // Set the flag to true when entering geofence
      } else if (distance > radius && isInsideGeofence) {
        handleGeofenceEvent(locationNotification['id'], GeofenceEvent.exit);
        isInsideGeofence = false; // Set the flag to false when exiting geofence
      }
    });
  }

  void handleGeofenceEvent(String id, GeofenceEvent event) {
    print('Geofence Event: ID: $id, Event: $event');

    late String notificationTitle;
    late String notificationBody;

    if (event == GeofenceEvent.enter) {
      notificationTitle = geofenceNotificationBody;
      notificationBody = "You're gonna love it here!";
    } else if (event == GeofenceEvent.exit) {
      notificationTitle = 'Geofence Exited';
      notificationBody = 'You\'ve now exited the geofence.';
    }

    displayNotification(notificationTitle, notificationBody);
  }

  void displayNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Channel',
      // 'Channel for geofence notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
