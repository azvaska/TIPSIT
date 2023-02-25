import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'model/trip.dart';

class InsertMap extends StatefulWidget {
  InsertMap({super.key, required this.stopList});
  LinkedHashMap<String, Stop> stopList;
  @override
  State<InsertMap> createState() => _InsertMapState();
}

class _InsertMapState extends State<InsertMap> {
  final _mapController = MapController();
  List<MapMarker> _markers = [];
  double _rotation = 0.0;
  LatLng base_position = LatLng(46.32443, 12.234);
  final PopupController _popupLayerController = PopupController();
  final tooltipController = JustTheController();
  void setPosition() {
    if (widget.stopList.isNotEmpty) {
      base_position = LatLng(
          widget.stopList.values.elementAt(widget.stopList.length - 1).lat,
          widget.stopList.values.elementAt(widget.stopList.length - 1).lng);
      _mapController.move(base_position, 15);
    } else {
      base_position = LatLng(46.32443, 12.234);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _markers = widget.stopList.entries
        .map((entry) => MapMarker(
              lat: entry.value.lat,
              lng: entry.value.lng,
              name: entry.key,
            ))
        .toList();
    _markers.add(MapMarker(
      lat: 46.32443,
      lng: 12.234,
      name: "idro",
    ));
  }

  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: availableHeight * 0.59,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: base_position,
          interactiveFlags: InteractiveFlag.all,

          onMapReady: () {
            setPosition();
          },
          onPositionChanged: (mapPosition, _) {
            setState(() {
              _rotation = _mapController.rotation;
            });
          },
          // onTap: (_, __) => _popupLayerController.hideAllPopups(),
          onTap: (_, position) {
            _popupLayerController.hideAllPopups(disableAnimation: true);
            widget.stopList.forEach((key, value) {
              if ((value.lat - position.latitude).abs() <= 0.005 &&
                  (value.lng - position.longitude).abs() <= 0.005) {
                _popupLayerController.showPopupsOnlyFor(
                    [_markers.firstWhere((element) => element.name == key)]);
              }
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dscimd..com',
          ),
          // MarkerLayer(markers: _markers as List<Marker>),

          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
                popupController: _popupLayerController,
                markers: _markers,
                // markerRotateAlignment:
                //     PopupMarkerLayerOptions.rotationAlignmentFor(
                //         AnchorAlign.top),
                popupBuilder: (BuildContext context, Marker marker) {
                  if (marker is MapMarker) {
                    return MapCardPopup(marker.name);
                  }
                  return const SizedBox.shrink();
                }),
          ),
          PolylineLayer(polylines: [
            Polyline(
              points: widget.stopList.entries
                  .map((entry) => LatLng(entry.value.lat, entry.value.lng))
                  .toList(),
            ),
          ]),
        ],
      ),
    );
  }
}

class MapCardPopup extends StatelessWidget {
  final String name;
  const MapCardPopup(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    print("showing popup: ");
    return SizedBox(
      width: 100,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(name),
          ],
        ),
      ),
    );
  }
}

class MapMarker extends Marker {
  final String name;

  MapMarker({required this.name, required double lat, required double lng})
      : super(
          point: LatLng(lat, lng),
          height: 90,
          width: 90,
          builder: (BuildContext ctx) {
            return const Icon(Icons.location_pin, size: 40);
          },
        );
}
