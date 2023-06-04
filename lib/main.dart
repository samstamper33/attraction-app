import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
// import 'dart:js';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:passmate/attraction_mapbox.dart';
import 'user_offers_provider.dart';
import 'package:passmate/discover.dart';
import 'package:passmate/attraction_navigator.dart';
import 'package:passmate/attraction_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passmate/permissions-screen.dart';
import 'package:http/http.dart' as http;
import 'package:passmate/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("handled background message");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $fcmToken');

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  final userOffersProvider = UserOffersProvider();

  bool isInitialRouteUpdated = false;

  // Initialize flutter_background_geolocation
  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    // Handle the background location update
    // Access location.latitude and location.longitude for the coordinates
  });

  bg.BackgroundGeolocation.ready(bg.Config(
    desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
    distanceFilter: 10,
    stopOnTerminate: false,
    startOnBoot: true,
  )).then((bg.State state) {
    if (!state.enabled) {
      // Start background geolocation
      bg.BackgroundGeolocation.start();
    }
  });

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) {
          if (!isInitialRouteUpdated) {
            updateInitialRoute(context);
            isInitialRouteUpdated = true;
          }

          return MyApp();
        },
      ),
      routes: {
        '/permissions': (context) => const PermissionsScreen(),
        '/discover': (context) => const DiscoverPage(),
        '/attraction': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)
              ?.settings
              .arguments as Map<String, dynamic>;

          return AttractionNavigatorPage(
            attractionId: arguments['attractionId'] as String,
            image: arguments['image'] as String,
            name: arguments['name'] as String,
            tileId: arguments['tileId'] as String,
            accent: arguments['accent'] as String,
            logo: arguments['logo'] as String,
            orientation: arguments['orientation'] as double,
            boundsEast: arguments['boundsEast'] as double,
            boundsNorth: arguments['boundsNorth'] as double,
            boundsSouth: arguments['boundsSouth'] as double,
            boundsWest: arguments['boundsWest'] as double,
            longitude: arguments['longitude'] as double,
            latitude: arguments['latitude'] as double,
            isLoading: false,
          );
        },
      },
    ),
  );
}

Future<void> updateInitialRoute(BuildContext context) async {
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    Navigator.pushNamed(context, '/'); // Navigates to the initial route
  } else if (permission == LocationPermission.denied) {
    final isFirstTime = await isFirstTimeOpeningApp();
    if (isFirstTime) {
      Navigator.pushNamed(
          context, '/permissions'); // Navigates to the permission screen
      await markFirstTimeOpeningApp();
    } else {
      Navigator.pushNamed(
          context, '/discover'); // Navigates to the discover page
    }
  } else {
    try {
      final position = await Geolocator.getCurrentPosition();
      final attractions = await getAttractionsList();

      final attractionNearby = findAttractionNearby(attractions, position);

      if (attractionNearby != null) {
        navigateToAttraction(context, attractionNearby);
        print(
            'Attraction found nearby: ${attractionNearby['attractionImage']}');
      } else {
        Navigator.pushNamed(context, '/discover');
        print('No Attraction found nearby');
      }
    } catch (e) {
      print('Error getting location: $e');
      // Handle the error here or navigate to a suitable screen
    }
  }
}

Future<bool> isFirstTimeOpeningApp() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;
  return isFirstTime;
}

Future<void> markFirstTimeOpeningApp() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', false);
}

void navigateToAttraction(
  BuildContext context,
  Map<String, dynamic> attraction,
) {
  final attractionId = attraction['id'] as String?;
  final image = attraction['attractionImage'] as String?;
  final name = attraction['name'] as String?;
  final tileId = attraction['rasterTileId'] as String?;
  final accent = attraction['accentColorHex'] as String?;
  final logo = attraction['attractionLogo'] as String?;
  final orientation = attraction['mapOrientation'] as double?;
  final boundsEast = attraction['mapBounds']['east'] as double?;
  final boundsNorth = attraction['mapBounds']['north'] as double?;
  final boundsSouth = attraction['mapBounds']['south'] as double?;
  final boundsWest = attraction['mapBounds']['west'] as double?;
  final longitude = attraction['longitude'] as double?;
  final latitude = attraction['latitude'] as double?;

  Navigator.pushNamed(
    context,
    '/attraction',
    arguments: {
      'attractionId': attractionId,
      'image': image,
      'name': name,
      'tileId': tileId,
      'accent': accent,
      'logo': logo,
      'orientation': orientation,
      'boundsEast': boundsEast,
      'boundsNorth': boundsNorth,
      'boundsSouth': boundsSouth,
      'boundsWest': boundsWest,
      'longitude': longitude,
      'latitude': latitude,
    },
  );
}

Future<List<dynamic>> getAttractionsList() async {
  const url = 'https://passmatetest1.azurewebsites.net/api/Attraction';
  final basicAuth = base64.encode(utf8.encode('passmateapp:passmateapppass'));

  final response = await http.get(
    Uri.parse(url),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic $basicAuth',
      HttpHeaders.acceptHeader: 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> attractionsJson = json.decode(response.body);
    log(response.body);
    return attractionsJson;
  } else {
    throw Exception('Failed to fetch attractions');
  }
}

Map<String, dynamic>? findAttractionNearby(
  List<dynamic> attractions,
  Position position,
) {
  final double userLatitude = position.latitude;
  final double userLongitude = position.longitude;
  const double threshold = 0.007;

  for (final attraction in attractions) {
    final double attractionLatitude = attraction['latitude'];
    final double attractionLongitude = attraction['longitude'];

    final double latitudeDifference = (userLatitude - attractionLatitude).abs();
    final double longitudeDifference =
        (userLongitude - attractionLongitude).abs();

    if (latitudeDifference <= threshold && longitudeDifference <= threshold) {
      return attraction;
    }
  }

  return null;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      title: 'Passmate',
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      routes: {
        '/': (context) {
          return FutureBuilder<String>(
            future: _getInitialRoute(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                final initialRoute = snapshot.data;
                return Navigator(
                  pages: [
                    if (initialRoute == '/discover')
                      const MaterialPage(child: DiscoverPage())
                    else
                      MaterialPage(
                        child: Builder(
                          builder: (BuildContext context) {
                            return MyApp();
                          },
                        ),
                      ),
                  ],
                  onPopPage: (route, result) => route.didPop(result),
                );
              }
            },
          );
        },
        '/permissions': (context) => const PermissionsScreen(),
        '/discover': (context) => const DiscoverPage(),
        '/attraction': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)
              ?.settings
              .arguments as Map<String, dynamic>;

          return AttractionNavigatorPage(
            attractionId: arguments['attractionId'] as String,
            image: arguments['image'] as String,
            name: arguments['name'] as String,
            tileId: arguments['tileId'] as String,
            accent: arguments['accent'] as String,
            logo: arguments['logo'] as String,
            orientation: arguments['orientation'] as double,
            boundsEast: arguments['boundsEast'] as double,
            boundsNorth: arguments['boundsNorth'] as double,
            boundsSouth: arguments['boundsSouth'] as double,
            boundsWest: arguments['boundsWest'] as double,
            longitude: arguments['longitude'] as double,
            latitude: arguments['latitude'] as double,
            isLoading: false,
          );
        },
      },
    );
  }

  Future<String> _getInitialRoute() async {
    // Replace this with your logic to determine the initial route
    // You can use SharedPreferences or any other mechanism to store and retrieve the initial route
    // For now, I'll return '/discover' as the initial route
    return '/discover';
  }
}
