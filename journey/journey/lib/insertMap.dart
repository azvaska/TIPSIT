import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
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
          onMapReady: () {
            setPosition();
          },
          onPositionChanged: (mapPosition, _) {
            setState(() {
              _rotation = _mapController.rotation;
            });
          },
          onTap: (_, __) => _popupLayerController.hideAllPopups(),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'devsd.ilbug.com',
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              markerCenterAnimation: const MarkerCenterAnimation(),
              markers: _markers,
              popupSnap: PopupSnap.markerCenter,
              popupController: _popupLayerController,
              popupBuilder: (BuildContext context, Marker marker) {
                if (marker is MapMarker) {
                  return MapCardPopup(marker.name);
                }
                return const Icon(
                  Icons.error,
                  size: 90,
                );
              },
              markerRotateAlignment:
                  PopupMarkerLayerOptions.rotationAlignmentFor(
                AnchorAlign.top,
              ),
              popupAnimation: const PopupAnimation.fade(
                  duration: Duration(milliseconds: 700)),
              markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
              onPopupEvent: (event, selectedMarkers) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(event.runtimeType.toString()),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          // MarkerLayer(markers: _markers),
          PolylineLayer(polylines: [
            Polyline(
              points: widget.stopList.entries
                  .map((entry) => LatLng(entry.value.lat, entry.value.lng))
                  .toList(),
            ),
          ]),

          // PopupMarkerLayerWidget(
          //   options: PopupMarkerLayerOptions(
          //       popupController: _popupLayerController,
          //       markers: _markers,
          //       markerRotateAlignment:
          //           PopupMarkerLayerOptions.rotationAlignmentFor(
          //               AnchorAlign.top),
          //       popupBuilder: (BuildContext context, Marker marker) {
          //         if (marker is MapMarker) {
          //           return MapCardPopup(marker.name);
          //         }
          //         return const SizedBox.shrink();
          //       }),
          // ),
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
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (BuildContext ctx) {
            print("DIOAN");
            return const Icon(Icons.location_pin, size: 40);
          },
        );
}
