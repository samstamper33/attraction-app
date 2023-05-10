import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:passmate/poi_info_page.dart';

const String baseUrl = 'https://passmatetest1.azurewebsites.net/api/';

class SearchPage extends StatefulWidget {
  late double orientation;
  String attractionId;
  String tileId;
  SearchPage({required this.attractionId, required this.orientation, required this.tileId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  getResults() {
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

  List _thisSearchState = [];
  _asyncSearchMethod() async {
    var thisSearchState = await getResults();
    // print(thisAttraction);
    var decodedSearchState = jsonDecode(thisSearchState);
    print(decodedSearchState);
    setState(() {
      _thisSearchState = decodedSearchState;
    });
  }

  List _filteredState = [];

  void updateList(String value) {
    setState(() {
      _filteredState = _thisSearchState
          .where((element) =>
              element['name']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['description']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _asyncSearchMethod();
    setState(() {
      _filteredState = _filteredState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FA),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 72, right: 24, left: 24),
              child: Material(
                  elevation: 16,
                  shadowColor: Color.fromARGB(123, 69, 91, 99),
                  borderRadius: BorderRadius.circular(17),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) => updateList(value),
                    showCursor: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                          left: 0, right: 20, top: 16, bottom: 16),
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            size: 20,
                            color: Color(0xFF454F63),
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                    // textAlignVertical: TextAlignVertical(y: -1),
                    style: GoogleFonts.inter(
                        height: 1.4,
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                    // cursorHeight: 32,

                    autofocus: true,
                  ))),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24),
            child: _filteredState.length > 1
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Search Results',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 24),
                      textAlign: TextAlign.start,
                    ),
                  )
                : SizedBox(),
          ),
          Expanded(
              child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemCount: _filteredState.length,
            itemBuilder: (context, index) {
              final hex = _filteredState[index]['iconHex'];
              final type = _filteredState[index]['type'];
              final id = _filteredState[index]['id'];
              final minHeight = _filteredState[index]['heightRequirement'];
              final orientation = widget.orientation;
              final locationName = _filteredState[index]['name'];
              final icon = _filteredState[index]['iconUnselected'];
              final poiimage = _filteredState[index]['image'];
              final description = _filteredState[index]['description'];
              final lon = _filteredState[index]['longitude'];
              final lat = _filteredState[index]['latitude'];
              var result = _filteredState[index];
              print(result);
              String typeString;
              switch (type) {
                case 1:
                  typeString = 'Rides';
                  break;
                case 2:
                  typeString = 'Water Rides';
                  break;
                case 3:
                  typeString = 'Animals';
                  break;
                case 4:
                  typeString = 'Aquatic Animals';
                  break;
                case 5:
                  typeString = 'Shops';
                  break;
                case 6:
                  typeString = 'Dining';
                  break;
                case 7:
                  typeString = 'Drinks';
                  break;
                case 8:
                  typeString = 'Treats';
                  break;
                case 9:
                  typeString = 'Shows';
                  break;
                case 10:
                  typeString = 'Attractions';
                  break;
                case 11:
                  typeString = 'Reptiles';
                  break;
                case 12:
                  typeString = 'Emergency';
                  break;
                case 13:
                  typeString = 'Games';
                  break;
                case 14:
                  typeString = 'Restrooms';
                  break;
                case 15:
                  typeString = 'Services';
                  break;
                case 16:
                  typeString = 'Entrance / Exit';
                  break;
                default:
                  typeString = 'Unknown';
              }
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InfoPage(
                              name: locationName,
                              type: typeString,
                              tileId: widget.tileId,
                              hex: hex,
                              minHeight: minHeight,
                              description: description,
                              image: poiimage,
                              orientation: orientation,
                              icon: icon,
                              attractionId: widget.attractionId,
                              itemId: id,
                              longitude: lon,
                              latitude: lat,
                            )));
                  },
                  child: Container(
                    // decoration: const BoxDecoration(
                    // border: Border(
                    //     bottom: BorderSide(
                    //         width: 1,
                    //         color: Color.fromARGB(255, 234, 234, 241)))),
                    child: Card(
                      elevation: 0,
                      color: Colors.transparent,
                      margin: EdgeInsets.only(bottom: 4, top: 4),
                      child: ListTile(
                        tileColor: Colors.transparent,
                        dense: false,
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Image.network(
                            _filteredState[index]['image'] ?? '',
                            width: 60,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('lottie_skeleton.json'),
                          ),
                        ),
                        title: Text(
                          _filteredState[index]['name'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            typeString,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(int.parse('0xFF' + hex.toString())),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}
