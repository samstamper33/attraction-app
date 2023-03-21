import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:passmate/poi.dart';
import 'dart:convert';

Widget filterButton(
  String typeString,
  int hex,
  bool filtered
) {
  return Container(
    height: 32,
    decoration: BoxDecoration(
      color: Color(0xff000000 + hex)
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(typeString),
    ),
  );
}

