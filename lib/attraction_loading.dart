import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

Widget loadingPage(
  BuildContext context, String image, String logo, String hex) {
  return Stack(
    alignment: AlignmentDirectional.topCenter,
    children: [
      Image.network(
        image,
        fit: BoxFit.fitHeight,
        height: double.infinity,
      ),
      Positioned(
        top: -150, // adjust the value as needed
        child: SizedBox(
          height: 700,
          width: 700,
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(350),
                color: Colors.white,
                border: Border.all(
                  color: Color(int.parse('0xFF${hex}')),
                  width: 8
                ),
              ),
              width: double.infinity,
            ),
          ),
        ),
      ),
      Container(
        height: 500,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: 240,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.network(logo),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Powered by',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: const Color(0xFF2A2E43),
                    decoration: TextDecoration.none
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Image.asset(
                  'assets/passmate_logo_text.png',
                  width: 112,
                ),
              ],
            )
          ],
        ),
      )
    ],
  );
}
