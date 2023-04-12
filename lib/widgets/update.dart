import 'dart:developer';

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

Widget updateSlider 
  (BuildContext context, ScrollController scrollController) {
  return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/update_animation.json'),
            SizedBox(height: 14),
            Text(
              'Time to update!',
              style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none),
            ),
            SizedBox(height: 14),
            Text(
              'We added new features and fixed some bugs to make sure your experience is as smooth as possible.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF10cccd)),
              ),
              onPressed: () {
                var url;
                if (Platform.isAndroid) {
                  url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.passmate.companion');
                } else if (Platform.isIOS) {
                  url = Uri.parse(
                      'https://apps.apple.com/us/app/passmate-attraction-companion/id6446158862');
                }
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 10, left: 12, right: 12),
                child: Text(
                  'Update',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ]));
}
