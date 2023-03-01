import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey/util.dart';
import 'dart:math' as math;
import 'package:permission_handler/permission_handler.dart';
import 'model/trip.dart';
import 'dart:math' as math;

class InsertMap extends StatefulWidget {
  InsertMap({super.key, required this.stopList});
  LinkedHashMap<String, Stop> stopList;
  @override
  State<InsertMap> createState() => _InsertMapState();
}

class _InsertMapState extends State<InsertMap> {
  late CameraPosition _kInitialPosition;
  Set<Marker> _markers = Set();
  late PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> latlonlist = [];
  List<LatLng> polylineCoordinates = [];
// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};
  // Position _currentPosition;
  double _rotation = 0.0;
  int _polylineIdCounter = 0;
  late GoogleMapController mapController;
  Future<Map<PolylineId, Polyline>> _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      int i) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    polylineCoordinates = [];
    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAYZpKch2gfAepDl2nsfm9Q59M0P6bqrUY", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    PolylineId id = PolylineId(polylineIdVal);
    _polylineIdCounter++;

    // Initializing Polyline

    Polyline polyline = Polyline(
      polylineId: id,
      color: lineColor[math.Random().nextInt(lineColor.length)],
      points: polylineCoordinates,
      consumeTapEvents:
          true, // Set to true to make polylines recognize tap events
      onTap: () {
        _handlePolylineTap(
            id); // function that will handle the color change and will be triggered when the polyline was tapped
      },
      width: 5,
    );
    return {id: polyline};
    // Adding the polyline to the map
  }

  _handlePolylineTap(PolylineId polylineId) {
    setState(() {
      Polyline newPolyline = polylines[polylineId]!.copyWith(
          colorParam: Colors
              .orange); // create a new polyline object which has a different color using the colorParam property
      polylines[polylineId] =
          newPolyline; // add that new polyline object to the list
    });
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        var _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 13.0,
            ),
          ),
        );
      });
      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
// Location permission is not granted
  }

  void setPosition() {
    mapController.moveCamera(
      CameraUpdate.newLatLngBounds(
        MapUtils.boundsFromLatLngList(latlonlist),
        10.0,
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  load_state() async {
    for (var i = 0; i < widget.stopList.entries.length - 1; i++) {
      var line = await _createPolylines(
          widget.stopList.entries.elementAt(i).value.lat,
          widget.stopList.entries.elementAt(i).value.lng,
          widget.stopList.entries.elementAt(i + 1).value.lat,
          widget.stopList.entries.elementAt(i + 1).value.lng,
          i % 2);
      latlonlist.add(LatLng(
        widget.stopList.entries.elementAt(i).value.lat,
        widget.stopList.entries.elementAt(i).value.lng,
      ));
      polylines[line.keys.first] = line.values.first;
    }
    setState(() {});
  }

  // load_state_fake() async {
  //   var line = await _createPolylines(
  //       45.5147114, 12.199587, 45.5057336, 12.2135167, 1);
  //   // latlonlist.add(LatLng(
  //   //   45.34242,
  //   //   12.54323,
  //   // ));
  //   polylines[line.keys.first] = line.values.first;
  //   line = await _createPolylines(
  //       45.5612417, 12.2962491, 45.5491125, 12.2849209, 2);
  //   // latlonlist.add(LatLng(
  //   //   45.7864,
  //   //   12.54323,
  //   // ));
  //   polylines[line.keys.first] = line.values.first;
  //   print('sus');
  //   setState(() {});
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // colori differenti per inizio e fine
    // colori tratte differenti
    // load_state_fake();
    if (widget.stopList.isNotEmpty) {
      load_state();
      _kInitialPosition = CameraPosition(
          target: LatLng(widget.stopList.entries.first.value.lat,
              widget.stopList.entries.first.value.lng),
          zoom: 13.0,
          tilt: 0,
          bearing: 0);
    } else {
      _kInitialPosition = const CameraPosition(
          target: LatLng(45.4935, 12.2463), zoom: 8.0, tilt: 0, bearing: 0);
    }
    _markers = widget.stopList.entries
        .map((entry) => Marker(
              position: LatLng(entry.value.lat, entry.value.lng),
              markerId: MarkerId(entry.key),
              infoWindow: InfoWindow(
                title: entry.key,
                snippet: entry.value.address,
              ),
            ))
        .toSet();

    // _markers.add(MapMarker(
    //   lat: 46.32443,
    //   lng: 12.234,
    //   name: "idro",
    //   build: (BuildContext ctx) {
    //     return Transform.rotate(
    //         angle: -_rotation * math.pi / 180,
    //         child: const Icon(Icons.pin_drop));
    //   },
    // ));
  }

  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Expanded(
      flex: 2,
      // height: availableHeight * 0.55,
      child: GoogleMap(
        mapType: MapType.hybrid,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          if (widget.stopList.isNotEmpty) {
            setPosition();
          } else {
            _getCurrentLocation();
          }
        },
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        markers: _markers,
        initialCameraPosition: _kInitialPosition,
      ),
    );
  }
}
