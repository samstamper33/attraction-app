// import 'dart:js';

import 'dart:collection';
import 'dart:developer';
import 'dart:ffi';
// import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:passmate/base_client.dart';
import 'package:passmate/discover.dart';
import 'package:passmate/poi.dart';
import 'package:flutter/services.dart';
import 'package:passmate/remote_services.dart';
// import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:passmate/poi_info_page.dart';
import 'package:passmate/search_page.dart';
import 'package:collection/collection.dart';
import 'attraction_view.dart';
import 'package:passmate/geolocator.dart';
import 'package:passmate/widgets/sidenav.dart';

const String baseUrl = 'https://passmatetest1.azurewebsites.net/api/';

class FullMap extends StatefulWidget {
  static const route = '/mapboxtest';

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

  FullMap(
      {required this.attractionId,
      required this.accent,
      required this.name,
      required this.image,
      required this.tileId,
      required this.logo,
      required this.boundsEast,
      required this.boundsNorth,
      required this.orientation,
      required this.boundsSouth,
      required this.boundsWest,
      required this.longitude,
      required this.latitude});
  CameraBoundsOptions cameraOptions() {
    return CameraBoundsOptions(
      maxZoom: 19.5,
      minZoom: 15.5,
      bounds: CoordinateBounds(
        southwest: Point(
          coordinates: Position(
            boundsWest,
            boundsSouth,
          ),
        ).toJson(),
        northeast: Point(
          coordinates: Position(
            boundsEast,
            boundsNorth,
          ),
        ).toJson(),
        infiniteBounds: false,
      ),
    );
  }

  @override
  State createState() => FullMapState();
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  MapboxMap mapboxMap;
  PointAnnotationManager pointAnnotationManager;
  List<PointAnnotation?> annotationList;
  int index;
  // List images;
  String oldAnnotationID;
  FullMapState parentState;

  AnnotationClickListener(
      {required this.pointAnnotationManager,
      required this.annotationList,
      required this.mapboxMap,
      required this.index,
      // required this.images,
      required this.oldAnnotationID,
      required this.parentState});

  @override
  onPointAnnotationClick(PointAnnotation annotation) {
    log('Old current ID: $oldAnnotationID');
    log('New current ID: $oldAnnotationID');
    parentState.annotationList = annotationList;
    parentState.oldAnnotationID = oldAnnotationID;
    // reset old marker
    if (oldAnnotationID != '1') {
      var oldAnnotation = annotationList.firstWhere(
          (annotation) => annotation!.id.toString() == oldAnnotationID);

      oldAnnotation!.iconSize = .25;
      pointAnnotationManager.update(oldAnnotation);

      TransitionOptions(duration: 200);
    }
    // create new marker
    var currentAnnotation = annotationList[0];
    var oldIconImage = annotation.iconImage.toString();
    log(annotation.iconImage.toString());
    annotation.iconImage = oldIconImage.replaceAll('Unselected', 'Selected');
    annotation.iconSize = .29;
    pointAnnotationManager.update(annotation);
    oldAnnotationID = annotation.id;
    // fly to
    // var point = Point.fromJson((annotation.geometry)!.cast());
    // log(annotation.geometry!.entries.contains('-').toString());
    // mapboxMap.flyTo(
    //     CameraOptions(
    //         center: Point(
    //                 coordinates: Position(point.coordinates.lng.toDouble(),
    //                     point.coordinates.lat.toDouble()))
    //             .toJson(),
    //         ),
    //     MapAnimationOptions(duration: 200, startDelay: 0));

    // popup
    parentState.setState(() {
      final type = parentState
          ._filteredAttractionMap[annotation.textOpacity!.toInt()]['type'];
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
          typeString = 'Entrance';
          break;
        default:
          typeString = 'Unknown';
      }
      parentState.currentTypeString = typeString;
      log('Current Type String${parentState.currentTypeString}');
      parentState.isVisible = true;
      parentState._pointAnnotationManager = pointAnnotationManager;
      parentState.selectedAnnotation = annotation;
      log(parentState.selectedAnnotation!.id.toString());
      parentState.listIndex =
          parentState.selectedAnnotation?.textOpacity!.toInt();
      log('this is index ${parentState.listIndex}');
    });
  }
}

class FullMapState extends State<FullMap> {
  MapboxMap? mapboxMap;
  OnMapTapListener? onMapTapListener;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? _pointAnnotationManager;
  List<PointAnnotation?> annotationList = [];
  List _filteredAnnotationList = [];
  int _selectedindex = -1;
  String oldAnnotationID = '';
  PointAnnotation? selectedAnnotation;
  late Int markerIndex;
  var currentTypeString;
  var listIndex;
  bool isVisible = false;
  final GlobalKey<ScaffoldState> _attractionScaffoldKey =
      GlobalKey<ScaffoldState>();

  // List pointAnnotationList = <PointAnnotation>[];
  _onTap(ScreenCoordinate coordinate) {
    log('This is for the _onTap function $oldAnnotationID');
    log(annotationList.map((annotation) => annotation!.id).toString());
    var isWithinRange = _filteredAttractionMap.any((annotation) =>
        (annotation['latitude'] - coordinate.x).abs() <= 0.00005 &&
        (annotation['longitude'] - coordinate.y).abs() <= 0.00005);
    if (isWithinRange && selectedAnnotation!.iconOpacity != 0) {
      mapboxMap?.easeTo(
          CameraOptions(
            center: Point(coordinates: Position(coordinate.y, coordinate.x))
                .toJson(),
          ),
          MapAnimationOptions(duration: 200, startDelay: 0));

      log('this is within range');
    } else {
      if (selectedAnnotation != null) {
        var oldAnnotation = annotationList.firstWhere((annotation) =>
            annotation!.id.toString() == selectedAnnotation!.id);

        selectedAnnotation!.iconSize = .25;
        selectedAnnotation!.iconImage = '$currentTypeString Unselected';
        log(_pointAnnotationManager.toString());
        _pointAnnotationManager?.update(selectedAnnotation!);
      }
      // log('This is your selected annotation ${selectedAnnotation!.id}');
      // selectedAnnotation!.iconSize = .2;
      // log('size');
      // pointAnnotationManager?.update(selectedAnnotation!);
      // log("this isn't within range");
      // selectedAnnotation = null;
      setState(() {
        selectedAnnotation = null;
        log(selectedAnnotation.toString());
      });
    }
  }

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
        .addLayer(RasterLayer(id: "layer", sourceId: "source"))
        .then((value) async {
      mapboxMap?.addListener(() {
        onMapTapListener;
      });
    });
    // mapboxMap?.onMapTapListener ==
    //     (point, coordinates) {
    //       setState(() {
    //         selectedAnnotation = null;
    //         log('onmaptap listener seems to be working?');
    //       });
    //     };
    var pointAnnotationManager =
        await mapboxMap!.annotations.createPointAnnotationManager();
    setState(() {
      _pointAnnotationManager = pointAnnotationManager;
    });
    // widget.pointAnnotationManager = pointAnnotationManager;
    var poiOptions = <PointAnnotationOptions>[];
    // var imageURLs = [];
    // for (var i = 0; i < _filteredAttractionMap.length; i++) {
    //   imageURLs.add(_filteredAttractionMap[i]['iconUnselected']);
    // }
    // // log(imageURLs.toString());
    // var client = http.Client();
    // getAllImages() async {
    //   return Future.wait(
    //       imageURLs.map((url) => client.get(Uri.parse(url)).then((response) {
    //             mapboxMap?.style.addStyleImage(
    //                 "Marker Shape",
    //                 1.0,
    //                 MbxImage(width: 20, height: 20, data: response.bodyBytes),
    //                 true,
    //                 [],
    //                 [],
    //                 null);
    //             return response.bodyBytes;
    //           })));
    // }

    // ;
    // var images = await getAllImages();
    log('This is for testing purposes ${_filteredAttractionMap.length}');
    for (var i = 0; i < _filteredAttractionMap.length; i++) {
      final type = _filteredAttractionMap[i]['type'];
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
          typeString = 'Entrance';
          break;
        default:
          typeString = 'Unknown';
      }
      final hex = _filteredAttractionMap[i]['iconHex'];
      poiOptions.add(PointAnnotationOptions(
        //this is where I'm storing index
        textOpacity: i.toDouble(),

        //these are actual options
        iconAnchor: IconAnchor.CENTER,
        iconImage: '$typeString Unselected',
        iconColor: int.parse('0xFF$hex'),
        iconSize: .25,
        geometry: Point(
                coordinates: Position(_filteredAttractionMap[i]['longitude'],
                    _filteredAttractionMap[i]['latitude']))
            .toJson(),
      ));
    }
    var oldAnnotationID = 1.toString();
    var annotationString = pointAnnotationManager.createMulti(poiOptions)
        // .then((value) async {
        //   mapboxMap?.addListener(() {
        //     OnMapTapListener;
        //   });
        // });
        .then((value) async {
      _filteredAnnotationList = value;
      pointAnnotationManager
          .addOnPointAnnotationClickListener(AnnotationClickListener(
              mapboxMap: mapboxMap!,
              parentState: this,
              pointAnnotationManager: pointAnnotationManager,
              index: _selectedindex,
              annotationList: value,
              // images: images,
              oldAnnotationID: oldAnnotationID));
    });
    // add on map tap listener that sets selected annotation to null
    mapboxMap?.addListener(() {
      OnMapTapListener;
    });
  }

  _onMapCreated(MapboxMap mapboxMap) {
    mapboxMap.compass.updateSettings(settings);
    mapboxMap.setBounds(widget.cameraOptions());
    mapboxMap.scaleBar.updateSettings(scaleSettings);
    mapboxMap.attribution.updateSettings(attributionSettings);
    print('onMapCreated called');
    this.mapboxMap = mapboxMap;
    log('create annotation');
    mapboxMap.location.updateSettings(LocationComponentSettings(
        showAccuracyRing: true,
        puckBearingEnabled: true,
        pulsingEnabled: true,
        locationPuck: LocationPuck(locationPuck2D: LocationPuck2D())));
  }

  Point createRandomPoint() {
    log(createRandomPosition().toString());
    return Point(coordinates: createRandomPosition());
  }

  Position createRandomPosition() {
    return Position(widget.longitude, widget.latitude);
  }

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
        // return response.body;
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

  var settings = CompassSettings(enabled: false);
  var scaleSettings = ScaleBarSettings(enabled: false);
  // final cameraOptions = CameraBoundsOptions(
  //   maxZoom: 19.5,
  //   minZoom: 15.5,
  //   bounds: CoordinateBounds(southwest: Point(
  //               coordinates: Position(
  //             late widget.boundsSouth,
  //             widget.boundsWest,
  //           )).toJson(),
  //           northeast: Point(
  //               coordinates: Position(
  //             widget.boundsNorth,
  //             widget.boundsEast,
  //           )).toJson(),
  //           infiniteBounds: false)
  // );
  var attributionSettings = AttributionSettings(
    position: OrnamentPosition.TOP_LEFT,
    marginLeft: 100,
    marginTop: 10,
    clickable: false,
    iconColor: 0xFF000000,
  );
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
    if (_filteredAttractionMap.isEmpty) {
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
      });
    }
    // for (Point marker in markers) {
    //   pointAnnotationManager!.createMulti(_filteredAttractionMap)
    // }
  }

  late final markerPositions = [
    _thisAttractionMapState.length,
    (index) => latlng.LatLng(_thisAttractionMapState[index]['latitude'],
        _thisAttractionMapState[index]['longitude'])
  ];
  // late final List<Marker> _markers;
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
    // _selectedFilters = [];
    _pointAnnotationManager;
    onMapTapListener;
    _selectedFilters;
    _selectedindex = (-1);
    navigationIndex = (0);
    _asyncAttractionMethod();
    _asyncAttractionMapMethod();
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredAttractionMap.isEmpty) {
      return Scaffold(
        key: _attractionScaffoldKey,
        drawer: buildAttractionDrawer(
            context,
            ModalRoute.of(context).toString(),
            widget.logo,
            widget.name,
            widget.accent,
            widget.image),
        body: Container(
          height: double.infinity,
          color: Colors.white,
        ),
      );
    }
    return Scaffold(
      key: _attractionScaffoldKey,
      drawer: buildAttractionDrawer(context, ModalRoute.of(context).toString(),
          widget.logo, widget.name, widget.accent, widget.image),
      body: Stack(children: [
        MapWidget(
            onTapListener: _onTap,
            onStyleLoadedListener: _onStyleLoaded,
            onSourceAddedListener: (sourceAddedEventData) {
              RasterLayer(id: 'attractionmap', sourceId: 'raster');
            },
            styleUri: 'mapbox://styles/passmate/clg1cjh0g001e01r36s2p69m8',
            cameraOptions: CameraOptions(
                bearing: widget.orientation,
                center: Point(
                        coordinates:
                            Position(widget.longitude, widget.latitude))
                    .toJson(),
                zoom: 17.5),
            onMapCreated: _onMapCreated,
            onMapLoadErrorListener: (mapLoadingErrorEventData) {
              print(widget.tileId + ' error on load');
            },
            resourceOptions: ResourceOptions(
                accessToken:
                    'sk.eyJ1IjoicGFzc21hdGUiLCJhIjoiY2xnMHdrcHhyMWV5ZzNrcDZ6ZW8zdnF1bCJ9.OjYPKwZO2Dw2MunTOfGV1w')),
        if (selectedAnnotation != null &&
            selectedAnnotation!.iconOpacity != 0.0)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: isVisible ? 16 : -120,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isVisible ? 1 : 0,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InfoPage(
                                type: currentTypeString,
                                name: _filteredAttractionMap[listIndex]['name'],
                                image: _filteredAttractionMap[listIndex]
                                    ['image'],
                                description: _filteredAttractionMap[listIndex]
                                    ['description'],
                                attractionId: widget.attractionId,
                                tileId: widget.tileId,
                                minHeight: _filteredAttractionMap[listIndex]
                                    ['heightRequirement'],
                                orientation: widget.orientation,
                                hex: _filteredAttractionMap[listIndex]
                                    ['iconHex'],
                                icon: _filteredAttractionMap[listIndex]
                                    ['coloredIcon'],
                                itemId: _filteredAttractionMap[listIndex]['id'],
                                longitude: _filteredAttractionMap[listIndex]
                                    ['longitude'],
                                latitude: _filteredAttractionMap[listIndex]
                                    ['latitude'],
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            _filteredAttractionMap[listIndex]
                                                ['image'])),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12)),
                                  )),
                              Container(
                                  width: 6,
                                  decoration: BoxDecoration(
                                      color: Color(int.parse(
                                          '0xFF${_filteredAttractionMap[listIndex]['iconHex']}')))),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 12, left: 24, top: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        // transform: Matrix4.translationValues(-24, 0, 0),
                                        child: Text(
                                          _filteredAttractionMap[listIndex]
                                              ['name'],
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Container(
                                          // transform: Matrix4.translationValues(-24, 0, 0),
                                          child: Text(
                                            currentTypeString,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Colors.black),
                                            overflow: TextOverflow.clip,
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
                                      color: Color.fromARGB(30, 0, 0, 0),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: Offset(2, 4),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.white),
                              height: 44,
                              width: 44,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.network(
                                    _filteredAttractionMap[listIndex]
                                        ['coloredIcon'],
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
                                        '0xFF${_filteredAttractionMap[listIndex]['iconHex']}')),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      print('object');
                                      // Navigator.of(context).push(
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             InfoPage(
                                      //               type:
                                      //                   typeString,
                                      //               name:
                                      //                   locationName,
                                      //               description:
                                      //                   description,
                                      //               image: poiimage,
                                      //               attractionId: widget
                                      //                   .attractionId,
                                      //               itemId: id,
                                      //               icon: icon,
                                      //               orientation:
                                      //                   orientation,
                                      //               longitude: lon,
                                      //               latitude: lat,
                                      //             )));
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
                ),
              ),
            ),
          ),
        Container(
          child: SizedBox(
            height: 132,
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
          top: 60,
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
                  color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      log('Drawer Opened');
                      _attractionScaffoldKey.currentState!.openDrawer();
                    },
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
                            orientation: widget.orientation,
                            tileId: widget.tileId,
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
          padding: EdgeInsets.only(top: 132),
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
                      typeString = 'Entrance';
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
                        log(updatedList.toString());
                        updatedList.remove(type);
                        log(updatedList.toString());
                        setState(() {
                          _selectedFilters = updatedList;
                          _selectedFilters.sort();
                        });
                        log(_selectedFilters.toString());
                      } else {
                        List updatedList = _selectedFilters;
                        updatedList.add(type);
                        setState(() {
                          _selectedFilters = updatedList;
                          _selectedFilters.sort();
                        });
                      }
                      for (var i = 0; i < _filteredAnnotationList.length; i++) {
                        var newTypeString =
                            '${_filteredAnnotationList[i].iconImage}';
                        var formattedTypeString =
                            newTypeString.replaceAll(' Selected', '');
                        var finalFormattedTypeString =
                            formattedTypeString.replaceAll(' Unselected', '');
                        int currentType;
                        switch (finalFormattedTypeString) {
                          case 'Rides':
                            currentType = 1;
                            break;
                          case 'Water Rides':
                            currentType = 2;
                            break;
                          case 'Water Play':
                            currentType = 3;
                            break;
                          case 'Natural Wonders':
                            currentType = 4;
                            break;
                          case 'Animals':
                            currentType = 5;
                            break;
                          case 'Aquatic Animals':
                            currentType = 6;
                            break;
                          case 'Shops':
                            currentType = 7;
                            break;
                          case 'Dining':
                            currentType = 8;
                            break;
                          case 'Drinks':
                            currentType = 9;
                            break;
                          case 'Treats':
                            currentType = 10;
                            break;
                          case 'Shows':
                            currentType = 11;
                            break;
                          case 'Attractions':
                            currentType = 12;
                            break;
                          case 'Reptiles':
                            currentType = 13;
                            break;
                          case 'Emergency':
                            currentType = 14;
                            break;
                          case 'Games':
                            currentType = 15;
                            break;
                          case 'Restrooms':
                            currentType = 16;
                            break;
                          case 'Services':
                            currentType = 17;
                            break;
                          case 'Entrance':
                            currentType = 18;
                            break;
                          default:
                            currentType = 0;
                        }
                        log(currentType.toString());
                        log(finalFormattedTypeString.toString());
                        log(_filteredAnnotationList[i].iconImage.toString());
                        if (_selectedFilters.contains(currentType)) {
                          _filteredAnnotationList[i].iconOpacity = 1.0;
                          _pointAnnotationManager!
                              .update(_filteredAnnotationList[i]);
                        } else {
                          _filteredAnnotationList[i].iconOpacity = 0.0;
                          _pointAnnotationManager!
                              .update(_filteredAnnotationList[i]);
                        }
                        // if (_filteredAnnotationList[i]
                        //     .iconImage
                        //     .contains(typeString)) {
                        //   _filteredAnnotationList[i].iconOpacity = 0.0;
                        //   _pointAnnotationManager!
                        //       .update(_filteredAnnotationList[i]);
                        // }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0, bottom: 8),
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
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
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
        ),
        AnimatedPositioned(
          duration:
              const Duration(milliseconds: 120), // Duration of the animation
          bottom: selectedAnnotation == null
              ? 24
              : 164, // Animate between 164 and 24 based on the value of isVisible
          left: 4,
          child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (_selectedFilters.contains(16)) {
                    return Color(
                        0xFF40E0D0); // set to desired color if 16 is selected
                  } else {
                    return Color.fromARGB(170, 255, 255,
                        255); // set to default color if 16 is not selected
                  }
                }),
                shape: MaterialStateProperty.all(
                  CircleBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                if (_selectedFilters.contains(16)) {
                  List updatedList = _selectedFilters;
                  log(updatedList.toString());
                  updatedList.remove(16);
                  log(updatedList.toString());
                  setState(() {
                    _selectedFilters = updatedList;
                    _selectedFilters.sort();
                  });
                  log(_selectedFilters.toString());
                } else {
                  List updatedList = _selectedFilters;
                  updatedList.add(16);
                  mapboxMap!.easeTo(
                      CameraOptions(
                        zoom: 16.5,
                        // center: Point(
                        //         coordinates:
                        //             Position(widget.longitude, widget.latitude))
                        //     .toJson(),
                      ),
                      MapAnimationOptions(duration: 200, startDelay: 0));
                  setState(() {
                    _selectedFilters = updatedList;
                    _selectedFilters.sort();
                  });
                }
                for (var i = 0; i < _filteredAnnotationList.length; i++) {
                  var newTypeString = '${_filteredAnnotationList[i].iconImage}';
                  var formattedTypeString =
                      newTypeString.replaceAll(' Selected', '');
                  var finalFormattedTypeString =
                      formattedTypeString.replaceAll(' Unselected', '');
                  int currentType;
                  switch (finalFormattedTypeString) {
                    case 'Rides':
                      currentType = 1;
                      break;
                    case 'Water Rides':
                      currentType = 2;
                      break;
                    case 'Water Play':
                      currentType = 3;
                      break;
                    case 'Natural Wonders':
                      currentType = 4;
                      break;
                    case 'Animals':
                      currentType = 5;
                      break;
                    case 'Aquatic Animals':
                      currentType = 6;
                      break;
                    case 'Shops':
                      currentType = 7;
                      break;
                    case 'Dining':
                      currentType = 8;
                      break;
                    case 'Drinks':
                      currentType = 9;
                      break;
                    case 'Treats':
                      currentType = 10;
                      break;
                    case 'Shows':
                      currentType = 11;
                      break;
                    case 'Attractions':
                      currentType = 12;
                      break;
                    case 'Reptiles':
                      currentType = 13;
                      break;
                    case 'Emergency':
                      currentType = 14;
                      break;
                    case 'Games':
                      currentType = 15;
                      break;
                    case 'Restrooms':
                      currentType = 16;
                      break;
                    case 'Services':
                      currentType = 17;
                      break;
                    case 'Entrance':
                      currentType = 18;
                      break;
                    default:
                      currentType = 0;
                  }
                  log(currentType.toString());
                  log(finalFormattedTypeString.toString());
                  log(_filteredAnnotationList[i].iconImage.toString());
                  if (_selectedFilters.contains(currentType)) {
                    _filteredAnnotationList[i].iconOpacity = 1.0;
                    _pointAnnotationManager!.update(_filteredAnnotationList[i]);
                  } else {
                    _filteredAnnotationList[i].iconOpacity = 0.0;
                    _pointAnnotationManager!.update(_filteredAnnotationList[i]);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.wc,
                  size: 32,
                  color: _selectedFilters.contains(16)
                      ? Colors.white
                      : Color.fromARGB(120, 0, 0, 0),
                ),
              )),
        ),
      ]),
    );
  }
  // ]);
}
