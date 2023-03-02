import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey/tripprovider.dart';
import 'package:journey/util.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'model/trip.dart';

// !D/EGL_emulation(16717):,!I/Counters(16717): exceeded sample count in FrameTime
class ManageStop extends StatefulWidget {
  const ManageStop(
      {super.key,
      this.base_lat = 45.4950,
      this.base_lng = 12.2578,
      this.stop,
      this.base_name});
  final double base_lat;
  final double base_lng;
  final Stop? stop;
  final String? base_name;
  @override
  State<ManageStop> createState() => _ManageStopState();
}

class DataPass {
  final String name;
  final Stop stop;
  DataPass(this.name, this.stop);
}

class _ManageStopState extends State<ManageStop> {
  Set<Marker> markers = Set();
  static const LatLng _kMapCenter = LatLng(45, 12);
  static const CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);
  TextEditingController textController = TextEditingController();
  TextEditingController textNameController = TextEditingController();

  late double current_lat;
  late double current_lng;
  late GoogleMapController mapController;

  String address = "";
  String name = "";
  double _rotation = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textNameController.text = widget.base_name ?? "";
    if (widget.stop != null) {
      current_lat = widget.stop!.lat;
      current_lng = widget.stop!.lng;
    } else {
      current_lat = widget.base_lat;
      current_lng = widget.base_lng;
      // _getCurrentLocation();
    }
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        var _currentPosition = position;
        current_lat = _currentPosition.latitude;
        current_lng = _currentPosition.longitude;
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

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    TripStopProvider tripStopDaoProvider =
        Provider.of<TripStopProvider>(context);
    markers = {
      Marker(
        position: LatLng(current_lat, current_lng),
        markerId: const MarkerId("current"),
        infoWindow: const InfoWindow(
          title: "current",
        ),
      )
    };
    print(availableHeight % 10);
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            var addresses =
                await placemarkFromCoordinates(current_lat, current_lng);
            String addressStr = address_serializer(addresses[0]);
            Stop? stop;

            if (widget.stop != null) {
              widget.stop!.lat = current_lat;
              widget.stop!.lng = current_lng;

              widget.stop!.address = addressStr;
              await tripStopDaoProvider.updateStop(widget.stop!);
              stop = widget.stop;
            } else {
              // add search for an existing stop
              stop =
                  Stop(lat: current_lat, lng: current_lng, address: addressStr);
              int stopId = await tripStopDaoProvider.insertStop(stop);
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(context, DataPass(textNameController.text, stop!));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.check),
        ),
        body: Column(
          children: [
            Row(
              children: [
                const Text("Name for this trip:"),
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  width: 180,
                  child: TextField(
                    controller: textNameController,
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  width: 80,
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    List<Location> locations = await locationFromAddress(
                        textController.text,
                        localeIdentifier: "IT");
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                              locations[0].latitude, locations[0].longitude),
                          zoom: await mapController.getZoomLevel(),
                        ),
                      ),
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      current_lat = locations[0].latitude;
                      current_lng = locations[0].longitude;
                    });

                    print(current_lat);
                    print(current_lng);
                  },
                ),
                Text(
                    "Lat: ${current_lat.toStringAsFixed(4)} , Lng:${current_lng.toStringAsFixed(4)}"),
              ],
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  if (widget.stop == null) {
                    _getCurrentLocation();
                  } else {
                    Future<void>.delayed(const Duration(milliseconds: 300),
                        () async {
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(current_lat, current_lng),
                            zoom: 13.0,
                          ),
                        ),
                      );
                      // setState(() {});
                    });
                  }
                },
                mapType: MapType.hybrid,
                myLocationEnabled: true,
                onTap: (argument) {
                  setState(() {
                    current_lat = argument.latitude;
                    current_lng = argument.longitude;
                  });
                },
                markers: markers,
                initialCameraPosition: _kInitialPosition,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
