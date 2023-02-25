import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:journey/tripprovider.dart';
import 'package:journey/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

import 'model/trip.dart';

class ManageStop extends StatefulWidget {
  const ManageStop(
      {super.key, this.base_lat = 45.4950, this.base_lng = 12.2578, this.stop});
  final double base_lat;
  final double base_lng;
  final Stop? stop;
  @override
  State<ManageStop> createState() => _ManageStopState();
}

class DataPass {
  final String name;
  final Stop stop;
  DataPass(this.name, this.stop);
}

class _ManageStopState extends State<ManageStop> {
  List<Marker> markers = [];
  TextEditingController textController = TextEditingController();
  TextEditingController textNameController = TextEditingController();

  late double current_lat;
  late double current_lng;
  String address = "";
  String name = "";
  double _rotation = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.stop != null) {
      current_lat = widget.stop!.lat;
      current_lng = widget.stop!.lng;
    } else {
      current_lat = widget.base_lat;
      current_lng = widget.base_lng;
    }
  }

  final _mapController = MapController();
  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    TripStopProvider tripStopDaoProvider =
        Provider.of<TripStopProvider>(context);
    print(availableHeight % 10);
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
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
                  onPressed: () async {},
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
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                    center: LatLng(current_lat, current_lng),
                    onLongPress: (tapPosition, point) {
                      setState(() {
                        current_lat = point.latitude;
                        current_lng = point.longitude;
                      });
                    },
                    onPositionChanged: (mapPosition, _) {
                      setState(() {
                        _rotation = _mapController.rotation;
                      });
                    }),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'dev.ilbug.com',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(current_lat, current_lng),
                        width: 50,
                        height: 50,
                        rotate: false,
                        builder: (context) => Transform.rotate(
                            angle: -_rotation * math.pi / 180,
                            child: const Icon(Icons.pin_drop)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
