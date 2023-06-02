import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:passmate/attraction_view.dart';
import 'package:passmate/widgets/sidenav.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:passmate/base_client.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passmate/attraction_navigator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passmate/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:passmate/widgets/update.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());
const String baseUrl = 'https://passmatetest1.azurewebsites.net/api/Attraction';

class DiscoverPage extends StatelessWidget {
  static const route = '/discover';

  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        DiscoverPage.route: (context) => const DiscoverPage(),
        // AttractionViewPage.route:(context) => AttractionViewPage(attractionId: AttractionNavigatorPage.attractionId, name: name, logo: logo, accent: accent, longitude: longitude, latitude: latitude, onItemTapped: onItemTapped),
        // AttractionMapPage.route:(context) => AttractionMapPage(attractionId: attractionId, boundsEast: boundsEast, boundsNorth: boundsNorth, boundsSouth: boundsSouth, boundsWest: boundsWest, longitude: longitude, latitude: latitude),
      },
      debugShowCheckedModeBanner: false,
      home: DiscoverApp(),
    );
  }
}

class DiscoverApp extends StatefulWidget {
  const DiscoverApp({super.key});
  State<DiscoverApp> createState() => _DiscoverAppState();
}

class _DiscoverAppState extends State<DiscoverApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _showUpdateModal = false;
  _getPackageInfo() async {
    var packageInfo = await PackageInfo.fromPlatform();
    // log(packageInfo.version);
    var client = new http.Client();
    var response = await client.get(Uri.parse(
        'https://passmate-update.azurewebsites.net/api/HttpTrigger1?code=D0bcpKV9BsHTA4_0IscG_dj6zPcOA42ucSzEL8DEttvsAzFu3z1Qcg=='));
    log(response.body);
    // if (response.body != packageInfo.version) {
    if (response.body.indexOf(packageInfo.version) >= 0) {
      setState(() {
        _showUpdateModal = true;
      });
      // log(_showUpdateModal.toString());
    }
  }

  double distanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }

  var client = http.Client();
  getAttractionsList() {
    _getPackageInfo();
    Future<dynamic> get() async {
      // Get the user's location
      // Position position = await Geolocator.getCurrentPosition();
      var url = Uri.parse(baseUrl);
      String basicAuth =
          'Basic ' + base64.encode(utf8.encode('passmateapp:passmateapppass'));
      print(basicAuth);

      var response = await http.get(Uri.parse(baseUrl), headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.acceptHeader: 'application/json'
      });
      // print(r.statusCode);
      // print(r.body);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print(response.statusCode);
      }
    }

    return get();
  }

  List _attractionState = [];
  _asyncMethod() async {
    var attractions = await getAttractionsList();
    // print(attractions);
    var decodedAttractions = jsonDecode(attractions);
    setState(() {
      _attractionState = decodedAttractions;
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      final snackBar =
          SnackBar(content: Container(
            height: 300,
            child: Column(
              children: [
                Text(message.notification?.title ?? ''),
                Text(message.notification?.body ?? ''),
                Image.network(message.notification?.apple?.imageUrl ?? '')
              ],
            ),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _asyncMethod();

    init() async {
      String deviceToken = await getDeviceToken();
      print('################# THIS IS THE DEVICE TOKEN#################');
      print(deviceToken);
    }
  }

  Future getDeviceToken() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();
    return (deviceToken ?? "");
  }

  List<dynamic> data = [0, 1, 2, 3];
  int _focusedIndex = 0;

  void _onItemFocus(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  Widget _buildItemList(BuildContext context, int index) {
    if (index == _attractionState.length)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Container(
      child: GestureDetector(
        onTap: () {
          print(_attractionState[index]['id']);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AttractionNavigatorPage(
                    image: _attractionState[index]['attractionImage'],
                    tileId: _attractionState[index]['rasterTileId'],
                    name: _attractionState[index]['name'],
                    attractionId: _attractionState[index]['id'],
                    logo: _attractionState[index]['attractionLogo'],
                    accent: _attractionState[index]['accentColorHex'],
                    orientation: _attractionState[index]['mapOrientation'],
                    boundsEast: _attractionState[index]['mapBounds']['east'],
                    boundsNorth: _attractionState[index]['mapBounds']['north'],
                    boundsSouth: _attractionState[index]['mapBounds']['south'],
                    boundsWest: _attractionState[index]['mapBounds']['west'],
                    longitude: _attractionState[index]['longitude'],
                    latitude: _attractionState[index]['latitude'],
                    isLoading: true,
                  )));
        },
        child: Container(
          margin: EdgeInsets.only(
            left: 4,
            right: 4,
          ),
          width: 348,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      colorFilter:
                          ColorFilter.mode(Colors.black54, BlendMode.dstATop),
                      image: NetworkImage(
                        _attractionState[index]['attractionImage'],
                      ),
                    ),
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(20, 0, 0, 0),
                          spreadRadius: 8,
                          blurRadius: 12),
                    ]),
                width: 348,
                height: MediaQuery.of(context).size.height * .8,
                margin: EdgeInsets.only(left: 0, right: 0, top: 16),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _attractionState[index]['city'].toUpperCase() +
                                  ", " +
                                  _attractionState[index]['state'],
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 16,
                                  letterSpacing: .1),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              _attractionState[index]['name'],
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.111,
                                fontSize: 32,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 32,
                            )
                          ],
                        )))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log(_showUpdateModal.toString());
    return Stack(children: [
      Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color.fromARGB(0, 255, 255, 255),
          shadowColor: Color.fromARGB(0, 255, 255, 255),
          leading: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 12),
              child: Image.asset('assets/Frame.png'),
              // child: Image.asset('assets/Frame.png'),
            ),
          ),
          title: Image.asset(
            'assets/passmate_logo_text.png',
            width: 140,
          ),
        ),
        drawer: buildDrawer(context, DiscoverPage().toString()),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: ScrollSnapList(
                  itemBuilder: _buildItemList,
                  // itemCount: _attractionState.length,
                  itemCount: _attractionState.length,
                  itemSize: 356,
                  dynamicItemSize: true,
                  dynamicSizeEquation: (distance) {
                    if (distance > 0) {
                      return 1 -
                          0.05 *
                              distance /
                              MediaQuery.of(context).size.width /
                              2;
                    } else {
                      return 1 +
                          0.05 *
                              distance /
                              MediaQuery.of(context).size.width /
                              2;
                    }
                  },
                  onItemFocus: _onItemFocus,
                  onReachEnd: () {
                    print('Done');
                  },
                ),
              )
            ],
          ),
        ),
      ),
      if (_showUpdateModal)
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
      if (_showUpdateModal)
        AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.9,
            child: DraggableScrollableSheet(
                initialChildSize: .9,
                maxChildSize: .99,
                minChildSize: .9,
                expand: true,
                builder: updateSlider))
    ]);
  }
}
