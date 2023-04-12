import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:passmate/discover.dart';
import 'package:in_app_webview/in_app_webview.dart';
import 'package:passmate/main.dart';

Widget _buildMenuItem(
    BuildContext context, Widget title, String routeName, String currentRoute) {
  final isSelected = routeName == currentRoute;

  return ListTile(
    selectedColor: Colors.black,
    title: title,
    selected: isSelected,
    onTap: () {
      if (isSelected) {
        Navigator.pop(context);
      } else if (routeName == '/discover') {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> r) => false);
      } else {
        Navigator.pushNamed(context, routeName);
      }
    },
  );
}

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: Container(
      color: Color(0xFF665EFF),
      // color: Color(0xFF665EFF),
      child: Column(
        children: <Widget>[
          Container(
            height: 240,
            padding: EdgeInsets.only(top: 0),
            margin: EdgeInsets.only(top: 0),
            color: Color(0xFF665EFF),
            child: DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF665EFF)),
              child: Padding(
                padding: const EdgeInsets.only(left: 22, right: 68),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/launcher_icon/icon.png'))),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'passmate',
                            style: GoogleFonts.quicksand(
                                color: Colors.white,
                                // color: Color(0xFF3ACCE1),
                                fontWeight: FontWeight.w400,
                                fontSize: 24),
                          ),
                        ],
                      )
                    ]),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'assets/gradient.png',
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0, top: 12),
                    child: _buildMenuItem(
                        context,
                        Row(
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 22,
                              color: Color(0xff3497FD),
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Text(
                              'Discover',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF454F63)),
                            ),
                          ],
                        ),
                        '/discover',
                        '/discover'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context)
                            // ignore: avoid_types_as_parameter_names
                            .push(MaterialPageRoute(builder: (BuildContext) {
                          return InAppWebView(
                            'https://www.passmate.us/privacy',
                            toolbarHeight: 32,
                            appBarBGColor: Color(0xFF2A2E43),
                            centerTitle: true,
                            titleWidget: Text(
                              'Privacy Policy',
                              style: GoogleFonts.inter(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          );
                        }));
                      },
                      selectedColor: Colors.black,
                      title: Row(
                        children: [
                          const Icon(
                            Icons.privacy_tip_outlined,
                            size: 22,
                            color: Color(0xFF78849E),
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Text(
                            'Privacy Policy',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF454F63)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Drawer buildAttractionDrawer(BuildContext context, String currentRoute,
    String logo, String name, String hex, String image) {
  return Drawer(
    child: Container(
      color: Color(0xFF665EFF),
      // color: Color(0xFF665EFF),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                // image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
                color: Color(int.parse('0xFF${hex}')),
                ),
            height: 240,
            padding: EdgeInsets.only(top: 0),
            margin: EdgeInsets.only(top: 0),
            // color: Color(int.parse('0xFF${hex}')),
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF${hex}')),
                // image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 22, right: 22, top: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                // image: DecorationImage(
                                //     image: NetworkImage(logo))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: NetworkImage(logo),
                                  )),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Flexible(
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(
                                  height: 1.2,
                                  color: Colors.white,
                                  // color: Color(0xFF3ACCE1),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: 
                          Text(
                            'powered by passmate',
                            style: GoogleFonts.poppins(
                                color: Color.fromARGB(255, 255, 255, 255),
                                // color: Color(0xFF3ACCE1),
                                fontWeight: FontWeight.w100,
                                fontSize: 14),
                          ),
                      )
                    ]),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'assets/gradient.png',
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0, top: 12),
                    child: _buildMenuItem(
                        context,
                        Row(
                          children: [
                            Transform.rotate(
                              angle: 3.14,
                              child: const Icon(
                                Icons.exit_to_app_rounded,
                                size: 22,
                                color: Color(0xff78849E),
                              ),
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Text(
                              'Leave Park',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF454F63)),
                            ),
                          ],
                        ),
                        '/discover',
                        currentRoute),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (BuildContext) {
                          return InAppWebView(
                            'https://www.passmate.us/privacy',
                            toolbarHeight: 32,
                            appBarBGColor: Color(0xFF2A2E43),
                            centerTitle: true,
                            titleWidget: Text(
                              'Privacy Policy',
                              style: GoogleFonts.inter(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          );
                        }));
                      },
                      selectedColor: Colors.black,
                      title: Row(
                        children: [
                          const Icon(
                            Icons.privacy_tip_outlined,
                            size: 22,
                            color: Color(0xFF78849E),
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Text(
                            'Privacy Policy',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF454F63)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
