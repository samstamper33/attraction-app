 import 'package:http/http.dart' as http;
 import 'package:flutter/material.dart';
 import 'dart:convert';
 import 'package:in_app_webview/in_app_webview.dart';
 import 'package:passmate/attraction_view.dart';
 import 'package:google_fonts/google_fonts.dart';



  // Widget _buildOfferList(BuildContext context, int index) {
  //   if (index == _thisAttractionOffersState.length)
  //     return Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   return Container(
  //     child: GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext) {
  //           return InAppWebView(
  //             _thisAttractionOffersState[index]['website'] ??
  //                 'https://www.google.com',
  //             appBarBGColor: Color(0xff34643F5),
  //             centerTitle: true,
  //             titleWidget: Text(
  //               _thisAttractionState['name'],
  //               style: GoogleFonts.poppins(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16),
  //             ),
  //           );
  //         }));
  //       },
  //       child: Container(
  //         margin: EdgeInsets.only(
  //           left: 8,
  //           right: 8,
  //         ),
  //         width: 348,
  //         child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
  //           Container(
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   // image: DecorationImage(
  //                   //   alignment: Alignment.center,
  //                   //   fit: BoxFit.cover,
  //                   //   colorFilter:
  //                   //       ColorFilter.mode(Colors.black54, BlendMode.dstATop),
  //                   //   image: NetworkImage(
  //                   //     _thisAttractionOffersState[index]['image'],
  //                   //   ),
  //                   // ),
  //                   color: Colors.white,
  //                   boxShadow: [
  //                     BoxShadow(
  //                         color: Color.fromARGB(25, 0, 0, 0),
  //                         offset: Offset.fromDirection(120, 6),
  //                         blurRadius: 4),
  //                   ]),
  //               width: 348,
  //               height: 400,
  //               margin: EdgeInsets.only(left: 0, right: 0, top: 16),
  //               child: Align(
  //                   alignment: Alignment.centerLeft,
  //                   child: Container(
  //                       width: 348,
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Container(
  //                             height: 225,
  //                             decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.only(
  //                                     topLeft: Radius.circular(8),
  //                                     topRight: Radius.circular(8)),
  //                                 image: DecorationImage(
  //                                     alignment: Alignment.center,
  //                                     fit: BoxFit.cover,
  //                                     image: NetworkImage(
  //                                         _thisAttractionOffersState[index]
  //                                                 ['image'] ??
  //                                             'https://passmateimages.z13.web.core.windows.net/attractions/santasvillage/main.jpg'))),
  //                           ),
  //                           SizedBox(height: 20),
  //                           Padding(
  //                             padding:
  //                                 const EdgeInsets.only(left: 16, right: 16),
  //                             child: Text(
  //                               _thisAttractionOffersState[index]['heading'] ??
  //                                   '',
  //                               style: GoogleFonts.poppins(
  //                                   fontWeight: FontWeight.w700,
  //                                   color: Colors.black,
  //                                   fontSize: 18,
  //                                   letterSpacing: .1),
  //                               textAlign: TextAlign.start,
  //                             ),
  //                           ),
  //                           SizedBox(height: 8),
  //                           Padding(
  //                             padding:
  //                                 const EdgeInsets.only(left: 16, right: 16),
  //                             child: Text(
  //                               _thisAttractionOffersState[index]
  //                                       ['description'] ??
  //                                   '',
  //                               style: GoogleFonts.poppins(
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Color.fromARGB(255, 42, 42, 42),
  //                                 height: 1.3,
  //                                 fontSize: 14,
  //                               ),
  //                               textAlign: TextAlign.start,
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 20,
  //                           )
  //                         ],
  //                       )))),
  //         ]),
  //       ),
  //     ),
  //   );
  // }