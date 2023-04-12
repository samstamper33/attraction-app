import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  LocationPermission? _permission;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    setState(() {
      _permission = permission;
    });
  }

  Future<void> _requestPermission() async {
    final permission = await Geolocator.requestPermission();
    setState(() {
      _permission = permission;
    });
    if (_permission == LocationPermission.denied ||
        _permission == LocationPermission.deniedForever) {
      return;
    }
    Navigator.pushReplacementNamed(context, '/discover');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF665EFF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 80,),
          Image.asset('assets/white_logo.png', width: 160,),
          SizedBox(height: 8,),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32),
            child: Text(
              'Experiences made easy',
              style: GoogleFonts.quicksand(
                  height: 1.5,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32),
            child: Text(
              'Passmate uses your location to help you navigate your favorite attractions',
              style: GoogleFonts.quicksand(
                  height: 1.5,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: SizedBox(
                height: 52,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.only(
                            top: 16, bottom: 16, left: 24, right: 24)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF3ACCE1)),
                  ),
                  onPressed: _permission == LocationPermission.denied
                      ? _requestPermission
                      : null,
                  child: Text(
                    'SET LOCATION PERMISSIONS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
