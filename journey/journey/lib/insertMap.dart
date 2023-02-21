import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'model/trip.dart';

class InsertMap extends StatefulWidget {
  InsertMap({super.key, required this.stopList});
  List<Stop> stopList;
  @override
  State<InsertMap> createState() => _InsertMapState();
}

class _InsertMapState extends State<InsertMap> {
  final _mapController = MapController();
  double _rotation = 0.0;
  late LatLng base_position;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.stopList.length > 0) {
      base_position =
          LatLng(widget.stopList.first.lat, widget.stopList.first.lng);
    } else {
      base_position = LatLng(46.32443, 12.234);
    }
  }

  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: availableHeight * 0.5,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            center: base_position,
            onPositionChanged: (mapPosition, _) {
              setState(() {
                _rotation = _mapController.rotation;
              });
            }),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.ilbug.com',
          ),
          MarkerLayer(
            markers: [
              ...widget.stopList
                  .map((stop) => Marker(
                        point: LatLng(stop.lat, stop.lng),
                        width: 50,
                        height: 50,
                        rotate: false,
                        builder: (context) => Transform.rotate(
                            angle: -_rotation * math.pi / 180,
                            child: const Icon(Icons.pin_drop)),
                      ))
                  .toList(),
            ],
          ),
          PolylineLayer(polylines: [
            Polyline(
              points: widget.stopList
                  .map((stop) => LatLng(stop.lat, stop.lng))
                  .toList(),
            ),
          ])
        ],
      ),
    );
  }
}
