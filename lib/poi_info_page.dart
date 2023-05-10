import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_map/plugin_api.dart';
// import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:in_app_webview/in_app_webview.dart';
import 'package:passmate/attraction_view.dart';

class InfoPage extends StatefulWidget {
  String itemId;
  String attractionId;
  String image;
  String icon;
  String tileId;
  String hex;
  String description;
  String type;
  String name;
  String minHeight;
  late double longitude;
  late double latitude;
  late double orientation;
  InfoPage(
      {required this.itemId,
      required this.name,
      required this.type,
      required this.image,
      required this.description,
      required this.attractionId,
      required this.icon,
      required this.tileId,
      required this.hex,
      required this.minHeight,
      required this.longitude,
      required this.latitude,
      required this.orientation});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  PointAnnotationManager? _pointAnnotationManager;

  getInfo() {
    Future<dynamic> get() async {
      var url = Uri.parse(baseUrl);
      String basicAuth =
          'Basic ${base64.encode(utf8.encode('passmateapp:passmateapppass'))}';
      print(basicAuth);

      var response = await http.get(
          Uri.parse(baseUrl + '/POI/${widget.attractionId}/${widget.itemId}'),
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

  MapboxMap? mapboxMap;
  var settings = CompassSettings(enabled: false);
  var scaleSettings = ScaleBarSettings(enabled: false);
  var attributionSettings = AttributionSettings(
    position: OrnamentPosition.BOTTOM_RIGHT,
    marginRight: -120, 
    clickable: false,
    iconColor: 0xFF000000,
  );

  _onStyleLoaded(StyleLoadedEventData data) async {
    print('onStyleLoaded called');
    await mapboxMap?.style.addSource(RasterSource(
      id: "source",
      tiles: [
        "https://api.mapbox.com/v4/${widget.tileId}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2t4enExNnhzMnZsMjJvcDY1YWloaGNkdCJ9.5VlS7VGzbL-sUaU8XKi16Q"
      ],
      tileSize: 256,
      scheme: Scheme.XYZ,
      minzoom: 15,
      maxzoom: 19,
      // boun, 180.0, 85.0],
    ));
    await mapboxMap?.style
        .addLayer(RasterLayer(id: "layer", sourceId: "source"));
    var pointAnnotationManager =
        await mapboxMap!.annotations.createPointAnnotationManager();
    setState(() {
      _pointAnnotationManager = pointAnnotationManager;
    });
    var poiOptions = <PointAnnotationOptions>[];
    // for (var i = 0; i < _filteredAttractionMap.length; i++) {
    // final hex = _filteredAttractionMap[i]['iconHex'];
    poiOptions.add(PointAnnotationOptions(
      //this is where I'm storing index
      // textOpacity: i.toDouble(),

      //these are actual options
      iconAnchor: IconAnchor.CENTER,
      iconImage: '${widget.type} Unselected',
      iconColor: int.parse('0xFF${widget.hex}'),
      iconSize: .25,
      geometry: Point(coordinates: Position(widget.longitude, widget.latitude))
          .toJson(),
    ));
    // }
    var oldAnnotationID = 1.toString();
    var annotationString = pointAnnotationManager.createMulti(poiOptions);
    // .then((value) async {
    //   mapboxMap?.addListener(() {
    //     OnMapTapListener;
    //   });
    // });
    // .then((value) async {
    // _filteredAnnotationList = value;
    // });
  }

  _onMapCreated(MapboxMap mapboxMap) {
    mapboxMap.compass.updateSettings(settings);
    // mapboxMap.setBounds(widget.cameraOptions());
    mapboxMap.scaleBar.updateSettings(scaleSettings);
    mapboxMap.attribution.updateSettings(attributionSettings);
    print('onMapCreated called');
    this.mapboxMap = mapboxMap;
    log('create annotation');
  }

  Map<String, dynamic> _thisPOIState = {};
  _asyncPOIMethod() async {
    var thisPOI = await getInfo();
    // print(thisAttraction);
    var decodedPOI = jsonDecode(thisPOI);
    setState(() {
      _thisPOIState = decodedPOI;
      log(_thisPOIState['name']);
    });
  }

  late String baseUrl;

  @override
  void initState() {
    super.initState();
    baseUrl = 'https://passmatetest1.azurewebsites.net/api/';
    _asyncPOIMethod();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Color(int.parse('0x33${widget.hex}')),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: Builder(
          builder: (BuildContext context) {
            // Use the actual background color of the AppBar.
            Color hexColor = Color(int.parse('0xFF${widget.hex}'));
            // Calculate the luminance of the AppBar's background color.
            double luminance = hexColor.computeLuminance();
            // Choose the text color based on the luminance value.
            Color textColor = luminance > 0.5
                ? Colors.black
                : Color(int.parse('0xFF${widget.hex}'));

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  widget.type,
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                )
              ],
            );
          },
        ),
      ),
      // return Scaffold(
      //   backgroundColor: Color(0xFFF7F7FA),
      //   appBar: AppBar(
      //     elevation: 0,
      //     centerTitle: false,
      //     backgroundColor: Color(int.parse('0xFF${widget.hex}')),
      //     leading: GestureDetector(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: Icon(
      //         Icons.arrow_back_ios_new_rounded,
      //         color: Colors.black,
      //         size: 24,
      //       ),
      //     ),
      //     title: Column(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(
      //           widget.name,
      //           style: GoogleFonts.inter(
      //               color: Colors.black,
      //               fontSize: 14,
      //               fontWeight: FontWeight.w600),
      //         ),
      //         SizedBox(height: 2),
      //         Text(
      //           widget.type,
      //           style: GoogleFonts.inter(
      //               color: Colors.black,
      //               fontSize: 14,
      //               fontWeight: FontWeight.w400),
      //         )
      //       ],
      //     ),
      //   ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  // color: Color(int.parse('0xFF${widget.hex}')),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Color(int.parse('0xFF${widget.hex}'))
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Color.fromARGB(69, 0, 0, 0),
                            //       offset: Offset(0, 4),
                            //       blurRadius: 4)
                            // ],
                            ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                              width: 344,
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      Container(
                                        color: Colors.green,
                                      );
                                    },
                                    image: NetworkImage(widget.image)),
                                // boxShadow: [
                                //   BoxShadow(
                                //       color: Color.fromARGB(69, 0, 0, 0),
                                //       offset: Offset(0, 4),
                                //       blurRadius: 4)
                                // ],
                                // color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  if (widget.type == 'Rides' || widget.type == 'Water Rides')
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .28,
                            height: 60,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black12, width: 1),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 24.0, right: 8),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'MINIMUM HEIGHT',
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .72,
                            height: 60,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black12, width: 1),
                            ),
                            child: Container(
                              padding: EdgeInsets.only(left: 12),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Riders must be >${widget.minHeight} inches tall',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              // Container(
              //   padding: EdgeInsets.only(left: 6),
              //   width: 344,
              //   child: Text(
              //     'Location',
              //     textAlign: TextAlign.start,
              //     style: GoogleFonts.inter(
              //         fontSize: 14,
              //         color: Colors.black,
              //         fontWeight: FontWeight.w600),
              //   ),
              // ),
              // SizedBox(
              //   height: 8,
              // ),
              // Container(
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12),
              //       boxShadow: [
              //         BoxShadow(
              //             color: Color.fromARGB(69, 0, 0, 0),
              //             offset: Offset(0, 4),
              //             blurRadius: 4)
              //       ]),
              //   height: 160,
              //   width: 344,
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(12),
              //     child: MapWidget(
              //         // onTapListener: _onTap,
              //         onStyleLoadedListener: _onStyleLoaded,
              //         onSourceAddedListener: (sourceAddedEventData) {
              //           RasterLayer(id: 'attractionmap', sourceId: 'raster');
              //         },
              //         styleUri:
              //             'mapbox://styles/passmate/clg1cjh0g001e01r36s2p69m8',
              //         cameraOptions: CameraOptions(
              //             bearing: widget.orientation,
              //             center: Point(
              //                     coordinates: Position(
              //                         widget.longitude, widget.latitude))
              //                 .toJson(),
              //             zoom: 17.8),
              //         onMapCreated: _onMapCreated,
              //         onMapLoadErrorListener: (mapLoadingErrorEventData) {
              //           print(widget.tileId + ' error on load');
              //         },
              //         resourceOptions: ResourceOptions(
              //             accessToken:
              //                 'sk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2xnMHdrcHhyMWV5ZzNrcDZ6ZW8zdnF1bCJ9.OjYPKwZO2Dw2MunTOfGV1w')),
              //   ),
              // ),
              // SizedBox(height: 36),
              Container(
                // padding: EdgeInsets.only(left: 6),
                width: 344,
                child: Text(
                  '${widget.name} Description',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                width: 344,
                child: Text(
                  widget.description,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(173, 0, 0, 0)),
                ),
              ),
              SizedBox(height: 36),
              Container(
                padding: EdgeInsets.only(left: 6),
                width: 344,
                child: Text(
                  'Location',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(69, 0, 0, 0),
                          offset: Offset(0, 4),
                          blurRadius: 4)
                    ]),
                height: 160,
                width: 344,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapWidget(
                      // onTapListener: _onTap,
                      onStyleLoadedListener: _onStyleLoaded,
                      onSourceAddedListener: (sourceAddedEventData) {
                        RasterLayer(id: 'attractionmap', sourceId: 'raster');
                      },
                      styleUri:
                          'mapbox://styles/passmate/clg1cjh0g001e01r36s2p69m8',
                      cameraOptions: CameraOptions(
                          bearing: widget.orientation,
                          center: Point(
                                  coordinates: Position(
                                      widget.longitude, widget.latitude))
                              .toJson(),
                          zoom: 17.8),
                      onMapCreated: _onMapCreated,
                      onMapLoadErrorListener: (mapLoadingErrorEventData) {
                        print(widget.tileId + ' error on load');
                      },
                      resourceOptions: ResourceOptions(
                          accessToken:
                              'sk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2xnMHdrcHhyMWV5ZzNrcDZ6ZW8zdnF1bCJ9.OjYPKwZO2Dw2MunTOfGV1w')),
                ),
              ),
              const SizedBox(
                height: 140,
              )
            ],
          ),
        ),
      ),
    );
  }
}
