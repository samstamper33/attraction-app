import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum GeofenceEvent {
  enter,
  exit,
}

class GeoFencing {
  String geofenceState = 'N/A';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late String geofenceNotificationTitle;
  late String geofenceNotificationBody;
  late Set<String> displayedNotificationIds;
  List<Map<String, dynamic>> userOffers = [];
  Set<String> registeredGeofences = {};
  Function(List<Map<String, dynamic>>) onUserOffersUpdated = (userOffers) {};
  final _userOffersController =
      BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);

  // StreamController<List<Map<String, dynamic>>> _userOffersController =
  //     StreamController<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>> get userOffersStream =>
      _userOffersController.stream;

  // Method to update userOffers and notify listeners
  void updateUserOffers(List<Map<String, dynamic>> updatedUserOffers) {
    userOffers = updatedUserOffers;
    // _userOffersController.add(userOffers);
    _userOffersController
        .add(userOffers); // Notify listeners of the updated list
    print('Updated userOffers: $userOffers');
  }

  // GeoFencing() {
  //   _userOffersController = BehaviorSubject<List<Map<String, dynamic>>>.seeded(
  //     userOffers,
  //   );

  //   // Listen to userOffersStream and print the streamed values
  //   // userOffersStream.listen((offers) {
  //   //   log('Streamed userOffers: $offers');
  //   // });
  // }

  void dispose() {
    _userOffersController.close();
  }

  Future<void> init() async {
    initPlatformState();
    displayedNotificationIds = <String>{};
    await retrieveNotificationIds();
    await retrieveUserOffers();
    print(retrieveNotificationIds().toString());
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
      final String notificationId = locationNotification['id'].toString();
      log(locationNotification.toString());
      if (!displayedNotificationIds.contains(notificationId) &&
          !registeredGeofences.contains(notificationId)) {
        registerGeofence(locationNotification);
        registeredGeofences
            .add(notificationId); // Add registered geofence to set
      }
    }
  }

  void registerGeofence(Map<String, dynamic> locationNotification) {
    final double latitude = locationNotification['position']['latitude'];
    final double longitude = locationNotification['position']['longitude'];
    final double radius = locationNotification['radius'];
    geofenceNotificationBody = locationNotification['message'];
    geofenceNotificationTitle = locationNotification['title'];
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
        handleGeofenceEvent(locationNotification['id'], GeofenceEvent.enter,
            locationNotification);
        isInsideGeofence = true; // Set the flag to true when entering geofence
      } else if (distance > radius && isInsideGeofence) {
        handleGeofenceEvent(locationNotification['id'], GeofenceEvent.exit,
            locationNotification);
        isInsideGeofence = false; // Set the flag to false when exiting geofence
      }
    });
  }

  void handleGeofenceEvent(String id, GeofenceEvent event,
      Map<String, dynamic> locationNotification) {
    print('Geofence Event: ID: $id, Event: $event');

    late String notificationTitle;
    late String notificationBody;

    if (event == GeofenceEvent.enter) {
      notificationTitle = locationNotification['title'];
      notificationBody = locationNotification['message'];
      userOffers.add(locationNotification);
      storeUserOffers();
      GeoFencing().updateUserOffers(userOffers);
      _userOffersController
          .add(userOffers); // Notify listeners of the updated list
      print('This is how many offers you have - ${userOffers.length}');
    } else if (event == GeofenceEvent.exit) {
      notificationTitle = 'Geofence Exited';
      notificationBody = 'You\'ve now exited the geofence.';
    }

    // Check if the notification with the ID has already been displayed
    if (!displayedNotificationIds.contains(id)) {
      displayNotification(id, notificationTitle, notificationBody);
      displayedNotificationIds.add(id);
    } else {
      print('Notification already shown');
    }

    // Store dismissed notification in the separate list
    if (event == GeofenceEvent.enter) {
      userOffers.add(locationNotification);
      storeUserOffers();
      GeoFencing().updateUserOffers(userOffers);
      _userOffersController
          .add(userOffers); // Notify listeners of the updated list
      print('This is how many offers you have - ${userOffers.length}');

      // Notify the callback function with the updated userOffers
      if (onUserOffersUpdated != null) {
        onUserOffersUpdated(userOffers);
      }
    }
  }

  void storeNotificationId(String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String>? storedIds =
        prefs.getStringList('displayedNotificationIds')?.toSet();
    storedIds ??= <String>{};
    storedIds.add(notificationId);
    await prefs.setStringList('displayedNotificationIds', storedIds.toList());
    displayedNotificationIds =
        storedIds; // Update the displayedNotificationIds set
    print('Notification stored: $notificationId');
  }

  Future<void> retrieveNotificationIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedIds = prefs.getStringList('displayedNotificationIds');
    if (storedIds != null) {
      displayedNotificationIds = storedIds.toSet();
      print('Retrieved notification IDs: $displayedNotificationIds');
    }
  }

  Future<void> storeUserOffers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userOffers', jsonEncode(userOffers));
    print('User offers stored');
  }

  Future<void> retrieveUserOffers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserOffers = prefs.getString('userOffers');
    if (storedUserOffers != null) {
      userOffers =
          List<Map<String, dynamic>>.from(jsonDecode(storedUserOffers));
      _userOffersController
          .add(userOffers); // Notify listeners of the updated list
      print('Retrieved user offers: $userOffers');
    }
  }

  Future<int?> getNotificationId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? notificationId = prefs.getInt('notificationId');
    return notificationId;
  }

  void displayNotification(String id, String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    if (!displayedNotificationIds.contains(id)) {
      displayedNotificationIds
          .add(id); // Add the ID to the set before displaying the notification
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );
      storeNotificationId(id); // Store the updated set with the new ID
      print('Notification stored after shown: $id');
    } else {
      print('Notification already shown');
    }
  }
}
