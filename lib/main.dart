// import 'dart:js';

import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:passmate/discover.dart';
import 'package:passmate/attraction_map.dart';
import 'package:passmate/attraction_navigator.dart';
import 'package:passmate/attraction_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      home: DiscoverApp(),
      routes: {
        '/discover': (context) => const DiscoverPage(),
        // AttractionViewPage.route:(context) => AttractionViewPage(attractionId: AttractionNavigatorPage.attractionId, name: name, logo: logo, accent: accent, longitude: longitude, latitude: latitude, onItemTapped: onItemTapped),
        // AttractionMapPage.route:(context) => AttractionMapPage(attractionId: attractionId, boundsEast: boundsEast, boundsNorth: boundsNorth, boundsSouth: boundsSouth, boundsWest: boundsWest, longitude: longitude, latitude: latitude),
      }
    );
  }
}
