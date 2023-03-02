import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String address_serializer(Placemark placeMark) {
  String name = placeMark.street!;
  String ncivico = placeMark.subThoroughfare!;
  String locality = placeMark.locality!;
  String administrativeArea = placeMark.administrativeArea!;
  String postalCode = placeMark.postalCode!;
  String country = placeMark.country!;
  String addressStr =
      "$name $ncivico, $locality, $administrativeArea $postalCode, $country";
  return addressStr;
}

class MapUtils {
  //
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double north, south, east, west;

    // initialize bounds with first coordinate
    north = south = list[0].latitude;
    east = west = list[0].longitude;

    // loop through remaining coordinates to determine bounds
    for (LatLng coordinate in list) {
      if (coordinate.latitude > north) {
        north = coordinate.latitude;
      }
      if (coordinate.latitude < south) {
        south = coordinate.latitude;
      }
      if (coordinate.longitude > east) {
        east = coordinate.longitude;
      }
      if (coordinate.longitude < west) {
        west = coordinate.longitude;
      }
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    return bounds;
  }

  // static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  //   double? x0, x1, y0, y1;
  //   for (LatLng latLng in list) {
  //     if (x0 == null) {
  //       x0 = x1 = latLng.latitude;
  //       y0 = y1 = latLng.longitude;
  //     } else {
  //       if (latLng.latitude > x1!) x1 = latLng.latitude;
  //       if (latLng.latitude < x0) x0 = latLng.latitude;
  //       if (latLng.longitude > y1!) y1 = latLng.longitude;
  //       if (latLng.longitude < y0!) y0 = latLng.longitude;
  //     }
  //   }
  //   return LatLngBounds(
  //       northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  // }
}

final List<Color> lineColor = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.cyan,
  Colors.indigo,
  Colors.lime,
  Colors.brown,
  Colors.amber,
  Colors.deepPurple,
  Colors.deepOrange,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.blueGrey,
  Colors.brown,
  Colors.cyan,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.green,
  Colors.grey,
  Colors.indigo,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.lime,
  Colors.orange,
  Colors.pink,
  Colors.purple,
  Colors.red,
  Colors.teal,
  Colors.yellow,
  Colors.white,
];
