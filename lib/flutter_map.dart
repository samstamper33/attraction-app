// import 'dart:js';

import 'dart:developer';
import 'dart:ffi';
// import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_popup/extension_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/parser.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:passmate/base_client.dart';
import 'package:passmate/discover.dart';
import 'package:passmate/poi.dart';
import 'package:flutter/services.dart';
import 'package:passmate/remote_services.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:passmate/poi_info_page.dart';
import 'package:passmate/search_page.dart';
import 'package:collection/collection.dart';
import 'attraction_view.dart';
import 'package:passmate/geolocator.dart';
import 'package:passmate/widgets/sidenav.dart';

const String baseUrl = 'https://passmatetest1.azurewebsites.net/api/';

class FlutterMapPage extends StatefulWidget {
  static const route = 'attractionMapPage';

  String logo;
  String name;
  String accent;
  String image;
  String tileId;
  String attractionId;
  late double boundsNorth;
  late double orientation;
  late double boundsSouth;
  late double boundsEast;
  late double boundsWest;
  late double longitude;
  late double latitude;

  FlutterMapPage(
      {required this.attractionId,
      required this.accent,
      required this.name,
      required this.image,
      required this.tileId,
      required this.logo,
      required this.orientation,
      required this.boundsEast,
      required this.boundsNorth,
      required this.boundsSouth,
      required this.boundsWest,
      required this.longitude,
      required this.latitude});

  @override
  State<FlutterMapPage> createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMapPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // ignore: non_constant_identifier_names

  getAttraction() {
    Future<dynamic> get() async {
      var url = Uri.parse(baseUrl);
      String basicAuth =
          'Basic ${base64.encode(utf8.encode('passmateapp:passmateapppass'))}';
      print(basicAuth);

      var response = await http.get(
          Uri.parse(baseUrl + '/Attraction/${widget.attractionId}'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.acceptHeader: 'application/json'
          });
      // print(response.body);
      // print(r.body);
      if (response.statusCode == 200) {
        print(widget.attractionId + 'hello');
        return response.body;
      } else {
        print(response.statusCode);
      }
    }

    return get();
  }

  Map<String, dynamic> _thisAttractionState = {};
  _asyncAttractionMethod() async {
    var thisAttraction = await getAttraction();
    var decodedAttraction = jsonDecode(thisAttraction);
    setState(() {
      _thisAttractionState = decodedAttraction;
    });
  }

  getPOI() {
    Future<dynamic> get() async {
      var url = Uri.parse(baseUrl);
      String basicAuth =
          'Basic ${base64.encode(utf8.encode('passmateapp:passmateapppass'))}';
      print(basicAuth);

      var response = await http
          .get(Uri.parse(baseUrl + '/POI/${widget.attractionId}'), headers: {
        HttpHeaders.authorizationHeader: basicAuth,
        HttpHeaders.acceptHeader: 'application/json'
      });
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print(response.statusCode);
      }
    }

    return get();
  }

  List _availableFilterList = [];
  List _selectedFilters = [];
  List _filteredAttractionMap = [];
  List _thisAttractionMapState = [];
  List filterResults = [];
  _asyncAttractionMapMethod() async {
    var thisAttractionMap = await getPOI();
    var decodedAttractionMap = jsonDecode(thisAttractionMap);
    var decodedAttractionMapFilters = jsonDecode(thisAttractionMap);
    var filters = List.generate(decodedAttractionMap.length,
        ((index) => decodedAttractionMap[index]['type']));
    var filterTypes = filters.toSet().toList();
    var selectedFilterTypes = filters.toSet().toList();
    filterResults = decodedAttractionMap
        .where((item) => _selectedFilters.contains(item['type']))
        .toList();
    setState(() {
      _thisAttractionMapState = decodedAttractionMap;
      _availableFilterList = filterTypes;
      _availableFilterList.sort();
      _selectedFilters = selectedFilterTypes;
      _selectedFilters.sort();
      filterResults = _thisAttractionMapState
          .where((item) => _selectedFilters.contains(item['type']))
          .toList();
      _filteredAttractionMap = filterResults;
      log(_availableFilterList.toString());
      // log('wassup $_filteredAttractionMap');
      // log('HELLO HELLO HELLO ' + filterResults.length.toString());
    });
  }

  // List<PointOfInterest>? pointsofinterest;
  // var isLoaded = false;

  // getJsonData() async{}

  // late String baseUrl;
  late final MapController mapController;
  late final PopupController _popupLayerController;
  late final markerPositions = [
    _thisAttractionMapState.length,
    (index) => latlng.LatLng(_thisAttractionMapState[index]['latitude'],
        _thisAttractionMapState[index]['longitude'])
  ];
  late final List<Marker> _markers;
  int _selectedindex = (-1);
  int navigationIndex = (0);
  void _onItemTapped(int index) {
    setState(() {
      navigationIndex = index;
    });
  }

  List _filteredMap = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _selectedindex = (-1);
    navigationIndex = (0);
    _popupLayerController = PopupController();
    // CustomPopupDisplay(thisAttractionMapState: _thisAttractionMapState, marker: List<Marker>);
    mapController = MapController();
    _asyncAttractionMethod();
    _asyncAttractionMapMethod();
  }

  // getData() {}
  @override
  Widget build(BuildContext context) {
    // print(_thisAttractionState);
    // print('object');
    // if (_thisAttractionState['mapOrientation'] != null) {
    //   mapController.rotate(_thisAttractionState['mapOrientation']);
    // }
    return Scaffold(
        key: _scaffoldKey,
        drawer: buildAttractionDrawer(
            context,
            ModalRoute.of(context).toString(),
            widget.logo,
            widget.name,
            widget.accent,
            widget.image),
        body: Builder(builder: (context) {
          return Stack(children: [
            FlutterMap(
                mapController: mapController,
                options: MapOptions(
                    onTap: (tapPosition, point) {
                      _popupLayerController.hideAllPopups(
                          disableAnimation: false);
                      _selectedindex = -1;
                    },
                    center: latlng.LatLng(widget.latitude, widget.longitude),
                    maxBounds: LatLngBounds(
                      latlng.LatLng(widget.boundsNorth, widget.boundsEast),
                      latlng.LatLng(widget.boundsSouth, widget.boundsWest),
                    ),
                    zoom: 17.2,
                    maxZoom: 18.4,
                    rotation: 360 - widget.orientation,
                    // rotation: 90,
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                children: [
                  TileLayer(
                    urlTemplate:
                        // 'https://api.mapbox.com/v4/passmate.bd8vqrvd/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2t4enExNnhzMnZsMjJvcDY1YWloaGNkdCJ9.5VlS7VGzbL-sUaU8XKi16Q',
                        'https://api.mapbox.com/styles/v1/passmate/ckyaksv1x06iq14p0i2tsx0ux/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2t4enExNnhzMnZsMjJvcDY1YWloaGNkdCJ9.5VlS7VGzbL-sUaU8XKi16Q',
                    additionalOptions: {
                      'accessToken':
                          'pk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2t4enExNnhzMnZsMjJvcDY1YWloaGNkdCJ9.5VlS7VGzbL-sUaU8XKi16Q',
                      'id': 'passmate.ctl4ikw5'
                    },
                  ),
                  CurrentLocationLayer(),
                  PopupMarkerLayerWidget(
                      options: PopupMarkerLayerOptions(
                          popupAnimation: PopupAnimation.fade(
                              duration: Duration(milliseconds: 300)),
                          markerCenterAnimation: MarkerCenterAnimation(),
                          // popupSnap: PopupSnap.mapBottom,
                          popupBuilder: (BuildContext context, Marker marker) {
                            final index = _thisAttractionMapState.indexWhere(
                                (element) =>
                                    element['latitude'] ==
                                        marker.point.latitude &&
                                    element['longitude'] ==
                                        marker.point.longitude);
                            final locationName =
                                _thisAttractionMapState[index]['name'];
                            final poiimage =
                                _thisAttractionMapState[index]['image'];
                            final hex =
                                _thisAttractionMapState[index]['iconHex'];
                            final coloredIcon =
                                _thisAttractionMapState[index]['coloredIcon'];
                            final type = _thisAttractionMapState[index]['type'];
                            final id = _thisAttractionMapState[index]['id'];
                            final icon = _thisAttractionMapState[index]
                                ['iconUnselected'];
                            final orientation =
                                _thisAttractionState['mapOrientation'];
                            final description =
                                _thisAttractionMapState[index]['description'];
                            final lon =
                                _thisAttractionMapState[index]['longitude'];
                            final lat =
                                _thisAttractionMapState[index]['latitude'];
                            String typeString;
                            switch (type) {
                              case 1:
                                typeString = 'Rides';
                                break;
                              case 2:
                                typeString = 'Water Rides';
                                break;
                              case 3:
                                typeString = 'Water Play';
                                break;
                              case 4:
                                typeString = 'Natural Wonders';
                                break;
                              case 5:
                                typeString = 'Animals';
                                break;
                              case 6:
                                typeString = 'Aquatic Animals';
                                break;
                              case 7:
                                typeString = 'Shops';
                                break;
                              case 8:
                                typeString = 'Dining';
                                break;
                              case 9:
                                typeString = 'Drinks';
                                break;
                              case 10:
                                typeString = 'Treats';
                                break;
                              case 11:
                                typeString = 'Shows';
                                break;
                              case 12:
                                typeString = 'Attractions';
                                break;
                              case 13:
                                typeString = 'Reptiles';
                                break;
                              case 14:
                                typeString = 'Emergency';
                                break;
                              case 15:
                                typeString = 'Games';
                                break;
                              case 16:
                                typeString = 'Restrooms';
                                break;
                              case 17:
                                typeString = 'Services';
                                break;
                              case 18:
                                typeString = 'Entrance / Exit';
                                break;
                              default:
                                typeString = 'Unknown';
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => InfoPage(
                                            type: typeString,
                                            name: locationName,
                                            image: poiimage,
                                            description: description,
                                            attractionId: widget.attractionId,
                                            orientation: orientation,
                                            icon: icon,
                                            itemId: id,
                                            longitude: lon,
                                            latitude: lat,
                                          )));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(60, 0, 0, 0),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(2, 4),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  width: 360,
                                  height: 120,
                                  child: Container(
                                    // decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(12)),
                                    child: Stack(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              height: 120,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image:
                                                        NetworkImage(poiimage)),
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12),
                                                    bottomLeft:
                                                        Radius.circular(12)),
                                              )),
                                          Container(
                                              width: 6,
                                              decoration: BoxDecoration(
                                                  color: Color(int.parse(
                                                      '0xFF' +
                                                          hex.toString())))),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12, left: 24, top: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    // transform: Matrix4.translationValues(-24, 0, 0),
                                                    child: Text(
                                                      locationName,
                                                      style: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Colors.black),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.only(top: 8),
                                                    child: Container(
                                                      // transform: Matrix4.translationValues(-24, 0, 0),
                                                      child: Text(
                                                        typeString,
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black),
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 38,
                                        left: 101,
                                        child: Container(
                                          // transform: Matrix4.translationValues(-24, 38, 0),
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                      30, 0, 0, 0),
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(2, 4),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              color: Colors.white),
                                          height: 44,
                                          width: 44,
                                          child: Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Image.network(
                                                coloredIcon,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          top: 48,
                                          right: 12,
                                          child: Container(
                                            height: 24,
                                            width: 24,
                                            decoration: BoxDecoration(
                                                color: Color(int.parse(
                                                    '0xFF' + hex.toString())),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  print('object');
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              InfoPage(
                                                                type:
                                                                    typeString,
                                                                name:
                                                                    locationName,
                                                                description:
                                                                    description,
                                                                image: poiimage,
                                                                attractionId: widget
                                                                    .attractionId,
                                                                itemId: id,
                                                                icon: icon,
                                                                orientation:
                                                                    orientation,
                                                                longitude: lon,
                                                                latitude: lat,
                                                              )));
                                                },
                                                child: Container(
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          },
                          popupSnap: PopupSnap.mapBottom,
                          popupController: _popupLayerController,
                          markerTapBehavior: MarkerTapBehavior.custom(
                              (marker, PopupState popupState, popupController) {
                            log('started call');
                            final index = _filteredAttractionMap.indexWhere(
                                (element) =>
                                    element['latitude'] ==
                                        marker.point.latitude &&
                                    element['longitude'] ==
                                        marker.point.longitude);
                            log('got to setstate');
                            setState(() {
                              _selectedindex = index;
                            });
                            _popupLayerController.showPopupsOnlyFor([marker]);
                            print(_selectedindex);
                          }),
                          selectedMarkerBuilder: (context, marker) =>
                              Image.network(
                                _filteredAttractionMap[_selectedindex]
                                    ['iconSelected'],
                              ),
                          markers: List.generate(
                              _filteredAttractionMap.length,
                              (index) => Marker(
                                    key: Key(index.toString()),
                                    point: latlng.LatLng(
                                        _filteredAttractionMap[index]
                                            ['latitude'],
                                        _filteredAttractionMap[index]
                                            ['longitude']),
                                    builder: (context) {
                                      if (_selectedindex == index) {
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          child: Image.network(
                                            _filteredAttractionMap[index]
                                                ['iconSelected'],
                                            height: 40,
                                            width: 40,
                                          ),
                                        );
                                      } else {
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          child: Image.network(
                                            _filteredAttractionMap[index]
                                                ['iconUnselected'],
                                            height: 32,
                                            width: 32,
                                          ),
                                        );
                                      }
                                    },
                                    width: 36,
                                    height: 36,
                                    rotate: true,
                                    anchorPos:
                                        AnchorPos.align(AnchorAlign.bottom),
                                  )))),
                ]),
            Container(
              child: SizedBox(
                height: 140,
                width: 450,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0x00ffffff)])),
                ),
              ),
            ),
            Container(
                child: Positioned(
              top: 72,
              left: 25,
              right: 25,
              child: Material(
                elevation: 16,
                shadowColor: Color(0xff455B63),
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 12),
                          child: Image.asset('assets/Frame.png'),
                          // child: Image.asset('assets/Frame.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          width: 1,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Color(0xFFF4F4F6),
                              borderRadius: BorderRadius.circular(1)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SearchPage(
                                orientation:
                                    _thisAttractionState['mapOrientation'],
                                attractionId: widget.attractionId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 120,
                          child: Text('Where to?',
                              style: GoogleFonts.inter(
                                  color: Color(0xFF78849E),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
            Padding(
              padding: EdgeInsets.only(top: 144),
              child: Container(
                // decoration: BoxDecoration(color: Colors.white),
                height: 40,
                child: ListView.builder(
                    padding: EdgeInsets.only(left: 28, right: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableFilterList.length,
                    itemBuilder: ((context, index) {
                      final type = _availableFilterList[index];
                      String typeString;
                      String hex;
                      switch (type) {
                        case 1:
                          typeString = 'Rides';
                          hex = 'FF774B';
                          break;
                        case 2:
                          typeString = 'Water Rides';
                          hex = '00DFFF';
                          break;
                        case 3:
                          typeString = 'Water Play';
                          hex = '00DFFF';
                          break;
                        case 4:
                          typeString = 'Natural Wonders';
                          hex = '56B447';
                          break;
                        case 5:
                          typeString = 'Animals';
                          hex = '56B447';
                          break;
                        case 6:
                          typeString = 'Aquatic Animals';
                          hex = '56B447';
                          break;
                        case 7:
                          typeString = 'Shops';
                          hex = 'FF70C6';
                          break;
                        case 8:
                          typeString = 'Dining';
                          hex = 'FFCE4B';
                          break;
                        case 9:
                          typeString = 'Drinks';
                          hex = 'FFCE4B';
                          break;
                        case 10:
                          typeString = 'Treats';
                          hex = 'FFCE4B';
                          break;
                        case 11:
                          typeString = 'Shows';
                          hex = 'D55EFF';
                          break;
                        case 12:
                          typeString = 'Attractions';
                          hex = '3ACCE1';
                          break;
                        case 13:
                          typeString = 'Reptiles';
                          hex = '56B447';
                          break;
                        case 14:
                          typeString = 'Emergency';
                          hex = 'FF515B';
                          break;
                        case 15:
                          typeString = 'Games';
                          hex = '67B6FF';
                          break;
                        case 16:
                          typeString = 'Restrooms';
                          hex = '40E0D0';
                          break;
                        case 17:
                          typeString = 'Services';
                          hex = '40E0D0';
                          break;
                        case 18:
                          typeString = 'Entrance / Exit';
                          hex = 'B2B7BA';
                          break;
                        default:
                          typeString = 'Unknown';
                          hex = '2A2E43';
                      }
                      return GestureDetector(
                        onTap: () {
                          if (_selectedFilters.contains(type)) {
                            List updatedList = _selectedFilters;
                            List updatedMarkers = _filteredAttractionMap;
                            updatedList.remove(type);
                            updatedMarkers.removeWhere(
                                (marker) => marker['type'] == type);
                            setState(() {
                              _selectedFilters = updatedList;
                              _selectedFilters.sort();
                              _filteredAttractionMap = updatedMarkers;
                              log(_filteredAttractionMap.toString());
                            });
                          } else {
                            List updatedList = _selectedFilters;
                            List updatedMarkers = _filteredAttractionMap;
                            updatedList.add(type);
                            updatedMarkers.addAll(_thisAttractionMapState
                                .where((marker) => marker['type'] == type));
                            setState(() {
                              _selectedFilters = updatedList;
                              _selectedFilters.sort();
                              _filteredAttractionMap = updatedMarkers;
                              log(_filteredAttractionMap.toString());
                            });
                          }
                          // _selectedFilters.contains(type)
                          //     ? setState(() {
                          //         _selectedFilters =
                          //             _selectedFilters.remove(type) as List;
                          //       })
                          //     : setState(() {
                          //         _selectedFilters =
                          //             _selectedFilters.add(type) as List;
                          //       });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 12.0, bottom: 8),
                          child: Container(
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromARGB(55, 0, 0, 0),
                                      offset: Offset(4, 4),
                                      blurRadius: 8)
                                ],
                                color: _selectedFilters.contains(type)
                                    ? Color(int.parse('0xFF' + hex))
                                    : Color.fromARGB(170, 255, 255, 255),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _selectedFilters.contains(type)
                                        ? Color.fromARGB(0, 255, 255, 255)
                                        : Color.fromARGB(0, 0, 0, 0),
                                    width: 1.5)),
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16),
                            child: Text(
                              typeString,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: _selectedFilters.contains(type)
                                      ? Colors.white
                                      : Color.fromARGB(181, 0, 0, 0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    })),
              ),
            )
          ]);
        }));
  }
}
