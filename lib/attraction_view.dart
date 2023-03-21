import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:passmate/widgets/sidenav.dart';
import 'dart:convert';
import 'dart:io';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:in_app_webview/in_app_webview.dart';
import 'package:passmate/attraction_map.dart';
import 'package:passmate/discover.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:passmate/attraction_navigator.dart';

class AttractionViewPage extends StatefulWidget {
  static const route = 'attractionViewPage';

  String attractionId;
  String logo;
  String accent;
  String name;
  String image;
  late double longitude;
  late double latitude;
  final ValueChanged<int> onItemTapped;
  AttractionViewPage(
      {required this.attractionId,
      required this.image,
      required this.name,
      required this.logo,
      required this.accent,
      required this.longitude,
      required this.latitude,
      required this.onItemTapped});

  @override
  State<AttractionViewPage> createState() => _AttractionViewPageState();
}

class _AttractionViewPageState extends State<AttractionViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isCollapsed = true;
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
    // print(thisAttraction);
    var decodedAttraction = jsonDecode(thisAttraction);
    setState(() {
      _thisAttractionState = decodedAttraction;
    });
  }

  getOffers() {
    Future<dynamic> get() async {
      var url = Uri.parse(baseUrl);
      String basicAuth =
          'Basic ${base64.encode(utf8.encode('passmateapp:passmateapppass'))}';
      print(basicAuth);

      var response = await http.get(
          Uri.parse(baseUrl + '/HomescreenOffer/${widget.attractionId}'),
          headers: {
            HttpHeaders.authorizationHeader: basicAuth,
            HttpHeaders.acceptHeader: 'application/json'
          });
      // print(response.body);
      // print(r.body);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print(response.statusCode);
      }
    }

    return get();
  }

  List _thisAttractionOffersState = [];
  _asyncAttractionOfferMethod() async {
    var thisAttractionOffers = await getOffers();
    // print(thisAttraction);
    var decodedAttractionOffers = jsonDecode(thisAttractionOffers);
    print(decodedAttractionOffers);
    setState(() {
      _thisAttractionOffersState = decodedAttractionOffers;
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
      // print(response.body);
      // print(r.body);
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

  late String baseUrl;
  int navigationIndex = (0);
  // void _onItemTapped(int index) {
  //   setState(() {
  //     navigationIndex = index;
  //     log(navigationIndex.toString());
  //   });
  // }

  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    baseUrl = 'https://passmatetest1.azurewebsites.net/api/';
    _asyncAttractionMethod();
    // navigationIndex = (0);
    _asyncAttractionOfferMethod();
    _asyncAttractionMapMethod();
    log('Data is Loaded');
  }

  int _focusedIndex = 0;

  void _onItemFocus(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  Widget _buildOfferList(BuildContext context, int index) {
    if (index == _thisAttractionOffersState.length)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext) {
            return InAppWebView(
              _thisAttractionOffersState[index]['website'] ??
                  'https://www.google.com',
              appBarBGColor: Color(
                  int.parse('0xFF${_thisAttractionState['accentColorHex']}')),
              centerTitle: true,
              titleWidget: Text(
                _thisAttractionState['name'],
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            );
          }));
        },
        child: Container(
          margin: EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          width: 348,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                decoration: BoxDecoration(
                    // border: Border.all(color: Color.fromARGB(255, 129, 129, 129), width: .5),
                    borderRadius: BorderRadius.circular(24),
                    // image: DecorationImage(
                    //   alignment: Alignment.center,
                    //   fit: BoxFit.cover,
                    //   colorFilter:
                    //       ColorFilter.mode(Colors.black54, BlendMode.dstATop),
                    //   image: NetworkImage(
                    //     _thisAttractionOffersState[index]['image'],
                    //   ),
                    // ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(20, 0, 0, 0),
                          offset: Offset(0, 0),
                          // spreadRadius: 8,
                          blurRadius: 20),
                    ]),
                width: 348,
                height: 380,
                margin: EdgeInsets.only(left: 0, right: 0, top: 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        width: 348,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 225,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24)),
                                  image: DecorationImage(
                                      alignment: Alignment.center,
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          _thisAttractionOffersState[index]
                                                  ['image'] ??
                                              'https://passmateimages.z13.web.core.windows.net/attractions/santasvillage/main.jpg'))),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 24, right: 24),
                              child: Text(
                                _thisAttractionOffersState[index]['heading'] ??
                                    '',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 18,
                                    letterSpacing: .1),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 24, right: 36),
                              child: Text(
                                _thisAttractionOffersState[index]
                                        ['description'] ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 59, 59),
                                  height: 1.3,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            SizedBox(
                              height: 20,
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAttractionDrawer(context, ModalRoute.of(context).toString(),
          widget.logo, widget.name, widget.accent, widget.image),
      backgroundColor: Color(0xFFF7F7FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: Color(0xFFF7F7FA),
        shadowColor: Color.fromARGB(42, 255, 255, 255),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 12),
              child: Image.asset('assets/Frame.png'),
              // child: Image.asset('assets/Frame.png'),
            ),
          ),
        ),
        title: SizedBox(
          child: Image.network(
            widget.logo,
          ),
          height: 70,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 440,
                child: ScrollSnapList(
                  itemBuilder: _buildOfferList,
                  itemCount: _thisAttractionOffersState.length,
                  itemSize: 364,
                  onItemFocus: _onItemFocus,
                  onReachEnd: () {
                    print('Done');
                  },
                )),
            // SizedBox(
            //   height: 16,
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context)
            //         .push(MaterialPageRoute(builder: (BuildContext) {
            //       return InAppWebView(
            //         _thisAttractionState['ticketingLink'] ??
            //             'https://www.google.com',
            //         appBarBGColor: Color(int.parse(
            //             '0xFF${_thisAttractionState['accentColorHex']}')),
            //         centerTitle: true,
            //         titleWidget: Text(
            //           _thisAttractionState['name'],
            //           style: GoogleFonts.poppins(
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //               fontSize: 16),
            //         ),
            //       );
            //     }));
            //   },
            //   child: Padding(
            //     padding: EdgeInsets.only(left: 44, right: 44),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         border: Border.all(width: 2,color: Color(int.parse(
            //             '0xFF${_thisAttractionState['accentColorHex']}'))),
            //         borderRadius: BorderRadius.circular(20),
            //         color: Colors.white,
            //       ),
            //       padding: EdgeInsets.only(left: 12, right: 12),
            //       height: 64,
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           Image.network(
            //             _thisAttractionState['attractionLogo'] ?? '',
            //             errorBuilder: (BuildContext context, Object exception,
            //                 StackTrace? stackTrace) {
            //               // Return a fallback image widget if the network image fails to load
            //               return Container(
            //                 height: 32,
            //                 width: 32,
            //               );
            //             },
            //             height: 28,
            //           ),
            //           SizedBox(
            //             width: 16,
            //           ),
            //           Text(
            //             'Buy Tickets',
            //             style: GoogleFonts.poppins(
            //                 fontSize: 18, fontWeight: FontWeight.w500, color: Color(int.parse(
            //             '0xFF${_thisAttractionState['accentColorHex']}'))),
            //           ),
            //           Spacer(),
            //           Icon(
            //             Icons.arrow_forward_ios,
            //             size: 20,
            //             color: Color(int.parse(
            //             '0xFF${_thisAttractionState['accentColorHex']}')),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 24,),
            Container(
                padding: EdgeInsets.only(bottom: 12, left: 4),
                alignment: Alignment.centerLeft,
                width: 340,
                child: Text(
                  'What to do',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                )),
            Center(
              // padding: EdgeInsets.only(left: 44, right: 44),
              child: Container(
                width: 348,
                child: Wrap(
                  children: List<Widget>.from(
                      List.generate(_availableFilterList.length, (index) {
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
                        typeString = 'Animals';
                        hex = '56B447';
                        break;
                      case 4:
                        typeString = 'Aquatic Animals';
                        hex = '56B447';
                        break;
                      case 5:
                        typeString = 'Shops';
                        hex = 'FF70C6';
                        break;
                      case 6:
                        typeString = 'Dining';
                        hex = 'FFCE4B';
                        break;
                      case 7:
                        typeString = 'Drinks';
                        hex = 'FFCE4B';
                        break;
                      case 8:
                        typeString = 'Treats';
                        hex = 'FFCE4B';
                        break;
                      case 9:
                        typeString = 'Shows';
                        hex = 'D55EFF';
                        break;
                      case 10:
                        typeString = 'Attractions';
                        hex = '3ACCE1';
                        break;
                      case 11:
                        typeString = 'Reptiles';
                        hex = '56B447';
                        break;
                      case 12:
                        typeString = 'Emergency';
                        hex = 'FF515B';
                        break;
                      case 13:
                        typeString = 'Games';
                        hex = '67B6FF';
                        break;
                      case 14:
                        typeString = 'Restrooms';
                        hex = '40E0D0';
                        break;
                      case 15:
                        typeString = 'Services';
                        hex = '40E0D0';
                        break;
                      case 16:
                        typeString = 'Entrance / Exit';
                        hex = 'B2B7BA';
                        break;
                      default:
                        typeString = 'Unknown';
                        hex = '2A2E43';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0, bottom: 8),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: _selectedFilters.contains(type)
                                  // ? Colors.white
                                  ? Color(int.parse('0x10' + hex))
                                  : Color.fromARGB(170, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _selectedFilters.contains(type)
                                      ? Color(int.parse('0xff' + hex))
                                      : Color(int.parse('0xFF' + hex)),
                                  width: .5)),
                          padding: const EdgeInsets.only(left: 16.0, right: 16),
                          child: Text(
                            typeString,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: _selectedFilters.contains(type)
                                    ? Color(int.parse('0xFF' + hex))
                                    : Color.fromARGB(181, 0, 0, 0),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  })),
                ),
              ),
            ),
            SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext) {
                  return InAppWebView(
                    _thisAttractionState['ticketingLink'] ??
                        'https://www.google.com',
                    appBarBGColor: Color(int.parse('0xFF${widget.accent}')),
                    centerTitle: true,
                    titleWidget: Text(
                      _thisAttractionState['name'],
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  );
                }));
              },
              child: Center(
                // padding: EdgeInsets.only(left: 44, right: 44),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  // elevation: 16,
                  // shadowColor: Color(int.parse(
                  //         '0x70${widget.accent}')),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(49, 0, 0, 0),
                          offset: Offset(0, 10),
                          blurRadius: 20,
                          spreadRadius: 0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(20),
                      color: Color(int.parse('0xFF${widget.accent}')),
                    ),
                    padding: EdgeInsets.only(left: 12, right: 12),
                    width: 348,
                    height: 64,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image.network(
                        //   _thisAttractionState['attractionLogo'] ?? '',
                        //   errorBuilder: (BuildContext context, Object exception,
                        //       StackTrace? stackTrace) {
                        //     // Return a fallback image widget if the network image fails to load
                        //     return Container(
                        //       height: 24,
                        //       width: 24,
                        //     );
                        //   },
                        //   height: 30,
                        // ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'Buy Tickets',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Stack(alignment: AlignmentDirectional.center, children: [
                Container(
                  height: 440,
                  child: FlutterMap(
                    options: MapOptions(
                        center:
                            latlng.LatLng(widget.latitude, widget.longitude),
                        // maxBounds: LatLngBounds(
                        //   latlng.LatLng(_thisAttractionState['mapBounds']['north'] ?? 28.4754341,
                        //       _thisAttractionState['mapBounds']['east'] ?? -81.4668636),
                        //   latlng.LatLng(_thisAttractionState['mapBounds']['south'] ?? 28.4682176,
                        //       _thisAttractionState['mapBounds']['west'] ?? -81.4750605),
                        // ),
                        zoom: 18.2,
                        maxZoom: 18.4,
                        rotation: _thisAttractionState['MapOrientation'] ?? 120,
                        interactiveFlags: InteractiveFlag.none),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/passmate/ckyaksv1x06iq14p0i2tsx0ux/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2t4enExNnhzMnZsMjJvcDY1YWloaGNkdCJ9.5VlS7VGzbL-sUaU8XKi16Q',
                        additionalOptions: {
                          'accessToken':
                              'pk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2t4enExNnhzMnZsMjJvcDY1YWloaGNkdCJ9.5VlS7VGzbL-sUaU8XKi16Q',
                          'id': 'passmate.ctl4ikw5'
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 440,
                  decoration:
                      BoxDecoration(color: Color.fromARGB(80, 255, 255, 255)),
                ),
                Container(
                  height: 240,
                  width: 320,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/Navbar_Icons/map_selected.png',
                              height: 20,
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 200,
                              child: Text(
                                'Explore ${_thisAttractionState['name']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 24, right: 24, top: 12, bottom: 37),
                          child: Container(
                            height: 63,
                            child: Text(
                              'See all there is to do at ${_thisAttractionState['name']} to help plan and guide your visit!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          )),
                      GestureDetector(
                        onTap: () {
                          widget.onItemTapped(1);
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 320,
                            height: 72,
                            decoration: BoxDecoration(
                                color: Color(int.parse(
                                    '0xff${_thisAttractionState['accentColorHex'] ?? 000000}')),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Explore the map',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
