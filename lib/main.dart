// import 'dart:js';

import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:passmate/attraction_mapbox.dart';
import 'package:passmate/discover.dart';
import 'package:passmate/attraction_navigator.dart';
import 'package:passmate/attraction_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passmate/permissions-screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/': (context) => FutureBuilder<String>(
          future: _getInitialRoute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(); // or a loading spinner
            } else {
              // return snapshot.data == '/permissions' ? PermissionsScreen() : FullMap();
              return snapshot.data == '/permissions' ? PermissionsScreen() : DiscoverPage();
            }
          },
        ),
        '/permissions': (context) => PermissionsScreen(),
        '/discover': (context) => const DiscoverPage(),
        // '/mapboxtest':(context) => const FullMap(),
      },
    );
  }

  static Future<String> _getInitialRoute() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // The user has previously denied permission and selected "never ask again"
      // TODO: handle this case appropriately (e.g. show a dialog explaining that they need to enable location permissions in the settings)
      return '/discover'; // For testing purposes, we return the home screen route
      // return '/discover'; // For testing purposes, we return the home screen route
    } else if (permission == LocationPermission.denied) {
      // The user has denied permission before but hasn't selected "never ask again"
      return '/permissions';
    } else {
      // The user has granted permission
      return '/discover';
      // return '/discover';
    }
  }
}
