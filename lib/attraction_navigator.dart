import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:passmate/attraction_mapbox.dart';
import 'package:passmate/attraction_view.dart';
import 'package:passmate/attraction_loading.dart';
import 'package:passmate/widgets/sidenav.dart';
import 'package:passmate/attraction_mapbox.dart';
import 'package:passmate/flutter_map.dart';

class AttractionNavigatorPage extends StatefulWidget {
  String attractionId;
  String image;
  String logo;
  String accent;
  String name;
  String tileId;
  late double boundsNorth;
  late double boundsSouth;
  late double boundsEast;
  late double boundsWest;
  late double orientation;
  late double longitude;
  late double latitude;
  AttractionNavigatorPage(
      {required this.attractionId,
      required this.image,
      required this.name,
      required this.tileId,
      required this.accent,
      required this.logo,
      required this.orientation,
      required this.boundsEast,
      required this.boundsNorth,
      required this.boundsSouth,
      required this.boundsWest,
      required this.longitude,
      required this.latitude});

  @override
  State<AttractionNavigatorPage> createState() =>
      _AttractionNavigatorPageState();
}

class _AttractionNavigatorPageState extends State<AttractionNavigatorPage> {
  late List<Widget> _pages;
  int navigationIndex = 0;
  bool isLoading = true;
  bool isAnimating = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    log(index.toString());
    setState(() {
      navigationIndex = index;
      log(navigationIndex.toString());
      // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    });
  }

  void _handleDrawerGesture(DragUpdateDetails details) {
    // if (details.delta.dx > 0) {
      // user is swiping from left to right
      _scaffoldKey.currentState?.openDrawer();
      // disable the pop gesture
      Navigator.of(context).pop();
    // }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      AttractionViewPage(
          image: widget.image,
          name: widget.name,
          attractionId: widget.attractionId,
          logo: widget.logo,
          accent: widget.accent,
          longitude: widget.longitude,
          latitude: widget.latitude,
          onItemTapped: _onItemTapped),
      FullMap(
          name: widget.name,
          accent: widget.accent,
          image: widget.image,
          orientation: widget.orientation,
          logo: widget.logo,
          tileId: widget.tileId,
          boundsEast: widget.boundsEast,
          boundsNorth: widget.boundsNorth,
          boundsWest: widget.boundsWest,
          boundsSouth: widget.boundsSouth,
          attractionId: widget.attractionId,
          longitude: widget.longitude,
          latitude: widget.latitude
      )
    ];
    // baseUrl = 'https://passmatetest1.azurewebsites.net/api/';
    // _asyncAttractionMethod();
    navigationIndex = (0);
    // _asyncAttractionOfferMethod();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(children: [
        Scaffold(
            key: _scaffoldKey,
            drawer: buildAttractionDrawer(
                context,
                ModalRoute.of(context).toString(),
                widget.logo,
                widget.name,
                widget.accent,
                widget.image),
            bottomNavigationBar: Theme(
              data: ThemeData(splashColor: Colors.transparent),
              child: BottomNavigationBar(
                  currentIndex: navigationIndex,
                  // elevation: 16,
                  selectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  enableFeedback: false,
                  onTap: _onItemTapped,
                  iconSize: 28.0,
                  selectedItemColor: navigationIndex == 0
                      ? Color(0xFF7B61FF)
                      : Color(0xFFFF5E99),
                  selectedFontSize: 14.0,
                  unselectedFontSize: 14.0,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: Image.asset(
                            'assets/Navbar_Icons/ios_home.png',
                            height: 26,
                          ),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 6),
                          child: Image.asset(
                            'assets/Navbar_Icons/home_selected.png',
                            height: 26,
                          ),
                        ),
                        label: 'HOME'),
                    BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: Image.asset(
                            'assets/Navbar_Icons/map_unselected.png',
                            height: 28,
                          ),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: Image.asset(
                            'assets/Navbar_Icons/map_selected.png',
                            height: 26,
                          ),
                        ),
                        label: 'MAP')
                  ]),
            ),
            body: IndexedStack(
              index: navigationIndex,
              children: _pages,
            )),
        if (isLoading)
          Opacity(
              opacity: 1,
              child: loadingPage(
                  context, widget.image, widget.logo, widget.accent)),
      ]),
    );
  }
}
