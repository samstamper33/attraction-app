import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'dart:convert';
import 'dart:io';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:in_app_webview/in_app_webview.dart';
import 'package:passmate/attraction_map.dart';
import 'package:passmate/attraction_view.dart';

class InfoPage extends StatefulWidget {
  String itemId;
  String attractionId;
  String image;
  String icon;
  String description;
  String type;
  String name;
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
      required this.longitude,
      required this.latitude,
      required this.orientation});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
        backgroundColor: Color(0xFFF7F7FA),
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
        title: Column(
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
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(69, 0, 0, 0),
                        offset: Offset(0, 4),
                        blurRadius: 4)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                      width: 344,
                      height: 240,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              Container(
                                color: Colors.green,
                              );
                            },
                            image: NetworkImage(widget.image)),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(69, 0, 0, 0),
                              offset: Offset(0, 4),
                              blurRadius: 4)
                        ],
                        // color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      )),
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                padding: EdgeInsets.only(left: 6),
                width: 344,
                child: Text(
                  'Description',
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
              IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(69, 0, 0, 0),
                            offset: Offset(0, 4),
                            blurRadius: 4)
                      ]),
                  // height: 300,
                  width: 344,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          color: Colors.white,
                          width: 344,
                          child: Text(
                            widget.name,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Flexible(
                            child: Container(
                          width: 344,
                          child: Text(
                            widget.description,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(173, 0, 0, 0)),
                          ),
                        )),
                      ],
                    ),
                  ),
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
                  child: FlutterMap(
                    options: MapOptions(
                      center: latlng.LatLng(widget.latitude, widget.longitude),
                      rotation: widget.orientation,
                      maxZoom: 18.4,
                      minZoom: 17.5,
                      zoom: 18.2,
                      interactiveFlags: InteractiveFlag.pinchZoom,
                    ),
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
                      PopupMarkerLayerOptions(
                        markers: List.generate(
                            1,
                            (index) => Marker(
                                point: latlng.LatLng(
                                    widget.latitude, widget.longitude),
                                builder: (context) =>
                                    Image.network(widget.icon),
                                width: 36,
                                height: 36,
                                anchorPos: AnchorPos.align(AnchorAlign.bottom),
                                rotate: true)),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
