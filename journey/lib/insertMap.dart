import 'dart:collection';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey/util.dart';
import 'dart:math' as math;
import 'model/trip.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class InsertMap extends StatefulWidget {
  InsertMap({super.key, required this.stopList});
  LinkedHashMap<String, Stop> stopList;
  @override
  State<InsertMap> createState() => _InsertMapState();
}

class _InsertMapState extends State<InsertMap> {
  late CameraPosition _kInitialPosition;
  Set<Marker> _markers = {};
  late PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> latlonlist = [];
  List<LatLng> polylineCoordinates = [];
// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};
  // Position _currentPosition;
  double _rotation = 0.0;
  int _polylineIdCounter = 0;
  GoogleMapController? mapController;
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
      width: 5,
    );
    return {id: polyline};
    // Adding the polyline to the map
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        var _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 10.0,
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
    var bounds = MapUtils.boundsFromLatLngList(latlonlist);
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  void dispose() {
    if (mapController != null) {
      mapController!.dispose();
    }
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
    if (!mounted) return;
    setState(() {});
  }

  launchGoogleMaps(String originLat, String originLong, String destLat,
      String destLong, List<String> waypoints) async {
    String waypointsUrl = "";
    if (waypoints.isNotEmpty) {
      waypointsUrl = "&waypoints=";
      waypointsUrl += waypoints.join("|");
    }

    Uri googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLong&destination=$destLat,$destLong&travelmode=driving$waypointsUrl');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.stopList.isNotEmpty) {
      var firstValue = widget.stopList.entries.first;
      load_state();
      _kInitialPosition = CameraPosition(
          target: LatLng(firstValue.value.lat, firstValue.value.lng),
          zoom: 5.0,
          tilt: 0,
          bearing: 0);
      _markers.add(Marker(
        position: LatLng(firstValue.value.lat, firstValue.value.lng),
        markerId: MarkerId(firstValue.key),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: firstValue.key,
          snippet: firstValue.value.address,
        ),
      ));
      latlonlist.add(LatLng(
        firstValue.value.lat,
        firstValue.value.lng,
      ));
      for (var i = 1; i < widget.stopList.entries.length - 1; i++) {
        MapEntry<String, Stop> entry = widget.stopList.entries.elementAt(i);
        latlonlist.add(LatLng(
          entry.value.lat,
          entry.value.lng,
        ));
        _markers.add(Marker(
          position: LatLng(entry.value.lat, entry.value.lng),
          markerId: MarkerId(entry.key),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: entry.key,
            snippet: entry.value.address,
          ),
        ));
      }
      if (widget.stopList.entries.length > 1) {
        latlonlist.add(LatLng(
          widget.stopList.entries.last.value.lat,
          widget.stopList.entries.last.value.lng,
        ));
        _markers.add(Marker(
          position: LatLng(widget.stopList.entries.last.value.lat,
              widget.stopList.entries.last.value.lng),
          markerId: MarkerId(widget.stopList.entries.last.key),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: widget.stopList.entries.last.key,
            snippet: widget.stopList.entries.last.value.address,
          ),
        ));
      }
    } else {
      _kInitialPosition = const CameraPosition(
          target: LatLng(45.4935, 12.2463), zoom: 8.0, tilt: 0, bearing: 0);
    }
    if (widget.stopList.entries.isNotEmpty) {}
  }

  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Expanded(
      flex: 2,
      // height: availableHeight * 0.55,
      child: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90.0),
          child: FloatingActionButton(
              child: const Icon(Icons.map),
              onPressed: () {
                List<String> waypoints = [];
                if (widget.stopList.length > 2) {
                  for (var i = 1; i < widget.stopList.length - 1; i++) {
                    waypoints.add(
                        "${widget.stopList.entries.elementAt(i).value.lat},${widget.stopList.entries.elementAt(i).value.lng}");
                  }
                  // waypoints.addAll(widget.stopList.entries
                  //     .map((e) => "${e.value.lat},${e.value.lng}"));
                }
                launchGoogleMaps(
                    widget.stopList.entries.first.value.lat.toString(),
                    widget.stopList.entries.first.value.lng.toString(),
                    widget.stopList.entries.last.value.lat.toString(),
                    widget.stopList.entries.last.value.lng.toString(),
                    waypoints);
              }),
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            if (widget.stopList.length > 1) {
              Future<void>.delayed(const Duration(milliseconds: 300), () async {
                setPosition();
                // setState(() {});
              });
            } else {
              if (widget.stopList.isNotEmpty) {
                mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                      target: LatLng(widget.stopList.entries.first.value.lat,
                          widget.stopList.entries.first.value.lng),
                      zoom: 13.0,
                      tilt: 0,
                      bearing: 0)),
                );
              } else {
                _getCurrentLocation();
              }
            }
          },
          polylines: Set<Polyline>.of(polylines.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          // mapToolbarEnabled: true,
          markers: _markers,
          initialCameraPosition: _kInitialPosition,
        ),
      ),
    );
  }
}
